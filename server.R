library(shiny)

shinyServer(function(session, input, output) {
  locationData <-
    reactiveValues(
      raw = rawData,
      base = formattedData,
      geofiltred = NA,
      timefiltred = NA
    )
  analysisData <- reactiveValues(homePoint = NA, workPoint = NA)
  
  output$map <- renderLeaflet({
    mapData <- locationData$base
    dataLength <- nrow(mapData)
    map <- leaflet(mapData) %>%
      addProviderTiles('CartoDB.DarkMatter',
                       group = "DarkMatter",
                       options = providerTileOptions(opacity = 1)) %>%
      addProviderTiles('Stamen.TonerLite',
                       group = "TonerLite",
                       options = providerTileOptions(opacity = 1)) %>%
      addMarkers(
        lng = ~ X,
        lat = ~ Y,
        clusterOptions = markerClusterOptions(),
        group = "Clusters"
      ) %>%
      hideGroup("Clusters") %>%
      addHeatmap(
        layerId = "heatmap",
        lng = ~ X,
        lat = ~ Y,
        intensity = (1 / dataLength) * 10 ,
        minOpacity = 0.3,
        radius = 5,
        blur = 5,
        gradient = "GnBu"
      ) %>%
      addLayersControl(
        baseGroups = c("DarkMatter", "TonerLite"),
        overlayGroups = c("Clusters"),
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      addDrawToolbar(
        layerID = "selectbox",
        polyline = FALSE,
        circle = FALSE,
        marker = FALSE,
        edit = FALSE,
        polygon = TRUE,
        rectangle = TRUE,
        remove = TRUE,
        singleLayer = TRUE
      )
    
    map
  })
  outputOptions(output, "map", suspendWhenHidden = FALSE)
  
  output$daydensity <- renderPlot({
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
      scale_y_continuous("Densité", labels = scales::percent) +
      theme_timelineEDB()
    
    
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
  
  
  # Update spatial selection
  observe({
    req(input$map_selectbox_features)
    
    selectionFeatures <- input$map_selectbox_features
    if (length(selectionFeatures$features) > 0) {
      thisFeature <- selectionFeatures$features[[1]]
      thisFeatCoordinates <- unlist(thisFeature$geometry$coordinates)
      featCoordsDF <-
        as.data.frame(t(matrix(data = thisFeatCoordinates, nrow = 2)))
      colnames(featCoordsDF) <- c("X", "Y")
      thisBounds <- featCoordsDF %>%
        summarise_each(funs = funs(min, max)) %>%
        as.vector()
      locationData$geofiltred <- locationData$base %>%
        filter(X >= thisBounds$X_min, X <= thisBounds$X_max) %>%
        filter(Y >= thisBounds$Y_min, Y <= thisBounds$Y_max)
    } else {
      locationData$geofiltred <- NA
    }
  })
  
  # Zoom map on spatial selection and update daydensity plot
  observe({
    if (length(locationData$geofiltred) > 1) {
      mapData <- locationData$geofiltred
    } else {
      mapData <- locationData$base
    }
    
    thisBounds <- mapData %>%
      select(X, Y) %>%
      summarise_each(funs = funs(min, max)) %>%
      as.vector()
    dataLength <- nrow(mapData)
    thisMapProxy <- leafletProxy("map", data = mapData)
    thisMapProxy %>%
      fitBounds(
        lng1 = thisBounds$X_min,
        lat1 = thisBounds$Y_min,
        lng2 = thisBounds$X_max,
        lat2 = thisBounds$Y_max
      )
    
  })
  
  
  # Update times selection
  observe({
    noselection <- TRUE
    currentlyFiltred <- locationData$base
    
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
    if (length(locationData$timefiltred) > 1) {
      mapData <- locationData$timefiltred
    } else {
      mapData <- locationData$base
    }
    dataLength <- nrow(mapData)
    thisMapProxy <- leafletProxy("map", data = mapData)
    thisMapProxy %>%
      removeHeatmap(layerId = "heatmap") %>%
      addHeatmap(
        layerId = "heatmap",
        lng = ~ X,
        lat = ~ Y,
        intensity = (1 / dataLength) * 10 ,
        minOpacity = 0.1,
        radius = 5,
        blur = 5,
        gradient = "GnBu"
      )
    
  })
  
  output$dayfreq <- renderPlot({
    dayfreqplot <- ggplot(data = locationData$base) +
      geom_bar(
        aes(jourN, y = (..count..) / sum(..count..)),
        fill = "#43a2ca",
        alpha = 0.3,
        colour = "#053144"
      ) +
      scale_y_continuous("Densité", labels = scales::percent) +
      theme_timelineEDB()
    
    if (length(locationData$geofiltred) > 1) {
      dayfreqplot <- dayfreqplot +
        geom_bar(
          data = locationData$geofiltred,
          aes(jourN, y = (..count..) / sum(..count..)),
          fill = "red",
          alpha = 0.3,
          colour = "#67000d"
        )
    }
    dayfreqplot
  }, bg = "transparent")
  
  output$monthfreq <- renderPlot({
    monthfreqplot <- ggplot(data = locationData$base) +
      geom_bar(
        aes(moisN, y = (..count..) / sum(..count..)),
        fill = "#43a2ca",
        alpha = 0.3,
        colour = "#053144"
      ) +
      scale_y_continuous("Densité", labels = scales::percent) +
      theme_timelineEDB()
    
    if (length(locationData$geofiltred) > 1) {
      monthfreqplot <- monthfreqplot +
        geom_bar(
          data = locationData$geofiltred,
          aes(moisN, y = (..count..) / sum(..count..)),
          fill = "red",
          alpha = 0.3,
          colour = "#67000d"
        )
    }
    monthfreqplot
  }, bg = "transparent")
  
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
  
  
  
})
