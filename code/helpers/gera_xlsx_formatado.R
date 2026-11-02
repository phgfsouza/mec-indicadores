#' Cria uma planilha Excel formatada para um indicador
#'
#' Recebe uma base de resultados de um indicador em formato longo, separa os
#' dados por combinacao de recorte e serie, e cria um workbook Excel com uma aba
#' de indice e uma aba para cada combinacao. Em cada aba, as unidades
#' "Quantidade", "Percentual" e "Taxa", quando presentes, sao escritas em
#' tabelas separadas e formatadas.
#'
#' @param x Data frame com os resultados do indicador. Deve conter as colunas
#'   `indicador_nome`, `bloco_var`, `bloco_nome`, `serie_nome`, `unidade`,
#'   `grupo_nome`, `valor` e uma coluna temporal chamada `ano`, `periodo` ou
#'   `coorte`. Colunas geograficas com prefixos `cod_`, `sigla_` e `nome_`
#'   sao preservadas antes do tempo. Quando houver varias colunas de
#'   identificacao, as linhas sao ordenadas por elas, com a geografia primeiro.
#'   Coortes tambem sao ordenadas; anos e periodos isolados mantem a ordem de entrada.
#'   `indicador_nome` pode estar preenchido somente na primeira linha.
#'   Anos em colunas `valor_AAAA` devem ser convertidos para `ano` e `valor`
#'   antes da chamada, como em `code/07-planilhas.R`.
#'   Percentuais ausentes por coorte permanecem vazios no Excel. Nas demais
#'   tabelas, os valores numericos ausentes sao preenchidos com zero.
#'
#' @return Objeto `Workbook` criado por `openxlsx::createWorkbook()`, pronto
#'   para ser salvo com `openxlsx::saveWorkbook()`.
#'
#' @examples
#' dados <- tibble(
#'   indicador_nome = "Exemplo",
#'   bloco_var = "total",
#'   bloco_nome = "Total",
#'   serie_nome = "Matriculas",
#'   unidade = "Quantidade",
#'   grupo_nome = "Total",
#'   ano = 2024,
#'   valor = 100
#' )
#'
#' wb <- gera_xlsx_formatado(dados)
#' # openxlsx::saveWorkbook(wb, "results/exemplo.xlsx", overwrite = TRUE)

