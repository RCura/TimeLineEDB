#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = "slate-bootstrap.css",
  # Application title
  tags$head(tags$link(rel="icon", type="image/png", href="favicon.png"), 
            tags$title("TimeLineEDB"),
            includeScript("www/intro.min.js"),
            includeCSS("www/introjs.min.css"),
            includeScript("www/CustomIntro.js")),
  #titlePanel("TimeLine Exploratory DashBoard", windowTitle = "TimeLineEDB"),
  h2("TimeLine Exploratory DashBoard",
     tags$a(style = "float: right;", icon(name="question-sign", lib = "glyphicon"),
     href="javascript:void(0);", onclick="startIntro();")),
  fluidRow(
    column(4, plotOutput("daydensity", brush = brushOpts(id = "daydensity_brush", direction = "x"))),
    
    column(8,  leafletOutput("map", height = "450px"))
  ),
  tags$br(),
  fluidRow(
    column(4,
           plotOutput("dayfreq", brush = brushOpts(id = "dayfreq_brush", direction = "x"))),
    column(4, plotOutput("monthfreq", brush = brushOpts(id = "monthfreq_brush", direction = "x"))),
    column(4,
           fluidRow(wellPanel(h3("Analyse automatique"),tags$hr(),
                        "D'après analyse automatique de vos données, on peut inférer ces informations vous concernant :",
                        tags$hr(),
                        tags$ul(
                          tags$li(
                            "Adresse (approximative) de résidence :", actionLink("analysisHome", textOutput("homeAddress", inline = TRUE))
                          ),
                          tags$br(),
                          tags$li(
                            "Adresse (apprximative) de travail :", actionLink("analysisWork", textOutput("workAddress", inline = TRUE))
                          )
                        )
                        )),
           fluidRow(actionButton("userData", "Explorez vos propres données", icon = icon("upload", lib = "glyphicon", class="primary"), width = "100%")))
           
  )
))
