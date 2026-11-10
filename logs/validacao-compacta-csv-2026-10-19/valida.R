.libPaths(c('C:/Users/ADM/AppData/Local/R/win-library/4.6', .libPaths()))
invisible(Sys.setlocale('LC_ALL', 'English_United States.utf8'))

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(purrr)
  library(tidyr)
  library(stringr)
  library(forcats)
  library(openxlsx)
})

pasta <- 'logs/validacao-compacta-csv-2026-10-19'
sink(file.path(pasta, 'execucao-R.txt'), split = TRUE)
cat(R.version.string, '\n')
cat('Locale:', Sys.getlocale(), '\n')
print(sapply(c('dplyr', 'readr', 'purrr', 'tidyr', 'stringr', 'forcats',
               'openxlsx'), \(p) as.character(packageVersion(p))))

anterior <- new.env()
sys.source(file.path(pasta, 'gera_xlsx_formatado_anterior.R'), envir = anterior)
source('code/helpers/gera_xlsx_formatado.R', encoding = 'UTF-8')
source('code/helpers/compacta_csv.R', encoding = 'UTF-8')

for (subpasta in c('csv', 'xlsx-anterior', 'xlsx-novo', 'xlsx-legado')) {
  dir.create(file.path(pasta, subpasta), showWarnings = FALSE)
}

# Confere sintaxe e as chamadas reais de exportacao, sem executar os calculos.
scripts <- c('code/02-indicadores-A.R', 'code/03-indicadores-B.R',
             'code/05-indicadores-G.R', 'code/06-indicadores-I.R')
exportacoes <- list()
for (script in scripts) {
  expressoes <- parse(script, encoding = 'UTF-8')
  for (expressao in expressoes) {
    if (is.call(expressao) && identical(expressao[[1]], as.name('write_excel_csv'))) {
      stopifnot(identical(expressao[[2]][[1]], as.name('compacta_csv')))
      exportacoes[[length(exportacoes) + 1L]] <- expressao
    }
  }
}
stopifnot(length(exportacoes) == 18L)
invisible(parse('code/helpers/compacta_csv.R', encoding = 'UTF-8'))
invisible(parse('code/helpers/gera_xlsx_formatado.R', encoding = 'UTF-8'))
invisible(parse('code/07-planilhas.R', encoding = 'UTF-8'))
cat('Sintaxe e 18 chamadas de exportacao: OK\n')

deve_falhar <- function(expr) {
  stopifnot(inherits(tryCatch(force(expr), error = identity), 'error'))
}

exemplo <- tibble(indicador_code = rep('T1', 3),
                  indicador_nome = rep('Indicador de teste', 3), valor = 1:3)
copia <- exemplo
compacto <- compacta_csv(exemplo)
stopifnot(identical(exemplo, copia),
          identical(compacto$indicador_code, c('T1', '', '')),
          identical(compacto$indicador_nome, c('Indicador de teste', '', '')),
          identical(compacto$valor, exemplo$valor),
          identical(compacta_csv(compacto), compacto),
          identical(compacta_csv(exemplo[0, ]), exemplo[0, ]),
          identical(compacta_csv(exemplo[1, ]), exemplo[1, ]))
deve_falhar(compacta_csv(mutate(exemplo, indicador_code = c('T1', 'T2', 'T1'))))
deve_falhar(compacta_csv(mutate(exemplo, indicador_nome = NA_character_)))
deve_falhar(compacta_csv(select(exemplo, -indicador_code)))
deve_falhar(gera_xlsx_formatado(mutate(exemplo, indicador_nome = '')))
deve_falhar(gera_xlsx_formatado(mutate(exemplo, indicador_nome = c('A', 'B', 'A'))))
parcial <- exemplo
parcial$indicador_nome <- c(NA, '', 'Indicador de teste')
stopifnot(identical(compacta_csv(parcial), compacto))
cat('Casos dirigidos: OK\n')

# O CSV municipal atual nao tem metadados; usa a configuracao atual somente no teste.
config <- new.env()
config$I2 <- list()
for (expressao in parse('code/06-indicadores-I.R', encoding = 'UTF-8')) {
  if (is.call(expressao) && identical(expressao[[1]], as.name('<-')) &&
      paste(deparse(expressao[[2]]), collapse = '') %in% c('I2$id', 'I2$name')) {
    eval(expressao, envir = config)
  }
}

