#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Dimensao A - Rede Institucional e Oferta
# Pedro HGF Souza 
# Junho/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script calcula os cinco indicadores da dimensao A.

# Etapas:
# 1. Importacao e pre-processamento dos dados do Censo da Educacao Superior
#    produzidos pelo script `01-preparacao.R`.
# 2. Calculos dos indicadores a partir de procedimentos padronizados: para cada
#    indicador, o script cria uma lista de inputs que sao usados como argumentos
#    para a funcao `calcula_dimensao_A()`.
# 3. As planilhas com resultados separados para cada indicador sao gravadas em 
#    `results/` no formato csv.

# Observacoes:
# - Os percentuais das contagens usam a soma dos grupos do bloco e ano;
#   a taxa de ocupacao corresponde a ingressantes por 100 vagas oferecidas.
# - Mantenedoras nao sao apresentadas por organizacao academica, pois uma
#   mesma mantenedora pode reunir IES com organizacoes distintas.
# - `compacta_csv()` mantem o codigo e o nome do indicador apenas na primeira
#   linha do CSV. A conversao para Excel e feita em `07-planilhas.R`.

# Inputs para o script:
# - `data/clean/ces_cursos.parquet`
# - `data/clean/ces_ies.parquet`
# - `data/clean/ces_mantenedoras.parquet`
# - `data/clean/rotulos_variaveis.csv`

# Outputs do script:
# - `results/indicadorA*.csv`


# CONFIGURACAO =================================================================

source('code/_setup.R')

# PRE-PROCESSAMENTO ============================================================

## Censo da Educacao Superior --------------------------------------------------

# Importacao de dados selecionados
data_A <- list(
  mantenedoras = read_parquet(
    file = here('data/clean/ces_mantenedoras.parquet'), 
    col_select = c(co_mantenedora_harm, catadm_it, ano, fx_ranking)
  ),
  ies =  read_parquet(
    file = here('data/clean/ces_ies.parquet'),
    col_select = c(
      co_mantenedora_harm, tp_organizacao_academica_harm, co_ies, ano
    )
  ),
  cursos = read_parquet(
    file = here('data/clean/ces_cursos.parquet'),
    col_select = c(
      co_ies, ano, tp_modalidade_ensino, co_cine_area_geral, qt_vg_total, 
      qt_ing, qt_ing_diurno, qt_ing_noturno, qt_ing_ead, 
      qt_mat, qt_mat_diurno, qt_mat_noturno, qt_mat_ead
    )
  )
) 

# Pre-processamento
# - reduz para data frame
# - otimiza uso de memoria
# - acrescenta colunas necessarias
data_A <- data_A |> 
  reduce(inner_join) |>
  summarise(
    across(matches('^qt'), ~ sum(.x, na.rm = TRUE)), 
    .by = !matches('^qt')
  ) |>
  mutate(total = 1L) |>
  combina_variaveis(catadm_it, co_cine_area_geral) |> 
  combina_variaveis(catadm_it, co_cine_area_geral, tp_modalidade_ensino) |>
  combina_variaveis(catadm_it, fx_ranking) |>
  combina_variaveis(catadm_it, tp_modalidade_ensino) |> 
  combina_variaveis(catadm_it, tp_organizacao_academica_harm) |>
  combina_variaveis(catadm_it, tp_organizacao_academica_harm, tp_modalidade_ensino) |>
  combina_variaveis(co_cine_area_geral, tp_modalidade_ensino) |>
  combina_variaveis(fx_ranking, co_cine_area_geral) |> 
  combina_variaveis(fx_ranking, co_cine_area_geral, tp_modalidade_ensino) |>
  combina_variaveis(fx_ranking, tp_modalidade_ensino) |> 
  combina_variaveis(fx_ranking, tp_organizacao_academica_harm) |>
  combina_variaveis(fx_ranking, tp_organizacao_academica_harm, tp_modalidade_ensino)  

