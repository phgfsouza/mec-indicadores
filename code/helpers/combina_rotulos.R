#' Combina rotulos de variaveis
#'
#' Gera todas as combinacoes dos grupos das variaveis informadas em `x` e
#' constroi os respectivos codigos e rotulos combinados.
#' Interrompe a execucao se houver codigos duplicados dentro de uma variavel ou
#' se os codigos combinados excederem o intervalo de inteiros exatos do R.
#'
#' @param x Vetor `character` com os nomes das variaveis, na ordem em que seus
#'   codigos e rotulos devem ser combinados.
#' @param source Data frame com os rotulos das variaveis. Deve conter as colunas
#'   `bloco_var`, `bloco_nome`, `grupo_code` e `grupo_nome`. Cada `grupo_code`
#'   deve ser unico dentro de `bloco_var`.
#'
#' @return Tibble com as colunas `bloco_var`, `bloco_nome`, `grupo_code` e
#'   `grupo_nome`, contendo todas as combinacoes dos grupos das variaveis.
#'
#' @examples
#' source <- tibble(
#'   bloco_var = c("a", "a", "b", "b"),
#'   bloco_nome = c("Variavel A", "Variavel A", "Variavel B", "Variavel B"),
#'   grupo_code = c(1, 2, 1, 2),
#'   grupo_nome = c("A1", "A2", "B1", "B2")
#' )
#'
#' combina_rotulos(c("a", "b"), source)
combina_rotulos <- function(x, source) {

  colunas_necessarias <- c(
    'bloco_var', 'bloco_nome', 'grupo_code', 'grupo_nome'
  )

  if (!is.data.frame(source) || !all(colunas_necessarias %in% names(source))) {
    stop(
      '`source` deve ser um data frame com as colunas: ',
      paste(colunas_necessarias, collapse = ', '),
      '.'
    )
  }

  if (!is.character(x) || length(x) == 0 || anyNA(x)) {
    stop('`x` deve ser um vetor character nao vazio e sem valores ausentes.')
  }

  variaveis_ausentes <- setdiff(x, source[['bloco_var']])

  if (length(variaveis_ausentes) > 0) {
    stop(
      'Variaveis ausentes em `source`: ',
      paste(variaveis_ausentes, collapse = ', '),
      '.'
    )
  }

  grupo_code <- source |>
    filter(.data[['bloco_var']] %in% .env$x) |>
    pull(grupo_code)

  grupo_code_valido <- is.numeric(grupo_code) &&
    !anyNA(grupo_code) &&
    all(is.finite(grupo_code)) &&
    all(grupo_code == floor(grupo_code)) &&
    all(grupo_code >= 0 & grupo_code <= 99)

  if (!grupo_code_valido) {
    stop('`grupo_code` deve conter apenas inteiros no intervalo de 0 a 99.')
  }

  codigos_duplicados <- source |>
    count(bloco_var, grupo_code, name = 'n') |>
    filter(n > 1)

  if (nrow(codigos_duplicados) > 0) {
    stop('`grupo_code` deve ser unico dentro de cada `bloco_var`.')
  }

  n_vars <- length(x)

  maximos_grupo_code <- map_dbl(
    x,
    \(var)
      source |>
        filter(.data[['bloco_var']] == .env$var) |>
        summarise(maximo = max(grupo_code)) |>
        pull(maximo)
  )

  limite_inteiro_exato <- 2 ^ 53
  codigo_maximo <- 0

  for (maximo in maximos_grupo_code) {
    if (codigo_maximo > floor((limite_inteiro_exato - maximo) / 100)) {
      stop(
        'Os codigos combinados excedem o intervalo de inteiros ',
        'exatamente representaveis por R.'
      )
    }

    codigo_maximo <- 100 * codigo_maximo + maximo
  }

  rotulos_x <- map2(
    .x = x,
    .y = seq_along(x),
    .f = \(var, i)
      source |>
        filter(.data[['bloco_var']] == .env$var) |>
        select(bloco_nome, grupo_code, grupo_nome) |>
        rename_with(\(nome) paste0(nome, '_x', i))
  )

  expand_grid(!!!unname(rotulos_x)) |>
    mutate(
      bloco_var = paste(x, collapse = '_'),
      bloco_nome = pmap_chr(
        pick(starts_with('bloco_nome_x')),
        paste,
        sep = ' + '
      ),
      grupo_code = drop(
        as.matrix(pick(starts_with('grupo_code_x'))) %*%
          100 ^ rev(seq_len(n_vars) - 1)
      ),
      grupo_nome = pmap_chr(
        pick(starts_with('grupo_nome_x')),
        paste,
        sep = ' - '
      )
    ) |>
    select(bloco_var, bloco_nome, grupo_code, grupo_nome) |>
    arrange(grupo_code)
}
