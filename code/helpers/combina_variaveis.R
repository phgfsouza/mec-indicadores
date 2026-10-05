#' Combina variaveis categoricas
#'
#' Cria uma variavel que combina os codigos de duas ou mais variaveis
#' categoricas. Cada codigo ocupa duas casas decimais, de modo compativel com
#' os codigos gerados por `combina_rotulos()`.
#'
#' @param x Data frame que contem as variaveis a combinar.
#' @param ... Duas ou mais variaveis de `x`, informadas sem aspas e na ordem em
#'   que seus codigos devem ser combinados.
#'
#' @return O data frame `x` acrescido da variavel combinada.
#'
#' @examples
#' data <- tibble(
#'   categoria = c(1, 2),
#'   modalidade = c(1, 2),
#'   turno = c(1, 3)
#' )
#'
#' combina_variaveis(data, categoria, modalidade)
#' combina_variaveis(data, categoria, modalidade, turno)
combina_variaveis <- function(x, ...) {

  if (!is.data.frame(x)) {
    stop('`x` deve ser um data frame.')
  }

  variaveis <- rlang::enquos(...)

  if (length(variaveis) < 2) {
    stop('`...` deve conter pelo menos duas variaveis.')
  }

  if (!all(map_lgl(variaveis, rlang::quo_is_symbol))) {
    stop('`...` deve conter apenas nomes de variaveis de `x`.')
  }

  nomes_variaveis <- map_chr(variaveis, rlang::as_name)

  if (anyDuplicated(nomes_variaveis) > 0) {
    stop('`...` deve conter variaveis distintas.')
  }

  variaveis_ausentes <- setdiff(nomes_variaveis, names(x))

  if (length(variaveis_ausentes) > 0) {
    stop(
      'Variaveis ausentes em `x`: ',
      paste(variaveis_ausentes, collapse = ', '),
      '.'
    )
  }

  nome_variavel_combinada <- paste(nomes_variaveis, collapse = '_')

  if (nome_variavel_combinada %in% names(x)) {
    stop(
      'A variavel combinada `',
      nome_variavel_combinada,
      '` ja existe em `x`.'
    )
  }

  valores_validos <- map_lgl(
    nomes_variaveis,
    \(var) {
      valores <- x[[var]]

      is.numeric(valores) &&
        !anyNA(valores) &&
        all(is.finite(valores)) &&
        all(valores == floor(valores)) &&
        all(valores >= 0 & valores <= 99)
    }
  )

  if (!all(valores_validos)) {
    stop(
      'Cada variavel em `...` deve conter apenas inteiros ',
      'no intervalo de 0 a 99.'
    )
  }

  limite_inteiro_exato <- 2 ^ 53
  codigo_maximo <- 0

  for (var in nomes_variaveis) {
    maximo <- if (length(x[[var]]) == 0) 0 else max(x[[var]])

    if (codigo_maximo > floor((limite_inteiro_exato - maximo) / 100)) {
      stop(
        'Os codigos combinados excedem o intervalo de inteiros ',
        'exatamente representaveis por R.'
      )
    }

    codigo_maximo <- 100 * codigo_maximo + maximo
  }

  x[[nome_variavel_combinada]] <- reduce(
    x[nomes_variaveis],
    \(codigo, valores) 100 * codigo + valores
  )

  x
}
