
suppressPackageStartupMessages({
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


formatData <- function(rawData){
  formattedData <- rawData %>%
    mutate(Time = with_tz(Time, tzone = "GMT")) %>%
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

formattedData <- formatData(rawData)


ZipPath <- "data/takeout-20160629T102959Z.zip"
google_jsonZip_to_DF <- function(ZipPath){
  
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
  formatData(resultDF)  
}

modalText <- "<div class=\"h5 text-primary\">
Cette application web permet à ses utilisateurs d'explorer dynamiquement
les traces GPS collectés par la société Google (<i class=\"fa fa-google\" aria-hidden=\"true\"></i>)

dans le cadre de son programme « Timeline ».
Lorsqu'un individu possède un smartphone fonctionnant avec le système « Android 
(<i class=\"fa fa-android\" aria-hidden=\"true\"></i>)», 
celui-ci lui propose d'enregistrer régulièrement et automatiquement les coordonnées de l'endroit où il se trouve. 
Ce choix effectué, les coordonnées ainsi que l'heure seront enregistrées, 
environ toutes les 5 minutes, et communiquées aux serveurs de Google. 
L'utilisateur peut alors les consulter sur un site dédié : 
<a href='https://www.google.fr/maps/timeline' target='_blank'>Google Timeline</a>.<br /> 
Ce site ne permet qu'une consultation jour par jour, 
et les données y sont en grande partie masquées, 
seuls les lieux identifiés par Google y apparaissant. 
On peut télécharger ces données, massives, mais les outils pour les consulter et explorer manquent.
<br />
TimeLineEDB se propose de combler ce manque.
<br />
Lors d'une première visite, nous vous invitons à suivre le tutoriel afin de comprendre
l'utilisation de TimeLine EDB.
<br />
Notez que vous pouvez toujours revenir au tutoriel en cliquant sur l'icone aide 
(<i class='fa fa-question-circle-o' aria-hidden='true'></i>) 
en haut à droite de l'application.
</div><div class=\"well well-sm text-center\">
L'exploration de ses propres données n'est pas possible avec le navigateur
Safari (<i class=\"fa fa-safari\" aria-hidden=\"true\"></i>).<br/>
Pour une navigation optimale, nous vous recommandons d'utiliser les
navigateurs Chrome (<i class=\"fa fa-chrome\" aria-hidden=\"true\"></i>)
ou Firefox (<i class=\"fa fa-firefox\" aria-hidden=\"true\"></i>).
</div>"

mapSettingsText <- "
<button class=\"btn btn-primary\" type=\"button\" data-toggle=\"collapse\" data-target=\"#collapseExample\" aria-expanded=\"false\" aria-controls=\"collapseExample\">
<i id=\"mapSettings\" class=\"fa fa-cogs fa-1x\"></i>
</button>
<div id=\"collapseExample\"class=\"collapse form-group shiny-input-container\">
<div class=\"checkbox\">
<label>
<input id=\"fitToBounds\" type=\"checkbox\"/>
<span>Synchroniser l'étendue de la carte avec la sélection ?</span>
</label>
</div>
</div>"

sourceHTML <- HTML(
  '<a href="https://doi.org/10.5281/zenodo.154528"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.154528.svg" alt="DOI"></a>',
  "Timeline EDB a été développé par",
  "<a href=\"http://www.parisgeo.cnrs.fr/spip.php?article6416&lang=fr\" target=\"_blank\">",
  "Robin Cura</a>, 2016.",
  "C'est un logiciel libre, sous licence ",
  "<a href=\"https://fr.wikipedia.org/wiki/GNU_Affero_General_Public_License\" target=\"_blank\">AGPL</a>,",
  "et ses sources sont consultables et ré-utilisables",
  "<a href=\"https://github.com/RCura/TimeLineEDB\" target=\"_blank\">sur ce dépôt GitHub</a>."
  )

