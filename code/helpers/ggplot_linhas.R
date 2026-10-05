
ggplot_linhas <- function(
  data, 
  x, 
  y, 
  color, 
  label = NULL,
  geom_line_width = 1.2,
  geom_point_size = 4.5,
  geom_text_size = 7,
  geom_text_nudge_y = 0,
  geom_text_nudge_x = 0,
  x_title = 'Ano',
  x_limits = c(2010, 2024),
  x_breaks = seq(2010, 2024, 2),
  y_title = NULL,
  y_limits = NULL,
  y_breaks = NULL,
  color_values = ggplot_cores()
) {

  # Configuracoes
  if( is.null(y_breaks) ) y_breaks <- y_limits
  label_quo   <- enquo(label)
  show_labels <- !quo_is_null(label_quo)
  hline_yintercept <- min(y_limits)

  config <- list(
    geom_line(linewidth = geom_line_width),
    geom_point(size = geom_point_size),
    if (show_labels) {
      geom_text(
        aes(label = !!label_quo),
        size = geom_text_size,
        nudge_y = geom_text_nudge_y,
        nudge_x = geom_text_nudge_x,
        show.legend = FALSE
      )
    },
    geom_hline(yintercept = hline_yintercept, color = "grey60", linewidth = 0.5),
    scale_x_continuous(name = x_title, limits = x_limits, breaks = x_breaks),
    scale_y_continuous(name = y_title, limits = y_limits, breaks = y_breaks),
    scale_color_manual(values = color_values),
    labs(x = x_title, y = y_title)
  )

  # Plot
  data |> ggplot(aes(x = {{x}}, y = {{y}}, color = {{color}})) + config 

}