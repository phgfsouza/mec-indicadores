#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Configuracao do projeto
# Pedro HGF Souza 
# Maio/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script carrega as configuracoes basicas do projeto, validas para todas as
# etapas subsequentes. 

# Etapas:
# 1. Carregamento dos pacotes e definicao das preferencias para funcoes com
#    nomes compartilhados entre pacotes.
# 2. Identificacao da raiz do projeto a partir de `code/_setup.R`.
# 3. Carregamento das funcoes auxiliares de `code/helpers/`.

# Inputs do script:
# - Pacotes listados abaixo, previamente instalados.
# - `code/helpers/*.R`.

# Outputs do script:
# - Pacotes e funcoes disponiveis na sessao, preferencias de conflitos e raiz
#   configurada para `here()`. Este script nao exporta arquivos de dados.


# PACOTES ======================================================================

library(arrow)
library(conflicted)
library(here)
library(janitor)
library(geobr)
library(openxlsx)
library(quarto)
library(readxl)
library(rlang)
library(stringi)
library(tidyverse)
library(writexl)
library(readxl)
library(sf)
library(glue)

conflict_scout()
conflicts_prefer(dplyr::filter, dplyr::lag)

i_am("code/_setup.R")

# FUNCOES PROPRIAS =============================================================

walk(
  .x = list.files(here('code/helpers'), '\\.R$', full.names = TRUE),
  .f = ~ invisible(source(.x))
)
