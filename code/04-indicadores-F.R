#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Dimensao F - Fluxo Academico e Conclusao
# Pedro HGF Souza 
# Outubro/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script calcula os seis indicadores da dimensao F, ampliando o conjunto
# previsto na proposta original.

# Etapas:
# 1. Importacao e pre-processamento dos dados de Trajetorias da Educacao
#    Superior produzidos pelo script `01-preparacao.R`.
# 2. Calculos dos indicadores a partir de procedimentos padronizados: para cada
#    indicador, o script cria uma lista de inputs que sao usados como argumentos
#    para a funcao `calcula_dimensao_F()`.
# 3. As planilhas com resultados separados para cada indicador sao gravadas em
#    `results/` no formato csv.

# Observacoes:
# - Sao mantidos cursos com prazo de integralizacao de 3 a 6 anos. Os
#   atributos de agrupamento sao fixados no ingresso de cada curso-coorte.
# - Os percentuais usam os ingressantes menos os falecidos acumulados ate
#   o ano de acompanhamento, para o mesmo grupo e coorte. Denominador zero
#   produz percentual NA.
# - F.1 acompanha ate o segundo ano; F.2 a F.4 usam o prazo de integralizacao;
#   F.5 e F.6 acrescentam, respectivamente, 2 e 4 anos a esse prazo.
# - Para cada horizonte, sao excluidas as coortes recentes sem tempo de
#   observacao suficiente para os cursos de maior duracao incluidos.
# - A coluna temporal da saida e `coorte`, e nao o ano de acompanhamento.
#   Atributos imputados na preparacao seguem a convencao descrita em
#   `01-preparacao.R`, sem confirmacao historica do valor preenchido.
# - `compacta_csv()` mantem o codigo e o nome do indicador apenas na primeira
#   linha do CSV. A conversao para Excel e feita em `07-planilhas.R`.

# Inputs do script:
# - `data/clean/trajetorias.parquet`
# - `data/clean/rotulos_variaveis.csv`

# Outputs do script:
# - `results/indicadorF*.csv`


# CONFIGURACAO =================================================================

source('code/_setup.R')

# PRE-PROCESSAMENTO ============================================================

## Trajetorias da Educacao Superior --------------------------------------------

# Importacao de dados selecionados
data_F <- read_parquet(here("data/clean/trajetorias.parquet")) 

# Pre-processamento
# - seleciona colunas necessarias
# - mantem somente cursos com prazo de integralizacao entre 3 e 6 anos 
#   (~98% de todos os ingressantes)
# - assegura ordenacao correta das linhas
# - fixa as caracteristicas no ano de ingresso de cada curso-coorte
# - acrescenta colunas com desagregacoes
data_F <- data_F |> 
  select(
    catadm_it, tp_modalidade_ensino, tp_grau_academico, co_cine_area_geral, 
    co_curso, coorte, ano, nu_prazo_integralizacao, nu_ano_integralizacao,
    qt_ingressante, qt_permanencia, qt_concluinte, qt_desistencia, qt_falecido
  ) |>  
  filter(nu_prazo_integralizacao %in% 3:6) |>
  arrange(coorte, co_curso, ano) |>
  mutate(
    across(catadm_it:co_cine_area_geral, ~ first(.x[ano == coorte])),
    total = 1L,
    qt_concluinte_acum = cumsum(qt_concluinte),
    qt_desistencia_acum = cumsum(qt_desistencia),
    qt_falecido_acum = cumsum(qt_falecido),
    qt_ingressante_vivo = qt_ingressante - qt_falecido_acum,
    .by = c(co_curso, coorte)
  ) |>
  combina_variaveis(catadm_it, co_cine_area_geral) |> 
  combina_variaveis(catadm_it, nu_prazo_integralizacao) |>
  combina_variaveis(catadm_it, tp_modalidade_ensino) |> 
  combina_variaveis(catadm_it, tp_grau_academico) |> 
  combina_variaveis(catadm_it, co_cine_area_geral, tp_modalidade_ensino) |>
  combina_variaveis(co_cine_area_geral, tp_modalidade_ensino)

## Rotulos de variaveis --------------------------------------------------------

rotulos_vars <- read_csv(here('data/clean/rotulos_variaveis.csv'))

## Blocos para desagregacoes ---------------------------------------------------

F_by <- c(
  'total', 
  'catadm_it', 
  'nu_prazo_integralizacao',
  'tp_modalidade_ensino',
  'tp_grau_academico',
  'co_cine_area_geral',
  'catadm_it_tp_modalidade_ensino',          
  'catadm_it_tp_grau_academico',
  'catadm_it_nu_prazo_integralizacao',
  'catadm_it_co_cine_area_geral',                  
  'catadm_it_co_cine_area_geral_tp_modalidade_ensino',
  'co_cine_area_geral_tp_modalidade_ensino'
) |> 
  set_names()

## Limite de coortes -----------------------------------------------------------

max_coorte <- max(data_F$ano) - max(data_F$nu_prazo_integralizacao) + 1L


# INDICADOR F.1 ================================================================

# Desistência acumulada até o final do segundo ano de acompanhamento

# Inicializa lista
F1 <- list()

# Identificacao
F1$id   <- 'F1'
F1$name <- 'Desistência acumulada até o final do segundo ano de acompanhamento'

# Blocos para desagregacoes
F1$by <- F_by

# Funcao para calcular o indicador
F1$fn <- function(df){
  df |>
    filter(ano == coorte + 1L) |> 
    summarise(
      qt_ingressante_vivo = sum(qt_ingressante_vivo),
      qt_desistencia_acum = sum(qt_desistencia_acum),
      .groups = 'keep'
    )
}

