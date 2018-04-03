library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    df <- city_rollup
    
    route_polylines <- eventReactive(input$MapIt,
                                     route(from = input$Origin,
                                           to = input$Destination,
                                           mode = "driving",
                                           structure = "route")
                                     )
    
    route_df_2 <- eventReactive(input$MapIt,
                              pickStationsOnRoute(input$Origin,
                                                  input$Destination, 
                                                  city_rollup))
                    
    output$national_state_map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron,
                             options = providerTileOptions(minZoom = 3, maxZoom = 8)) %>%
            addCircles(lng = df$Longitude,
                       lat = df$Latitude,
                       radius= df$station_count*ifelse(input$GeoView %in% c("State-Level Station Map"),
                                                        10000, 15000),
                       layerId = df$City,
                       weight = 1.5,
                       fillColor = "#3399ff", 
                       fillOpacity = 0.5,
                       highlightOptions = highlightOptions(color = "#3399ff", weight = 3.5, 
                                                           bringToFront = TRUE),
                       popup = lapply(paste0("<b>", df$City, ", ",
                                             df$State, "</b></br>",
                                             df$popup_content), HTML)) %>%
            setView(lng = ifelse(input$GeoView %in% c("State-Level Station Map"),
                                 state_rollup$avg_lon[which(state_rollup$State == input$State)],
                                 -98.5795),
                    lat = ifelse(input$GeoView %in% c("State-Level Station Map"),
                                 state_rollup$avg_lat[which(state_rollup$State == input$State)],
                                 39.8283),
                    zoom = ifelse(input$GeoView %in% c("National Station Map", 
                                                       "Road Trip Map (beta)"), 4, 6))
    })
    
    output$route_map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron,
                             options = providerTileOptions(minZoom = 3, maxZoom = 8)) %>%
            addCircles(lng = route_df_2()$Longitude,
                       lat = route_df_2()$Latitude,
                       radius= route_df_2()$station_count*15000,
                       layerId = route_df_2()$City,
                       weight = 1.5,
                       fillColor = "#3399ff", 
                       fillOpacity = 0.5,
                       highlightOptions = highlightOptions(color = "#3399ff", weight = 3.5, 
                                                           bringToFront = TRUE),
                       popup = lapply(paste0("<b>", route_df_2()$City, ", ",
                                             route_df_2()$State, "</b></br>",
                                             route_df_2()$popup_content), HTML)) %>%
            addPolylines(route_polylines(),
                         lng = route_polylines()$lon, 
                         lat = route_polylines()$lat,
                         color = "red") %>%
            setView(lng = mean(route_polylines()$lon),
                    lat = mean(route_polylines()$lat),
                    zoom = 5)
    })
})
