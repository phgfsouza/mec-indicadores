#==============================================================================#
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# Pedro HGF Souza 
# Maio/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# to do

# CONFIGURACAO DO PROJETO ======================================================

source(file.path('code/_setup.R'))

# PREPARACAO DOS MICRODADOS ====================================================

source(file.path('code/01-preparacao.R'))

# CALCULO DOS INDICADORES ======================================================

source(file.path('code/02-indicadores-A.R'))

source(file.path('code/03-indicadores-B.R'))

source(file.path('code/04-indicadores-F.R'))

source(file.path('code/05-indicadores-G.R'))

source(file.path('code/06-indicadores-I.R'))


# PRODUTOS =====================================================================

## Planilhas com resultados ----------------------------------------------------

source(file.path('code/07-planilhas.R'))


## Relatorio 1 -----------------------------------------------------------------

source(file.path('code/08-graficos-relatorio-1.R'))

quarto_render(
  input = file.path('produtos/relatorio-1/relatorio-descritivo-1.qmd'), 
  output_format = c("docx", "pdf")
)

