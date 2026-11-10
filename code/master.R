#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Execucao do pipeline completo
# Pedro HGF Souza 
# Maio/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script executa a preparacao dos dados, o calculo dos indicadores e a
# producao das planilhas e do primeiro relatorio descritivo.
# Executar a partir da raiz do projeto, com os pacotes de `_setup.R` instalados.

# Etapas:
# 1. Configuracao do projeto e preparacao dos dados brutos com `01-preparacao.R`.
# 2. Calculo dos indicadores das dimensoes A, B, F, G e I com os scripts 02 a 06.
# 3. Conversao dos resultados CSV para Excel com `07-planilhas.R`.
# 4. Geracao das figuras com `08-graficos-relatorio-1.R` e renderizacao do
#    relatorio em Word e PDF com Quarto.

# Observacoes:
# - A preparacao consulta as malhas de 2010 pelo pacote `geobr` e pode exigir
#   acesso a internet. Os demais dados brutos devem estar disponiveis localmente.
# - A renderizacao requer Quarto, os pacotes utilizados no documento, LuaLaTeX
#   e a fonte Noto Serif, alem do modelo Word e dos filtros locais.
# - A execucao atualiza os arquivos derivados; as planilhas finais existentes
#   sao sobrescritas. As pastas de destino devem existir antes da execucao.

# Inputs do script:
# - Scripts `code/_setup.R` e `code/01-preparacao.R` a
#   `code/08-graficos-relatorio-1.R`, com os inputs descritos em cada etapa.
# - `produtos/relatorio-1/relatorio-descritivo-1.qmd` e seus arquivos de apoio.

# Outputs do script:
# - Bases e malhas processadas em `data/clean/`.
# - Resultados CSV e planilhas de diagnostico em `results/`.
# - Planilhas Excel em `produtos/planilhas/`.
# - Figuras, dados e objetos ggplot em `produtos/relatorio-1/figuras/`.
# - Relatorio Word e PDF em `produtos/relatorio-1/`.

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

