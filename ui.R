library(shiny)

shinyUI(fluidPage(
    titlePanel(title=div(img(src="NPR-Logo.jpg"), "  Member Station Explorer")),
    tabsetPanel(
        tabPanel(title = "Explorer",
        fluidRow(
            column(3,
                   radioButtons(inputId = "GeoView",
                                label = "Select Map:",
                                choices = c("National Station Map", "State-Level Station Map"),
                                selected = "National Station Map"
                   )),
            column(2,
                   conditionalPanel(condition = "input.GeoView == 'State-Level Station Map'",
                                    selectInput(inputId = "State",
                                                label = "Select State:",
                                                choices = unique(state_rollup$State),
                                                selected = "Michigan",
                                                selectize = TRUE)))),
        leafletOutput("national_state_map", width = "100%", height = 550),
        value = "national"),
    tabPanel(title = "Road Trip Map",
        fluidRow(column(3,
                        textInput(inputId = "Origin",
                                   label = "From:",
                                   value = "Washington, DC 20005, United States",
                                   placeholder = "Washington, DC 20005, United States")),
             column(3, textInput(inputId = "Destination",
                         label = "To:",
                         value = "Grand Rapids, MI 49534, United States",
                         placeholder = "Grand Rapids, MI 49534, United States")),
             column(3, actionButton(inputId = "MapIt",
                                   label = "Map My Route",
                                   width = "100%"))),
        tags$style(type='text/css', "#MapIt { width:100%; margin-top: 25px;}"),
        leafletOutput("route_map", width = "100%", height = 550),
        value = "roadtrip")
    
    )
))
