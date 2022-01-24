

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

source(here::here("scripts/js_html_for_app.R"))




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
source(here::here("scripts/Feature_coding.R"))
source(here::here("scripts/feature_1_query_downloader.R"))
source(here::here("scripts/feature_1_functions.R"))



# Data --------------------------------------------------------------------

pca_result <- readRDS(here("data/fp_select_attrib_per_class_pca.rds"))
# ToDo: Außerhalb der App machen (vorher)
pca_result$new_brand <- plyr::mapvalues(pca_result$brand, 
                                  from = c("Adidas_Stan_Smith", "Adidas_Ultraboost",
                                           "Asics_Gel", "Birkenstock_Arizona", "Crocs",
                                           "Fila_Sneaker", "Louboutin_Shoes", "Puma_Sneaker",
                                           "vans_sneaker"), 
                                  to = c("Sneaker", "Sneaker",
                                         "Sneaker", "Sandal", "Sandal",
                                         "Sneaker", "High-Heel", "Sneaker",
                                         "Sneaker"))


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
      menuItem("Data Exploration", tabName = "data_exploration", icon = icon("wpexplorer")),
      menuItem("Shoe Gallery", tabName = "image_selection", icon = icon("camera")),
      menuItem("Outfit Recommendation", tabName = "recommendation", icon = icon("dumbbell")),
      menuItem("Shoe Recommendation", tabName = "recommendation2", icon = icon("dumbbell")),
      menuItem("Outfit Evaluation", tabName = "evaluation", icon = icon("dumbbell"))
    )
  ),
  dashboardBody(
    customTheme,

    
    tabItem(
      tabName = "data_exploration",
    
      sidebarLayout(
        
        # inputs
        conditionalPanel("input.side_bar_menue == 'data_exploration'",
          # select type of clothing that should be shown
          radioButtons(inputId = "choice", label = "What type of apparel item are you interested in?", 
                       choices = c("Pullovers", "Shirts", "Dresses", "Pants")),
          
          # select type of shoe to be shown
          checkboxGroupInput("variable", "Type of shoe to show:",
                             #c(as.character(sort(unique(pca_result$new_brand)))),
                             c("Sneaker", "Sandal", "Flipflops", "High-Heel", "Sandal"),
                             #selected = as.character(sort(unique(pca_result$new_brand)))[1],
                             selected = "Sneaker",
                             inline = F),
          width = 2),
        mainPanel())
    ),
    
    
    # feature 1: Recommendation Page
    tabItems(
      # feature 1: Image Selection in Gallery
      tabItem(
        tabName = "image_selection",
        conditionalPanel("input.side_bar_menue == 'image_selection'",
        fluidRow(
          useShinyjs(),
          tags$head(tags$script(HTML(js))),
          HTML(img_html),
        )),
        mainPanel(
          div(id = "image-container", style = "display:flexbox")
        )
      ),
      tabItem(
        tabName = "recommendation",
        conditionalPanel("input.side_bar_menue == 'recommendation'",
        column(
          2,
          fluidRow(
            withSpinner(uiOutput("selected_shoe"), size = 0)
          ),
          br(), br(), br(),
          conditionalPanel("input.side_bar_menue == 'recommendation'",
            selectizeInput(
              "feature_1_filter_gender",
              label = "Change your gender",
              choices = c("Men", "Women", "Diverse"),
              selected = "Men",
              width = "230px"
            )
          ),
          br(),
          conditionalPanel("input.side_bar_menue == 'recommendation'",
                           selectizeInput(
                             "feature_1_filter_country",
                             label = "Change country of origin",
                             choices = c("de", "es", "fr", "gb", "it", "us"),
                             selected = "us",
                             width = "230px"
                           )
          ),
          conditionalPanel("input.side_bar_menue == 'recommendation'",
                           selectizeInput(
                             "feature_1_filter_items_class",
                             label = "Which items do you want recommendations for?",
                             choices = c("shirt, blouse", "top, t-shirt, sweatshirt", 
                                         "sweater", "cardigan", "jacket", "vest", "pants", 
                                         "shorts", "skirt", "coat", "dress", "jumpsuit", 
                                         "glasses", "hat", "tie") %>% 
                               sort(),
                             width = "230px",
                             multiple = TRUE,
                             options = list(maxItems = 5) 
                           )
          )
        ),
        column(
          2,
          withSpinner(uiOutput("recommended_items_class_1"), size = 0)
        ),
        column(
          2,
          withSpinner(uiOutput("recommended_items_class_2"), color = "#4F4F4F")
        ),
        column(
          2,
          withSpinner(uiOutput("recommended_items_class_3"), size = 0)
        ),
        column(
          2,
          withSpinner(uiOutput("recommended_items_class_4"), size = 0)
        ),
        column(
          2,
          withSpinner(uiOutput("recommended_items_class_5"), size = 0)
        ),
        textOutput("feature_1_query")
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
    # current_img <- readJPEG(paste0("www/", file_path))
    # current_img_tensor <- torch$Tensor(current_img)
    # classifier_pred <- return_shoe_type(model, current_img_tensor)
    # pred_class <- return_shoe_type(model, current_img_tensor)

    file_path <- image_click_to_path(input$last_click)

    output$selected_shoe <- renderUI({
      tagList(
        h5(id = paste0("selected_image"), 
           tags$b("selected shoe:"),
           align = "center"),
        img(id = "recommendation_shoe", 
            src = file_path, 
            style = image_style_shoe_selected_recommendation_tab)
      )
    })
    
    

    
    #recommendation_links_and_prices <<- image_click_to_recommendation(input$last_click)[[1]]
    recommendation_links_and_prices <<-  reactive({
      req(input$last_click, 
          input$feature_1_filter_gender, 
          input$feature_1_filter_country)
      image_click_to_recommendation(input$last_click,
                                    country = input$feature_1_filter_country,
                                    gender = input$feature_1_filter_gender)[[1]]
    })

    output$recommended_items_class_1 <- renderUI({
      recommendation_links_and_prices() %>%
        .[1:3, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_2 <- renderUI({
      recommendation_links_and_prices() %>%
        .[4:6, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_3 <- renderUI({
      recommendation_links_and_prices() %>%
        .[7:9, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_4 <- renderUI({
      recommendation_links_and_prices() %>%
        .[10:12, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_5 <- renderUI({
      recommendation_links_and_prices() %>%
        .[13:15, ] %>%
        create_image_objects_for_recommedation()
    })
  })

  
 

  

}




# Run App -----------------------------------------------------------------

shinyApp(ui, server)
