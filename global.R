library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(leaflet) # For now : devtools::install_github("RCura/leaflet")
library(ggthemes)
library(ggmap)

moisFr <- c(
  "janv.",
  "févr.",
  "mars",
  "avril",
  "mai",
  "juin",
  "juil.",
  "août",
  "sept.",
  "oct.",
  "nov.",
  "déc."
)

joursFr <- c("lun.", "mar.", "mer.", "jeu.",
             "ven.", "sam.", "dim.")

colorPalette <- colorNumeric(
    palette = c('#ffffb2', '#fd8d3c', '#fd8d3c', '#f03b20',  '#bd0026'),
    domain = c(0, 1)
  )


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
      panel.background = element_rect(fill = "transparent", colour = NA),
      plot.background = element_rect(fill = "transparent", colour = NA)
    )
  ret
}


rawData <- read_csv(file = "data/SelfPoints.csv") %>%
  select(X, Y, timestamp, accuracy)

formattedData <- rawData %>%
  mutate(time = parse_datetime(timestamp, format = "%Y/%m/%d %H:%M:%S")) %>%
  mutate(jour = day(time)) %>%
  mutate(jourN = factor(weekdays(time, abbreviate = TRUE), levels = joursFr)) %>%
  mutate(mois = month(time)) %>%
  mutate(moisN = factor(months(time, abbreviate = TRUE), levels = moisFr)) %>%
  mutate(annee = year(time)) %>%
  mutate(heure = hour(time)) %>%
  mutate(minute = minute(time)) %>%
  mutate(dhour = hour(time) + minute(time) / 60 + second(time) / 3600) %>%
  sample_n(50000)

locationData <- reactiveValues(
    raw = rawData,
    base = formattedData,
    geofiltred = NA,
    timefiltred = NA
  )

analysisData <- reactiveValues(homePoint = NA, workPoint = NA)
