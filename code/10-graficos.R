#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Graficos para relatorio descritivo
# Pedro HGF Souza 
# Junho/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# to do

# CONFIGURACAO =================================================================

source('code/_setup.R')

# PRE-PROCESSAMENTO ============================================================

## Importacao dos inputs -------------------------------------------------------

indicadores <- map(
  .x = list.files(here('results'), 'indicador') |> set_names(),
  .f = ~ read_csv(here('results', .x))
)

## Pre-processamento de variaveis ----------------------------------------------

indicadores <- map(
  .x = indicadores,
  .f = ~ .x |> mutate(across(matches('nome$'), fct_inorder))
)

## Inicializacao ---------------------------------------------------------------

gfx.data   <- list()
gfx.plots  <- list()

# DIMENSAO A ===================================================================

## Figura 01 -------------------------------------------------------------------

# Titulo: 
# Quantidade de mantenedoras e de IES, 2010/2024

# Descricao:
# Grafico de linhas com series para o numero absoluto de mantenedoras e de IES 
# em cada ano.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA1.csv |> 
  filter(bloco_var == 'total' & serie_var %in% c('qt_ies', 'qt_mantenedoras')) |> 
  mutate(lbl = if_else(ano %in% c(2010, 2017, 2024), as.character(valor), "")) |>
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]]  <- ggplot_linhas(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    color = serie_nome, 
    label = lbl, 
    geom_text_nudge_y = 200,
    y_title =  'Instituições (quantidade)',
    y_limits = c(0, 3000)
  ) + 
  ggplot_tema()
  
## Figura 02 -------------------------------------------------------------------

# Titulo:
# Quantidade de IES por categoria administrativa, 2010/2024

# Descricao:
# Grafico de linhas com series para o numero absoluto de IES por  categoria 
# administrativa (federal, estadual, municipal, sem fins lucrativos e com fins 
# lucrativos) em cada ano.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA1.csv |> 
  filter(bloco_var == 'catadm_it' & serie_var == 'qt_ies') |>
  mutate(
    lbl = case_when(
      ano %in% c(2010, 2017, 2024) & str_detect(grupo_nome, 'Privada') ~ as.character(valor), 
      ano %in% c(2010, 2017, 2024) & str_detect(grupo_nome, 'Estadual') ~ as.character(valor), 
    )
  ) |> 
  arrange(grupo_nome, ano)
  
gfx.plots[[nome]] <- ggplot_linhas(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    color = grupo_nome, 
    label = lbl, 
    geom_text_nudge_y = 80,
    y_title =  'IES (quantidade)',
    y_limits = c(0, 1900)
  ) + 
  ggplot_tema(
    legend_text_size = 18,
    legend_key_spacing = 0,
    legend_key_height = .9,
    legend_position_inside =  c(0.20, 0.85)
  )
  
## Figura 03 -------------------------------------------------------------------

# Titulo:
# Quantidade de vagas oferecidas por modalidade de ensino, 2010/2024

# Descricao:
# Grafico de barras empilhadas com series para numero absoluto de vagas ofertadas 
# por modalidade de ensino (Presencial e EaD) em cada ano.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA2.csv |> 
  filter(bloco_var == 'tp_modalidade_ensino' & serie_var == 'qt_vg_total') |>
  mutate(
    unidade = paste(unidade, '(milhões)'),
    valor = valor / 10^6,
    lbl = if_else(ano %in% c(2010, 2017, 2024), sprintf('%.1f', valor),  "")
  ) |> 
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]] <- ggplot_barras(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    fill = grupo_nome, 
    label = lbl, 
    geom_text_size = 6,
    total_text_size = 7.5,
    y_title =  'Vagas ofertadas (milhões)',
    y_limits = c(0, 25)
  ) + 
  ggplot_tema(legend_position_inside =  c(0.20, 0.90))

## Figura 04 -------------------------------------------------------------------

# Titulo:
# Taxa de ocupacao de vagas por modalidade de ensino, 2010/2024

# Descricao:
# Grafico de linhas com series para a taxa de ocupacao (razaoentre o 
# total de ingressantes para cada 100 vagas oferecidas) para o sistema como um 
# todo e por modalidade de ensino em cada ano. 

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA2.csv |> 
  filter(serie_var == 'tx_ocupacao_vaga') |>
  mutate(lbl = if_else(ano %in% c(2010, 2017, 2024), sprintf('%.1f', valor), "")) |> 
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]] <- ggplot_linhas(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    color = grupo_nome, 
    label = lbl, 
    geom_text_nudge_y = c(rep(-4, 14), rep(4, 16), rep(-4, 15)),
    y_title =  'Taxa de ocupação das vagas (%)',
    y_limits = c(0, 70)
  ) + 
  ggplot_tema(legend_position_inside = c(.825, .875))

