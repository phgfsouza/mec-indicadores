#' Padroniza variaveis de texto
#'
#' Corrige o encoding quando necessario, remove aspas duplas, remove acentos
#' de letras e padroniza o texto em maiusculas. A remocao de acentos usa
#' normalizacao Unicode e apaga apenas marcas combinantes, preservando simbolos
#' como indicadores ordinais e pontuacao.
#'
#' @param x Vetor `character` ou `factor`.
#' @param from Encoding de origem usado por `iconv()` quando o texto nao e'
#'   UTF-8 valido. O padrao e' `"Windows-1252"`, que cobre os acentos latinos
#'   usuais e tambem caracteres de pontuacao comuns nos microdados antigos.
#'
#' @return Vetor `character` com o mesmo comprimento de `x`.
#'
#' @examples
#' padroniza_chr("Fundacao do Municipio - 2o andar")
#' padroniza_chr("FUNDA\u00c7\u00c3O DO MUNIC\u00cdPIO - 2\u00ba ANDAR")

padroniza_chr <- function(x, from = "Windows-1252") {
  
  if (!is.character(x) && !is.factor(x)) {
    stop("`x` precisa ser character ou factor.", call. = FALSE)
  }
  
  if (!is.character(from) || length(from) != 1L || is.na(from)) {
    stop("`from` precisa ser uma string de tamanho 1.", call. = FALSE)
  }
  
  x_cleaned <- as.character(x)
  
  # Corrige encoding quando o texto ainda nao e' UTF-8 valido
  utf8_ok <- stringi::stri_enc_isutf8(x_cleaned)
  converter <- !is.na(x_cleaned) & !utf8_ok
  x_cleaned[converter] <- iconv(x_cleaned[converter], from = from, to = "UTF-8")
  x_cleaned[!converter] <- enc2utf8(x_cleaned[!converter])
  
  # Remove aspas
  x_cleaned <- gsub('"', "", x = x_cleaned, fixed = TRUE)
  
  # Remove acentuacao de letras
  x_cleaned <- x_cleaned |>
    stringi::stri_trans_nfd() |>
    stringi::stri_replace_all_regex("\\p{M}+", "") |>
    stringi::stri_trans_nfc()
  
  # Padroniza em maiusculas
  x_cleaned <- toupper(x_cleaned)
  
  x_cleaned
  
}
