library(shiny)

shinyServer(function(session, input, output) {
  options(shiny.maxRequestSize = 50 * 1024^2)
  locationData <- reactiveValues(
      base = formattedData,
      geofiltred = NA,
      timefiltred = NA
    )
  
  analysisData <- reactiveValues(homePoint = NA, workPoint = NA)
  
  
  
  showModal(modalDialog(size = "l",
                        title = "Bienvenue dans TimeLine Exploratory Dashboard",
                        HTML(modalText),
                        easyClose = FALSE,
                        footer = tagList(
                          column(6, actionButton(inputId = "showHelp", label = "Suivre le tutoriel", icon = icon("education", lib = "glyphicon"))),
                          column(6, modalButton(label = "Entrer directement dans l'application", icon = icon("remove", lib = "glyphicon")))
                        )
  ))
  
  
  observeEvent(input$showHelp,{
    removeModal()
    js$launchIntro()
  })
  
  observeEvent(input$mainHelp, {
    js$launchIntro()
    })
  
  observeEvent(input$userDataHelp,{
    js$launchUserIntro()
  })
  
  
  observeEvent(input$loadUserData,{
    req(input$userData)
    withBusyIndicatorServer("loadUserData", {
      showNotification(ui = "Conversion des données...", duration = NULL, closeButton = TRUE, id = "notifData", type = "message")
      locationData$base <- google_jsonZip_to_DF(input$userData$datapath)
      removeNotification( id = "notifData")
      locationData$geofiltred <- NA
      locationData$timefiltred <- NA
    })

  })

  output$map <- renderLeaflet({
    mapData <- isolate(locationData$base)
    dataLength <- nrow(mapData)
    leaflet(mapData) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addHeatmap(layerId = "heatmap", lng = ~ X, lat = ~ Y, intensity = (1 / dataLength) * 50,
                 minOpacity = 0.2, radius = 5, blur = 5, gradient = "GnBu")  %>%
      addDrawToolbar(polylineOptions = FALSE, polygonOptions = FALSE, circleOptions = FALSE,
                     markerOptions = FALSE, singleFeature = TRUE,
                     editOptions = editToolbarOptions(edit = FALSE, remove = TRUE)) %>%
      addControl(position = "bottomleft", html = HTML(mapSettingsText), className = "primary")
  })
  outputOptions(output, "map", suspendWhenHidden = FALSE)
  

  output$daydensity <- renderPlot({
    densityPlot <-  ggplot(locationData$base, aes(dhour))  +
      geom_density(col = "#053144", fill = "#43a2ca", alpha = 0.3, adjust = 0.75) +
      scale_x_continuous("Heure", breaks = c(0, 6, 12, 18, 24),
                         minor_breaks = c(3, 9, 15, 21),
                         labels = function(x){paste(x, "h")}) +
      scale_y_continuous("Densité", labels = scales::percent) +
      theme_timelineEDB()
    
    if (length(locationData$geofiltred) > 1) {
      densityPlot <- densityPlot +
        geom_density(data = locationData$geofiltred, aes(dhour),
                     col = "#67000d", fill = "red", alpha = 0.3, adjust = 0.75)
    }
    densityPlot
  }, bg = "transparent",  type = "cairo")
  
  output$dayfreq <- renderPlot({
    dayfreqplot <- ggplot(data = locationData$base) +
      geom_bar(aes(jourN, y = (..count..) / sum(..count..)),
               fill = "#43a2ca", alpha = 0.3, colour = "#053144") +
      scale_y_continuous("Densité", labels = scales::percent) +
      theme_timelineEDB()
    
    if (length(locationData$geofiltred) > 1) {
      dayfreqplot <- dayfreqplot +
        geom_bar(data = locationData$geofiltred,
          aes(jourN, y = (..count..) / sum(..count..)),
          fill = "red", alpha = 0.3, colour = "#67000d")
    }
    dayfreqplot
  }, bg = "transparent", type = "cairo")
  
  output$monthfreq <- renderPlot({
    monthfreqplot <- ggplot(data = locationData$base) +
      geom_bar(aes(moisN, y = (..count..) / sum(..count..)),
               fill = "#43a2ca", alpha = 0.3, colour = "#053144") +
      scale_y_continuous("Densité", labels = scales::percent) +
      theme_timelineEDB()
    
    if (length(locationData$geofiltred) > 1) {
      monthfreqplot <- monthfreqplot +
        geom_bar(data = locationData$geofiltred,
          aes(moisN, y = (..count..) / sum(..count..)),
          fill = "red", alpha = 0.3, colour = "#67000d")
    }
    monthfreqplot
  }, bg = "transparent", type = "cairo")
  
  
  # Update spatial selection
  observe({
    req(input$map_draw_all_features)
    if (length(input$map_draw_all_features$features) > 0) {
      coordsSelectBox <- unlist(input$map_draw_all_features$features[[1]]$geometry$coordinates)[c(1,2,4,5)]
      locationData$geofiltred <- locationData$base %>%
        filter(X >= coordsSelectBox[1], X <= coordsSelectBox[4]) %>%
        filter(Y >= coordsSelectBox[2], Y <= coordsSelectBox[3])
    } else {
      locationData$geofiltred <- NA
    }
  })
  
  # Zoom map on spatial selection
  observeEvent(input$map_draw_all_features,{
    req(input$map_draw_all_features, input$fitToBounds)
    if (length(input$map_draw_all_features$features) > 0) {
      coordsSelectBox <- unlist(input$map_draw_all_features$features[[1]]$geometry$coordinates)[c(1,2,4,5)]
      proxy <- leafletProxy('map')
      proxy %>%
        fitBounds(lng1 = coordsSelectBox[1],
                  lng2 = coordsSelectBox[4],
                  lat1 = coordsSelectBox[2],
                  lat2 =  coordsSelectBox[3])
    }
  })
  
  
  # Update times selection
  observe({
    noselection <- TRUE
    currentlyFiltred <- locationData$base
    
    if (!is.null(input$yearplot_brush)) {
      #yearfreq
      timeSelection <- input$yearplot_brush
      currentlyFiltred <- currentlyFiltred %>%
        filter(annee >= timeSelection$xmin, annee <= timeSelection$xmax)
      noselection <- FALSE
    }
    
    if (!is.null(input$daydensity_brush)) {
      #daydensity
      timeSelection <- input$daydensity_brush
      currentlyFiltred <- currentlyFiltred %>%
        filter(dhour >= timeSelection$xmin, dhour <= timeSelection$xmax)
      noselection <- FALSE
    }
    if (!is.null(input$dayfreq_brush)) {
      #dayfreq
      timeSelection <- input$dayfreq_brush
      currentlyFiltred <- currentlyFiltred %>%
        filter(
          as.numeric(jourN) >= round(timeSelection$xmin),
          as.numeric(jourN) <= round(timeSelection$xmax)
        )
      noselection <- FALSE
    }
    if (!is.null(input$monthfreq_brush)) {
      #monthfreq
      timeSelection <- input$monthfreq_brush
      currentlyFiltred <- currentlyFiltred %>%
        filter(
          as.numeric(moisN) >= round(timeSelection$xmin),
          as.numeric(moisN) <= round(timeSelection$xmax)
        )
      noselection <- FALSE
    }
    
    if (noselection) {
      locationData$timefiltred <- NA
    } else {
      locationData$timefiltred <- currentlyFiltred
    }
  })

  # Update heatmap on time selection
  observe({
    req(locationData$base)
    if (length(locationData$timefiltred) > 1) {
      mapData <- locationData$timefiltred
    } else {
      mapData <- locationData$base
    }
    dataLength <- nrow(mapData)
    thisMapProxy <- leafletProxy("map", data = mapData)
    thisMapProxy %>%
      clearHeatmap() %>%
      addHeatmap(layerId = "heatmap", lng = ~ X, lat = ~ Y, intensity = (1 / dataLength) * 50,
                 minOpacity = 0.2, radius = 5, blur = 5, gradient = "GnBu")
  })
  
  # Zoom on Home
  observeEvent(input$analysisHome, {
    thisMapProxy <- leafletProxy("map")
    
    thisMapProxy %>%
      fitBounds(
        analysisData$homePoint$Xround,
        analysisData$homePoint$Yround,
        analysisData$homePoint$Xround,
        analysisData$homePoint$Yround
      )
  })
  
  # Zoom on Work
  observeEvent(input$analysisWork, {
    thisMapProxy <- leafletProxy("map")
    
    thisMapProxy %>%
      fitBounds(
        analysisData$workPoint$Xround,
        analysisData$workPoint$Yround,
        analysisData$workPoint$Xround,
        analysisData$workPoint$Yround
      )
  })
  
  output$homeAddress <- renderText({
    req(input$revGeoCode)
    homeData <- locationData$base %>%
      filter(heure > 19 | heure < 8) %>%
      filter(moisN != "juil.", mois != "août") %>%
      mutate(Xround = round(X, 3)) %>%
      mutate(Yround = round(Y, 3))
    
    analysisData$homePoint <- homeData %>%
      group_by(Xround, Yround) %>%
      summarise(count = n()) %>%
      ungroup() %>%
      arrange(desc(count)) %>%
      top_n(1, wt = count)
    
    suppressMessages(revgeocode(
      location = c(
        analysisData$homePoint$Xround,
        analysisData$homePoint$Yround
      )
    ))
  })
  
  output$workAddress <- renderText({
    req(input$revGeoCode)
    workData <- locationData$base %>%
      filter(heure >= 14, heure <=  16) %>%
      filter(moisN != "juil.", mois != "août") %>%
      filter(jourN != "sam.", jourN != "dim.") %>%
      mutate(Xround = round(X, 3)) %>%
      mutate(Yround = round(Y, 3))
    
    analysisData$workPoint <- workData %>%
      group_by(Xround, Yround) %>%
      summarise(count = n()) %>%
      ungroup() %>%
      arrange(desc(count)) %>%
      top_n(1, wt = count)
    
    suppressMessages(revgeocode(
      location = c(
        analysisData$workPoint$Xround,
        analysisData$workPoint$Yround
      )
    ))
  })
  
  
  output$yearPlot <- renderPlot({
    yearfreqplot <- ggplot(data = locationData$base) +
      geom_bar(
        aes(annee, y = (..count..) / sum(..count..)),
        fill = "#43a2ca",
        alpha = 0.3,
        colour = "#053144"
      ) +
      scale_y_continuous("Densité", labels = scales::percent) +
      theme_timelineEDB()
    
    if (length(locationData$geofiltred) > 1) {
      yearfreqplot <- yearfreqplot +
        geom_bar(
          data = locationData$geofiltred,
          aes(annee, y = (..count..) / sum(..count..)),
          fill = "red",
          alpha = 0.3,
          colour = "#67000d"
        )
    }
    yearfreqplot
  }, bg = "transparent", type = "cairo")
  
  output$calendarPlot <- renderPlot({
    req(locationData$base)

    if (length(locationData$geofiltred) > 1) {
      filtredData <- locationData$geofiltred
    } else {
      filtredData <- locationData$base
    }
    
    calendarData <- filtredData %>%
      group_by(annee, moisN, monthWeek, jourN) %>%
      summarise(count =  n()) %>%
      mutate(jourN = factor(jourN, levels = rev(levels(jourN))))
    
    calendarPlot <- ggplot(locationData$base, aes(monthWeek, jourN, fill = count)) +
      geom_tile(data = calendarData, colour = "#333333", alpha = 0.8) +
      facet_grid(annee~moisN) + 
      scale_x_discrete("") +
      labs(x = "", y = "") +
      theme_timelineEDB() +
      theme(legend.position = "bottom") +
      guides(fill = guide_legend(keywidth = 5, keyheight = 2))
    
    if (length(locationData$geofiltred) > 1) {
      calendarPlot <- calendarPlot + scale_fill_gradient(name = "Densité", high = "red", low = "#333333")
    } else {
      calendarPlot <- calendarPlot + scale_fill_gradient(name = "Densité", high = "#43a2ca", low = "#333333")
    }
    
    calendarPlot
  },  bg = "transparent", type = "cairo")
  
})
