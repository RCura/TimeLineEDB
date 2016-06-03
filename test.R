densityPlot  <-  ggplot(formattedData, aes(dhour))  +
  geom_density(col = "black",  fill = "green", alpha = 0.3, adjust = 0.75) +
  scale_x_continuous("Heure",breaks = c(0,6,12,18,24), minor_breaks = c(3, 9, 15, 21)) +
  scale_y_continuous("Densité", labels = scales::percent) +
  theme_timelineEDB()

densityPlot + theme(panel.grid.major = element_line(colour = "gray50", 
    size = 0.3, linetype = "longdash"), panel.grid.minor = element_line(colour = "gray30", 
    size = 0.1, linetype = "dotdash"), panel.background = element_rect(fill = "black"))

if (length(locationData$geofiltred)>1){
  densityPlot <- densityPlot + 
    geom_density(data = locationData$geofiltred, aes(dhour),
                 col = "red",  fill = "red", alpha = 0.3,
                 adjust = 0.75)
}
densityPlot 



mapData <- formattedData
dataLength <- nrow(mapData)
map <- leaflet(mapData %>% mutate(X =  round(X, digits = 3), Y =  round(Y, digits = 3))) %>%
  addProviderTiles('CartoDB.DarkMatter', group = "DarkMatter") %>%
  addMarkers(lng = ~X, lat = ~Y,   clusterOptions = markerClusterOptions(), group = "Clusters") %>%
  hideGroup("Clusters") %>%
  addHeatmap(layerId = "heatmap", lng = ~X, lat = ~Y,
             intensity = (1/dataLength) * 10 , minOpacity = 0.3,
             radius = 5, blur = 5, gradient = "GnBu") %>%
  fitBounds(2.359, 48.810 ,2.359 , 48.810)

map

abc <- ggplot(formattedData, aes(x = jour, y = mois)) + geom_point()



homeData <- formattedData %>%
  filter(heure > 19 | heure < 8) %>%
  filter(mois != 7, mois != 8) %>%
  mutate(Xround = round(X, 3)) %>%
  mutate(Yround = round(Y, 3)) %>%
  group_by(Xround, Yround) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  arrange(desc(count)) %>%
  top_n(1)

leaflet() %>%
