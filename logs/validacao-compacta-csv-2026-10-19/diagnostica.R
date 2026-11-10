.libPaths(c('C:/Users/ADM/AppData/Local/R/win-library/4.6', .libPaths()))
invisible(Sys.setlocale('LC_ALL', 'English_United States.utf8'))
library(readr)
library(dplyr)
a <- read_csv('results/indicadorB2.csv', show_col_types = FALSE)
b <- read_csv('logs/validacao-compacta-csv-2026-10-19/csv/indicadorB2.csv', show_col_types = FALSE)
print(all.equal(select(a, -indicador_code, -indicador_nome),
                select(b, -indicador_code, -indicador_nome)))
for (nome in setdiff(names(a), c('indicador_code', 'indicador_nome'))) {
  if (!identical(a[[nome]], b[[nome]])) {
    print(nome)
    print(all.equal(a[[nome]], b[[nome]]))
    if (is.numeric(a[[nome]])) {
      idx <- which(a[[nome]] != b[[nome]])
      print(length(idx))
      print(max(abs(a[[nome]] - b[[nome]]), na.rm = TRUE))
      print(data.frame(a = a[[nome]][head(idx)], b = b[[nome]][head(idx)]))
    }
  }
}
