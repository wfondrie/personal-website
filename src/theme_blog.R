
library(ggplot2)

#theme_colors <- list("#ffffff", "#404040", "#24B8A0", "#7d828a")
theme_colors <- list("#000000", "#ffffff", "#24B8A0", "#7d828a")
names(theme_colors) <- c("bg", "fg", "hl", "accent")

theme_pal <- c("#ffffff", "#24B8A0", "#f0b67f", "#fe5f55")

theme_blog <- function(base_size = 14) {
    theme_classic(base_size = base_size, base_family = "Roboto") +
    theme(plot.background = element_blank(),
          plot.margin = margin(20, 20, 10, 10, "pt"),
          panel.background = element_blank(),
          text = element_text(color = theme_colors$fg),
          axis.text = element_text(color = theme_colors$fg),
          axis.ticks = element_line(size = 1, color = theme_colors$fg,
                                    lineend = "round"),
          axis.line = element_line(size = 1, color = theme_colors$fg,
                                   lineend = "round"),
          legend.background = element_blank())
}
