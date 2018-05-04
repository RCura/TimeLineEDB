
suppressPackageStartupMessages({
  library(jqr)
  library(shiny)
  library(tidyverse)
  library(lubridate)
  library(leaflet) # devtools::install_github("rstudio/leaflet")
  library(leaflet.extras) # For devtools::install_github("bhaskarvk/leaflet.extras")
  library(ggthemes)
  library(ggmap)
  library(stringi)
  library(shinyjs)
  library(V8)
})
options(shiny.maxRequestSize = 8*1024^2)
#enableBookmarking(store = "server")

jsCode <- "
  shinyjs.launchIntro = function(){startIntro();};
  shinyjs.launchUserIntro = function(){userDataIntro();}
"

source("src/helpers.R")

moisFr <- c( "janv.", "févr.", "mars", "avril", "mai","juin",
             "juil.", "août", "sept.", "oct.", "nov.", "déc.")

joursFr <- c("lun.", "mar.", "mer.", "jeu.",
             "ven.", "sam.", "dim.")

colorPalette <- colorNumeric(
    palette = c('#ffffb2', '#fd8d3c', '#fd8d3c', '#f03b20',  '#bd0026'),
    domain = c(0, 1)
  )


formatData <- function(rawData){
  rawData %>%
    # mutate(Time = with_tz(Time, tzone = "GMT")) %>%
    mutate(jour = day(Time)) %>%
    mutate(jourN = factor(weekdays(Time, abbreviate = TRUE), levels = joursFr)) %>%
    mutate(mois = month(Time)) %>%
    mutate(moisN = factor(months(Time, abbreviate = TRUE), levels = moisFr)) %>%
    mutate(annee = year(Time)) %>%
    mutate(heure = hour(Time)) %>%
    mutate(minute = minute(Time)) %>%
    mutate(dhour = hour(Time) + minute(Time) / 60 + second(Time) / 3600) %>%
    mutate(monthWeek = stri_datetime_fields(Time)$WeekOfMonth )
}

theme_timelineEDB <- function(){
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
            colour = "gray50", size = 0.3, linetype = "longdash"
          ),
          panel.grid.minor = element_line(
            colour = "gray40", size = 0.2, linetype = "dotdash"
          ),
          plot.background = element_rect(fill ="#272B30", colour = "#272B30", linetype = 0)
    )
  ret
}


rawData <- read_csv(file = "data/SelfPoints.csv",
                    col_types = c("ddiTi"),
                    progress = FALSE) %>%
  dplyr::select(Time, X, Y)

formattedData <- formatData(rawData)

locationHistory_zippedJson_to_DF <- function(ZipPath){
  # Extract JSON from ZIP
  ## Detecting files inside ZIP
  zipFiles <- unzip(ZipPath, list = TRUE)
  jsonPath <- zipFiles[grepl(zipFiles$Name,pattern = ".json"),]
  ## Unzipping
  tmpDir <- tempfile()
  unzip(ZipPath, files = jsonPath$Name,
        overwrite = TRUE,
        junkpaths = TRUE,
        exdir = tmpDir)
  jsonFile <- paste(tmpDir,basename(jsonPath$Name), sep = "/")
  # Reading JSON
  raw_data <- read_lines(jsonFile, progress = FALSE)
  # Filter JSON with `jq` and convert it to tibble
  resultDF <- raw_data %>%
    jq('[.locations[] | {ts : .timestampMs, lat : .latitudeE7, long : .longitudeE7}]') %>%
    jsonlite::fromJSON() %>%
    as_tibble() %>%
    mutate(X = long / 1E7,
           Y = lat / 1E7,
           ts = as.numeric(ts)/1E3,
           Time = as.POSIXct(ts, origin = "1970-01-01")) %>%
    dplyr::select(Time, Y, X)
  # Add properly detailed time columns
  formatData(resultDF)
}

source("src/textes.R")