# Calculo do indicador
F1$output <- calcula_dimensao_F(data_F, F1, rotulos_vars) 

# Output 
write_excel_csv(compacta_csv(F1$output), here('results/indicadorF1.csv'))


# INDICADOR F.2 ================================================================

# Desistência acumulada até o prazo previsto de integralização
# - Exclui as coortes sem o periodo necessario para integralizacao de cursos 
#   mais longos 

# Inicializa lista
F2 <- list()

# Identificacao
F2$id   <- 'F2'
F2$name <- 'Desistência acumulada até o prazo previsto de integralização'

# Blocos para desagregacoes
F2$by <- F_by

# Funcao para calcular o indicador
F2$fn <- function(df){
  df |>
    filter(coorte <= max_coorte & ano == nu_ano_integralizacao) |> 
    summarise(
      qt_ingressante_vivo = sum(qt_ingressante_vivo),
      qt_desistencia_acum = sum(qt_desistencia_acum),
      .groups = 'keep'
    )
}

# Calculo do indicador
F2$output <- calcula_dimensao_F(data_F, F2, rotulos_vars) 

# Output 
write_excel_csv(compacta_csv(F2$output), here('results/indicadorF2.csv'))


# INDICADOR F.3 ================================================================

# Permanência no ano previsto de integralização — estudantes ainda cursando ou 
# com matrícula trancada
# - Exclui as coortes sem o periodo necessario para integralizacao de cursos 
#   mais longos 

# Inicializa lista
F3 <- list()

# Identificacao
F3$id   <- 'F3'
F3$name <- 'Permanência no ano previsto de integralização — estudantes ainda cursando ou com matrícula trancada'

# Blocos para desagregacoes
F3$by <- F_by

# Funcao para calcular o indicador
F3$fn <- function(df){
  df |>
    filter(coorte <= max_coorte & ano == nu_ano_integralizacao) |> 
    summarise(
      qt_ingressante_vivo = sum(qt_ingressante_vivo),
      qt_permanencia = sum(qt_permanencia),
      .groups = 'keep'
    )
}

# Calculo do indicador
F3$output <- calcula_dimensao_F(data_F, F3, rotulos_vars) 

# Output 
write_excel_csv(compacta_csv(F3$output), here('results/indicadorF3.csv'))


# INDICADOR F.4 ================================================================

# Conclusão acumulada até o prazo previsto de integralização
# - Exclui as coortes sem o periodo necessario para integralizacao de cursos 
#   mais longos 

# Inicializa lista
F4 <- list()

# Identificacao
F4$id    <- 'F4'
F4$name <- 'Conclusão acumulada até o prazo previsto de integralização'

# Blocos para desagregacoes
F4$by <- F_by

# Funcao para calcular o indicador
F4$fn <- function(df){
  df |>
    filter(coorte <= max_coorte & ano == nu_ano_integralizacao) |> 
    summarise(
      qt_ingressante_vivo = sum(qt_ingressante_vivo),
      qt_concluinte_acum = sum(qt_concluinte_acum),
      .groups = 'keep'
    )
}

# Calculo do indicador
F4$output <- calcula_dimensao_F(data_F, F4, rotulos_vars) 

# Output 
write_excel_csv(compacta_csv(F4$output), here('results/indicadorF4.csv'))


# INDICADOR F.5 ================================================================

#	Conclusão acumulada até o prazo previsto de integralização + 2 anos
# - Exclui as coortes sem o periodo necessario para integralizacao de cursos 
#   mais longos 

# Inicializa lista
F5 <- list()

# Identificacao
F5$id    <- 'F5'
F5$name <- 'Conclusão acumulada até o prazo previsto de integralização + 2 anos'

# Blocos para desagregacoes
F5$by <- F_by

# Funcao para calcular o indicador
F5$fn <- function(df){
  df |>
    filter(coorte <= max_coorte - 2L & ano == nu_ano_integralizacao + 2L) |> 
    summarise(
      qt_ingressante_vivo = sum(qt_ingressante_vivo),
      qt_concluinte_acum = sum(qt_concluinte_acum),
      .groups = 'keep'
    )
}

# Calculo do indicador
F5$output <- calcula_dimensao_F(data_F, F5, rotulos_vars) 

# Output 
write_excel_csv(compacta_csv(F5$output), here('results/indicadorF5.csv'))

# INDICADOR F.6 ================================================================

# Conclusão acumulada até o prazo previsto de integralização + 4 anos
# - Exclui as coortes sem o periodo necessario para integralizacao de cursos 
#   mais longos 

# Inicializa lista
F6 <- list()

# Identificacao
F6$id    <- 'F6'
F6$name <- 'Conclusão acumulada até o prazo previsto de integralização + 4 anos'

# Blocos para desagregacoes
F6$by <- F_by

# Funcao para calcular o indicador
F6$fn <- function(df){
  df |>
    filter(coorte <= max_coorte - 4L & ano == nu_ano_integralizacao + 4L) |> 
    summarise(
      qt_ingressante_vivo = sum(qt_ingressante_vivo),
      qt_concluinte_acum = sum(qt_concluinte_acum),
      .groups = 'keep'
    )
}

# Calculo do indicador
F6$output <- calcula_dimensao_F(data_F, F6, rotulos_vars) 

# Output 
write_excel_csv(compacta_csv(F6$output), here('results/indicadorF6.csv'))



