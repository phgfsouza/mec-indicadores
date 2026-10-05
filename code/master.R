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

## Dimensao A ------------------------------------------------------------------

source(file.path('code/02-indicadores-A.R'))

## Dimensao B ------------------------------------------------------------------

source(file.path('code/03-indicadores-B.R'))

## Dimensao C ------------------------------------------------------------------
## Dimensao D ------------------------------------------------------------------
## Dimensao E ------------------------------------------------------------------
## Dimensao F ------------------------------------------------------------------
## Dimensao G ------------------------------------------------------------------

source(file.path('code/08-indicadores-G.R'))

## Dimensao H ------------------------------------------------------------------


# PRODUTOS =====================================================================

## Graficos para relatorio -----------------------------------------------------

source(file.path('code/10-graficos.R'))

## Planilhas com resultados ----------------------------------------------------

source(file.path('code/11-planilhas.R'))

## Relatorio descritivo --------------------------------------------------------

quarto_render(
  input = file.path('produtos/relatorio/relatorio-descritivo-1.qmd'), 
  output_format = c("docx", "pdf")
)

