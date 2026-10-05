

#' Calcula um indicador da dimensao G
#'
#' Aplica a funcao de resumo de um indicador da dimensao G para os recortes
#' padrao de total, categoria administrativa, tamanho da mantenedora e faixa de
#' participacao de matriculas em EaD. Em seguida, empilha os blocos calculados,
#' junta os rotulos dos blocos e grupos e cria as colunas padronizadas de nome
#' de serie e unidade.
#'
#' A funcao tambem calcula percentuais de variaveis de docentes em relacao ao
#' total de docentes em exercicio e, quando `qt_mat` estiver disponivel, a taxa
#' de matriculas por docente em exercicio.
#'
#' @param data Data frame com `ano`, os recortes `total`, `catadm_it`,
#'   `fx_ranking` e `fx_pct_ead`, alem das variaveis necessarias para calcular o
#'   indicador.
#' @param config Lista com a especificacao do indicador. Deve conter `fn`, uma
#'   funcao que recebe dados agrupados e retorna estatisticas agregadas; `id`, o
#'   codigo do indicador; e `name`, o nome descritivo do indicador.
#' @param labels Data frame com as colunas `bloco_var`, `bloco_nome`,
#'   `grupo_code` e `grupo_nome`, usado para rotular os blocos e grupos do
#'   indicador.
#'
#' @return Tibble com os resultados de `config$fn()` por bloco, grupo e ano,
#'   acrescido das colunas de identificacao do indicador, rotulos de bloco e
#'   grupo, nome da serie, unidade e valor.
#'
#' @examples
#' data <- tibble(
#'   total = 1,
#'   catadm_it = 4,
#'   fx_ranking = 5,
#'   fx_pct_ead = 2,
#'   ano = c(2023, 2023),
#'   qt_doc_exe = c(10, 20),
#'   qt_doc_ex_int = c(4, 10),
#'   qt_mat = c(100, 260)
#' )
#'
#' config <- list(
#'   id = "G0",
#'   name = "Exemplo",
#'   fn = function(df) {
#'     summarise(
#'       df,
#'       qt_doc_exe = sum(qt_doc_exe),
#'       qt_doc_ex_int = sum(qt_doc_ex_int),
#'       qt_mat = sum(qt_mat),
#'       .groups = "drop"
#'     )
#'   }
#' )
#'
#' labels <- tibble(
#'   bloco_var = c("total", "catadm_it", "fx_ranking", "fx_pct_ead"),
#'   bloco_nome = c(
#'     "Total",
#'     "Categoria Administrativa",
#'     "Tamanho da mantenedora",
#'     "Percentual de matriculas na educacao a distancia"
#'   ),
#'   grupo_code = c(1, 4, 5, 2),
#'   grupo_nome = c(
#'     "Total",
#'     "Privada com fins lucrativos",
#'     "Demais mantenedoras",
#'     "Mais de 0% e ate 33% das matriculas"
#'   )
#' )
#'
#' calcula_dimensao_G(data, config, labels)
calcula_dimensao_G <- function(data, config, labels){

  fn <- config[['fn']]
  by <- c('total', 'catadm_it', 'fx_ranking', 'fx_pct_ead') |> set_names()

  map(
    .x = by,
    .f = \(by_var)
      data |>
        rename(grupo_code = all_of(by_var)) |>
        filter(!is.na(grupo_code)) |>
        group_by(grupo_code, ano) |> 
        fn() |>
    mutate(
      across(
        any_of(matches('^qt_doc')), ~ 100 * .x / qt_doc_exe, 
        .names = "{sub('^qt', 'pct', .col)}"
      ),
      across(any_of('qt_mat'), ~  .x / qt_doc_exe, .names = "tx_mat_por_doc_ex")
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
        str_detect(serie_var, 'doc_exe$') ~ 'Docentes em exercício',
        str_detect(serie_var, 'doc_ex_int$') ~ 'Docentes em exercício em tempo integral',
        str_detect(serie_var, 'doc_ex_parc$') ~ 'Docentes em exercício em tempo parcial',
        str_detect(serie_var, 'doc_ex_hor$') ~ 'Docentes em exercício horistas', 
        str_detect(serie_var, 'doc_ex_sempg$') ~ 'Docentes em exercício sem pós graduação',
        str_detect(serie_var, 'doc_ex_esp$') ~ 'Docentes em exercício com especialização',
        str_detect(serie_var, 'doc_ex_mest$') ~ 'Docentes em exercício com mestrado',
        str_detect(serie_var, 'doc_ex_dout$') ~ 'Docentes em exercício com doutorado', 
        serie_var == 'qt_mat' ~ 'Matrículas', 
        serie_var == 'tx_mat_por_doc_ex' ~ 'Matrículas por docente em exercício'     
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


