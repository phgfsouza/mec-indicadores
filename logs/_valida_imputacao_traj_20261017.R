.libPaths(c('C:/Users/ADM/AppData/Local/R/win-library/4.6', .libPaths()))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(purrr))
source('code/helpers/moda.R')
options(width = 180, tibble.width = Inf)

linhas <- readLines('code/01-preparacao.R', encoding = 'UTF-8')
invisible(parse(text = linhas))
inicio <- grep('^## Imputacao de missing values nos dados de trajetoria', linhas) + 1L
fim <- grep('^## Harmonizacao com dados do CES', linhas) - 1L
bloco <- parse(text = linhas[inicio:fim])

executa <- function(cursos, entrada) {
  ces_cursos <- cursos
  traj <- entrada
  eval(bloco, envir = environment())
  stopifnot(nrow(traj) == nrow(entrada))
  variaveis <- imputacao.traj$variaveis
  outras <- setdiff(names(entrada), variaveis)
  stopifnot(identical(traj[outras], entrada[outras]))
  for (v in intersect(names(entrada), variaveis)) {
    validos <- !is.na(entrada[[v]])
    stopifnot(identical(traj[[v]][validos], entrada[[v]][validos]))
    nome_indicador <- paste0('imputado_', v)
    anteriores <- if (nome_indicador %in% names(entrada)) entrada[[nome_indicador]] else FALSE
    stopifnot(identical(traj[[nome_indicador]], anteriores | (is.na(entrada[[v]]) & !is.na(traj[[v]]))))
  }
  anual <- traj |> distinct(co_curso, ano, across(all_of(variaveis)))
  stopifnot(!anyDuplicated(anual[c('co_curso', 'ano')]))
  ies_imputadas <- traj |> filter(imputado_co_ies) |> distinct(co_ies, ano)
  stopifnot(nrow(anti_join(ies_imputadas, imputacao.traj$ies_ativas, by = c('co_ies', 'ano'))) == 0L)
  stopifnot(!any(grepl('_imputacao$', names(traj))))
  list(traj = traj, imputacao = imputacao.traj)
}

# Cursos 1 e 2 testam limites iguais/diferentes; 3 testa grau ausente em
# cadastro existente; 4 testa modalidade divergente; 5 nao tem cadastro.
ces_teste <- tibble(
  co_curso = rep(1:4, each = 2), ano = rep(c(2012L, 2014L), 4),
  co_ies = c(100L, 100L, 100L, 200L, 100L, 100L, 100L, 100L),
  no_curso = c('A', 'A', 'B', 'C', 'D', 'D', 'E', 'E'),
  co_cine_area_geral = c(1L, 1L, 2L, 2L, 3L, 3L, 4L, 4L),
  no_cine_area_geral = c('X', 'X', 'Y', 'Z', 'W', 'W', 'V', 'V'),
  tp_grau_academico = c(1L, 1L, 1L, 2L, NA_integer_, 1L, 2L, 2L),
  tp_modalidade_ensino = c(1L, 1L, 1L, 1L, 2L, 2L, 1L, 2L), qt_mat = 10L
)
# IES 100 tem atividade em 2013 e 2015; 200 apenas em 2015. Nenhuma em 2011.
ces_teste <- bind_rows(
  ces_teste,
  ces_teste |> slice(c(1, 1, 4)) |>
    mutate(co_curso = 90:92, ano = c(2013L, 2015L, 2015L)),
  ces_teste |> slice(1) |> mutate(co_curso = 93L, ano = 2011L, qt_mat = 0L),
  ces_teste |> slice(1) |> mutate(co_curso = 94L, ano = 2011L, qt_mat = NA_integer_)
)
cria_entrada <- function(chaves, cursos) {
  chaves |>
    left_join(
      cursos |> select(-qt_mat, -no_curso),
      by = c('co_curso', 'ano'), relationship = 'many-to-one'
    ) |>
    mutate(presente_ces = !is.na(co_ies), co_ies_traj = 999L) |>
    arrange(desc(ano), coorte, co_curso)
}
entrada_teste <- cria_entrada(expand_grid(co_curso = 1:5, ano = 2011:2015, coorte = 2010:2011), ces_teste)
teste <- executa(ces_teste, entrada_teste)
valor <- function(curso, ano_alvo, v) {
  unique(teste$traj[[v]][teste$traj$co_curso == curso & teste$traj$ano == ano_alvo])
}
stopifnot(
  valor(1, 2013, 'co_ies') == 100L,
  is.na(valor(1, 2011, 'co_ies')),
  valor(1, 2015, 'co_ies') == 100L,
  valor(1, 2011, 'no_curso') == 'A',
  valor(1, 2013, 'no_curso') == 'A',
  is.na(valor(2, 2013, 'co_ies')),
  is.na(valor(2, 2013, 'no_curso')),
  is.na(valor(2, 2013, 'co_cine_area_geral')),
  is.na(valor(2, 2013, 'no_cine_area_geral')),
  valor(2, 2015, 'co_ies') == 200L,
  is.na(valor(3, 2012, 'tp_grau_academico')),
  is.na(valor(3, 2013, 'tp_grau_academico')),
  valor(3, 2011, 'tp_grau_academico') == 1L,
  is.na(valor(4, 2013, 'tp_modalidade_ensino')),
  is.na(valor(5, 2013, 'tp_modalidade_ensino'))
)
stopifnot(identical(executa(ces_teste, teste$traj)$traj, teste$traj))
# A mesma IES antes e depois nao basta se nao houver atividade no ano interno.
sem_atividade <- executa(ces_teste |> filter(ano != 2013L), entrada_teste)
stopifnot(all(is.na(sem_atividade$traj$co_ies[sem_atividade$traj$ano == 2013L])))
cat('PASS: casos controlados, limites, conflitos, ausencia de referencias, atividade, preservacao e reexecucao.\n')

