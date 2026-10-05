#' Cria um tema personalizado para graficos
#'
#' Retorna uma lista de componentes de tema do `ggplot2` com tamanhos de texto,
#' configuracao e posicionamento da legenda, borda do painel, grades e margens
#' padronizados para os graficos do projeto.
#'
#' @param base_size Tamanho base da fonte usado por `theme_minimal()`.
#' @param axis_title_size Tamanho da fonte dos titulos dos eixos.
#' @param axis_text_size Tamanho da fonte dos rotulos dos eixos.
#' @param legend_text_size Tamanho da fonte dos textos da legenda.
#' @param title_size Tamanho da fonte do titulo do grafico.
#' @param subtitle_size Tamanho pretendido da fonte do subtitulo. Atualmente,
#'   este argumento nao e aplicado ao tema retornado.
#' @param legend_key_width Largura das chaves da legenda, em centimetros.
#' @param legend_key_height Altura das chaves da legenda, em centimetros.
#' @param legend_key_spacing Espacamento vertical entre as chaves da legenda, em
#'   centimetros.
#' @param legend_position Posicao da legenda aceita por
#'   `ggplot2::theme(legend.position)`.
#' @param legend_position_inside Vetor numerico de tamanho dois com as
#'   coordenadas relativas horizontal e vertical da legenda quando
#'   `legend_position = "inside"`.
#' @param show_major_grid Logico escalar. Se `TRUE`, exibe as linhas principais
#'   da grade; se `FALSE`, remove essas linhas.
#' @param plot_margin Vetor numerico de tamanho quatro com as margens superior,
#'   direita, inferior e esquerda do grafico, em pontos.
#'
#' @return Lista com um tema minimo e personalizacoes de tema que pode ser
#'   adicionada a um objeto `ggplot`.
#'
#' @examples
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   ggplot_tema(show_major_grid = TRUE)
ggplot_tema <- function(
  base_size = 12,
  axis_title_size = 24,
  axis_text_size_x = 20,
  axis_text_size_y = 20, 
  legend_text_size = 22,
  title_size = 28,
  subtitle_size = 24,
  legend_key_width = 1,
  legend_key_height = 1,
  legend_key_spacing = 0.25, 
  legend_position = "inside",
  legend_position_inside = c(.85, .15),
  show_major_grid = FALSE,
  plot_margin = c(10, 10, 10, 10)
) {
  list(
    theme_minimal(base_size = base_size),
    theme(
      axis.title = element_text(size = axis_title_size),
      axis.title.y = element_text(margin = margin(r = 10)),
      axis.title.x = element_text(margin = margin(t = 25)),
      axis.text.x = element_text(size = axis_text_size_x),
      axis.text.y = element_text(size = axis_text_size_y),

      legend.position = legend_position,
      legend.position.inside = legend_position_inside,
      legend.text = element_text(size = legend_text_size),
      legend.title = element_blank(),
      legend.background = element_rect(fill = "white", colour = NA),
      legend.key = element_rect(fill = "white", colour = NA),
      legend.key.width  = grid::unit(legend_key_width, "cm"),
      legend.key.height = grid::unit(legend_key_height, "cm"),
      legend.key.spacing.y = grid::unit(legend_key_spacing, "cm"),

      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.75),
      panel.grid.major = if (show_major_grid) {
        element_line(color = "grey80", linewidth = 0.75)
      } else {
        element_blank()
      },
      panel.grid.minor = element_blank(),

      plot.margin = margin(
        plot_margin[1],
        plot_margin[2],
        plot_margin[3],
        plot_margin[4],
        unit = "pt"
      ),
      plot.title = element_text(size = title_size, margin = margin(b = 12))
    )
  )
}