## Figura 05 -------------------------------------------------------------------

# Titulo: 
# Quantidade de ingressantes por modalidade de ensino e turno, 2010/2024

# Descricao:
# Graficos de barras empilhadas com o numero absoluto de ingressantes por 
# modalidade e turno (Presencial - Diurno, Presencial - Noturno e EaD) em cada 
# ano.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA3.csv |> 
  filter(bloco_var == 'turno' & serie_var == 'qt_ing') |>
  mutate(
    unidade = paste(unidade, '(milhões)'),
    valor = valor / 10^6,
    lbl = if_else(ano %in% c(2010, 2017, 2024), sprintf('%.1f', valor),  ""),
  ) |> 
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]] <- ggplot_barras(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    fill = grupo_nome, 
    label = lbl, 
    geom_text_size = 6,
    total_text_size = 7.5,
    y_title =  'Ingressantes (milhões)',
    y_limits = c(0, 6)
  ) + 
  ggplot_tema(legend_position_inside =  c(0.20, 0.85))


## Figura 06 -------------------------------------------------------------------

# Titulo: 
# Quantidade de matriculas por modalidade de ensino e turno, 2010/2024

# Descricao:
# Graficos de barras empilhadas com o numero absoluto de matriculas por 
# modalidade e turno (Presencial - Diurno, Presencial - Noturno e EaD) em cada 
# ano.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA3.csv |> 
  filter(bloco_var == 'turno' & serie_var == 'qt_mat') |>
  mutate(
    unidade = paste(unidade, '(milhões)'),
    valor = valor / 10^6,
    lbl = if_else(ano %in% c(2010, 2017, 2024), sprintf('%.1f', valor),  ""),
  ) |> 
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]] <- ggplot_barras(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    fill = grupo_nome, 
    label = lbl, 
    geom_text_size = 6,
    total_text_size = 7.5,
    y_title =  'Matrículas (milhões)',
    y_limits = c(0, 12)
  ) + 
  ggplot_tema(legend_position_inside =  c(0.20, 0.85))

## Figura 07 -------------------------------------------------------------------

# Titulo:
# Quantidade de ingressantes por faixas de tamanho de mantenedoras, 2010/2024

# Descricao:
# Graficos de barras empilhadas com o numero absoluto de ingressantes por 
# por faixas de tamanho de mantenedoras (Top 5, 6-10, 11-15, 16-20 e demais) 
# em cada ano. 

# Notas:
# As faixas de tamanho de mantenedoras sao baseadas na quantidade de matriculas e
# em rankings recalculados em cada ano e, portanto, nao representam as mesmas 
# mantenedoras ao longo do tempo.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA4.csv |> 
  filter(bloco_var == 'fx_ranking' & serie_var == 'qt_ing') |>
  mutate(
    unidade = paste(unidade, '(milhões)'),
    valor = valor / 10^6,
    lbl = if_else(ano %in% c(2010, 2017, 2024), sprintf('%.1f', valor),  ""),
  ) |> 
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]] <- ggplot_barras(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    fill = grupo_nome, 
    label = lbl, 
    geom_text_size = 6,
    total_text_size = 7.5,
    y_title = 'Ingressantes (milhões)',
    y_limits = c(0, 6)
  ) + 
  ggplot_tema(
    legend_text_size = 18,
    legend_key_spacing = 0,
    legend_key_height = .9,
    legend_position_inside =  c(0.20, 0.825)
  )

## Figura 08 -------------------------------------------------------------------

# Titulo:
# Quantidade de matriculas por faixas de tamanho de mantenedoras, 2010/2024

# Descricao:
# Graficos de barras empilhadas com o numero absoluto de matriculas por 
# por faixas de tamanho de mantenedoras (Top 5, 6-10, 11-15, 16-20 e demais) 
# em cada ano. 

