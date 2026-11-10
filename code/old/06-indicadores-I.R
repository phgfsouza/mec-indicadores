#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Dimensao I - Distribuicao geografica 
# Pedro HGF Souza 
# Outubro/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script calcula os seis indicadores da dimensao I para anos selecionados.
# Esta dimensao nao estava originalmente prevista no projeto, mas foi adicionada
# por demanda da SEGAPE/MEC.
# O padrao do script difere um pouco  dos anteriores por tratar de desagregacoes 
# geograficas.

# Etapas:
# 1. Importacao e pre-processamento dos dados produzidos por `01-preparacao.R`,
#    mantendo somente registros com municipio identificado nos anos selecionados.
# 2. Calculo dos indicadores com `calcula_dimensao_I()`, a partir das
#    configuracoes de agrupamento e das funcoes de resumo de cada indicador.
# 3. Inclusao das combinacoes geograficas faltantes dos grupos observados
#    em I.2 a I.6, com valor zero, e exportacao dos resultados por indicador
#    e nivel geografico.

# Observacoes sobre missing values geograficos:
# - Nao ha informacoes geograficas nos registros com `tp_dimensao` == 3
#   (EaD com dados somente nacionais) e em outros 14 registros de
#   10 cursos denominados 'ABI - Educacao Fisica'.
# - Entre 2010 e 2024, sao 63.551 linhas com NA em variaveis geograficas.
#   Essas linhas somam 123.749.238 vagas e somente 65 matriculas, ignorando NA
#   nas somas; 18.694 linhas tambem tem NA em `qt_mat`.
# - Em 2024, as 11.328 linhas sem municipio somam 18.590.273 vagas. Destas,
#   18.583.348 estao nas 11.319 linhas com `tp_dimensao` == 3.
# - Essas vagas nao podem ser desagregadas espacialmente com os dados
#   disponiveis e ficam fora dos indicadores geograficos deste script.

# Observacoes sobre os indicadores:
# (a) I.1 conta AMC de municipios no conjunto do pais. I.2 a I.6 apresentam
#     resultados por regiao, UF, mesorregiao AMC, microrregiao AMC e AMC municipal.
# (b) I.3 inclui somente vagas presenciais, pois as vagas EaD nao podem ser
#     quantificadas por territorio com os dados disponiveis.
# (c) I.1 e I.2 definem oferta local pela existencia de cursos com ingressantes,
#     matriculas e/ou concluintes positivos. I.2 apresenta somente quantidades.
# (d) Em I.1, os percentuais usam o total de AMC, incluindo aquelas sem
#     oferta. Nos demais indicadores com percentuais, o denominador e
#     a soma das contagens do bloco e ano. Em I.1, os percentuais dos grupos
#     podem somar mais de 100%, pois uma AMC pode integrar varios grupos.

# Inputs do script:
# - `data/clean/ces_cursos.parquet`
# - `data/clean/ces_ies.parquet`
# - `data/clean/ces_mantenedoras.parquet`
# - `data/clean/ripsa_pop.parquet`
# - `data/clean/rotulos_variaveis.csv`

# Outputs do script:
# - `results/indicadorI*.csv`
# - Para I.2 a I.6, os sufixos a, b, c, d e e correspondem, respectivamente,
#   a regiao, UF, mesorregiao AMC, microrregiao AMC e AMC municipal.


# CONFIGURACAO =================================================================

source('code/_setup.R')


# PRE-PROCESSAMENTO ============================================================

## Censo da Educacao Superior --------------------------------------------------

