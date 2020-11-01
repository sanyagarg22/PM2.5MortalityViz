library(ggplot2)
library(plyr)
library(dplyr)
library("sf")
library("leaflet")
library(RCurl)
library(httr)
library(shiny)
library(htmltools)
library(rsconnect)

load("time_pm25_map.RData")
load("mean_pm25_map.RData")
load("mean_mortality_map.RData")
load("time_mortality_map.RData")

server <- function(input, output) {
  filteredData <- reactive({
    filter(time_pm25_map, year == input$slider)
  })
  
  colorpal <- colorBin("YlOrRd", time_pm25_map$pm25, 6, pretty = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addLegend("bottomright", pal = colorpal, values = time_pm25_map$pm25,
                title = "PM 2.5 Levels ",
                opacity = 1) %>%
      setView(-95.712891, 37.09024, zoom = 3)
  })
  
  filteredMortalityData <- reactive({
    filter(time_mortality_map, Date == as.character(input$slider2))
  })
  
  colorpal2 <- colorBin("YlOrRd", time_mortality_map$mortality, 6, pretty = FALSE)
  
  output$mymap2 <- renderLeaflet({
    leaflet() %>%
      addLegend("bottomright", pal = colorpal2, values = time_mortality_map$mortality,
                title = "Mortality (Deaths/Population) per 10,000",
                opacity = 1, group = "Mortality") %>%
      setView(-95.712891, 37.09024, zoom = 3)
  })
  
  pmbinpal <- colorBin("YlOrRd", mean_pm25_map$mean_pm25, 6, pretty = FALSE)
  meanpm25popup <- sprintf(
    "<strong>%s County</strong><br/>%g",
    mean_pm25_map$NAME, mean_pm25_map$mean_pm25
  ) %>% lapply(htmltools::HTML)
  output$mymap3 <- renderLeaflet({
    leaflet() %>%
      addPolygons(data = mean_pm25_map, color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.7, fillOpacity = 0.5,
                  fillColor = ~pmbinpal(mean_pm25),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE), group = "Mean PM 2.5",  popup = ~meanpm25popup) %>%
      addLegend("bottomright", pal = pmbinpal, values = mean_pm25_map$mean_pm25,
                title = "Mean PM 2.5 Levels",
                opacity = 1, group = "Mean PM 2.5"
                
      )
  })
  
  mortalitybinpal <- colorBin("YlOrRd", mean_mortality_map$Crude.Rate, 6, pretty = FALSE)
  mortalitypopup <- sprintf(
    "<strong>%s County</strong><br/>%g",
    mean_mortality_map$NAME, mean_mortality_map$Crude.Rate
  ) %>% lapply(htmltools::HTML)
  
  output$mymap4 <- renderLeaflet({
    leaflet() %>%
      addPolygons(data = mean_mortality_map, color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.7, fillOpacity = 0.5,
                  fillColor = ~mortalitybinpal(Crude.Rate),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE), group = "Mortality", popup = ~mortalitypopup) %>%
      addLegend("bottomright", pal = mortalitybinpal, values = mean_mortality_map$Crude.Rate,
                title = "Mortality (Deaths/Population) per 10,000",
                opacity = 1, group = "Mortality"
      )
  })
  
  
  observe({
    timepm25popup <- sprintf(
      "<strong>%s County</strong><br/>%g",
      filteredData()$NAME, filteredData()$pm25
    ) %>% lapply(htmltools::HTML)
    
    leafletProxy("mymap", data = filteredData()) %>%
      clearShapes() %>%
      addPolygons(data = filteredData(), color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.7, fillOpacity = 0.5,
                  fillColor = ~colorpal(pm25),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE), group = "Mean PM 2.5", popup = ~timepm25popup)
    
  })
  
  observe({
    timemortalitypopup <- sprintf(
      "<strong>%s County</strong><br/>%g",
      filteredMortalityData()$NAME, filteredMortalityData()$mortality
    ) %>% lapply(htmltools::HTML)
    leafletProxy("mymap2", data = filteredMortalityData()) %>%
      clearShapes() %>%
      addPolygons(data = filteredMortalityData(), color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.7, fillOpacity = 0.5,
                  fillColor = ~colorpal2(mortality),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE), group = "Mortality", popup = ~timemortalitypopup)
  })
}

