#' Calcula um indicador da dimensao F
#'
#' Aplica a funcao de resumo para cada variavel definida em `config$by`,
#' agrupando por grupo e coorte de ingresso. Calcula percentuais, empilha os
#' blocos e junta os rotulos dos blocos e grupos.
#'
#' Os percentuais das contagens `qt_*`, exceto `qt_ingressante_vivo`, usam
#' como denominador o total de ingressantes vivos retornado por `config$fn()`
#' para o mesmo grupo e coorte. Esse total deve excluir os falecidos acumulados
#' ate o ano de acompanhamento selecionado. Quando o denominador e zero, o
#' percentual e `NA`. A coluna do denominador nao e incluida na saida.
#'
#' A selecao do ano de acompanhamento e a agregacao das quantidades cabem a
#' `config$fn()`. Os acumulados devem ser calculados no pre-processamento,
#' antes de qualquer filtro que remova anos da trajetoria. A coluna temporal
#' da saida e `coorte`, correspondente ao ano de ingresso.
#'
#' @param data Data frame com `coorte`, as variaveis de agrupamento e os dados
#'   necessarios para calcular o indicador, incluindo os acumulados e o total
#'   de ingressantes vivos no ano de acompanhamento de cada linha.
#' @param config Lista com `by`, vetor `character` nomeado com as variaveis de
#'   agrupamento; `fn`, funcao que recebe os dados agrupados e retorna as
#'   contagens agregadas `qt_*` e `qt_ingressante_vivo`, preservando as chaves
#'   `grupo_code` e `coorte`; `id`, codigo do indicador; e `name`, nome
#'   descritivo do indicador.
#' @param labels Data frame com as colunas `bloco_var`, `bloco_nome`,
#'   `grupo_code` e `grupo_nome`, usado para rotular os blocos e grupos.
#'
#' @return Tibble sem agrupamento com quantidades e percentuais por bloco,
#'   grupo e coorte, acrescido da identificacao do indicador, dos rotulos,
#'   do nome da serie, da unidade e do valor. Nesta versao, as series de
#'   desistencia recebem o nome "Desistentes".
#'
#' @examples
#' data <- tibble(
#'   total = 1L,
#'   coorte = 2020L,
#'   ano = c(2020L, 2021L, 2020L, 2021L),
#'   qt_ingressante_vivo = c(100, 99, 200, 200),
#'   qt_desistencia_acum = c(10, 30, 20, 60)
#' )
#'
#' config <- list(
#'   id = "F1",
#'   name = "Desistencia acumulada ate o segundo ano",
#'   by = c(total = "total"),
#'   fn = function(df) {
#'     df |>
#'       filter(ano == coorte + 1L) |>
#'       summarise(
#'         qt_ingressante_vivo = sum(qt_ingressante_vivo),
#'         qt_desistencia_acum = sum(qt_desistencia_acum),
#'         .groups = "drop"
#'       )
#'   }
#' )
#'
#' labels <- tibble(
#'   bloco_var = "total",
#'   bloco_nome = "Total",
#'   grupo_code = 1L,
#'   grupo_nome = "Total"
#' )
#'
#' calcula_dimensao_F(data, config, labels)
calcula_dimensao_F <- function(data, config, labels){

  fn   <- config[['fn']]

  map(
    .x = config[['by']],
    .f = \(by_var)
      data |>
        rename(grupo_code = all_of(by_var)) |>
        group_by(grupo_code, coorte) |> 
        fn() |>
        mutate(
          across(
            .cols = !matches('qt_ingressante_vivo') & matches('^qt'), 
            .fns = ~ 100 * .x /  na_if(qt_ingressante_vivo, 0), 
            .names = "pct_{sub('^qt_', '', .col)}"
          )
        ) |>
        ungroup() |> 
        select(-qt_ingressante_vivo) |>
        pivot_longer(
          cols = !c(grupo_code, coorte),
          names_to = 'serie_var', 
          values_to = 'valor'
        ) |> 
        arrange(grupo_code, serie_var, coorte)
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
        str_detect(serie_var, '^(qt|pct)_desistencia') ~ 'Desistentes',
        str_detect(serie_var, '^(qt|pct)_concluinte') ~ 'Concluintes',
        str_detect(serie_var, '^(qt|pct)_permanencia') ~ 'Cursando ou trancados'
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
      coorte,
      valor
    )
}