data_I <- list(
  mantenedoras = read_parquet(
    file = here('data/clean/ces_mantenedoras.parquet'), 
    col_select = c(co_mantenedora_harm, catadm_it, ano, fx_ranking)
  ),
  ies =  read_parquet(
    file = here('data/clean/ces_ies.parquet'),
    col_select = c(
      co_mantenedora_harm, co_ies, ano, tp_categoria_administrativa_harm, 
      tp_organizacao_academica_harm
    )
  ),
  cursos = read_parquet(
    file = here('data/clean/ces_cursos.parquet'),
    col_select = c(
      cod_regiao, nome_regiao, sigla_regiao, cod_uf, nome_uf, sigla_uf, 
      cod_meso_amc, nome_meso_amc, cod_micro_amc, nome_micro_amc, cod_muni_amc, 
      nome_muni_amc, co_ies, co_curso, ano, tp_modalidade_ensino, 
      co_cine_area_geral, qt_vg_total, qt_ing, qt_mat, qt_conc
    )
  )
) 

# Pre-processamento
# - reduz para data frame
# - filtro para manter somente anos selecionados
# - acrescenta colunas necessarias
data_I <- data_I |>
  reduce(inner_join) |>
  mutate(total = 1L) |>
  filter(!is.na(cod_muni_amc)) |> 
  filter(ano %in% c(2010, 2017, 2024)) |>
  combina_variaveis(catadm_it, co_cine_area_geral) |>
  combina_variaveis(catadm_it, tp_modalidade_ensino) |>
  combina_variaveis(co_cine_area_geral, tp_modalidade_ensino) |> 
  combina_variaveis(fx_ranking, tp_modalidade_ensino)

## Populacao e geografia -------------------------------------------------------

pop <- read_parquet(here("data/clean/ripsa_pop.parquet")) |>
  filter(ano %in% c(2010, 2017, 2024))

geo <- pop |> select(cod_regiao:ano) |> distinct()

geovars <- list(
  regiao = c("cod_regiao", "sigla_regiao", "nome_regiao"),
  uf = c("cod_uf", "sigla_uf", "nome_uf"),
  meso = c("cod_meso_amc", "nome_meso_amc"),
  micro = c("cod_micro_amc", "nome_micro_amc"),
  muni = c("cod_muni_amc", "nome_muni_amc")
)

## Rotulos de variaveis --------------------------------------------------------

rotulos_vars <- read_csv(here('data/clean/rotulos_variaveis.csv'))


# INDICADOR I.1 ================================================================

# Quantidade de municipios com oferta local em anos selecionados.

# Obs:
# - "Oferta local" definida pela existencia de cursos com ingressantes, 
#   matriculas e/ou concluintes.

# Inicializa lista
I1 <- list()

# Identificacao
I1$id   <- 'I1'
I1$name <- 'Quantidade de AMC de municípios com oferta local em anos selecionados'

# Blocos para desagregacoes
I1$by <- c(
  'total', 
  'catadm_it', 
  'fx_ranking',
  'tp_modalidade_ensino', 
  'catadm_it_tp_modalidade_ensino',
  'catadm_it_co_cine_area_geral',
  'fx_ranking_tp_modalidade_ensino'
) |> 
  set_names()

# Funcao para calcular o indicador
I1$fn <- function(df){
  df |> 
    filter(qt_ing > 0 | qt_mat > 0 | qt_conc > 0) |>
    summarise(qt_municipios = n_distinct(cod_muni_amc), .groups = 'drop')
}

# Calculo do indicador
I1$output <- calcula_dimensao_I(data_I, I1, rotulos_vars)

# Recalcula os percentuais sobre todas as AMC, inclusive aquelas sem oferta
I1$output <- I1$output |>
  left_join(
    geo |> summarise(total_amc = n_distinct(cod_muni_amc), .by = ano), 
    by = 'ano'
  ) |>
  mutate(
    valor = if_else(
      serie_var == 'pct_municipios',
      100 * valor[serie_var == 'qt_municipios'] / total_amc,
      valor
    ),
    .by = c(bloco_var, grupo_code, ano)
  ) |>
  select(-total_amc)

# Output 
write_excel_csv(compacta_csv(I1$output), here('results/indicadorI1.csv'))


