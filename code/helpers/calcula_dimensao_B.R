#' Calcula um indicador da dimensao B
#'
#' Calcula, para cada variavel de agrupamento definida em `config$by`, a
#' variacao de ingressantes e matriculas entre anos consecutivos de 2010 a 2024
#' e nos periodos 2010-2016, 2016-2024 e 2010-2024. Tambem calcula a
#' contribuicao percentual de cada grupo para o saldo total do bloco.
#'
#' Grupos ausentes em um dos extremos do periodo e valores `NA` em `qt_ing` ou
#' `qt_mat` sao tratados como zero. Quando todos os grupos apresentam variacao
#' zero, suas contribuicoes percentuais sao zero. Quando variacoes nao nulas se
#' anulam e o saldo total e zero, as contribuicoes percentuais sao `NA`.
#'
#' @param data Data frame com as colunas `ano`, `qt_ing`, `qt_mat` e as
#'   variaveis de agrupamento informadas em `config$by`.
#' @param config Lista com a especificacao do indicador. Deve conter `by`, um
#'   vetor `character` nomeado com as variaveis de agrupamento; `id`, o codigo
#'   do indicador; e `name`, o nome descritivo do indicador.
#' @param labels Data frame com as colunas `bloco_var`, `bloco_nome`,
#'   `grupo_code` e `grupo_nome`, usado para rotular os blocos e grupos do
#'   indicador.
#'
#' @return Tibble com as variacoes absolutas e as contribuicoes percentuais por
#'   indicador, bloco, grupo e periodo, acrescido dos rotulos de bloco e grupo.
#'
#' @examples
#' data <- tibble(
#'   categoria = c(1, 1, 2, 2),
#'   ano = c(2010, 2011, 2010, 2011),
#'   qt_ing = c(10, 15, 20, 25),
#'   qt_mat = c(100, 110, 200, 220)
#' )
#'
#' config <- list(
#'   id = "B0",
#'   name = "Exemplo",
#'   by = c(categoria = "categoria")
#' )
#'
#' labels <- tibble(
#'   bloco_var = c("categoria", "categoria"),
#'   bloco_nome = c("Categoria", "Categoria"),
#'   grupo_code = c(1, 2),
#'   grupo_nome = c("Grupo 1", "Grupo 2")
#' )
#'
#' calcula_dimensao_B(data, config, labels)
calcula_dimensao_B <- function(data, config, labels){

  periodos <- data.frame(
    t0 = c(2010:2023, 2010, 2017, 2010), 
    t1 = c(2011:2024, 2017, 2024, 2024)
  )

  input_for_pmap <- expand_grid(by_var = config[['by']], periodos)

  pmap(
    .l = input_for_pmap,
    .f = \(by_var, t0, t1)
      data |> 
        select(all_of(by_var), ano, qt_ing, qt_mat) |> 
        filter(ano %in% c(t0, t1)) |> 
        rename(grupo_code = all_of(by_var)) |>
        summarise(
          across(c(qt_ing, qt_mat), ~ sum(.x, na.rm = TRUE)), 
          .by = c(grupo_code, ano)
        ) |> 
        summarise(
          across(
            .cols = c(qt_ing, qt_mat),
            .fns = ~ sum(.x[ano == t1], na.rm = TRUE) - sum(.x[ano == t0], na.rm = TRUE),
            .names = 'delta_{.col}'
          ),
          .by = grupo_code
        ) |> 
        mutate(
          periodo = paste0(t0, '-', t1),
          across(
            .cols = c(delta_qt_ing, delta_qt_mat),
            .fns = ~ 
            if (sum(abs(.x)) == 0) 0
            else if (sum(.x) == 0) NA_real_
            else 100 * .x / sum(.x),
            .names = 'pct_{.col}'
          )
        )  |>
        pivot_longer(
          cols = !c(grupo_code, periodo),
          names_to = 'serie_var', 
          values_to = 'valor'
        ) |> 
        arrange(grupo_code)
  ) |> 
    bind_rows(.id = 'bloco_var') |> 
    left_join(
      labels,
      by = c("bloco_var", "grupo_code"),
      relationship = "many-to-one"
    ) |>
    mutate(
      indicador_code = config[['id']],
      indicador_nome = config[['name']],
      serie_nome = case_when( 
        str_detect(serie_var, 'qt_ing$') ~ 'Ingressantes',
        str_detect(serie_var, 'qt_mat$') ~ 'Matrículas',
      ),
      unidade = case_when(
        str_detect(serie_var, '^delta')  ~ 'Quantidade',
        str_detect(serie_var, '^pct') ~ 'Percentual', 
      )
    ) |>
    relocate(
      indicador_code, indicador_nome, 
      bloco_var, bloco_nome,
      grupo_code, grupo_nome, 
      serie_var, serie_nome, 
      unidade,
      periodo,
      valor
    )
}
