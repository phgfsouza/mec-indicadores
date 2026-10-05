#==============================================================================#
# Convert numeric vectors to integer when lossless
# Pedro HGF Souza
# June/2026
#==============================================================================#

as_integer_if_possible <- function(x) {

  if (!is.numeric(x) || is.integer(x)) {
    return(x)
  }

  # Integers cannot represent NaN or infinite values without information loss.
  if (any(is.nan(x)) || any(is.infinite(x))) {
    return(x)
  }

  observed_values <- x[!is.na(x)]

  can_be_integer <- all(abs(observed_values) <= .Machine$integer.max) &&
    all(observed_values == trunc(observed_values))

  if (can_be_integer) {
    return(as.integer(x))
  }

  x
}