# Notas:
# As faixas de tamanho de mantenedoras sao baseadas na quantidade de matriculas e
# em rankings recalculados em cada ano e, portanto, nao representam as mesmas 
# mantenedoras ao longo do tempo.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA4.csv |> 
  filter(bloco_var == 'fx_ranking' & serie_var == 'qt_mat') |>
  mutate(
    unidade = paste(unidade, '(milhões)'),
    valor = valor / 10^6,
    lbl = if_else(ano %in% c(2010, 2017, 2024), sprintf('%.1f', valor),  ""),
  ) |> 
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]] <- ggplot_barras(
    data = gfx.data[[nome]],
    x = ano,
    y = valor,
    fill = grupo_nome, 
    label = lbl, 
    geom_text_size = 6,
    total_text_size = 7.5,
    y_title = 'Matrículas (milhões)',
    y_limits = c(0, 12)
  ) + 
  ggplot_tema(
    legend_text_size = 18,
    legend_key_spacing = 0,
    legend_key_height = .9,
    legend_position_inside =  c(0.20, 0.825)
  )

## Figura 09 -------------------------------------------------------------------

# Titulo:
# Quantidade de ingressantes por area do conhecimento - Brasil, 2010, 2017 e 2024

# Descricao:
# Lollipop chart com numero absoluto de ingressantes por area do conhecimento
# CINE Brasil (11 areas) em anos selecionados.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA5.csv |> 
  filter(
    bloco_var == 'co_cine_area_geral' & 
    serie_var == 'qt_ing' &
      ano %in% c(2010, 2017, 2024)
  ) |>
  mutate(
    unidade = paste(unidade, '(milhões)'),
    valor = valor / 10^6,
    grupo_nome = fct_reorder(grupo_nome, (ano == 2024) * valor, max),
    ano = factor(ano)
  ) |> 
  arrange(grupo_nome, serie_nome, ano)

gfx.plots[[nome]] <- gfx.data[[nome]] |>
  ggplot(aes(x = grupo_nome, y = valor, group = grupo_nome, color = ano)) +
  geom_line(color = "black", linewidth = .5) +
  geom_point(size = 5) +
  scale_y_continuous(limits = c(0, 1.6), breaks = seq(0, 1.6, .2)) +
  scale_x_discrete(labels = \(x) str_wrap(x, width = 28)) + 
  scale_color_manual(values = ggplot_cores()) +
  labs(x = NULL, y = 'Ingressantes (milhões)') + 
  coord_flip() +
  ggplot_tema(
    legend_position_inside = c(.875, .125),
    axis_text_size_y = 18,
    show_major_grid = TRUE
  ) + 
  theme(axis.text.y = element_text(hjust = 0.5))

## Figura 10 -------------------------------------------------------------------

# Titulo:
# Participação do EaD entre os ingressantes de cada área do conhecimento - Brasil, 
# 2010, 2017 e 2024

# Descricao:
# Lollipop chart com o percentual de ingressantes na modalidade EaD por area do
# conhecimento CINE Brasil (11 areas) em anos selecionados.

nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

gfx.data[[nome]] <- indicadores$indicadorA5.csv |> 
  filter(
    bloco_var == 'co_cine_area_geral_tp_modalidade_ensino' & 
    serie_var == 'pct_ing' & 
    ano %in% c(2010, 2017, 2024)
  ) |> 
  separate_wider_delim(grupo_nome, ' - ', names = c('grupo_nome', 'modalidade')) |> 
  mutate(valor = 100 * valor / sum(valor), .by = c(ano, grupo_nome)) |>
  filter(modalidade == 'Presencial') |> 
  mutate(
    valor = 100 - valor, 
    grupo_nome = fct_reorder(grupo_nome, (ano == 2024) * valor, max),
    ano = factor(ano),
    serie_var = 'qt_ing_ead',
    serie_nome = 'Ingressantes no Ensino à Distância'
  ) |> 
  arrange(grupo_nome, serie_nome, ano) 

gfx.plots[[nome]] <- gfx.data[[nome]] |>
  ggplot(aes(x = grupo_nome, y = valor, group = grupo_nome, color = ano)) +
  geom_line(color = "black", linewidth = .5) +
  geom_point(size = 5) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 10)) +
  scale_x_discrete(labels = \(x) str_wrap(x, width = 28)) + 
  scale_color_manual(values = ggplot_cores()) +
  labs(x = NULL, y = 'Ingressantes no Ensino à Distância (%)') + 
  coord_flip() +
  ggplot_tema(
    legend_position_inside = c(.875, .125),
    axis_text_size_y = 18,
    show_major_grid = TRUE
  ) + 
  theme(axis.text.y = element_text(hjust = 0.5))


