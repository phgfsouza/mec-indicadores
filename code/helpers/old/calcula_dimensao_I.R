#' Calcula um indicador da dimensao I
#'
#' Aplica a funcao de resumo para cada variavel definida em `config$by`,
#' agrupando tambem pelas colunas geograficas de `config$geo` e pelo ano.
#' Se `config$geo` for `NULL` ou `character(0)`, agrupa apenas por grupo e ano,
#' sem desagregacao geografica.
#' Empilha os blocos calculados e junta os rotulos dos blocos e grupos.
#'
#' Os percentuais de cada variavel `qt_*` usam como denominador a soma das
#' contagens de todos os territorios e grupos do bloco no ano. Para entidades
#' presentes em varios territorios ou grupos, essa soma pode diferir do total
#' nacional de entidades distintas.
#'
#' @param data Data frame com `ano`, as colunas geograficas e de agrupamento
#'   e os dados necessarios para calcular o indicador.
#' @param config Lista com `geo`, vetor `character` com as colunas geograficas,
#'   ou `NULL`/`character(0)` para calcular sem desagregacao geografica;
#'   `by`, vetor `character` nomeado com as variaveis de agrupamento; `fn`,
#'   funcao que recebe os dados agrupados e retorna estatisticas agregadas,
#'   preservando as chaves e removendo o agrupamento; `id`, codigo do indicador;
#'   e `name`, nome descritivo do indicador.
#' @param labels Data frame com as colunas `bloco_var`, `bloco_nome`,
#'   `grupo_code` e `grupo_nome`, usado para rotular os blocos e grupos.
#'
#' @return Tibble com quantidades e percentuais por territorio, bloco, grupo
#'   e ano, acrescido da identificacao do indicador, dos rotulos, da unidade
#'   e do valor. As colunas geograficas mantem a ordem de `config$geo`.
#'
#' @examples
#' data <- tibble(
#'   cod_muni = c(1L, 2L),
#'   nome_muni = c("Municipio A", "Municipio B"),
#'   total = 1L,
#'   ano = c(2023L, 2023L),
#'   qt_mat = c(10, 30)
#' )
#'
#' config <- list(
#'   id = "I0",
#'   name = "Exemplo",
#'   geo = c("cod_muni", "nome_muni"),
#'   by = c(total = "total"),
#'   fn = function(df) {
#'     summarise(df, qt_mat = sum(qt_mat), .groups = "drop")
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
#' calcula_dimensao_I(data, config, labels)
calcula_dimensao_I <- function(data, config, labels){

  fn  <- config[['fn']]
  geo <- config[['geo']]

  map(
    .x = config[['by']],
    .f = \(by_var)
      data |>
        rename(grupo_code = all_of(by_var)) |>
        group_by(across(all_of(geo)), grupo_code, ano) |>
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
          cols = !c(all_of(geo), grupo_code, ano),
          names_to = 'serie_var',
          values_to = 'valor'
        ) |>
        arrange(across(all_of(geo)), grupo_code, serie_var, ano)
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
        str_detect(serie_var, '^(qt|pct)_municipios$') ~ 'AMC de municípios',
        str_detect(serie_var, '^(qt|pct)_mantenedoras') ~ 'Mantenedoras',
        str_detect(serie_var, '^(qt|pct)_ies') ~ 'IES',
        str_detect(serie_var, '^(qt|pct)_cursos') ~ 'Cursos',
        str_detect(serie_var, '^(qt|pct)_vg_total') ~ 'Vagas',
        str_detect(serie_var, '^(qt|pct)_ing') ~ 'Ingressantes',
        str_detect(serie_var, '^(qt|pct)_mat') ~ 'Matrículas',
        str_detect(serie_var, '^(qt|pct)_conc') ~ 'Concluintes',
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
      all_of(geo),
      bloco_var, bloco_nome,
      grupo_code, grupo_nome,
      serie_var, serie_nome,
      unidade,
      ano,
      valor
    )
}
