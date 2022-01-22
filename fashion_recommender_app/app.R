

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
library(reticulate)
library(jpeg)

torch <- import("torch")
np <- import("numpy")
source_python("Inference_Shoe_Type_Classifier.py")





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
    width = "310",
    sidebarMenu(
      id = "side_bar_menue",
      br(), br(),
      menuItem("Shoe Gallery", tabName = "image_selection", icon = icon("camera")),
      menuItem("Outfit Recommendation", tabName = "recommendation", icon = icon("dumbbell")),
      menuItem("Shoe  Recommendation", tabName = "recommendation2", icon = icon("dumbbell")),
      menuItem("Outfit Evaluation", tabName = "evaluation", icon = icon("dumbbell"))
    )
  ),
  
  dashboardBody(
    
    customTheme,
    
    tabItems(
      tabItem(
        tabName = "recommendation",
        fluidRow(
          uiOutput("recommende_shoe"),
          br(),
          textOutput("text"),
          textOutput("test_var")
          
        )
      ),
      
      tabItem(
        tabName = "image_selection",
        
        fluidRow(
          useShinyjs(),
          tags$head(tags$script(HTML(js))),
          HTML(img_html),
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
    
    current_img <- readJPEG(paste0("www/", file_path))
    current_img_tensor <- torch$Tensor(current_img)
    classifier_pred <- return_shoe_type(model, current_img_tensor)
    #pred_class <- return_shoe_type(model, current_img_tensor)
    
    
    output$recommende_shoe <- renderUI({
      img(id = file_id, src = file_path, style = image_style_recommendation_shoe)
    })
    updateTabItems(session, "side_bar_menue", "recommendation")
    #browser()
  })
  
  # observeEvent(input$side_bar_menue, {
  #   if(input$side_bar_menue){}
  # })
  
  
  output$text <- renderText({
    input$last_click
  })
  
  #py_run_file("fashion_recommender_app/Inference_Shoe_Type_Classifier.py")
  
  #output$test_var <- renderText({
  #  y <- py$classes
  #  y[2] %>% unlist()
  #})
  

  
  
}




# Run App -----------------------------------------------------------------

shinyApp(ui, server)