# DIMENSAO B ===================================================================

# ## Figura 11 -------------------------------------------------------------------

# # Titulo:
# # Variacao do total de ingressantes por categoria administrativa, modalidade de 
# # ensino e turno - Brasil, 2010 e 2024

# # Descricao:
# # Graficos de barras empilhadas horizontais a variacao do numero total de 
# # ingressantes por categoria administrativa, modalidade de ensino e turno para 
# # o periodo 2010-2024.

# nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

# gfx.data[[nome]] <- indicadores$indicadorB1.csv |>
#   filter(
#     bloco_var == 'catadm_it_turno' & 
#     serie_var == 'delta_qt_ing' & 
#     periodo %in% c('2010-2024')
#   ) |>
#   separate_wider_delim(
#     grupo_nome,
#     delim = " - ",
#     names = c("grupo_nome_1", "grupo_nome_2"),
#     too_many = "merge"
#   ) |> 
#     mutate(
#       grupo_nome_1 = fct_rev(fct_inorder(grupo_nome_1)),
#       grupo_nome_2 = fct_rev(fct_inorder(grupo_nome_2)),
#       valor = valor / 10^3,
#       unidade = paste(unidade, '(milhares)'),
#       lbl = if_else(abs(valor) > 300, sprintf('%.0f', valor), "")
#   )

# gfx.plots[[nome]] <- ggplot_barras(
#     data = gfx.data[[nome]],
#     x = grupo_nome_1,
#     y = valor,
#     fill = grupo_nome_2, 
#     label = lbl, 
#     geom_text_size = 6,
#     total_text_size = 7.5,
#     total_text_vjust = -0.2,
#     x_title = 'Categoria administrativa',
#     y_title = 'Variação no total de ingressantes (milhares)',
#     y_limits = c(-900, 3200),
#     y_breaks = c(-900, 0, 3200),
#     flip = TRUE,
#     total_selection = 'all_vars',
#     total_mode = 'net',
#     total_digits = 0
#   ) + 
#   geom_hline(yintercept = 0, colour = "black", linewidth = 0.6) +
#   ggplot_tema(
#     legend_position_inside =  c(0.775, 0.875)
#   ) + 
#   scale_x_discrete(labels = \(x) str_wrap(x, width = 18)) + 
#   theme(axis.text.y = element_text(hjust = 0.5))


# ## Figura 12 -------------------------------------------------------------------

# # Titulo:
# # Variacao do total de matriculas por categoria administrativa, modalidade de 
# # ensino e turno - Brasil, 2010 e 2024

# # Descricao:
# # Graficos de barras empilhadas horizontais a variacao do numero total de 
# # matriculas por categoria administrativa, modalidade de ensino e turno para 
# # o periodo 2010-2024.

# nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

# gfx.data[[nome]] <- indicadores$indicadorB1.csv |>
#   filter(
#     bloco_var == 'catadm_it_turno' & 
#     serie_var == 'delta_qt_mat' & 
#     periodo %in% c('2010-2024')
#   ) |>
#   separate_wider_delim(
#     grupo_nome,
#     delim = " - ",
#     names = c("grupo_nome_1", "grupo_nome_2"),
#     too_many = "merge"
#   ) |> 
#     mutate(
#       grupo_nome_1 = fct_rev(fct_inorder(grupo_nome_1)),
#       grupo_nome_2 = fct_rev(fct_inorder(grupo_nome_2)),
#       valor = valor / 10^3,
#       unidade = paste(unidade, '(milhares)'),
#       lbl = if_else(abs(valor) > 300, sprintf('%.0f', valor), "")
#   )

# gfx.plots[[nome]] <- ggplot_barras(
#     data = gfx.data[[nome]],
#     x = grupo_nome_1,
#     y = valor,
#     fill = grupo_nome_2, 
#     label = lbl, 
#     geom_text_size = 6,
#     total_text_size = 7.5,
#     total_text_vjust = -0.2,
#     x_title = 'Categoria administrativa',
#     y_title = 'Variação no total de matrículas (milhares)',
#     y_limits = c(-2000, 5000),
#     y_breaks = c(-2000, 0, 5000),
#     flip = TRUE,
#     total_selection = 'all_vars',
#     total_mode = 'net',
#     total_digits = 0
#   ) + 
#   geom_hline(yintercept = 0, colour = "black", linewidth = 0.6) +
#   ggplot_tema(legend_position_inside =  c(0.775, 0.875)) + 
#   scale_x_discrete(labels = \(x) str_wrap(x, width = 18)) + 
#   theme(axis.text.y = element_text(hjust = 0.5))

