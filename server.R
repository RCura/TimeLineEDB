library(shiny)

shinyServer(function(session, input, output) {
  locationData <-
    reactiveValues(
      base = formattedData,
      geofiltred = NA,
      timefiltred = NA
    )
  analysisData <- reactiveValues(homePoint = NA, workPoint = NA)
  
  
  
  showModal(modalDialog(size = "l",
                        title = "Bienvenue dans TimeLine Exploratory Dashboard",
                        HTML("Cette application web permet à ses utilisateurs d'explorer dynamiquement
                             les traces GPS collectés par la société Google dans le cadre de son programme « Timeline ».
                             Lorsqu'un individu possède un smartphone fonctionnant avec le système « Android », 
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
                             en haut à droite de l'application."),
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
  
  observeEvent(input$loadUserData,{
    req(input$userData)
    withBusyIndicatorServer("loadUserData", {
      thisMapProxy <- leafletProxy("map")
      thisMapProxy %>%
        clearHeatmap() %>%
        removeDrawToolbar()
      showNotification(ui = "Conversion des données...", duration = NULL, closeButton = TRUE, id = "notifData", type = "message")
      locationData$base <- google_jsonZip_to_DF(input$userData$datapath, input$timezone)
      removeNotification( id = "notifData")
      locationData$geofiltred <- NA
      locationData$timefiltred <- NA
      showNotification(ui = "Mise à jour de la carte", duration = NULL, closeButton = TRUE, id = "notifMap", type = "message")
      thisMapProxy %>%
        addDrawToolbar(
          layerID = "selectbox",
          polyline = FALSE,
          circle = FALSE,
          marker = FALSE,
          edit = FALSE,
          polygon = FALSE,
          rectangle = TRUE,
          remove = TRUE,
          singleLayer = TRUE
        )
      removeNotification( id = "notifMap")
      
    })

  })

  output$map <- renderLeaflet({
    mapData <- isolate(locationData$base)
    dataLength <- nrow(mapData)
    map <- leaflet(mapData) %>%
      addProviderTiles('CartoDB.DarkMatter',
                       group = "DarkMatter",
                       options = providerTileOptions(opacity = 1)) %>%
      addProviderTiles('Stamen.TonerLite',
                       group = "TonerLite",
                       options = providerTileOptions(opacity = 1)) %>%
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
      addLayersControl(
        baseGroups = c("DarkMatter", "TonerLite"),
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      addDrawToolbar(
        layerID = "selectbox",
        polyline = FALSE,
        circle = FALSE,
        marker = FALSE,
        edit = FALSE,
        polygon = FALSE,
        rectangle = TRUE,
        remove = TRUE,
        singleLayer = TRUE
      )
    
    map
  })
  outputOptions(output, "map", suspendWhenHidden = FALSE)
  
  observe({
    if (isTRUE(input$showClusters)){
      thisMapProxy <- leafletProxy("map", data = locationData$base)
      thisMapProxy %>%
        addMarkers(
          lng = ~ X,
          lat = ~ Y,
          clusterOptions = markerClusterOptions(),
          group = "Clusters"
        )
    } else {
      thisMapProxy <- leafletProxy("map", data = locationData$base)
      thisMapProxy %>%
        clearGroup(group = "Clusters")
    }
    
  })
  
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
  
  # Zoom map on spatial selection
  observe({
    req(input$fitToBounds)
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
  
 # Change the default behavior of deleting : 
 # the selectbox is deleted each time the user
 # clicks on the garbage/delete-mode icon
  observe({
    currentDeleting <- input$map_selectbox_deleting
    if (isTRUE(currentDeleting)){
      thisMapProxy <- leafletProxy("map")
      thisMapProxy %>%
        removeDrawToolbar() %>%
        addDrawToolbar(
          layerID = "selectbox",
          polyline = FALSE,
          circle = FALSE,
          marker = FALSE,
          edit = FALSE,
          polygon = FALSE,
          rectangle = TRUE,
          remove = TRUE,
          singleLayer = TRUE
        )
    } else if (is.null(currentDeleting)){
      locationData$geofiltred <- NA
    }
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
  
  # This is an ugly trick :
  # Leaflet.draw & Leaflet.heat are conflicting
  # When a heatmap is displayed, it's not possible
  # to delete a drawing
  # Thus, when delete is triggered, (_deleting == TRUE)
  # I remove the heatmap
  # And add it back when deleting session is finished (_deleting == NULL)
  observe({
    if (length(isolate(locationData$timefiltred)) > 1) {
      mapData <- isolate(locationData$timefiltred)
    } else {
      mapData <- isolate(locationData$base)
    }
    dataLength <- nrow(mapData)
    thisMapProxy <- leafletProxy("map", data = mapData)

    if (isTRUE(input$map_selectbox_deleting)){
      thisMapProxy %>% removeHeatmap("heatmap")
    } else if (is.null(input$map_selectbox_deleting)){
      thisMapProxy %>% addHeatmap(
        layerId = "heatmap",
        lng = ~ X,
        lat = ~ Y,
        intensity = (1 / dataLength) * 50 ,
        minOpacity = 0.2,
        radius = 5,
        blur = 5,
        gradient = "GnBu"
      )
    }
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
  }, bg = "transparent")
  
  output$calendarPlot <- renderPlot({
    req(locationData$base)
    
    if (length(locationData$geofiltred) > 1) {
      calendarFiltredData <- locationData$geofiltred %>%
        group_by(annee, moisN, monthWeek, jourN) %>%
        summarise(count =  n()) %>%
        mutate(jourN = factor(jourN, levels=rev(levels(jourN))))
      
      calendarPlot <- ggplot(locationData$base, aes(monthWeek, jourN, fill = count)) +
        geom_tile(data =calendarFiltredData, colour="#333333", alpha = 0.8) +
        facet_grid(annee~moisN) + 
        scale_fill_gradient(name="Densité", high="red",low="#333333") +
        scale_x_discrete("") +
        xlab("") +
        ylab("") +
        theme_timelineEDB() +
        theme(legend.position="bottom") +
        guides(fill = guide_legend(keywidth = 5, keyheight = 2))
      
      
    } else {
      calendarBaseData <- locationData$base %>%
        group_by(annee, moisN, monthWeek, jourN) %>%
        summarise(count =  n()) %>%
        mutate(jourN = factor(jourN, levels=rev(levels(jourN))))
      
      
      calendarPlot <- ggplot(calendarBaseData, aes(monthWeek, jourN, fill = count)) +
        geom_tile(colour="#333333", alpha = 0.8) +
        facet_grid(annee~moisN) + 
        scale_fill_gradient(name="Densité", high="#43a2ca",low="#333333") +
        scale_x_discrete("") +
        xlab("") +
        ylab("") +
        theme_timelineEDB() +
        theme(legend.position="bottom") +
        guides(fill = guide_legend(keywidth = 5, keyheight = 2))
    }
    
    calendarPlot
    
  },  bg = "transparent")
  
  
})
