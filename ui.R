library(shiny)

shinyUI(
  fluidPage(
    theme = "slate-bootstrap.css",
    tags$head(
      tags$link(rel = "icon", type = "image/png", href = "favicon.png"),
      tags$title("TimeLineEDB"),
      includeScript("www/intro.min.js"),
      includeCSS("www/introjs.min.css"),
      includeScript("www/CustomIntro.js"),
      includeCSS("www/timelineEDB.css")
    ),
    h2(
      "TimeLine Exploratory DashBoard",
      tags$a(
        id = "mainHelp",
        style = "float: right;",
        icon(name = "question-circle", class = "fa-1x", lib = "font-awesome"),
        href = "javascript:void(0);",
        onclick = "startIntro();"
      )
    ),
    fluidRow(column(
      4, plotOutput("daydensity", brush = brushOpts(id = "daydensity_brush", direction = "x"))
    ),
    
    column(8,
           tags$input(id = "mapSettings", type = "checkbox", class = "inv-checkbox"),
           tags$label('for' = "mapSettings",  icon(name = "cogs", class = "fa-1x", lib = "font-awesome")),
           conditionalPanel(condition = "input.mapSettings == true",
                            checkboxInput("showClusters", label = "Afficher les clusters de points ?",  value = FALSE),
                            checkboxInput("fitToBounds", label = "Synchroniser l'étendue de la carte avec la sélection ?", value = FALSE)),
           leafletOutput("map", height = "450px"))),
    tags$br(),
    fluidRow(
      column(4,
             plotOutput(
               "dayfreq", brush = brushOpts(id = "dayfreq_brush", direction = "x")
             )),
      column(4, plotOutput(
        "monthfreq", brush = brushOpts(id = "monthfreq_brush", direction = "x")
      )),
      column(
        4,
        fluidRow(
          wellPanel(
            h3("Analyse automatique"),
            tags$hr(),
            "D'après analyse automatique de vos données, on peut inférer ces informations vous concernant :",
            tags$hr(),
            tags$ul(
              tags$li(
                "Adresse (approximative) de résidence :",
                actionLink("analysisHome", textOutput("homeAddress", inline = TRUE))
              ),
              tags$br(),
              tags$li(
                "Adresse (approximative) de travail :",
                actionLink("analysisWork", textOutput("workAddress", inline = TRUE))
              )
            )
          )
        ),
        fluidRow(
                 tags$input(id = "userSettings", type = "checkbox", class = "inv-checkbox"),
                 tags$label('for' = "userSettings", span("Explorez vos propres données",  class = "btn btn-info"),
                            onclick = "userDataIntro();"),
                 tags$a(
                   id = "userDataHelp",
                   icon(name = "question-circle", class = "fa-3x", lib = "font-awesome"),
                   href = "javascript:void(0);",
                   onclick = "userDataIntro();"
                 )
          ),
        fluidRow(
          conditionalPanel(condition = "input.userSettings == true",
                           fluidRow(fileInput("userData",
                                     label = "Chargez vos données", 
                                     multiple = FALSE,
                                    accept = "application/zip",
                                     width = "100%")),
                           fluidRow(selectInput("timezone", label = "Fuseau horaire",
                                                choices = lubridate::olson_time_zones(),
                                                multiple = FALSE,
                                                selected = "Europe/Paris",
                                                selectize = FALSE))
          )
        ),
        fluidRow(
          HTML(
            "Timeline EDB a été développé par",
            "<a href=\"http://www.parisgeo.cnrs.fr/spip.php?article6416&lang=fr\" target=\"_blank\">",
            "Robin Cura</a>, 2016.",
            "C'est un logiciel libre, sous licence ",
            "<a href=\"https://fr.wikipedia.org/wiki/GNU_Affero_General_Public_License\" target=\"_blank\">AGPL</a>,",
            "et ses sources sont consultables et ré-utilisables",
            "<a href=\"https://github.com/RCura/TimeLineEDB\" target=\"_blank\">sur ce dépôt GitHub</a>."
          )
        )
      )
    ),
    checkboxInput("morePlots", "Plus de graphiques"),
    conditionalPanel("input.morePlots", fluidRow(
      column(8, plotOutput("test", brush = brushOpts(id = "calendar_brush", direction = "y")))
    ))
  )
)
