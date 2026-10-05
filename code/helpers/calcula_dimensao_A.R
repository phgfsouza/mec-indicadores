#' Calcula um indicador da dimensao A
#'
#' Aplica a funcao de resumo de um indicador para cada variavel de agrupamento
#' definida em `config$by`, empilha os blocos calculados e junta os rotulos dos
#' blocos e grupos.
#'
#' @param data Data frame com `ano`, as variaveis de agrupamento e os dados
#'   necessarios para calcular o indicador.
#' @param config Lista com a especificacao do indicador. Deve conter `by`, um
#'   vetor `character` nomeado com as variaveis de agrupamento; `fn`, uma funcao
#'   que recebe os dados agrupados e retorna estatisticas agregadas; `id`, o
#'   codigo do indicador; e `name`, o nome descritivo do indicador.
#' @param labels Data frame com as colunas `bloco_var`, `bloco_nome`,
#'   `grupo_code` e `grupo_nome`, usado para rotular os blocos e grupos do
#'   indicador.
#'
#' @return Tibble com os resultados de `config$fn()` por bloco, grupo e ano,
#'   acrescido das colunas de identificacao do indicador e dos rotulos de bloco
#'   e grupo.
#'
#' @examples
#' data <- tibble(total = 1, ano = c(2023, 2023), valor = c(1, 2))
#'
#' config <- list(
#'   id = "A0",
#'   name = "Exemplo",
#'   by = c(total = "total"),
#'   fn = function(df) {
#'     summarise(df, total_valor = sum(valor), .groups = "drop")
#'   }
#' )
#'
#' labels <- tibble(
#'   bloco_var = "total",
#'   bloco_nome = "Total",
#'   grupo_code = 1,
#'   grupo_nome = "Total"
#' )
#'
#' calcula_dimensao_A(data, config, labels)
calcula_dimensao_A <- function(data, config, labels){

  fn   <- config[['fn']]

  map(
    .x = config[['by']],
    .f = \(by_var)
      data |>
        rename(grupo_code = all_of(by_var)) |>
        group_by(grupo_code, ano) |> 
        fn() |>
        mutate(
          across(
            .cols = matches('^qt'), 
            .fns = ~ 100 * .x / sum(.x, na.rm = TRUE), 
            .names = "pct_{sub('^qt_', '', .col)}"
          ), 
          .by = ano
        ) |>
        pivot_longer(
          cols = !c(grupo_code, ano),
          names_to = 'serie_var', 
          values_to = 'valor'
        ) |> 
        arrange(grupo_code, serie_var, ano)
  ) |>
    bind_rows(.id = "bloco_var") |>
    left_join(
      labels,
      by = c("bloco_var", "grupo_code"),
      relationship = "many-to-one"
    ) |>
    mutate(
      indicador_code = config[['id']],
      indicador_nome = config[['name']],
      serie_nome = case_when( 
        str_detect(serie_var, '^(qt|pct)_mantenedoras') ~ 'Mantenedoras',
        str_detect(serie_var, '^(qt|pct)_ies') ~ 'IES',
        str_detect(serie_var, '^(qt|pct)_vg_total') ~ 'Vagas',
        str_detect(serie_var, '^(qt|pct)_ing') ~ 'Ingressantes',
        str_detect(serie_var, '^(qt|pct)_mat') ~ 'Matrículas',       
        serie_var == 'tx_ocupacao_vaga' ~ 'Ingressantes por 100 vagas'
      ),
      unidade = case_when(
        str_detect(serie_var, '^qt')  ~ 'Quantidade',
        str_detect(serie_var, '^pct') ~ 'Percentual', 
        str_detect(serie_var, '^tx')  ~ 'Taxa'
      )
    ) |>
    relocate(
      indicador_code, indicador_nome, 
      bloco_var, bloco_nome,
      grupo_code, grupo_nome, 
      serie_var, serie_nome, 
      unidade,
      ano,
      valor
    )
}
