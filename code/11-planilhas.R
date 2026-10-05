#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Planilhas para entregar ao MEC
# Pedro HGF Souza 
# Julho/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script converte os arquivos `csv` com resultados em formato `long` em 
# arquivos Excel com formato `wide` e formatacao padronizada, prontos para 
# entrega ao MEC.

# Inputs:
# - Script com a configuracao do projeto
#   - `code/_setup.R`
# - Planilhas com os resultados em formato `long`
#   - `results/indicador*.csv`

# Outputs:
# - Planilhas Excel com resultados em `wide` e com formatacao
#   - `produtos/planilhas/indicador*.xlsx`


# CONFIGURACAO =================================================================

source('code/_setup.R')

# PROCESSAMENTO ================================================================

xlsx <- map(
  .x = list.files(here('results'), 'indicador[A-Z][0-9]') |> set_names(), 
  .f = ~ read_csv(here('results', .x)) |> gera_xlsx_formatado()
)
  
names(xlsx) <- str_replace(names(xlsx), 'csv', 'xlsx')
  
# EXPORTACAO ===================================================================

imap(xlsx, ~ saveWorkbook(.x, here('produtos/planilhas', .y), overwrite = TRUE))


