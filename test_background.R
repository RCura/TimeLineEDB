library(tidyverse)
library(ggthemes)

theme_timelineEDB <- function() {
  ret <- theme_solarized(base_family = "serif",
                         base_size = 11,
                         light = FALSE) +
    theme(
      axis.text = element_text(colour = "white", size =  10),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      panel.grid.major = element_line(
        colour = "gray50",
        size = 0.3,
        linetype = "longdash"
      ),
      panel.grid.minor = element_line(
        colour = "gray40",
        size = 0.2,
        linetype = "dotdash"
      ),
      legend.key = element_rect(fill = "transparent", colour = NA),
      legend.background = element_rect(fill = "transparent", colour = NA),
      panel.background = element_blank(),
      plot.background = element_blank()
    )
  ret
}

theme_timelineEDB2 <- function(){
  ret <- theme_bw(base_family = "serif", base_size = 11) +
    theme(text = element_text(colour = "white", size = 10),
          title = element_text(color = "white"),
          line = element_line(colour = "#272B30"),
          rect = element_rect(fill = "#272B30", color = NA),
          axis.ticks = element_line(color = "#586e75"),
          axis.line = element_line(color = "#586e75", linetype = 1),
          axis.text = element_text(colour = "white", size =  10),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          legend.background = element_rect(fill = NULL, color = NA),
          legend.key = element_rect(fill = NULL, colour = NULL, linetype = 0),
          panel.background = element_rect(fill = "#272B30", colour = NA),
          #panel.border = element_rect(fill = "#272B30", colour = NULL, linetype = 0),
          panel.grid = element_line(color = "#272B30"),
          panel.grid.major = element_line(
            colour = "gray50",
            size = 0.3,
            linetype = "longdash"
          ),
          panel.grid.minor = element_line(
            colour = "gray40",
            size = 0.2,
            linetype = "dotdash"
          ),
          plot.background = element_rect(fill ="#272B30", colour = "#272B30", linetype = 0)
    )
  ret
}

ggplot(mtcars, aes(hp)) +
  geom_histogram(fill = "yellow") +
  theme_timelineEDB2()
