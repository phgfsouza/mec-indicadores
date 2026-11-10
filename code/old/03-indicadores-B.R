#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Dimensao B - Padroes de crescimento do setor
# Pedro HGF Souza 
# Junho/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script calcula os tres indicadores da dimensao B.

# Etapas:
# 1. Importacao e pre-processamento dos dados do Censo da Educacao Superior
#    produzidos pelo script `01-preparacao.R`.
# 2. Calculos dos indicadores a partir de procedimentos padronizados: para cada
#    indicador, o script cria uma lista de inputs que sao usados como argumentos
#    para a funcao `calcula_dimensao_B()`.
# 3. As planilhas com resultados separados para cada indicador sao gravadas em 
#    `results/` no formato csv.

# Inputs do script:
# - `data/clean/ces_cursos.parquet`
# - `data/clean/ces_ies.parquet`
# - `data/clean/ces_mantenedoras.parquet`
# - `data/clean/rotulos_variaveis.csv`

# Outputs do script:
# - `results/indicadorB*.csv`


# CONFIGURACAO =================================================================

source('code/_setup.R')

# PRE-PROCESSAMENTO ============================================================

## Censo da Educacao Superior --------------------------------------------------

# Importacao de dados selecionados
data_B <- list(
  mantenedoras = read_parquet(
    file = here('data/clean/ces_mantenedoras.parquet'), 
    col_select = c(co_mantenedora_harm, catadm_it, ano, fx_ranking)
  ),
  ies =  read_parquet(
    file = here('data/clean/ces_ies.parquet'),
    col_select = c(co_mantenedora_harm, co_ies, ano)
  ),
  cursos = read_parquet(
    file = here('data/clean/ces_cursos.parquet'),
    col_select = c(
      co_ies, ano, tp_modalidade_ensino, co_cine_area_geral, 
      qt_ing_diurno, qt_ing_noturno, qt_ing_ead, 
      qt_mat_diurno, qt_mat_noturno, qt_mat_ead
    )
  )
) 

# Pre-processamento
data_B <- data_B |> 
  # Reduz para data frame
  reduce(inner_join) |>
  # Otimiza uso de memoria
  summarise(
    across(matches('^qt'), ~ sum(.x, na.rm = TRUE)), 
    .by = !matches('^qt')
  ) |>
  # Separa turnos e aplica filtros para descartar linhas desnecessarias
  pivot_longer(
    cols = matches('^qt'), 
    names_pattern = '(qt_[a-z]+)_(.+)', 
    names_to = c('.value', 'turno_chr')
  ) |> 
  mutate(turno = recode_values(turno_chr, 'diurno' ~ 1, 'noturno' ~ 2, 'ead' ~ 3)) |>
  filter(replace_na(qt_ing, 0) + replace_na(qt_mat, 0) > 0) |>   
  select(-turno_chr) |>
  # Acrescenta outras colunas necessarias
  mutate(total = 1L) |>
  combina_variaveis(catadm_it, turno) |>
  combina_variaveis(catadm_it, co_cine_area_geral) |>
  combina_variaveis(catadm_it, co_cine_area_geral, tp_modalidade_ensino) |>
  combina_variaveis(catadm_it, co_cine_area_geral, turno) |>
  combina_variaveis(catadm_it, tp_modalidade_ensino) |>
  combina_variaveis(co_cine_area_geral, tp_modalidade_ensino) |> 
  combina_variaveis(co_cine_area_geral, turno) |>  
  combina_variaveis(fx_ranking, tp_modalidade_ensino) |>
  combina_variaveis(fx_ranking, turno) 

## Rotulos de variaveis --------------------------------------------------------

rotulos_vars <- read_csv(here('data/clean/rotulos_variaveis.csv'))

# INDICADOR B.1 ================================================================

# Apropriacao acumulada do saldo de ingressantes e matriculas por categoria
# administrativa, turno e modalidade (presencial e EaD) entre 2010 e 2024

# Inicializacao da lista
B1 <- list()

# Identificacao
B1$id <- 'B1'
B1$name <- 'Apropriação acumulada do saldo de ingressantes e matrículas por categoria administrativa, turno e modalidade (presencial e EaD) entre 2010 e 2024'

# Blocos para desagregacoes
B1$by <- c(
  'total', 
  'catadm_it', 
  'tp_modalidade_ensino', 
  'turno', 
  'catadm_it_tp_modalidade_ensino',
  'catadm_it_turno'
) |> set_names()

# Calculo do indicador
B1$output <- calcula_dimensao_B(data_B, B1, rotulos_vars)

# Output 
write_excel_csv(compacta_csv(B1$output), here('results/indicadorB1.csv'))


# INDICADOR B.2 ================================================================

# Apropriacao acumulada do saldo de ingressantes e matriculas por area de 
# conhecimento (CINE Brasil), categoria administrativa e modalidade (presencial 
# e ensino a distancia) entre 2010 e 2024

# Inicializacao da lista
B2 <- list()

# Identificacao
B2$id <- 'B2'
B2$name <- 'Apropriação acumulada do saldo de ingressantes e matrículas por área de conhecimento (CINE Brasil), categoria administrativa e modalidade (presencial e ensino a distância) entre 2010 e 2024'

# Blocos para desagregacoes
B2$by <- c(
  'total', 
  'co_cine_area_geral',
  'catadm_it', 
  'tp_modalidade_ensino', 
  'turno',
  'catadm_it_co_cine_area_geral',
  'catadm_it_tp_modalidade_ensino',
  'co_cine_area_geral_tp_modalidade_ensino',
  'co_cine_area_geral_turno'
) |> set_names()


# Calculo do indicador
B2$output <- calcula_dimensao_B(data_B, B2, rotulos_vars)

# Output 
write_excel_csv(compacta_csv(B2$output), here('results/indicadorB2.csv'))


# INDICADOR B.3 ================================================================

# Apropriacao acumulada do saldo de ingressantes e matrículas por tamanho de 
# mantenedora entre 2010 e 2024.

# Inicializacao da lista
B3 <- list()

# Identificacao
B3$id <- 'B3'
B3$name <- 'Apropriação acumulada do saldo de ingressantes e matrículas por tamanho de mantenedora entre 2010 e 2024'

# Blocos para desagregacoes
B3$by <- c(
  'total', 
  'fx_ranking', 
  'tp_modalidade_ensino',
  'turno',
  'fx_ranking_tp_modalidade_ensino',
  'fx_ranking_turno'
) |> set_names()

# Calculo do indicador
B3$output <- calcula_dimensao_B(data_B, B3, rotulos_vars)

# Output 
write_excel_csv(compacta_csv(B3$output), here('results/indicadorB3.csv'))