# ## Figura 13 -------------------------------------------------------------------

# # Titulo:
# # Variacao do total de ingressantes por area do conhecimento, modalidade de 
# # ensino e turno - Brasil, 2010 e 2024

# # Descricao:
# # Graficos de barras empilhadas horizontais a variacao do numero total de 
# # ingressantes por area do conhecimento, modalidade de ensino e turno para 
# # o periodo 2010-2024.

# nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

# gfx.data[[nome]] <- indicadores$indicadorB2.csv |> 
#   filter(
#     bloco_var == 'co_cine_area_geral_turno' & 
#     serie_var == 'delta_qt_ing' & 
#     periodo %in% c('2010-2024')
#   ) |>
#   separate_wider_delim(
#     grupo_nome,
#     delim = " - ",
#     names = c("grupo_nome_1", "grupo_nome_2"),
#     too_many = "merge"
#   ) |> 
#     mutate(
#       grupo_code_agregado = floor(grupo_code / 100),
#       grupo_nome_1 = fct_rev(fct_inorder(grupo_nome_1)),
#       grupo_nome_2 = fct_rev(fct_inorder(grupo_nome_2)),
#       valor = valor / 10^3,
#       unidade = paste(unidade, '(milhares)'),
#       lbl = if_else(abs(valor) > 300, sprintf('%.0f', valor), "")
#   ) |>
#   mutate(total = sum(valor), .by = grupo_code_agregado) |>
#   arrange(desc(total), grupo_nome_2) |> 
#   mutate(grupo_nome_1 = fct_rev(fct_inorder(grupo_nome_1))) |> 
#   select(-total) 

# gfx.plots[[nome]] <- ggplot_barras(
#     data = gfx.data[[nome]],
#     x = grupo_nome_1,
#     y = valor,
#     fill = grupo_nome_2, 
#     label = lbl, 
#     geom_text_size = 6,
#     total_text_size = 7.5,
#     total_text_vjust = -0.2,
#     x_title = 'Área do conhecimento',
#     y_title = 'Variação no total de ingressantes (milhares)',
#     y_limits = c(-250, 1000),
#     y_breaks = c(-250, 0, 1000),
#     flip = TRUE,
#     total_selection = 'all_vars',
#     total_mode = 'net',
#     total_digits = 0
#   ) + 
#   geom_hline(yintercept = 0, colour = "black", linewidth = 0.6) +
#   ggplot_tema(
#     axis_text_size_y = 18,
#     legend_position_inside =  c(0.725, 0.125)
#   ) + 
#   scale_x_discrete(labels = \(x) str_wrap(x, width = 24)) + 
#   theme(axis.text.y = element_text(hjust = 0.5))


# ## Figura 14 -------------------------------------------------------------------

# # Titulo:
# # Variacao do total de matriculas por area do conhecimento, modalidade de 
# # ensino e turno - Brasil, 2010 e 2024

# # Descricao:
# # Graficos de barras empilhadas horizontais a variacao do numero total de 
# # matriculas por area do conhecimento, modalidade de ensino e turno para 
# # o periodo 2010-2024.

# nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

# gfx.data[[nome]] <- indicadores$indicadorB2.csv |> 
#   filter(
#     bloco_var == 'co_cine_area_geral_turno' & 
#     serie_var == 'delta_qt_mat' & 
#     periodo %in% c('2010-2024')
#   ) |>
#   separate_wider_delim(
#     grupo_nome,
#     delim = " - ",
#     names = c("grupo_nome_1", "grupo_nome_2"),
#     too_many = "merge"
#   ) |> 
#     mutate(
#       grupo_code_agregado = floor(grupo_code / 100),
#       grupo_nome_1 = fct_rev(fct_inorder(grupo_nome_1)),
#       grupo_nome_2 = fct_rev(fct_inorder(grupo_nome_2)),
#       valor = valor / 10^3,
#       unidade = paste(unidade, '(milhares)'),
#       lbl = if_else(abs(valor) > 300, sprintf('%.0f', valor), "")
#   ) |>
#   mutate(total = sum(valor), .by = grupo_code_agregado) |>
#   arrange(desc(total), grupo_nome_2) |> 
#   mutate(grupo_nome_1 = fct_rev(fct_inorder(grupo_nome_1))) |> 
#   select(-total) 

