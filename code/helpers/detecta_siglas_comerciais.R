
#' Detecta siglas comerciais no texto
#'
#' Identifica textos que contem siglas normalmente usadas por sociedades
#' empresarias ou formas juridicas comerciais. Por padrao, a busca e' restrita
#' a S.A. e EIRELI. Quando `restrito = FALSE`, LTDA e LIMITADA tambem sao
#' considerados. O padrao S/A aceita SA sem separador. Os padroes nao sao
#' detectados quando aparecem dentro de uma palavra, inclusive em palavras com
#' letras acentuadas.
#'
#' @param x Vetor `character` ou `factor` com nomes a serem pesquisados.
#' @param restrito Logico escalar. Se `TRUE`, pesquisa somente S.A. e EIRELI.
#'   Se `FALSE`, tambem pesquisa LTDA e LIMITADA.
#'
#' @return Vetor `logical` com o mesmo comprimento de `x`. Retorna `TRUE` para
#'   textos que contem algum dos padroes comerciais, `FALSE` para textos sem
#'   esses padroes e `NA` quando o elemento correspondente de `x` e' `NA`. A
#'   busca e' sensivel a maiusculas e minusculas.
#'
#' @examples
#' detecta_sigla_comercial(c("ESCOLA LTDA", "FUNDACAO X", NA))
#' detecta_sigla_comercial(c("ESCOLA LTDA", "FUNDACAO X"), restrito = FALSE)
#' detecta_sigla_comercial(c("SOCIEDADE S.A.", "EMPRESA EIRELI"))

detecta_sigla_comercial <- function(x, restrito = TRUE) {
  
  if (!is.character(x) && !is.factor(x)) {
    stop("`x` precisa ser character ou factor.", call. = FALSE)
  }
  
  if (!is.logical(restrito) || length(restrito) != 1L || is.na(restrito)) {
    stop("`restrito` precisa ser TRUE ou FALSE.", call. = FALSE)
  }
  
  caractere_substituicao <- intToUtf8(0xFFFD)
  limite_esquerdo <- paste0("(?<![\\p{L}\\p{N}\\?", caractere_substituicao, "])")
  limite_direito <- paste0("(?![\\p{L}\\p{N}\\?", caractere_substituicao, "])")
  
  regex_cfl <- c(
    sa     = paste0(limite_esquerdo, "S\\.?\\s*/?\\s*A\\.?", limite_direito),
    eireli = paste0(limite_esquerdo, "EIRELI", limite_direito),
    ltda   = paste0(limite_esquerdo, "(?:LIMITADA|LTDA\\.?)", limite_direito),
    empresarial = paste0(limite_esquerdo, "EMPRESARIAL", limite_direito)
  )
  
  if (restrito) {
    regex_cfl <- regex_cfl[c("sa", "eireli")]
  }
  
  regex_cfl <- regex_cfl |> 
    paste(collapse = "|")
  
  x_texto <- enc2utf8(as.character(x))
  resultado <- grepl(regex_cfl, x_texto, perl = TRUE)
  resultado[is.na(x_texto)] <- NA
  
  resultado
  
}