# INDICADOR I.2 ================================================================

# Numero de IES e mantenedoras com oferta local em anos selecionados.

# Obs:
# - "Oferta local" definida pela existencia de cursos com ingressantes, 
#   matriculas e/ou concluintes.

# Inicializa lista
I2 <- list()

# Identificacao
I2$id   <- 'I2'
I2$name <- 'Número de IES e mantenedoras com oferta local em anos selecionados'

# Blocos para desagregacoes
I2$by <- c(
  'total', 
  'catadm_it', 
  'fx_ranking',
  'tp_modalidade_ensino', 
  'catadm_it_tp_modalidade_ensino',
  'fx_ranking_tp_modalidade_ensino'
) |> 
  set_names()

# Funcao para calcular o indicador
I2$fn <- function(df){
  df |> 
    filter(qt_ing > 0 | qt_mat > 0 | qt_conc > 0) |>
    summarise(
      qt_mantenedoras = n_distinct(co_mantenedora_harm),
      qt_ies = n_distinct(co_ies),
      .groups = 'drop'
    )
}

# Unidades geograficas
I2$geo <- geovars |> set_names(paste0("I2", letters[1:5]))

I2 <- map(I2$geo, ~ modifyList(I2, list(geo = .x)))

# Calculo dos indicadores, removendo linhas com percentuais (ja que IES e 
# mantenedoras podem atuar em multiplas regioes) e completando o grid geografico
I2 <- map(
  .x = I2, 
  .f = \(x) {
    x$output <- calcula_dimensao_I(data_I, x, rotulos_vars) |>
      filter(!str_detect(serie_var, "^pct_")) |>
      completa_output_geografico(geo, preenchimento = 0)
    x
  }
)

# Output 
iwalk(
  .x = I2, 
  .f = \(x, id) 
    write_excel_csv(compacta_csv(x$output), here(glue("results/indicador{id}.csv")))
)

# INDICADOR I.3 ================================================================

# Quantidade de vagas presenciais por territorio em anos selecionados.

# Inicializa lista
I3 <- list()

# Identificacao
I3$id   <- 'I3'
I3$name <- 'Quantidade de vagas presenciais por território em anos selecionados'

# Blocos para desagregacoes
I3$by <- c(
  'total', 
  'catadm_it', 
  'fx_ranking',
  'co_cine_area_geral'
) |> 
  set_names()

# Funcao para calcular o indicador
I3$fn <- function(df){
  df |> 
    filter(tp_modalidade_ensino == 1) |>
    summarise(qt_vg_total = sum(qt_vg_total), .groups = 'drop')
}

# Unidades geograficas
I3$geo <- geovars |> set_names(paste0("I3", letters[1:5]))

I3 <- map(I3$geo, ~ modifyList(I3, list(geo = .x)))

# Calculo dos indicadores, completando o grid geografico
I3 <- map(
  .x = I3, 
  .f = \(x) {
    x$output <- calcula_dimensao_I(data_I, x, rotulos_vars) |>
      completa_output_geografico(geo, preenchimento = 0)
    x
  }
)

# Output 
iwalk(
  .x = I3, 
  .f = \(x, id) 
    write_excel_csv(compacta_csv(x$output), here(glue("results/indicador{id}.csv")))
)

# INDICADOR I.4 ================================================================

# Quantidade de ingressantes por regiao em anos selecionados. 

# Inicializa lista
I4 <- list()

# Identificacao
I4$id   <- 'I4'
I4$name <- 'Quantidade de ingressantes por região em anos selecionados'

# Blocos para desagregacoes
I4$by <- c(
  'total', 
  'catadm_it', 
  'fx_ranking',
  'co_cine_area_geral',
  'tp_modalidade_ensino', 
  'catadm_it_tp_modalidade_ensino',
  'fx_ranking_tp_modalidade_ensino', 
  'co_cine_area_geral_tp_modalidade_ensino'  
) |> 
  set_names()

