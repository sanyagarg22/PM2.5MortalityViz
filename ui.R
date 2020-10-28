library(shiny)
library("sf")
library("leaflet")
library(stringr)
library(RCurl)
library(shiny)
library(rsconnect)

lowestDate <- "2020-01-22"
highestDate <- "2020-10-24"

ui <- verticalLayout (
  tags$style(type='text/css', "body { font-family: Arial;}" ),
  titlePanel("PM 2.5 & Mortality Visualizations"),
  verticalLayout(
    p("The Harvard University", a("COVID-19 PM2.5 study", href = "https://projects.iq.harvard.edu/covid-pm/home"), "investigates whether long-term average exposure to fine particulate matter (PM2.5) is associated with an increased risk of COVID-19 death in the United States. It found that an increase of only 1 ug/m3 in PM2.5 is associated with an 8% increase in the COVID-19 death rate. The results were statistically significant and robust to secondary and sensitivity analyses. Despite inherent limitations of the ecological study design, the results underscore the importance of continuing to enforce existing air pollution regulations to protect human health both during and after the COVID-19 crisis."),
    p("The below visualizations illustrate the data used in the study in the format of interactive maps that compare PM2.5 levels to COVID-19 mortality."),
    p("Created by Sanya Garg."),
    splitLayout(
      verticalLayout(
        h3("PM 2.5 Levels Over Time (2000-2016)"),
        leafletOutput("mymap"),
        sliderInput(inputId = "slider",
                    label = "Year",
                    min = 2000,
                    max = 2016,
                    value = 0,
                    step = 1,
                    width = "97%")
      ),
      verticalLayout(
        h3(paste("Daily COVID-19 Mortality Over Time (", lowestDate, " to ", highestDate, ")")),
        leafletOutput("mymap2"),
        sliderInput(inputId = "slider2",
                    label = "Dates",
                    min = as.Date(lowestDate),
                    max = as.Date(highestDate),
                    value = as.Date(lowestDate),
                    step = 2,
                    timeFormat="%Y-%m-%d",
                    width = "97%")
      )
    ),
    splitLayout(
      verticalLayout(
        h3("Mean PM 2.5 Levels"),
        leafletOutput("mymap3")
      ),
      verticalLayout(
        h3("Cumulative COVID-19 Mortality"),
        leafletOutput("mymap4")
      )
    )
  )
)
