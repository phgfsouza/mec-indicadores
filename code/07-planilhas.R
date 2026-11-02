#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Planilhas para entregar ao MEC
# Pedro HGF Souza 
# Julho/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script converte os arquivos `csv` com resultados em formato `long` ou
# com anos em colunas `valor_AAAA` para arquivos Excel com formato `wide` e
# formatacao padronizada, prontos para entrega ao MEC.

# Etapas:
# 1. Leitura dos CSV dos indicadores em `results/`.
# 2. Conversao de `valor_AAAA` para `ano` e `valor`, quando necessario.
# 3. Geracao de indice, abas por recorte e serie, e tabelas por unidade com
#    `gera_xlsx_formatado()`.
# 4. Exportacao para `produtos/planilhas/`, sobrescrevendo arquivos existentes.

# Observacoes:
# - As identificacoes geograficas sao preservadas antes de `ano`, `periodo`
#   ou `coorte`. Com varias colunas de identificacao, as linhas sao ordenadas
#   por elas; coortes tambem sao ordenadas quando sao a unica identificacao.
# - Anos e periodos isolados mantem a ordem do CSV, inclusive os periodos de B.
# - Percentuais ausentes por coorte permanecem vazios. Nas demais tabelas,
#   os valores numericos ausentes sao preenchidos com zero.
# - Nomes de abas sao limitados a 31 caracteres, com sufixos em caso de colisao.
# - Os resultados CSV devem estar atualizados antes desta etapa; o script
#   nao recalcula indicadores. A pasta de destino deve existir.

# Inputs do script:
# - Script com a configuracao do projeto
#   - `code/_setup.R`
# - Planilhas com os resultados em formato `long` ou com anos em colunas
#   - `results/indicador*.csv`

# Outputs do script:
# - Planilhas Excel com resultados em `wide` e com formatacao
#   - `produtos/planilhas/indicador*.xlsx`


# CONFIGURACAO =================================================================

source('code/_setup.R')

# PROCESSAMENTO ================================================================

xlsx <- map(
  .x = list.files(here('results'), 'indicador[A-Z][0-9]') |> set_names(), 
  .f = \(arquivo) {
    dados <- read_csv(here('results', arquivo))

    if (any(str_detect(names(dados), '^valor_[0-9]{4}$'))) {
      dados <- dados |>
        pivot_longer(
          cols = matches('^valor_[0-9]{4}$'),
          names_to = 'ano',
          names_prefix = 'valor_',
          names_transform = list(ano = as.integer),
          values_to = 'valor'
        )
    }

    gera_xlsx_formatado(dados)
  }
)
  
names(xlsx) <- str_replace(names(xlsx), 'csv', 'xlsx')
  
# EXPORTACAO ===================================================================

imap(xlsx, ~ saveWorkbook(.x, here('produtos/planilhas', .y), overwrite = TRUE))


