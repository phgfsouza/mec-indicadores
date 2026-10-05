
#' Calcula a moda de um vetor
#'
#' Calcula o(s) valor(es) mais frequente(s) de `x`. Por default, cada observacao
#' tem peso 1. Se `w` for informado, a frequencia de cada categoria e' a soma
#' dos pesos das observacoes naquela categoria.
#'
#' @param x Vetor `numeric`, `logical`, `character` ou `factor`.
#' @param w Vetor numerico de pesos, ou `NULL`. Quando informado, precisa ter o
#'   mesmo comprimento de `x`, nao pode ter valores missing, infinitos ou
#'   negativos, e pode ter pesos iguais a zero.
#' @param na.rm Logico de tamanho 1. Se `FALSE`, valores `NA` em `x` entram na
#'   contagem como uma categoria propria. Se `TRUE`, valores `NA` em `x` sao
#'   removidos antes da contagem. `NA` em `w` nunca e' permitido.
#'
#' @return Um escalar, quando ha uma unica moda, ou um vetor, quando ha empate.
#'   Se `x` for `integer` ou `logical`, o resultado e' `integer`. 
#'   Se `x` for `numeric` nao inteiro, o resultado e' `numeric`. 
#'   Se `x` for `character` ou `factor`, o resultado e' `character`. 
#'   Em caso de empate, o resultado e' ordenado do menor para o maior; se `NA` 
#'   estiver entre as modas, ele aparece ao final. Se nao houver observacoes 
#'   validas, ou se todos os pesos validos somarem zero, retorna `integer(0)`,
#'   `numeric(0)` ou `character(0)`, conforme a classe de `x`.
#'
#' @examples
#' moda(c(1, 2, 2, 4, 4, 9, 13, 13))
#' moda(c("b", "a", "b", NA), na.rm = FALSE)
#' moda(c("b", "a", "b", NA), na.rm = TRUE)
#' moda(c("a", "b", "b"), w = c(10, 1, 1))

moda <- function(x, w = NULL, na.rm = FALSE) {
  
  if (!is.numeric(x) && !is.logical(x) && !is.factor(x) && !is.character(x)) {
    stop("`x` precisa ser numeric, logical, factor ou character.", call. = FALSE)
  }
  
  na.rm_ok <- is.logical(na.rm) && length(na.rm) == 1L && !is.na(na.rm)
  
  if (!na.rm_ok) {
    stop("`na.rm` precisa ser TRUE ou FALSE.", call. = FALSE)
  }
  
  x_numerico <- is.numeric(x) || is.logical(x)
  x_inteiro <- is.integer(x) || is.logical(x)
  
  if (x_inteiro) {
    x_valores <- as.integer(x)
    vazio <- integer(0)
  } else if (x_numerico) {
    x_valores <- as.numeric(x)
    vazio <- numeric(0)
  } else {
    x_valores <- as.character(x)
    vazio <- character(0)
  }
  
  if (is.null(w)) {
    
    w_valores <- rep(1, length(x_valores))
    
  } else {
    
    if (!is.numeric(w)) {
      stop("`w` precisa ser numerico.", call. = FALSE)
    }
    
    if (length(x_valores) != length(w)) {
      stop("`x` e `w` precisam ter o mesmo comprimento.", call. = FALSE)
    }
    
    if (any(is.na(w))) {
      stop("`w` nao pode ter valores missing.", call. = FALSE)
    }
    
    if (any(!is.finite(w))) {
      stop("`w` nao pode ter valores infinitos.", call. = FALSE)
    }
    
    if (any(w < 0)) {
      stop("`w` nao pode ter pesos negativos.", call. = FALSE)
    }
    
    w_valores <- w
    
  }
  
  if (na.rm) {
    ok <- !is.na(x_valores)
    x_valores <- x_valores[ok]
    w_valores <- w_valores[ok]
  }
  
  if (length(x_valores) == 0 || sum(w_valores) == 0) {
    return(vazio)
  }
  
  valores <- sort(unique(x_valores[!is.na(x_valores)]))
  
  if (any(is.na(x_valores))) {
    valores <- c(valores, vazio[NA_integer_])
  }
  
  frequencias <- vapply(
    X = valores,
    FUN.VALUE = numeric(1),
    FUN = function(valor) {
      if (is.na(valor)) {
        sum(w_valores[is.na(x_valores)])
      } else {
        sum(w_valores[!is.na(x_valores) & x_valores == valor])
      }
    }
  )
  
  valores[frequencias == max(frequencias)]
  
}
