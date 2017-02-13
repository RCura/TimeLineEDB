#library(devtools)
#install_github('rstudio/leaflet')
#install_github("bhaskarvk/leaflet.extras")


library(shiny)
library(tidyverse)
library(leaflet)
library(leaflet.extras)
library(ggplot2)


ui <- fluidPage(
  fluidRow(
    column(6, leafletOutput("map", height = "800px")),
    column(6, plotOutput("plot",
                         height = "800px",
                         brush = brushOpts(id = "plot_brush", direction = "x")
                         ))
  ),
  actionButton(inputId = "removeDraw", label = "remove")
)

# Define server logic required to draw a histogram
server <- function(session, input, output) {
  locationData <- reactiveValues(
    base = formattedData,
    geofiltred = NA,
    timefiltred = NA
  )
  
  output$map <- renderLeaflet({
    mapData <- isolate(locationData$base)
    dataLength <- nrow(mapData)
    
    leaflet(mapData) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addHeatmap(
        layerId = "heatmap",
        lng = ~ X,
        lat = ~ Y,
        intensity = (1 / dataLength) * 50,
        minOpacity = 0.2,
        radius = 5,
        blur = 5,
        gradient = "GnBu"
      ) %>%
      addDrawToolbar(targetGroup = "test",
        polylineOptions = FALSE,
        polygonOptions = FALSE,
        circleOptions = FALSE,
        markerOptions = FALSE,
        editOptions = editToolbarOptions(
          edit = FALSE
        )
      )
  })
  
  output$plot <- renderPlot({
    densityPlot <-  ggplot(locationData$base, aes(dhour))  +
      geom_density(
        col = "#053144",
        fill = "#43a2ca",
        alpha = 0.3,
        adjust = 0.75
      ) +
      scale_x_continuous("Heure",
                         breaks = c(0, 6, 12, 18, 24),
                         minor_breaks = c(3, 9, 15, 21)) +
      scale_y_continuous("Densité", labels = scales::percent)
    
    
    if (length(locationData$geofiltred) > 1) {
      densityPlot <- densityPlot +
        geom_density(
          data = locationData$geofiltred,
          aes(dhour),
          col = "#67000d",
          fill = "red",
          alpha = 0.3,
          adjust = 0.75
        )
    }
    densityPlot
    
  }, bg = "transparent")
  
  # Update times selection
  observe({
    noselection <- TRUE
    currentlyFiltred <- locationData$base
    #browser()
    if (!is.null(input$plot_brush)) {
      timeSelection <- input$plot_brush
      currentlyFiltred <- currentlyFiltred %>%
        filter(dhour >= timeSelection$xmin, dhour <= timeSelection$xmax)
      noselection <- FALSE
    }
    if (noselection) {
      locationData$timefiltred <- NA
    } else {
      locationData$timefiltred <- currentlyFiltred
    }
  })
  
  observe({
    if (length(locationData$timefiltred) > 1) {
      mapData <- locationData$timefiltred
    } else {
      mapData <- locationData$base
    }
    dataLength <- nrow(mapData)
    thisMapProxy <- leafletProxy("map", data = mapData)
    thisMapProxy %>%
      clearHeatmap() %>%
      addHeatmap(
        layerId = "heatmap",
        lng = ~ X,
        lat = ~ Y,
        intensity = (1 / dataLength) * 50,
        minOpacity = 0.2,
        radius = 5,
        blur = 5,
        gradient = "GnBu"
      )

  })
  
  observeEvent(input$removeDraw,{
    if (length(locationData$timefiltred) > 1) {
      mapData <- locationData$timefiltred
    } else {
      mapData <- locationData$base
    }
    
    leafletProxy("map", data = mapData) %>%
      removeDrawToolbar(clearFeatures = TRUE)
  })

    
}

# Run the application 
shinyApp(ui = ui, server = server)


library(shiny)
library(leaflet)
library(leaflet.extras)

testui <- fluidPage(
  leafletOutput("map"),
  actionButton("removeDraw", label = "remove draw toolbar")
)

testserver <- function(session, input, output){
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap) %>%
      addDrawToolbar()
  })
  
  observeEvent(input$removeDraw,{
    proxy <- leafletProxy("map")
    proxy %>%
      removeDrawToolbar(clearFeatures = TRUE)
  })
}
shinyApp(ui = testui , server = testserver)
