#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Configuracao do projeto
# Pedro HGF Souza 
# Maio/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script carrega as configuracoes basicas do projeto, validas para todas as
# etapas subsequentes. 

# Sao apenas duas etapas:
# - Importacao do pacotes necessarios
# - Importacao de funcoes proprias auxiliares


# PACOTES ======================================================================

library(arrow)
library(conflicted)
library(here)
library(janitor)
library(openxlsx)
library(quarto)
library(readxl)
library(rlang)
library(stringi)
library(tidyverse)
library(writexl)

conflict_scout()
conflicts_prefer(dplyr::filter, dplyr::lag)

i_am("code/_setup.R")

# FUNCOES PROPRIAS =============================================================

walk(
  .x = list.files(here('code/helpers'), '\\.R$', full.names = TRUE),
  .f = ~ invisible(source(.x))
)
