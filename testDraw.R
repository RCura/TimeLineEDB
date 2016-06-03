library(shiny)
library(miniUI)
library(leaflet)

  ui <- miniPage(
    gadgetTitleBar("leaflet Draw"),
    miniContentPanel(
      leafletOutput("mymap")
    )
  )
  
  server <- function(input, output, session) {
    
    myMap <- reactive({
      return(leaflet() %>%
               addTiles() %>%
               addDrawToolbar(polyline = FALSE,  polygon = FALSE,  rectangle = TRUE, circle = FALSE, 
                              marker = TRUE, edit = TRUE, remove = TRUE))
    })
    
    # Define reactive expressions, outputs, etc.
    output$mymap <- renderLeaflet({
      myMap()
    })
    
    observeEvent(input$mymap_drawnItems_created, {
      output$mymap <- renderLeaflet({
        if( "radius" %in% names(input$mymap_drawnItems_created$properties))
        {
          lng = input$mymap_drawnItems_created$geometry$coordinates[[1]]
          lat = input$mymap_drawnItems_created$geometry$coordinates[[2]]
          radius = input$mymap_drawnItems_created$properties$radius
          myMap() %>% addCircles(lng = lng, lat = lat, radius = radius, color="green")
        }
        else{
          myMap() %>% addGeoJSON(input$mymap_drawnItems_created, color="green")
        }
      })
      
      print(123)
    })
    
    # When the Done button is clicked, return a value
    observeEvent(input$done, {
      print(input$mymap)
      stopApp()
    })
  }
  runGadget(ui, server)
