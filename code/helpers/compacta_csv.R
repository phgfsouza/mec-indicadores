#' Compacta a identificacao do indicador para exportacao em CSV
#'
#' Mantem `indicador_code` e `indicador_nome` preenchidos somente na primeira
#' linha. Aplicar depois dos filtros, dentro da chamada de exportacao, para
#' preservar os metadados completos no objeto original.
#'
#' @param x Data frame com um unico codigo e nome de indicador.
#' @return Data frame com as demais linhas dessas duas colunas vazias.
compacta_csv <- function(x){

  if (nrow(x) == 0L) return(x)

  x |>
    mutate(
      across(
        all_of(c('indicador_code', 'indicador_nome')),
        \(coluna) {
          valor <- unique(coluna[!is.na(coluna) & trimws(coluna) != ''])

          if (length(valor) != 1L) {
            stop('Cada coluna de identificacao deve conter um unico valor preenchido.')
          }

          if_else(seq_len(nrow(x)) == 1L, valor, '')
        }
      )
    )
}