# Funcao para calcular o indicador
I4$fn <- function(df){
  df |> summarise(qt_ing = sum(qt_ing, na.rm = TRUE), .groups = 'drop')
}

# Unidades geograficas
I4$geo <-  geovars |> set_names(paste0("I4", letters[1:5]))

I4 <- map(I4$geo, ~ modifyList(I4, list(geo = .x)))

# Calculo dos indicadores, completando o grid geografico
I4 <- map(
  .x = I4, 
  .f = \(x) {
    x$output <- calcula_dimensao_I(data_I, x, rotulos_vars) |>
      completa_output_geografico(geo, preenchimento = 0)
    x
  }
)

# Output 
iwalk(
  .x = I4, 
  .f = \(x, id) 
    write_excel_csv(compacta_csv(x$output), here(glue("results/indicador{id}.csv")))
)

# INDICADOR I.5 ================================================================

# Quantidade de matriculas por regiao em anos selecionados. 

# Inicializa lista
I5 <- list()

# Identificacao
I5$id   <- 'I5'
I5$name <- 'Quantidade de matrículas por região em anos selecionados'

# Blocos para desagregacoes
I5$by <- c(
  'total', 
  'catadm_it', 
  'fx_ranking',
  'co_cine_area_geral',
  'tp_modalidade_ensino', 
  'catadm_it_tp_modalidade_ensino',
  'fx_ranking_tp_modalidade_ensino', 
  'co_cine_area_geral_tp_modalidade_ensino'  
) |> 
  set_names()

# Funcao para calcular o indicador
I5$fn <- function(df){
  df |> summarise(qt_mat = sum(qt_mat, na.rm = TRUE), .groups = 'drop')
}

# Unidades geograficas
I5$geo <-  geovars |> set_names(paste0("I5", letters[1:5]))

I5 <- map(I5$geo, ~ modifyList(I5, list(geo = .x)))

# Calculo dos indicadores, completando o grid geografico
I5 <- map(
  .x = I5, 
  .f = \(x) {
    x$output <- calcula_dimensao_I(data_I, x, rotulos_vars) |>
      completa_output_geografico(geo, preenchimento = 0)
    x
  }
)

# Output 
iwalk(
  .x = I5, 
  .f = \(x, id) 
    write_excel_csv(compacta_csv(x$output), here(glue("results/indicador{id}.csv")))
)


# INDICADOR I.6 ================================================================

# Quantidade de concluintes por regiao em anos selecionados. 

# Inicializa lista
I6 <- list()

# Identificacao
I6$id   <- 'I6'
I6$name <- 'Quantidade de concluintes por região em anos selecionados'

# Blocos para desagregacoes
I6$by <- c(
  'total', 
  'catadm_it', 
  'fx_ranking',
  'co_cine_area_geral',
  'tp_modalidade_ensino', 
  'catadm_it_tp_modalidade_ensino',
  'fx_ranking_tp_modalidade_ensino', 
  'co_cine_area_geral_tp_modalidade_ensino'  
) |> 
  set_names()

# Funcao para calcular o indicador
I6$fn <- function(df){
  df |> summarise(qt_conc = sum(qt_conc, na.rm = TRUE), .groups = 'drop')
}

# Unidades geograficas
I6$geo <-  geovars |> set_names(paste0("I6", letters[1:5]))

I6 <- map(I6$geo, ~ modifyList(I6, list(geo = .x)))

# Calculo dos indicadores, completando o grid geografico
I6 <- map(
  .x = I6, 
  .f = \(x) {
    x$output <- calcula_dimensao_I(data_I, x, rotulos_vars) |>
      completa_output_geografico(geo, preenchimento = 0)
    x
  }
)

# Output 
iwalk(
  .x = I6, 
  .f = \(x, id) 
    write_excel_csv(compacta_csv(x$output), here(glue("results/indicador{id}.csv")))
)
