library(shiny)
library(dplyr)
library(leaflet)
library(htmltools)
library(maps)
library(ggmap)

stations <- read.csv("npr_stations_list.csv", stringsAsFactors = FALSE) %>%
    mutate(popup_content = paste0("<a href='http://www.", Website, "' style='color:#3399ff' target='_blank'>", Call.Sign, " (", 
                                  Frequency, " ", AM.FM, ")</a>"))

city_rollup <- stations %>%
    group_by(City, State, Latitude, Longitude, Population) %>%
    summarise(station_count = length(Call.Sign),
              popup_content = paste(popup_content, collapse = "</br>")) %>%
    mutate(keep = "TRUE")

state_rollup <- stations %>%
    group_by(State) %>%
    summarise(avg_lat = mean(Latitude), avg_lon = mean(Longitude),
              station_count = length(Call.Sign),
              popup_content = paste(popup_content, collapse = "</br>"))

earth.dist <- function (long1, lat1, long2, lat2) {rad <- pi/180
                a1 <- lat1 * rad
                a2 <- long1 * rad
                b1 <- lat2 * rad
                b2 <- long2 * rad
                dlon <- b2 - a2
                dlat <- b1 - a1
                a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
                c <- 2 * atan2(sqrt(a), sqrt(1 - a))
                R <- 3963.196
                d <- R * c
                return(d)
}

pickStationsOnRoute <- function(origin, destination, city_df) {
    
    route_df <- route(from = origin,
          to = destination,
          mode = "driving",
          structure = "route")

    for(i in 1:nrow(city_df)) {
        city_lat <- city_df$Latitude[i]
        city_lon <- city_df$Longitude[i]
        for(j in 1:nrow(route_df)) {
            route_lat <- route_df$lat[j]
            route_lon <- route_df$lon[j]
            route_df$distances[j] <- earth.dist(city_lon, city_lat,
                                                route_lon, route_lat)
        }
        
        city_df$keep[i] <- min(route_df$distances) <= 100
    }
    city_df_filtered <- city_df %>%
            dplyr::filter(keep == "TRUE")

    return(city_df_filtered)
}