vars <- c('co_ies', 'no_curso', 'co_cine_area_geral', 'no_cine_area_geral', 'tp_grau_academico', 'tp_modalidade_ensino')
ces <- arrow::read_parquet('data/clean/ces_cursos.parquet', col_select = all_of(c('co_curso', 'ano', vars, 'qt_mat'))) |>
  mutate(co_cine_area_geral = as.integer(co_cine_area_geral))
arquivos <- list.files('data/raw/INEP-TRAJETORIA', pattern = '\\.xlsx$', recursive = TRUE, full.names = TRUE)
origem <- map(arquivos, function(f) {
  nomes <- names(readxl::read_xlsx(f, skip = 8, n_max = 0))
  manter <- c('CO_CURSO', 'CO_IES', 'NU_ANO_INGRESSO', 'NU_ANO_REFERENCIA')
  tipos <- ifelse(nomes %in% manter, 'numeric', 'skip')
  dados <- readxl::read_xlsx(f, skip = 8, col_types = tipos) |>
    filter(!is.na(CO_CURSO))
  cat('Lido:', basename(dirname(f)), '\n'); flush.console()
  dados
}) |> bind_rows() |>
  rename(co_curso = CO_CURSO, coorte = NU_ANO_INGRESSO, ano = NU_ANO_REFERENCIA, co_ies_traj = CO_IES)
entrada <- origem |>
  left_join(
    ces |> select(-qt_mat, -no_curso) |> distinct(),
    by = c('co_curso', 'ano'), relationship = 'many-to-one'
  ) |>
  mutate(
    presente_ces = !is.na(co_ies), n_presente_ces = sum(presente_ces),
    n_ausente_ces = sum(!presente_ces), pct_presente_ces = mean(presente_ces),
    .by = c(co_curso, coorte)
  ) |>
  arrange(coorte, co_curso, ano)
real <- executa(ces, entrada)
stopifnot(nrow(real$traj) == 2731155L)
resumo <- map_dfr(vars, function(v) {
  antes <- if (v %in% names(entrada)) entrada[[v]] else {
    entrada |> select(co_curso, ano) |>
      left_join(ces |> select(co_curso, ano, no_curso) |> distinct(), by = c('co_curso', 'ano'), relationship = 'many-to-one') |>
      pull(no_curso)
  }
  tibble(variavel = v, na_antes = sum(is.na(antes)), imputados = sum(real$traj[[paste0('imputado_', v)]]), na_depois = sum(is.na(real$traj[[v]])))
})
stopifnot(all(resumo$na_antes - resumo$imputados == resumo$na_depois))
stopifnot(sum(is.na(real$traj$tp_grau_academico[real$traj$presente_ces])) == sum(is.na(entrada$tp_grau_academico[entrada$presente_ces])))
cat('PASS: dados reais, linhas e ordem preservadas, valores observados, flags, coortes e atividade da IES.\n')
print(resumo, n = Inf, width = Inf)
cat('NA de grau em cadastros encontrados:', sum(is.na(real$traj$tp_grau_academico[real$traj$presente_ces])), '\n')
