

# Packages ----------------------------------------------------------------

if (!require("pacman")){
  install.packages("pacman")
} 

library(pacman)

p_load(shiny, shinydashboard, dashboardthemes, shinyFiles, gallerier,
       tidyverse, shinyjs, htmlwidgets, readr, reticulate, jpeg, here,
       magrittr, waiter, shinycssloaders, shinybusy)


# Python Packages
torch <- import("torch")
np <- import("numpy")



# java script and html ----------------------------------------------------

source(here("scripts/js_html_for_app.R"))



# Functions ---------------------------------------------------------------

# Theme and Logo of the App
source("dashboard_theme.R")
source("dashboard_logo.R")


# dynamically create the html img tags from the image files to be displayed
source("create_img_tags.R")
img_html <- read_file("img_html")


# Load the Classifier including pre-trained weights for Classifying uploaded 
# Shoe images
source_python("Inference_Shoe_Type_Classifier.py")


# Functions for Feature 1: Get recommended items and load respective images
# from the web
source(here("scripts/Feature_coding.R"))
source(here("scripts/feature_1_query_downloader.R"))
source(here("scripts/feature_1_functions.R"))



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

    # feature 1
    tabItems(
      tabItem(
        tabName = "recommendation",
        column(2,
          fluidRow(
            withSpinner(uiOutput("selected_shoe"), size = 0)
          )
        ),
        
  
              column(2,
                     withSpinner(uiOutput("recommended_items_class_1"), size = 0)
               ),
              column(2,
                     withSpinner(uiOutput("recommended_items_class_2"), color = "#4F4F4F")
               ),
               column(2,
                      withSpinner(uiOutput("recommended_items_class_3"), size = 0)
               ),
               column(2,
                      withSpinner(uiOutput("recommended_items_class_4"), size = 0)
               ),
               column(2,
                      withSpinner(uiOutput("recommended_items_class_5"), size = 0)
               ),
    
               
          
          #textOutput("text"),
          textOutput("feature_1_query")
          #textOutput("test_var")
      ),
      
      # feature 1
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
        
      )
      
    )
  )
)


# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # When an image in the gallery is clicked, we switch to the Outfit 
  # Recommendation tab, where the clicked image is displayed together with the 
  # recommended items
  
 

  observeEvent(input$last_click, {
    
    updateTabItems(session, "side_bar_menue", "recommendation")
    #current_img <- readJPEG(paste0("www/", file_path))
    #current_img_tensor <- torch$Tensor(current_img)
    #classifier_pred <- return_shoe_type(model, current_img_tensor)
    #pred_class <- return_shoe_type(model, current_img_tensor)
    
    file_path <- image_click_to_path(input$last_click)

    output$selected_shoe <- renderUI({
      img(id = "recommendation_shoe", src = file_path, style = image_style_recommendation_shoe)
    })
    
    recommendation_links_and_prices <- image_click_to_recommendation(input$last_click)[[1]]
  
    output$recommended_items_class_1 <- renderUI({
      recommendation_links_and_prices %>%
        .[1:3,] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_2 <- renderUI({
      recommendation_links_and_prices %>%
        .[4:6,] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_3 <- renderUI({
      recommendation_links_and_prices %>%
        .[7:9,] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_4 <- renderUI({
      recommendation_links_and_prices %>%
        .[10:12,] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_5 <- renderUI({
      recommendation_links_and_prices %>%
        .[13:15,] %>%
        create_image_objects_for_recommedation()
    })
  })
  
  
  
  
  output$text <- renderText({
    input$last_click
  })
  
  output$feature_1_query <- renderText({
    image_click_to_recommendation(input$last_click)[[2]] %>%
      paste0(collapse = ", ") %>%
      as.character()
  })
  
  
  

  
  
  
  

  

  
  
}




# Run App -----------------------------------------------------------------

shinyApp(ui, server)
