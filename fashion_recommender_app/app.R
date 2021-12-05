

# Packages ----------------------------------------------------------------

library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinyFiles)
library(gallerier)
library(tidyverse)
library(shinyjs)
library(htmlwidgets)
library(readr)





# java script and html ----------------------------------------------------

js <- "
$(document).ready(function(){
  $('img').on('click', function(){
    Shiny.setInputValue('last_click', this.id);
  });
})
"

image_style_gallery <- "cursor:pointer; width:200pt; height:250pt;border: 1px solid #ddd;
  border-radius: 0px;
  padding: 8px;
  width: 200pt;
  hover:box-shadow: 0 0 2px 1px rgba(0, 140, 186, 0.5);"

image_style_recommendation_shoe <- "cursor:pointer; width:200pt; height:250pt;border: 1px solid #ddd;
  border-radius: 0px;
  padding: 8px;
  width: 200pt;
  hover:box-shadow: 0 0 2px 1px rgba(0, 140, 186, 0.5);"


# Functions ---------------------------------------------------------------

source("dashboard_theme.R")
source("dashboard_logo.R")
# dynamically create the html img tags from the image files to be displayed
source("create_img_tags.R")
img_html <- read_file("img_html")




# UI ----------------------------------------------------------------------

ui <- dashboardPage(
  dashboardHeader(
    title = customLogo,
    titleWidth = "270"
  ),
  
  dashboardSidebar(
    width = "270",
    sidebarSearchForm(textId = "searchbar", buttonId = "searchbtn", label = "Search..."),
    sidebarMenu(
      id = "side_bar_menue",
      menuItem("Image Selection", tabName = "image_selection", icon = icon("camera")),
      menuItem("Recommendation", tabName = "recommendation", icon = icon("dumbbell"))
      
      #menuItem("Model Performance", tabName = "model_performance", icon = icon("chart-line"))
    )
  ),
  dashboardBody(
    customTheme,
    tabItems(
      tabItem(
        tabName = "recommendation",
        fluidRow(
          #shinyDirButton("folder", "Select a folder", "Please select a folder", FALSE),
          #textOutput("folder"),
          #actionButton("start_straining", label = "Starte Modell-Training"),
          uiOutput("recommende_shoe"),
          br(),
          textOutput("text")
          
        )
      ),
      tabItem(
        tabName = "image_selection",
        
        fluidRow(
          useShinyjs(),
          tags$head(tags$script(HTML(js))),
          #img(id="test",src="img/Adidas_Stan_Smith.jpg",width="19.5%",style=image_style),
          HTML(img_html),
          #img(id="my_img3",src="img/New_Balance.jpg",width="19.5%",style=image_style),
          #uiOutput("image_galery"),
          
        ),
        mainPanel(
          div(id = "image-container", style = "display:flexbox")
        )
      ),
      tabItem(
        tabName = "model_performance"
      )
    )
  )
)

# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  
  # image_galery_files <- list.files("www/img")
  # image_galery_list <- list()
  # for(i in seq_along(image_galery_files)){
  #   file_name <- image_galery_files[[i]]
  #   file_src <- paste0("img/", file_name)
  #   image_galery_list[[i]] <- img(id=file_name,src=file_src,
  #       style="cursor:pointer; width:200pt; height:250pt;border: 1px solid #ddd;
  # border-radius: 0px;
  # padding: 8px;
  # width: 200pt;
  # hover:box-shadow: 0 0 2px 1px rgba(0, 140, 186, 0.5);")
  #   onclick(file_name, function(){
  #     updateTabItems(session, "side_bar_menue", "model_training")
  #     }
  #   )
  # }
  
  
  #output$image_galery <- renderUI({image_galery_list})
  
  
  observeEvent(input$last_click, {
    file_name <- str_replace_all(input$last_click, " ", "_") %>% 
      paste0(".jpg")
    file_path <- paste0("img/", file_name)
    file_id <- "recommendation_shoe"
    output$recommende_shoe <- renderUI({
      img(id = file_id, src = file_path, style = image_style_recommendation_shoe)
    })
    updateTabItems(session, "side_bar_menue", "recommendation")
  })
  
  
  output$text <- renderText({
    input$last_click
  })
  
  
  
  
  
  
}




# Run App -----------------------------------------------------------------

shinyApp(ui, server)
