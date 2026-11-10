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
#'   `grupo_nome`, `valor` e uma coluna temporal chamada `ano` ou `periodo`.
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
  abas <- names(x) |> set_names()

  # Titulos 
  titulo  <- map_chr(abas, ~ unique(x[[.x]]$indicador_nome)) |> unique()
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
        select(unidade, grupo_nome, matches('ano|periodo'), valor) |> 
        split(~ unidade),
      .f = ~ .x |> 
        select(-unidade) |> 
        rename(any_of(c(Ano = 'ano', `Período` = 'periodo'))) |> 
        pivot_wider(names_from = grupo_nome, values_from = valor) |> 
        mutate(across(where(is.numeric), ~ replace_na(.x, 0)))
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
      r1 <- r + 1
      r2 <- r + 2
      rr <- r1 + nr
      writeData(wb, aba, j, startRow = r, startCol = 1)
      writeData(wb, aba, dfs[[j]], startRow = r + 1, startCol = 1)
      setColWidths(wb, aba, cols = 1, widths = "10")
      setColWidths(wb, aba, cols = 2:nc, widths = "16")
      addStyle(wb, aba, estilo_header, rows = r:r1, cols = 1:nc, gridExpand = TRUE)
      addStyle(wb, aba, estilo_ano, rows = r2:rr, cols = 1, gridExpand = TRUE)
      mergeCells(wb, aba, cols = 1:nc, rows = r)
      if(j %in% c('Percentual', 'Taxa')){
        addStyle(wb, aba, estilo_pct, rows = r2:rr, cols = 2:nc, gridExpand = TRUE)
      }
      if(j == 'Quantidade'){
        addStyle(wb, aba, estilo_qtd, rows = r2:rr, cols = 2:nc, gridExpand = TRUE)
      }     
      r <- rr + 3
    }

  }

  return(wb)


}

