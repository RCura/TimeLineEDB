suppressPackageStartupMessages({
  library(shiny)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(lubridate)
  library(leaflet) # For now : devtools::install_github("RCura/leaflet")
  library(ggthemes)
  library(ggmap)
  library(stringi)
  library(shinyjs)
  library(V8)
})

#enableBookmarking(store = "server")

jsCode <- "
  shinyjs.launchIntro = function(){startIntro();};
  shinyjs.launchUserIntro = function(){userDataIntro();}
"

options(shiny.maxRequestSize = 8*1024^2)
source("src/helpers.R")

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


formatData <- function(rawData, tz){
  formattedData <- rawData %>%
    # mutate(time = parse_datetime(Time, format = "%Y/%m/%d %H:%M:%S")) %>%
    mutate(Time = with_tz(Time, tzone = tz)) %>%
    mutate(jour = day(Time)) %>%
    mutate(jourN = factor(weekdays(Time, abbreviate = TRUE), levels = joursFr)) %>%
    mutate(mois = month(Time)) %>%
    mutate(moisN = factor(months(Time, abbreviate = TRUE), levels = moisFr)) %>%
    mutate(annee = year(Time)) %>%
    mutate(heure = hour(Time)) %>%
    mutate(minute = minute(Time)) %>%
    mutate(dhour = hour(Time) + minute(Time) / 60 + second(Time) / 3600) %>%
    mutate(monthWeek = stri_datetime_fields(Time)$WeekOfMonth )
  if (nrow(formattedData) > 50E3){
    formattedData <- formattedData %>%
      sample_n(size = 50E3)
  }
}

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
  select(Time, X, Y)

formattedData <- formatData(rawData,  "Europe/Paris")


ZipPath <- "data/takeout-20160629T102959Z.zip"
google_jsonZip_to_DF <- function(ZipPath, tz){
  
  # Extract JSON from ZIP
  ## Detecting files inside ZIP
  zipFiles <- unzip(ZipPath, list = TRUE)
  jsonPath <- zipFiles[grepl(zipFiles$Name,pattern = ".json"),]
  ## Unzipping
  unzip(ZipPath, files = jsonPath$Name,
        overwrite = TRUE,
        junkpaths = TRUE,
        exdir = tempdir())
  extractedFile <- paste(tempdir(),basename(jsonPath$Name), sep = "/")
  # Convert JSON to CSV
  jsonFile <- tempfile(fileext = ".json")
  ## Make sure not conflicting
  file.rename(from = extractedFile, to = jsonFile)
  csvFile <- tempfile(fileext = ".csv")
  ## Python call
  cmdCall <- sprintf("python %s %s --output %s --format csv",
                     "src/location_history_json_converter.py",
                     jsonFile,
                     csvFile)
  system(cmdCall)
  ## Clean
  file.remove(jsonFile)
  
  # Read CSV
  resultDF <- read_csv(csvFile) %>%
    separate(Location, into = c("Y", "X"),  sep = " ",  remove = TRUE, convert = TRUE)
  
  # Format it correctly
  formatData(resultDF, tz)  
}