arquivos <- list.files('results', '^indicador[A-Z][0-9][a-z]?\\.csv$', full.names = TRUE)
stopifnot(length(arquivos) == 18L)
resumo <- list()
for (arquivo in arquivos) {
  nome <- basename(arquivo)
  cat('Validando', nome, '\n')
  flush.console()
  original <- read_csv(arquivo, show_col_types = FALSE, progress = FALSE)
  faltam <- setdiff(c('indicador_code', 'indicador_nome'), names(original))
  if (length(faltam) > 0L) {
    stopifnot(identical(nome, 'indicadorI2e.csv'), length(faltam) == 2L)
    original <- original |>
      mutate(indicador_code = config$I2$id, indicador_nome = config$I2$name,
             .before = 1)
    cat('  Metadados municipais reconstruidos somente para validacao.\n')
  }
  copia <- original
  compacto <- compacta_csv(original)
  stopifnot(identical(original, copia),
            identical(select(compacto, -indicador_code, -indicador_nome),
                      select(original, -indicador_code, -indicador_nome)),
            all(compacto$indicador_code[-1] == ''),
            all(compacto$indicador_nome[-1] == ''))
  restaurado <- compacto |>
    mutate(across(c(indicador_code, indicador_nome), \(coluna) rep(coluna[1], n())))
  stopifnot(identical(as.data.frame(restaurado), as.data.frame(original)))

  destino <- file.path(pasta, 'csv', nome)
  # Reproduz exatamente a chamada modificada, sem alterar os CSVs de results.
  objeto <- sub('\\.csv$', '', sub('^indicador', '', nome))
  ambiente <- new.env()
  ambiente[[objeto]] <- list(output = original)
  ambiente$here <- function(...) destino
  chamada <- exportacoes[[which(vapply(exportacoes, \(e)
    identical(as.character(e[[2]][[2]][[2]]), objeto), logical(1)))]]
  eval(chamada, envir = ambiente)
  relido <- read_csv(destino, show_col_types = FALSE, progress = FALSE)
  dados_originais <- select(original, -indicador_code, -indicador_nome)
  dados_relidos <- select(relido, -indicador_code, -indicador_nome)
  if (!identical(dados_originais, dados_relidos)) {
    # Controla o arredondamento do proprio ciclo de escrita/leitura do readr.
    controle <- file.path(pasta, 'controle-roundtrip.csv')
    write_excel_csv(original, controle)
    controle <- read_csv(controle, show_col_types = FALSE, progress = FALSE) |>
      select(-indicador_code, -indicador_nome)
    stopifnot(identical(controle, dados_relidos),
              isTRUE(all.equal(dados_originais, dados_relidos, tolerance = 1e-15)))
    cat('  Diferenca numerica do ciclo CSV, identica ao controle sem compactacao.\n')
  }
  stopifnot(identical(relido$indicador_nome[1], original$indicador_nome[1]),
            all(is.na(relido$indicador_nome[-1])),
            all(is.na(relido$indicador_code[-1])),
            identical(ambiente[[objeto]]$output, original))

  # Para I.2, o formatador atual nao distingue territorios: testa um territorio.
  escopo <- 'integral'
  if (grepl('^indicadorI2', nome)) {
    geo <- grep('^cod_.*_curso$', names(original), value = TRUE)
    stopifnot(length(geo) == 1L)
    manter <- original[[geo]][1] == original[[geo]]
    original_xlsx <- original[manter, ]
    relido_xlsx <- relido[manter, ]
    escopo <- 'um territorio'
  } else {
    original_xlsx <- original
    relido_xlsx <- relido
  }
  nome_xlsx <- sub('\\.csv$', '.xlsx', nome)
  antigo <- anterior$gera_xlsx_formatado(original_xlsx)
  novo <- gera_xlsx_formatado(relido_xlsx)
  compativel <- gera_xlsx_formatado(original_xlsx)
  saveWorkbook(antigo, file.path(pasta, 'xlsx-anterior', nome_xlsx), overwrite = TRUE)
  saveWorkbook(novo, file.path(pasta, 'xlsx-novo', nome_xlsx), overwrite = TRUE)
  saveWorkbook(compativel, file.path(pasta, 'xlsx-legado', nome_xlsx), overwrite = TRUE)

  resumo[[nome]] <- tibble(
    arquivo = nome, linhas = nrow(original),
    bytes_atual = file.info(file.path('results', nome))$size,
    bytes_compactado = file.info(destino)$size,
    metadados_reconstruidos = length(faltam) > 0L,
    escopo_xlsx = escopo,
    dados_em_memoria_identicos = TRUE,
    roundtrip_exato = identical(dados_originais, dados_relidos),
    valores_com_arredondamento_csv = sum(original$valor != relido$valor, na.rm = TRUE),
    diferenca_maxima_csv = max(abs(original$valor - relido$valor), na.rm = TRUE)
  )
  rm(original, compacto, restaurado, relido, copia, ambiente,
     original_xlsx, relido_xlsx, antigo, novo, compativel)
  invisible(gc())
}
write_csv(bind_rows(resumo), file.path(pasta, 'resumo-csv.csv'))
cat('Todos os testes R concluidos.\n')
sink()
