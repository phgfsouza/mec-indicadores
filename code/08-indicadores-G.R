#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Dimensao G - Corpo Docente
# Pedro HGF Souza 
# Junho/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script calcula os quatro indicadores da dimensao G.

# Etapas:
# 1. Importacao e pre-processamento dos dados do Censo da Educacao Superior
#    produzidos pelo script `01-preparacao.R`.
# 2. Calculos dos indicadores a partir de procedimentos padronizados: para cada
#    indicador, o script cria uma lista de inputs que sao usados como argumentos
#    para a funcao `calcula_dimensao_G()`.
# 3. As planilhas com resultados separados para cada indicador sao gravadas em 
#    `results/` no formato csv.

# Observacoes:
# (a) Documentacao estipula desagregacoes por modalidade de ensino para alguns
#     indicadores. No entanto, essa e' uma caracteristica dos cursos, e nao das 
#     IES, e portanto nao e' possivel atribuir docentes a modalidades de ensino. 
#     Para contornar o problema, o script desagrega por uma variavel derivada 
#     com faixas do percentual de matriculas em EaD em cada IES.
# (b) O script produz desagregacoes identicas para todos os indicadores, que 
#     estao hard-coded em `calcula_dimensao_G`. Essas desagregacoes sao mais 
#     detalhadas do que o exigido pela documentacao.

# Inputs do script:
# - `data/clean/ces_cursos.parquet`
# - `data/clean/ces_ies.parquet`
# - `data/clean/ces_mantenedoras.parquet`
# - `data/clean/rotulos_variaveis.csv`

# Outputs do script:
# - `results/indicadorG*.csv`


# CONFIGURACAO =================================================================

source('code/_setup.R')


# PRE-PROCESSAMENTO ============================================================

## Censo da Educacao Superior ---------------------------------------------------

# Importacao de dados selecionados
data_G <- list(
  mantenedoras = read_parquet(
    file = here('data/clean/ces_mantenedoras.parquet'), 
    col_select = c(co_mantenedora_harm, catadm_it, ano, fx_ranking)
  ),
  ies =  read_parquet(
    file = here('data/clean/ces_ies.parquet'),
    col_select = c(
      co_mantenedora_harm, co_ies, ano, qt_doc_exe, qt_doc_ex_int, 
      qt_doc_ex_parc, qt_doc_ex_hor, qt_doc_ex_sem_grad, qt_doc_ex_grad,
      qt_doc_ex_esp, qt_doc_ex_mest, qt_doc_ex_dout
)
  ),
  cursos = read_parquet(
    file = here('data/clean/ces_cursos.parquet'),
    col_select = c(co_ies, ano, qt_mat, qt_mat_diurno, qt_mat_noturno, qt_mat_ead)
  )
) 

# Pre-processamento
data_G <- data_G |> 
  # Reduz para data frame
  reduce(inner_join) |> 
  # Agrega por IES
  summarise(
    across(matches('^qt_doc'), ~ mean(.x)), 
    across(matches('^qt_mat'), ~ sum(.x, na.rm = TRUE)), 
    .by = !matches('^qt')
  ) |> 
  # Acrescenta outras colunas necessarias
  mutate(
    total = 1L,
    qt_doc_ex_sempg = qt_doc_ex_sem_grad + qt_doc_ex_grad,
    pct_ead = qt_mat_ead / qt_mat,
    fx_pct_ead = replace_na(cut(pct_ead, c(-Inf, 0, .33, .66, Inf), labels = FALSE), 1)
    ) |>
  # Exclui colunas desnecessarias
  select(-pct_ead, -matches('_grad$'), -matches('qt_mat_'))

## Rotulos de variaveis --------------------------------------------------------

rotulos_vars <- read_csv(here('data/clean/rotulos_variaveis.csv'))


# INDICADOR G.1 ================================================================

# Quantidade de docentes em exercicio em tempo integral por modalidade de ensino 
# entre 2010 e 2024

# Obs.: este indicador e' redundante, pois os mesmos numeros ja estao incluidos
# nos resultados do indicador G.3. 

# Inicializacao da lista
G1 <- list()

# Identificacao
G1$id   <- 'G1'
G1$name <- 'Quantidade de docentes em exercício em tempo integral por modalidade de ensino entre 2010 e 2024'

# Funcao para calcular o indicador
G1$fn <- function(df){
  df |> 
    summarise(across(c(qt_doc_exe, qt_doc_ex_int), sum), .groups = 'drop') 
}

# Calculo do indicador
G1$output <- calcula_dimensao_G(data_G, G1, rotulos_vars) 
  
# Output 
write_excel_csv(G1$output, here('results/indicadorG1.csv'))


# INDICADOR G.2 ================================================================

# Titulacao do corpo docente por modalidade de ensino entre 2010 e 2024

# Inicializacao da lista
G2 <- list()

# Identificacao
G2$id   <- 'G2'
G2$name <- 'Titulação do corpo docente (doutor, mestre, especialista) por modalidade de ensino entre 2010 e 2024'

# Funcao para calcular o indicador
G2$fn <- function(df){
  df |> 
    summarise(
      across(c(qt_doc_exe, matches('qt_doc_ex_(sempg|esp|mest|dout)$')), sum), 
      .groups = 'drop'
    )
}

# Calculo do indicador
G2$output <- calcula_dimensao_G(data_G, G2, rotulos_vars) 
  
# Output 
write_excel_csv(G2$output, here('results/indicadorG2.csv'))


# INDICADOR G.3 ================================================================

# Regime de trabalho dos docentes (tempo integral, parcial, horário) entre 2010 e 2024

# Inicializacao da lista
G3 <- list()

# Identificacao
G3$id   <- 'G3'
G3$name <- 'Regime de trabalho dos docentes (tempo integral, parcial, horário) entre 2010 e 2024'

# Funcao para calcular o indicador
G3$fn <- function(df){
  df |> 
    summarise(
      across(c(qt_doc_exe, qt_doc_ex_int, qt_doc_ex_parc, qt_doc_ex_hor), sum), 
      .groups = 'drop'
    )
}

# Calculo do indicador
G3$output <- calcula_dimensao_G(data_G, G3, rotulos_vars) 
  
# Output 
write_excel_csv(G3$output, here('results/indicadorG3.csv'))


# INDICADOR G.4 ================================================================

# Relação aluno por docente entre 2010 e 2024

# Inicializacao da lista
G4 <- list()

# Identificacao
G4$id   <- 'G4'
G4$name <- 'Relação aluno por docente entre 2010 e 2024'

# Funcao para calcular o indicador
G4$fn <- function(df){
  df |> 
    summarise(across(c(qt_doc_exe, qt_mat), sum), .groups = 'drop')
}

# Calculo do indicador
G4$output <- calcula_dimensao_G(data_G, G4, rotulos_vars) 
  
# Output 
write_excel_csv(G4$output, here('results/indicadorG4.csv'))