gera_xlsx_formatado <- function(x){ 

  # Pre-processamento ----------------------------------------------------------

  titulo <- unique(x$indicador_nome[
    !is.na(x$indicador_nome) & trimws(x$indicador_nome) != ''
  ])

  if (length(titulo) != 1L) {
    stop('A base deve conter um unico nome de indicador preenchido.')
  }

  geografia <- names(x)[str_detect(names(x), '^(cod|sigla|nome)_')]
  tempo <- intersect(c('ano', 'periodo', 'coorte'), names(x))
  identificacao <- c(geografia, tempo)

  if (length(tempo) == 0L) {
    stop('A base deve conter uma coluna temporal: ano, periodo ou coorte.')
  }

  # Vetores para renomear categorias 
  renomeia_blocos <- c(
    'catadm_it' = 'CatAdm', 
    'tp_organizacao_academica_harm' = 'OrgAcad',
    'tp_modalidade_ensino' = 'Modal', 
    'fx_ranking' = 'Tamanho',
    'fx_pct_ead' = 'FxEaD',
    'total' = 'Total',
    'turno' = 'Turno',
    'co_cine_area_geral' = 'CINE',
    '_' = '+'
  )
  renomeia_series <- c(
    'Docentes em exercício em tempo integral' = 'DocInt',
    'Docentes em exercício em tempo parcial'  = 'DocParc',
    'Docentes em exercício horistas' = 'DocHor',
    'Docentes em exercício com doutorado' = 'DocDout',
    'Docentes em exercício com especialização' = 'DocEsp',
    'Docentes em exercício com mestrado'= 'DocMest',
    'Docentes em exercício sem pós graduação' = 'DocSemPos',
    'Docentes em exercício' = 'Doc', 
    'Ingressantes por 100 vagas' = 'IngVaga',
    'Ingressantes' = 'Ing',
    'Mantenedoras' = 'Mant',
    'Matrículas por docente em exercício' = 'MatDoc',
    'Matrículas' = 'Mat', 
    'Vagas' = 'Vaga'
  )
  
  # Preparacao do data frame
  x <- x |>
    mutate(
      bloco_code = str_replace_all(bloco_var, renomeia_blocos),
      serie_code = str_replace_all(serie_nome, renomeia_series),
      ordem = if_else(bloco_code == 'Total', 0, str_count(bloco_code, '\\+') + 1),
    ) |>
    arrange(serie_nome, ordem, bloco_code, row_number()) |> 
    mutate(aba = fct_inorder(paste(bloco_code, serie_code, sep = '_'))) |> 
    select(-ordem) |> 
    split(~ aba)

  # Definicoes para planilha Excel ---------------------------------------------

  # Abas
  # Reserva os nomes validos para que o truncamento nao os altere.
  nomes_originais <- names(x)
  reservados <- tolower(c('Índice', nomes_originais[nchar(nomes_originais) <= 31L]))
  usados <- tolower('Índice')
  for (i in seq_along(x)) {
    nome <- substr(nomes_originais[i], 1, 31)
    sufixo <- 0L
    while (tolower(nome) %in% usados ||
           (nome != nomes_originais[i] && tolower(nome) %in% reservados)) {
      sufixo <- sufixo + 1L
      final <- paste0('_', sufixo)
      nome <- paste0(substr(nomes_originais[i], 1, 31L - nchar(final)), final)
    }
    names(x)[i] <- nome
    usados <- c(usados, tolower(nome))
  }
  abas <- names(x) |> set_names()

  # Titulos 
  recorte <- map_chr(abas, ~ unique(x[[.x]]$bloco_nome))
  serie   <- map_chr(abas, ~ unique(x[[.x]]$serie_nome))

  # Estilos
  estilo_titulo <- createStyle(textDecoration = 'bold', fontSize = 13)
  estilo_subtitulo <- createStyle(textDecoration = 'italic', fontSize = 12)
  estilo_header <- createStyle(
    textDecoration = 'bold', 
    valign = 'center',
    halign = 'center', 
    fgFill = '#DCE6F1',
    wrapText = TRUE
  )
  estilo_pct <- createStyle(numFmt = '0.0')
  estilo_qtd <- createStyle(numFmt = "#,##0")
  estilo_ano <- createStyle(textDecoration = 'bold', halign = 'center', valign = 'center')
  
  # Producao da planilha Excel -------------------------------------------------
  
  # Inicializa workbook
  wb <- createWorkbook()

  # Indice
  indice <- tibble(Aba = abas, Recorte = recorte, `Série` = serie)
  addWorksheet(wb, 'Índice')
  writeData(wb, 'Índice', titulo, startRow = 1, startCol = 1)
  writeData(wb, 'Índice', indice, startRow = 3, startCol = 1)
  addStyle(wb, 'Índice', estilo_titulo, rows = 1, cols = 1)
  addStyle(wb, 'Índice', estilo_header, rows = 3, cols = 1:ncol(indice))
  setColWidths(wb, 'Índice', cols = 1, widths = '32')
  setColWidths(wb, 'Índice', cols = 2:ncol(indice), widths = 'auto')

  # Abas 
  for(aba in abas){ 
    # Inicializa aba
    addWorksheet(wb, aba)
    # Titulos e subtitulos
    writeData(wb, aba, titulo, startRow = 1, startCol = 1)
    writeData(wb, aba, 'Recorte:', startRow = 2, startCol = 1)
    writeData(wb, aba, 'Série:', startRow = 3, startCol = 1)
    writeData(wb, aba, recorte[[aba]], startRow = 2, startCol = 2)
    writeData(wb, aba, serie[[aba]], startRow = 3, startCol = 2)
    addStyle(wb, aba, estilo_titulo, rows = 1, cols = 1)
    addStyle(wb, aba, estilo_subtitulo, rows = 2:3, cols = 1:2, gridExpand = TRUE)
    # Dados
    dfs <- map(
      .x = x[[aba]] |> 
        select(unidade, grupo_nome, all_of(identificacao), valor) |>
        split(~ unidade),
      .f = function(dados) {
        unidade_atual <- unique(dados$unidade)

        if (anyDuplicated(dados[c(identificacao, 'grupo_nome')]) > 0L) {
          stop(paste0('Ha valores duplicados para a mesma identificacao e grupo na aba ', aba, '.'))
        }

        dados <- dados |>
          select(-unidade) |>
          pivot_wider(
            id_cols = all_of(identificacao),
            names_from = grupo_nome,
            values_from = valor
          )

        if (length(identificacao) > 1L || 'coorte' %in% tempo) {
          dados <- dados |> arrange(across(all_of(identificacao)))
        }

        # Ausencia de observacao na coorte nao representa uma taxa igual a zero.
        preservar_ausentes <- 'coorte' %in% tempo &&
          unidade_atual == 'Percentual'

        if (!preservar_ausentes) {
          dados <- dados |>
            mutate(across(where(is.numeric) & !all_of(identificacao), ~ replace_na(.x, 0)))
        }

        dados |>
          rename(any_of(c(Ano = 'ano', `Período` = 'periodo', `Coorte de ingresso` = 'coorte')))
      }
    )
    # Inverte ordem entre Percentual e Quantidade 
    nm  <- names(dfs)
    idx <- which(head(nm, -1) == "Percentual" & tail(nm, -1) == "Quantidade") 
    if (length(idx) > 0) {
      idx <- idx[1]
      ordem <- seq_along(dfs)
      ordem[c(idx, idx + 1)] <- ordem[c(idx + 1, idx)]
      dfs <- dfs[ordem]
    }
    # Escreve abas
    r <- 5 
    for(j in names(dfs)){
      nc <- ncol(dfs[[j]])
      nr <- nrow(dfs[[j]])
      colunas_id <- seq_along(identificacao)
      colunas_valor <- seq.int(length(identificacao) + 1L, nc)
      r1 <- r + 1
      r2 <- r + 2
      rr <- r1 + nr
      writeData(wb, aba, j, startRow = r, startCol = 1)
      writeData(wb, aba, dfs[[j]], startRow = r + 1, startCol = 1)
      setColWidths(wb, aba, cols = 1, widths = "10")
      setColWidths(wb, aba, cols = 2:nc, widths = "16")
      if (length(geografia) > 0L || 'coorte' %in% tempo) {
        setColWidths(
          wb, aba, cols = colunas_id,
          widths = ifelse(str_detect(identificacao, '^nome_'), 32,
                          ifelse(identificacao == 'coorte', 20, 10))
        )
      }
      addStyle(wb, aba, estilo_header, rows = r:r1, cols = 1:nc, gridExpand = TRUE)
      addStyle(wb, aba, estilo_ano, rows = r2:rr, cols = colunas_id, gridExpand = TRUE)
      mergeCells(wb, aba, cols = 1:nc, rows = r)
      if(j %in% c('Percentual', 'Taxa')){
        addStyle(wb, aba, estilo_pct, rows = r2:rr, cols = colunas_valor, gridExpand = TRUE)
      }
      if(j == 'Quantidade'){
        addStyle(wb, aba, estilo_qtd, rows = r2:rr, cols = colunas_valor, gridExpand = TRUE)
      }     
      r <- rr + 3
    }

  }

  return(wb)


}

