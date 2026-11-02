#' Imputa valores ausentes ou invalidos de uma coluna
#'
#' Primeiro, preenche valores invalidos de `x` com valores validos de `y`,
#' quando houver sobreposicao valida e todas as posicoes comparaveis forem
#' iguais. Depois, preenche lacunas internas de `x` quando os valores validos
#' mais proximos antes e depois da lacuna forem iguais. Esta segunda etapa
#' ocorre mesmo quando `y` for incompativel, usando o resultado da primeira.
#'
#' @param data Data frame com as colunas a utilizar.
#' @param x Coluna numerica ou character a preencher, informada sem aspas.
#' @param y Coluna de referencia, informada sem aspas, ou NULL. Deve ter tipo
#'   compativel com `x`; inteiros e decimais podem ser comparados entre si.
#' @param .by Colunas de agrupamento, na sintaxe do mutate(), ou NULL.
#'   Sem agrupamento, considera toda a tabela.
#'
#' @return A tabela com apenas `x` atualizada, preservando a ordem das linhas.
#'   NA, NaN, Inf e -Inf sao invalidos; zero e strings vazias sao validos.
#'   Vetores logical contendo apenas NA sao aceitos como ausentes.
#'   Nao preenche lacunas nas pontas nem entre limites diferentes.
#'   A ordem atual das linhas define antes e depois dentro de cada grupo;
#'   ordene a tabela previamente se a imputacao depender de uma ordem temporal.
#'
#' @examples
#' dados <- data.frame(id = c(1, 1, 1), valor = c(1, NA, 1))
#' imputa_valores(dados, valor, .by = id)
#' # traj |> imputa_valores(tp_modalidade_ensino,
#' #                        tp_modalidade_ensino_traj,
#' #                        .by = c(co_curso, coorte))
imputa_valores <- function(data, x, y = NULL, .by = NULL) {

  if (!is.data.frame(data)) {
    stop("`data` precisa ser um data frame.", call. = FALSE)
  }

  coluna_x <- rlang::enquo(x)
  coluna_y <- rlang::enquo(y)

  if (!rlang::quo_is_symbol(coluna_x) ||
      (!rlang::quo_is_null(coluna_y) && !rlang::quo_is_symbol(coluna_y))) {
    stop("Informe nomes de colunas sem aspas em `x` e `y`, ou NULL em `y`.",
         call. = FALSE)
  }

  nome_x <- rlang::as_name(coluna_x)
  nome_y <- if (rlang::quo_is_null(coluna_y)) NULL else rlang::as_name(coluna_y)

  if (!all(c(nome_x, nome_y) %in% names(data))) {
    stop("As colunas informadas em `x` e `y` precisam existir em `data`.",
         call. = FALSE)
  }

  vetor_aceito <- function(vetor) {
    is.null(dim(vetor)) && (
      (is.numeric(vetor) && !is.complex(vetor)) ||
        is.character(vetor) ||
        (is.logical(vetor) && all(is.na(vetor)))
    )
  }

  if (!vetor_aceito(data[[nome_x]]) ||
      (!is.null(nome_y) && !vetor_aceito(data[[nome_y]]))) {
    stop("`x` e `y` precisam ser colunas numericas ou character.", call. = FALSE)
  }

  if (!is.null(nome_y) &&
      ((is.numeric(data[[nome_x]]) && is.character(data[[nome_y]])) ||
       (is.character(data[[nome_x]]) && is.numeric(data[[nome_y]])))) {
    stop("`x` e `y` precisam ter tipos compativeis; numeros e texto nao podem ser comparados.",
         call. = FALSE)
  }

  valores_validos <- function(vetor) {
    if (is.numeric(vetor)) is.finite(vetor) else !is.na(vetor)
  }

  imputa_grupo <- function(valores_x, valores_y) {
    x_valido <- valores_validos(valores_x)

    if (all(x_valido)) {
      return(valores_x)
    }

    if (!is.null(valores_y)) {
      y_valido <- valores_validos(valores_y)
      comparaveis <- x_valido & y_valido
      compativeis <- any(comparaveis) &&
        all(valores_x[comparaveis] == valores_y[comparaveis])

      if (compativeis) {
        preencher <- !x_valido & y_valido
        valores_x[preencher] <- valores_y[preencher]
        x_valido <- valores_validos(valores_x)
      }
    }

    # Cada lacuna e' delimitada pelos valores validos mais proximos.
    posicoes_validas <- which(x_valido)

    if (length(posicoes_validas) >= 2L) {
      lacunas <- which(diff(posicoes_validas) > 1L)

      for (lacuna in lacunas) {
        anterior <- posicoes_validas[lacuna]
        posterior <- posicoes_validas[lacuna + 1L]

        if (valores_x[anterior] == valores_x[posterior]) {
          valores_x[seq.int(anterior + 1L, posterior - 1L)] <- valores_x[anterior]
        }
      }
    }

    valores_x
  }

  dplyr::mutate(
    data,
    !!nome_x := .env$imputa_grupo(
      .data[[nome_x]],
      if (is.null(.env$nome_y)) NULL else .data[[nome_y]]
    ),
    .by = {{ .by }}
  )
}
