ggplot_barras <- function(
  data,
  x,
  y,
  fill,
  label = NULL,
  show_totals = TRUE,
  geom_col_width = 0.8,
  geom_text_size = 7,
  geom_text_colour = "white",
  geom_text_vjust = 0.5,
  total_text_size = 7,
  total_text_colour = "black",
  total_text_vjust = -0.8,
  total_digits = 1,
  total_selection = c("labeled_vars", "all_vars"),
  total_mode = c("sum", "net", "ends"),
  x_title = "Ano",
  x_limits = NULL,
  x_breaks = NULL,
  y_title = NULL,
  y_limits = NULL,
  y_breaks = NULL,
  fill_title = NULL,
  fill_values = ggplot_cores(),
  flip = FALSE
) {

  # Captura as colunas informadas para reutiliza-las com tidy evaluation.
  x_quo     <- rlang::enquo(x)
  y_quo     <- rlang::enquo(y)
  label_quo <- rlang::enquo(label)

  total_selection <- match.arg(total_selection)
  total_mode <- match.arg(total_mode)

  # Extrai os valores do eixo x para identificar se a escala deve ser continua.
  x_data <- dplyr::pull(data, !!x_quo)

  # Define se os rotulos internos e os totais devem ser exibidos.
  show_labels <- !rlang::quo_is_null(label_quo)
  show_total_labels <- show_totals &&
    (show_labels || total_selection == "all_vars")

  # Usa os limites do eixo y como marcacoes quando elas nao forem informadas.
  if (is.null(y_breaks)) y_breaks <- y_limits

  # Configura uma escala continua e amplia os limites para acomodar as barras.
  if (is.numeric(x_data)) {
    # Define o periodo e as marcacoes padrao para eixos numericos.
    if (is.null(x_limits)) x_limits <- c(2010, 2024)
    if (is.null(x_breaks)) x_breaks <- seq(2010, 2024, 2)

    # Cria a escala numerica que sera adicionada ao grafico.
    x_scale <- scale_x_continuous(
      name = x_title,
      breaks = x_breaks
    )

    # Inclui metade da largura das barras nas extremidades visiveis.
    x_coord_limits <- x_limits + c(-geom_col_width / 2, geom_col_width / 2)

  } else {
    # Configura uma escala discreta e preserva os limites das categorias.
    if (is.null(x_breaks)) x_breaks <- waiver()
    x_scale <- scale_x_discrete(
      name = x_title,
      limits = x_limits,
      breaks = x_breaks
    )

    x_coord_limits <- NULL
  }

  # Define o sistema de coordenadas sem substituir os limites posteriormente.
  plot_coord <- if (flip) {
    coord_flip(
      xlim = x_coord_limits,
      ylim = y_limits,
      clip = "off"
    )
  } else {
    coord_cartesian(
      xlim = x_coord_limits,
      ylim = y_limits,
      clip = "off"
    )
  }

  # Calcula os totais usando todos os segmentos de cada barra.
  if (show_total_labels) {
    total_label_format <- paste0("%.", total_digits, "f")
    total_text_inward_just <- 1 - total_text_vjust

    totals_data <- data |>
      # Agrupa os segmentos que pertencem a cada barra.
      dplyr::group_by(!!x_quo) |>
      # Calcula o saldo liquido e os extremos positivo e negativo.
      dplyr::summarise(
        total = sum(!!y_quo, na.rm = TRUE),
        positive_end = sum(pmax(!!y_quo, 0), na.rm = TRUE),
        negative_end = sum(pmin(!!y_quo, 0), na.rm = TRUE),
        .groups = "drop"
      )

    # Identifica separadamente as barras com algum rotulo interno preenchido.
    if (show_labels) {
      labeled_vars <- data |>
        dplyr::group_by(!!x_quo) |>
        dplyr::summarise(
          has_label = any(
            !is.na(as.character(!!label_quo)) &
              as.character(!!label_quo) != ""
          ),
          .groups = "drop"
        )

      totals_data <- totals_data |>
        dplyr::left_join(labeled_vars, by = rlang::as_name(x_quo))
    } else {
      totals_data <- totals_data |>
        dplyr::mutate(has_label = FALSE)
    }

    # Mantem somente as barras selecionadas para exibicao dos totais.
    if (total_selection == "labeled_vars") {
      totals_data <- totals_data |>
        dplyr::filter(has_label)
    }

    if (total_mode == "ends") {
      # Cria um rotulo para cada extremo nao nulo da pilha divergente.
      totals_data <- totals_data |>
        dplyr::mutate(
          has_nonzero_end = positive_end != 0 | negative_end != 0
        ) |>
        tidyr::pivot_longer(
          cols = c(positive_end, negative_end),
          names_to = "total_side",
          values_to = "total_position"
        ) |>
        dplyr::filter(
          total_position != 0 |
            (!has_nonzero_end & total_side == "positive_end")
        ) |>
        dplyr::mutate(
          total_label_value = total_position,
          total_label_outward_just = dplyr::if_else(
            total_position < 0,
            total_text_inward_just,
            total_text_vjust
          )
        )
    } else if (total_mode == "net") {
      # Posiciona o saldo liquido no extremo externo correspondente.
      totals_data <- totals_data |>
        dplyr::mutate(
          total_position = dplyr::if_else(
            total < 0,
            negative_end,
            positive_end
          ),
          total_label_value = total,
          total_label_outward_just = dplyr::if_else(
            total < 0,
            total_text_inward_just,
            total_text_vjust
          )
        )
    } else {
      # Preserva o posicionamento historico do saldo no proprio valor.
      totals_data <- totals_data |>
        dplyr::mutate(
          total_position = total,
          total_label_value = total,
          total_label_outward_just = total_text_vjust
        )
    }

    # Aplica o afastamento no eixo visual dos valores.
    if (flip) {
      totals_data <- totals_data |>
        dplyr::mutate(
          total_label_hjust = total_label_outward_just,
          total_label_vjust = 0.5
        )
    } else {
      totals_data <- totals_data |>
        dplyr::mutate(
          total_label_hjust = 0.5,
          total_label_vjust = total_label_outward_just
        )
    }

    # Formata os totais e evita a exibicao de zero negativo.
    totals_data <- totals_data |>
      dplyr::mutate(
        total_label_value = dplyr::if_else(
          round(total_label_value, total_digits) == 0,
          0,
          total_label_value
        ),
        total_label = sprintf(total_label_format, total_label_value)
      )
  }

  # Cria o grafico e mapeia os eixos e o preenchimento das barras.
  data |>
    ggplot(aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})) +
    # Desenha as barras, empilhando automaticamente os grupos de preenchimento.
    geom_col(width = geom_col_width) +
    {
      # Adiciona os rotulos no centro de cada segmento quando solicitados.
      if (show_labels) {
        geom_text(
          aes(label = !!label_quo),
          position = position_stack(vjust = geom_text_vjust),
          size = geom_text_size,
          colour = geom_text_colour,
          show.legend = FALSE
        )
      }
    } +
    {
      # Adiciona o valor total acima de cada barra quando solicitado.
      if (show_total_labels) {
        geom_text(
          data = totals_data,
          aes(
            x = !!x_quo,
            y = total_position,
            label = total_label,
            hjust = total_label_hjust,
            vjust = total_label_vjust
          ),
          inherit.aes = FALSE,
          colour = total_text_colour,
          size = total_text_size,
          show.legend = FALSE
        )
      }
    } +
    # Aplica a escala do eixo x definida conforme o tipo da coluna.
    x_scale +
    # Configura o eixo y e reserva espaco superior para os totais.
    scale_y_continuous(
      name = y_title,
      breaks = y_breaks,
      expand = expansion(mult = c(0, 0.08))
    ) +
    # Aplica a paleta manual aos segmentos das barras.
    scale_fill_manual(values = fill_values) +
    # Limita a area visivel sem remover dados e permite desenhar fora do painel.
    plot_coord +
    # Define os titulos dos eixos e da legenda.
    labs(
      x = x_title,
      y = y_title,
      fill = fill_title
    )
}