# gfx.plots[[nome]] <- ggplot_barras(
#     data = gfx.data[[nome]],
#     x = grupo_nome_1,
#     y = valor,
#     fill = grupo_nome_2, 
#     label = lbl, 
#     geom_text_size = 6,
#     total_text_size = 7.5,
#     total_text_vjust = -0.2,
#     x_title = 'Área do conhecimento',
#     y_title = 'Variação no total de matrículas (milhares)',
#     y_limits = c(-1000, 2000),
#     y_breaks = c(-1000, 0, 2000),
#     flip = TRUE,
#     total_selection = 'all_vars',
#     total_mode = 'net',
#     total_digits = 0
#   ) + 
#   geom_hline(yintercept = 0, colour = "black", linewidth = 0.6) +
#   ggplot_tema(
#     axis_text_size_y = 18,
#     legend_position_inside =  c(0.725, 0.125)
#   ) + 
#   scale_x_discrete(labels = \(x) str_wrap(x, width = 24)) + 
#   theme(axis.text.y = element_text(hjust = 0.5))

# ## Figura 15 --------------------------------------------------------------------

# # Titulo:
# # Variacao do total de ingressantes por faixas de tamanho de mantenedoras, 
# # modalidade de ensino e turno - Brasil, 2010 e 2024

# # Descricao:
# # Graficos de barras empilhadas horizontais a variacao do numero total de 
# # ingressantes por faixas de tamanho de mantenedoras, modalidade de ensino e 
# # turno para o periodo 2010-2024.

# nome <- paste0('figura', sprintf('%02d', length(gfx.data) + 1))

# gfx.data[[nome]] <- indicadores$indicadorB3.csv |>
#   filter(
#     bloco_var == 'fx_ranking_turno' & 
#     serie_var == 'delta_qt_ing' & 
#     periodo %in% c('2010-2024')
#   ) |>
#   separate_wider_delim(
#     grupo_nome,
#     delim = " - ",
#     names = c("grupo_nome_1", "grupo_nome_2"),
#     too_many = "merge"
#   ) |> 
#     mutate(
#       grupo_nome_1 = fct_rev(fct_inorder(grupo_nome_1)),
#       grupo_nome_2 = fct_rev(fct_inorder(grupo_nome_2)),
#       valor = valor / 10^3,
#       unidade = paste(unidade, '(milhares)'),
#       lbl = if_else(abs(valor) > 300, sprintf('%.0f', valor), "")
#   )

# gfx.plots[[nome]] <- ggplot_barras(
#     data = gfx.data[[nome]],
#     x = grupo_nome_1,
#     y = valor,
#     fill = grupo_nome_2, 
#     label = lbl, 
#     geom_text_size = 6,
#     total_text_size = 7.5,
#     total_text_vjust = -0.2,
#     x_title = 'Faixas de tamanho',
#     y_title = 'Variação no total de ingressantes (milhares)',
#     y_limits = c(-900, 3200),
#     y_breaks = c(-900, 0, 3200),
#     flip = TRUE,
#     total_selection = 'all_vars',
#     total_mode = 'net',
#     total_digits = 0
#   ) + 
#   geom_hline(yintercept = 0, colour = "black", linewidth = 0.6) +
#   ggplot_tema(
#     legend_position_inside =  c(0.775, 0.875)
#   ) + 
#   scale_x_discrete(labels = \(x) str_wrap(x, width = 18)) + 
#   theme(axis.text.y = element_text(hjust = 0.5))


# OUTPUTS ======================================================================

# Graficos
pmap(
  .l = expand_grid(gfx = names(gfx.plots),  fmt = c('.pdf', '.svg', '.png')),
  .f = \(gfx, fmt)
    ggsave(
      filename = here('produtos/relatorio/figuras', paste0(gfx, fmt)),
      plot = gfx.plots[[gfx]],
      height = 8,
      width = 12, 
      dpi = 300
    )
)

# Objetos ggplot
walk(
  .x = names(gfx.plots), 
  ~ saveRDS(gfx.plots[[.x]], here('produtos/relatorio/figuras', paste0(.x, '.rds')))
)

# Planilhas
walk(
  .x = names(gfx.data), 
  .f = ~ write_csv(gfx.data[[.x]], here('produtos/relatorio/figuras', paste0(.x, '.csv')))
)
