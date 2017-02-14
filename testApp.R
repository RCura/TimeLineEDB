library(shiny)
library(leaflet)
library(leaflet.extras)

ui <- fluidPage(
  leafletOutput("map"),
  actionButton("rmDraw", "remove Draw toolbar"),
  actionButton('addDraw', "add Draw toolbar")
)

server <- function(session, input, output){
  output$map <- renderLeaflet(
    leaflet() %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addDrawToolbar(targetGroup = "test",
                     editOptions = editToolbarOptions(edit = FALSE,
                                                      remove = TRUE),
                     singleFeature = TRUE) %>%
      addControl(position = "bottomleft",
                 html = HTML("
                   <p>
                     <button class=\"btn btn-primary\" type=\"button\" data-toggle=\"collapse\" data-target=\"#collapseExample\" aria-expanded=\"false\" aria-controls=\"collapseExample\">
                             Button with data-target
                    </button>
                     </p>
                     <div class=\"collapse\" id=\"collapseExample\">
                     <div class=\"card card-block\">
                     Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident.
                   </div>
                     </div>"
                 )
                  )
  )
  
  observeEvent(input$rmDraw, {
    proxy <- leafletProxy("map")
    proxy %>%
      removeDrawToolbar(clearFeatures = TRUE)
  })
  
  observeEvent(input$addDraw, {
    proxy <- leafletProxy("map",
                          data = data_frame(lng = runif(n = 3, min = 0, max = 90),
                                            lat =runif(n = 3, min = 0, max = 90)))
    proxy %>%
      clearHeatmap() %>%
      addHeatmap(lng = ~ lng,
                 lat = ~ lat)
  })
  
  observeEvent(input$map_draw_all_features,{
    req(input$map_draw_all_features, input$fitToBounds)
    if ( length(input$map_draw_all_features$features) > 0 ) {
      coordsSelectBox <- unlist(input$map_draw_all_features$features[[1]]$geometry$coordinates)[c(1,2,4,5)]
      proxy <- leafletProxy('map')
      proxy %>%
        fitBounds(lng1 = coordsSelectBox[1],
                  lng2 = coordsSelectBox[4],
                  lat1 = coordsSelectBox[2],
                  lat2 =  coordsSelectBox[3])
    }
  })
}

shinyApp(ui = ui, server = server)
