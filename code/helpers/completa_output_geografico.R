#' Completa as combinacoes geograficas de um output
#'
#' Identifica a geografia pelas colunas compartilhadas entre `df` e `geo`,
#' exceto `ano` e `valor`. Cruza os territorios-anos de `geo` com as
#' combinacoes observadas das demais colunas de `df`, mantendo juntos os
#' blocos, grupos, series e seus rotulos. Grupos inteiramente ausentes de
#' `df` nao sao criados.
#'
#' @param df Output com as colunas geograficas, `ano` e `valor`, antes da
#'   compactacao dos metadados para exportacao.
#' @param geo Referencia com `ano` e as colunas geograficas, com os mesmos
#'   nomes e valores usados em `df`. Outras colunas sao ignoradas.
#' @param preenchimento Valor escalar atribuido somente as linhas novas.
#'
#' @return Output com as combinacoes faltantes, ordenado por bloco, territorio,
#'   grupo, serie e ano, quando essas colunas estiverem presentes.
#'   Preserva as colunas e os valores existentes,
#'   inclusive `NA`. Interrompe se houver chaves duplicadas em `df` ou
#'   territorios-anos de `df` ausentes da referencia.
completa_output_geografico <- function(df, geo, preenchimento = 0){

  if (!is.data.frame(df) || !is.data.frame(geo) ||
      !all(c('ano', 'valor') %in% names(df)) || !'ano' %in% names(geo)) {
    stop('`df` deve conter `ano` e `valor`, e `geo` deve conter `ano`.')
  }

  if (length(preenchimento) != 1L || !is.atomic(preenchimento)) {
    stop('`preenchimento` deve ser um valor escalar.')
  }

  colunas_geo <- setdiff(intersect(names(df), names(geo)), c('ano', 'valor'))

  if (length(colunas_geo) == 0L) {
    stop('Nao ha colunas geograficas compartilhadas entre `df` e `geo`.')
  }

  chaves <- setdiff(names(df), 'valor')
  colunas_territorio <- c(colunas_geo, 'ano')
  colunas_grupo <- setdiff(chaves, colunas_territorio)

  df <- ungroup(df)

  if (anyDuplicated(df[chaves]) > 0L) {
    stop('`df` contem mais de uma linha para a mesma combinacao de chaves.')
  }

  territorios <- geo |>
    ungroup() |>
    distinct(across(all_of(colunas_territorio)))

  fora_referencia <- df |>
    distinct(across(all_of(colunas_territorio))) |>
    anti_join(territorios, by = colunas_territorio)

  if (nrow(fora_referencia) > 0L) {
    stop('Ha territorios-anos de `df` ausentes em `geo`; confira codigos e rotulos.')
  }

  if (nrow(df) == 0L) return(df)

  grupos <- df |>
    distinct(across(all_of(colunas_grupo)))

  faltantes <- expand_grid(territorios, grupos) |>
    anti_join(df, by = chaves) |>
    mutate(valor = preenchimento)

  bind_rows(df, faltantes) |>
    select(all_of(names(df))) |>
    arrange(
      across(any_of('bloco_var')),
      across(all_of(colunas_geo)),
      across(any_of(c('grupo_code', 'serie_var'))),
      ano
    )
}