# Data frame especial para o indicador A3
# - descarta variaveis nao transponiveis para formato long;
# - converte data frame em long
# - acrescenta variavel `turno`
# - descarta linhas e colunas irrelevantes
data_A3 <- data_A |> 
  select(-qt_vg_total, -qt_ing, -qt_mat) |> 
  pivot_longer(
    cols = matches('^qt'), 
    names_pattern = '(qt_[a-z]+)_(.+)', 
    names_to = c('.value', 'turno_chr')
  ) |> 
  mutate(turno = recode_values(turno_chr, 'diurno' ~ 1, 'noturno' ~ 2, 'ead' ~ 3)) |>
  select(-turno_chr) |> 
  filter(replace_na(qt_ing, 0) + replace_na(qt_mat, 0) > 0) 

## Rotulos de variaveis --------------------------------------------------------

rotulos_vars <- read_csv(here('data/clean/rotulos_variaveis.csv'))


# INDICADOR A.1 ================================================================

# Numero e distribuicao de IES e mantenedoras por categoria administrativa e 
# organizacao academica entre 2010 e 2024.

# Inicializa lista
A1 <- list()

# Identificacao
A1$id   <- 'A1'
A1$name <- 'Número e distribuição de IES e mantenedoras por categoria administrativa e organização acadêmica entre 2010 e 2024'

# Blocos para desagregacoes
A1$by <- c(
  'total', 
  'catadm_it', 
  'fx_ranking',
  'tp_organizacao_academica_harm', 
  'catadm_it_tp_organizacao_academica_harm',
  'catadm_it_fx_ranking'
) |> 
  set_names()

# Funcao para calcular o indicador
A1$fn <- function(df){
  df |> 
    summarise(
      qt_mantenedoras = n_distinct(co_mantenedora_harm),
      qt_ies = n_distinct(co_ies),
      .groups = 'drop'
    )
}

# Calculo do indicador
A1$output <- calcula_dimensao_A(data_A, A1, rotulos_vars) 
  
# Filtro dos resultados
# - Para evitar confusoes, ja que a mesma mantenedora pode aparecer com mais de 
#   um tipo de organizacao academica, as informacoes para mantenedoras sao 
#   excluidas quando a desagregacao for por organizacao academica
A1$output <- A1$output |> 
  filter(
    !(str_detect(bloco_var, "organizacao_academica") &
      str_detect(serie_var, "mantenedoras")
  )
) 

# Output 
write_excel_csv(compacta_csv(A1$output), here('results/indicadorA1.csv'))

# INDICADOR A.2 ================================================================
 
# Numero de vagas oferecidas e taxa de ocupacao por modalidade (presencial e 
# ensino a distancia) entre 2010 e 2024.

# Inicializacao da lista
A2 <- list()

# Identificacao
A2$id   <- 'A2'
A2$name <- 'Número de vagas oferecidas e taxa de ocupação por modalidade (presencial e ensino a distância) entre 2010 e 2024'

# Blocos para desagregacoes
A2$by <- c(
  'total', 
  'catadm_it',
  'fx_ranking',
  'tp_organizacao_academica_harm',
  'tp_modalidade_ensino',
  'co_cine_area_geral',
  'catadm_it_tp_organizacao_academica_harm',          
  'catadm_it_tp_modalidade_ensino',                   
  'catadm_it_co_cine_area_geral',                   
  'fx_ranking_tp_modalidade_ensino'
  ) |> 
  set_names()

# Funcao para calcular o indicador
A2$fn <- function(df){
  df |> 
    summarise(
      across(c(qt_vg_total, qt_ing), ~ sum(.x, na.rm = TRUE)),
      tx_ocupacao_vaga = 100 * qt_ing / qt_vg_total, 
      .groups = 'drop'
    )
}

# Calculo do indicador
A2$output <- calcula_dimensao_A(data_A, A2, rotulos_vars)

# Output
write_excel_csv(compacta_csv(A2$output), here('results/indicadorA2.csv'))


