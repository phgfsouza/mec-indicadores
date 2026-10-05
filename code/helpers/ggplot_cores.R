

ggplot_cores <- function(n = 6){

  if(n > 6){
    stop('`n` tem que ser <= 6.')
  }
  
  cores <- c(
    "#4477AA",
    "#EE6677",
    "#228833",
    "#CCBB44",
    "#66CCEE",
    "#AA3377"
  )

  cores[1:n]
}