# INDICADOR A.3 ================================================================

# Distribuicao de ingressantes e matriculas por modalidade (presencial e EaD) e 
# turno entre 2010 e 2024

# Inicializacao da lista
A3 <- list()

# Identificacao
A3$id   <- 'A3'
A3$name <- 'Distribuição de ingressantes e matrículas por modalidade (presencial e EaD) e turno entre 2010 e 2024'

# Blocos para desagregacoes
A3$by <- c(
  'total', 
  'catadm_it',
  'tp_modalidade_ensino', 
  'turno',
  'tp_organizacao_academica_harm',
  'catadm_it_tp_modalidade_ensino',
  'catadm_it_tp_organizacao_academica_harm',
  'catadm_it_tp_organizacao_academica_harm_tp_modalidade_ensino'
) |> 
  set_names()

# Funcao para calcular o indicador
A3$fn <- function(df){
  df |> 
    summarise(
      across(c(qt_ing, qt_mat), ~ sum(.x, na.rm = TRUE)), 
      .groups = 'drop'
    )
}

# Calculo do indicador
A3$output <- calcula_dimensao_A(data_A3, A3, rotulos_vars)

# Output
write_excel_csv(compacta_csv(A3$output), here('results/indicadorA3.csv'))


# INDICADOR A.4 ================================================================

# Distribuicao de ingressantes e matriculas por tamanho da mantenedora 
# (presencial e EaD) entre 2010 e 2024.

# Inicializacao da lista
A4 <- list()

# Identificacao
A4$id   <- 'A4'
A4$name <- 'Distribuição de ingressantes e matrículas por tamanho da mantenedora (presencial e EaD) entre 2010 e 2024'

# Blocos para desagregacoes
A4$by <- c(
  'total', 
  'fx_ranking', 
  'tp_modalidade_ensino',
  'tp_organizacao_academica_harm',
  'fx_ranking_tp_modalidade_ensino',
  'fx_ranking_tp_organizacao_academica_harm',
  'fx_ranking_tp_organizacao_academica_harm_tp_modalidade_ensino'
) |> 
  set_names()

# Funcao para calculo do indicador
A4$fn <- function(df){
  df |>       
    summarise(
      across(c(qt_ing, qt_mat), ~ sum(.x, na.rm = TRUE)), 
      .groups = 'drop'
    )
}

# Calculo do indicador 
A4$output <- calcula_dimensao_A(data_A, A4, rotulos_vars)

# Output
write_excel_csv(compacta_csv(A4$output), here('results/indicadorA4.csv'))

# INDICADOR A.5 ================================================================

# Distribuicao de ingressantes e matriculas por area do conhecimento (CINE Brasil)
# e modalidade (presencial e EaD) entre 2010 e 2024.

# Inicializacao da lista
A5 <- list()

# Identificacao
A5$id   <- 'A5'
A5$name <- 'Distribuição de ingressantes e matrículas por área de conhecimento (CINE Brasil) e modalidade (presencial e ensino a distância) entre 2010 e 2024'

# Blocos para desagregacoes
A5$by <- c(
  'total', 
  'co_cine_area_geral', 
  'co_cine_area_geral_tp_modalidade_ensino',
  'catadm_it_co_cine_area_geral',
  'catadm_it_co_cine_area_geral_tp_modalidade_ensino',
  'fx_ranking_co_cine_area_geral',
  'fx_ranking_co_cine_area_geral_tp_modalidade_ensino'
) |> set_names()

# Funcao para calculo do indicador
A5$fn <- function(df){
  df |> 
    summarise(
      across(c(qt_ing, qt_mat), ~ sum(.x, na.rm = TRUE)), 
      .groups = 'drop'
    )
}

# Calculo do indicador 
A5$output <- calcula_dimensao_A(data_A, A5, rotulos_vars)

# Output
write_excel_csv(compacta_csv(A5$output), here('results/indicadorA5.csv'))

