

# Packages ----------------------------------------------------------------

if (!require("pacman")){
  install.packages("pacman")
} 

library(pacman)

p_load(shiny, shinydashboard, dashboardthemes, shinyFiles, gallerier,
       tidyverse, shinyjs, htmlwidgets, readr, reticulate, jpeg, here,
       magrittr, waiter, shinycssloaders, shinybusy, scales, tidymodels)


# Python Packages
torch <- import("torch")
np <- import("numpy")



# java script and html ----------------------------------------------------

source(here::here("scripts/js_html_for_app.R"))



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
database_unique_classes <- readRDS(here("data/database_unique_classes.rds"))




# Functions ---------------------------------------------------------------

# Theme and Logo of the App
source("dashboard_theme.R")
source("dashboard_logo.R")


# dynamically create the html img tags from the image files to be displayed
source("create_img_tags.R")
img_html <- read_file("img_html")


# Load the Classifier including pre-trained weights for Classifying uploaded 
# Shoe images
source_python(here("scripts/Inference_Shoe_Type_Classifier.py"))

# Load Random Forest Model for Feature 2 including pre-trained weights
source_python(here("scripts/RF_prediction.py"))




# Functions for Feature 1: Get recommended items and load respective images
# from the web
source(here::here("scripts/Feature_coding.R"))
source(here::here("scripts/feature_1_query_downloader.R"))
source(here::here("scripts/feature_1_functions.R"))
source(here::here("scripts/feature_2_and_3_functions.R"))




# Modules -----------------------------------------------------------------

source(here::here("scripts/data_exploration_module.R"))



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
      #menuItem("Data Exploration", tabName = "data_exploration", icon = icon("wpexplorer")),
      menuItem("Shoe Gallery", tabName = "image_selection", icon = icon("camera")),
      menuItem("Outfit Recommendation", tabName = "recommendation", icon = icon("dumbbell")),
      menuItem("Shoe Recommendation", tabName = "recommendation2", icon = icon("dumbbell")),
      menuItem("Outfit Evaluation", tabName = "evaluation", icon = icon("dumbbell"))
    )
  ),
  dashboardBody(
    customTheme,

    
    # tabItem(
    #   tabName = "data_exploration",
    # 
    #   fluidRow(
    #     explorationUI("exploration"),
    #     plotlyOutput("test_plot"),
    #     plotlyOutput("test_plot2")
    #   )
    # ),
    
    
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
          conditionalPanel("!is.null(output.recommended_items_class_2)",
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
          ),
          br(), br(),
          box(
            id = "feature_1_button_box",
            actionButton(
              inputId = "action_button_feature_1",
              label = "Start Calculations"
            ),
            title = "Get Recommendations",
            width = 9
          )
        ),
        column(
          2,
          withSpinner(uiOutput("recommended_items_class_1"), size = 0)
        ),
        column(
          2,
          withSpinner(uiOutput("recommended_items_class_2"), size = 0)
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
      ),
      
      
      
      tabItem(
        tabName = "recommendation2",
        conditionalPanel(
          "input.side_bar_menue == 'recommendation2'",
          fileInput("feature_2_upload", NULL, buttonLabel = "Upload...", multiple = TRUE),
        ),
        
        
        column(
          2,
          fluidRow(
            imageOutput("feature_2_image")
          )
        ),
        column(
          6,
          fluidRow(
            withSpinner(
              DT::dataTableOutput("feature_2_results")
            )
          )
        )
      ),
      tabItem(
        tabName = "evaluation",
        column(2,
               br(), br(), 
               
        conditionalPanel(
          "input.side_bar_menue == 'evaluation'",
          fluidRow(
            useShinyjs(),  # Set up shinyjs
            
            box(
              id = "feature_3_outfit_box",
              fileInput(
                "feature_3_upload_body", 
                NULL, 
                buttonLabel = "Upload...", 
                multiple = FALSE
              ), 
              uiOutput("feature_3_outfit_spinner"),
              title = "Upload an image of your outfit", 
              width = 12
            ),
            uiOutput("feature_3_shoe_box_and_spinner"),
            br(), br(),
            uiOutput("feature_3_button_box_ui")
            
  
          ),
          
         
        )
        ),
        column(
          2,
          uiOutput("feature_3_recommended_items_class_1")
        ),
        column(
          2,
          uiOutput("feature_3_recommended_items_class_2")
        ),
        column(
          2,
          uiOutput("feature_3_recommended_items_class_3")
        ),
        column(
          2,
          uiOutput("feature_3_recommended_items_class_4")
        )
      )
    )
  )
)


# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  hide("feature_3_shoe_box")
  hide("feature_3_button_box")


# Feature 1 ---------------------------------------------------------------


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
    
    
  })
  
  
  observeEvent(input$action_button_feature_1, {
    #recommendation_links_and_prices <<- image_click_to_recommendation(input$last_click)[[1]]
    recommendation_links_and_prices <<-  reactive({
      req(input$last_click, 
          input$feature_1_filter_gender, 
          input$feature_1_filter_country)
      image_click_to_recommendation(input$last_click,
                                    country = input$feature_1_filter_country,
                                    gender = input$feature_1_filter_gender,
                                    filter_opts = input$feature_1_filter_items_class)[[1]]
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
  
  

# Exploration -------------------------------------------------------------

  
  
  explorationServer("exploration")
  df <- data.frame(x = c(1,2,3), y = c(3,4,5), z = c(5, 9, 2))
  p <- df %>% 
    ggplot(aes(x,y)) +
    geom_point() 
  output$test_plot <- renderPlotly(
    p %>% 
      ggplotly()
  )
  
  output$test_plot2 <- renderPlotly({
    plot <- plot_ly(df,
                    type = "scatter3d",
                    mode = "markers",
                    x = ~x, y = ~y, z = ~z
    
  )
  })
  
  

# Feature 2 ---------------------------------------------------------------

  
  
  observeEvent(input$feature_2_upload, {
    feature_2_image <<- readJPEG(input$feature_2_upload$datapath)
    
    output$feature_2_image <- renderImage({
      list(
        src = input$feature_2_upload$datapath,
        width = 200,
        height = 250
      )
    }, deleteFile = FALSE)
    
    
    
    reticulate::source_python(here("scripts/fashionpedia_python_script.py"))
    feature_2_attributes <- extract_fashion_attibutes(
      model = "attribute_mask_rcnn", 
      image_size=as.integer(640), 
      in_app_use=TRUE, 
      shoe_image_path=input$feature_2_upload$datapath
    )
    feature_2_attributes_df <<- do.call(rbind, feature_2_attributes) %>% 
      extract_attributes_from_fashionpedia_raw()
    feature_2_attributes_df_reac <- reactive({
      feature_2_attributes_df
    })
    pca_estimates <- readRDS(here("data/pca_estimates.rds"))
    pca_results <- pca_estimates %>% 
      bake(new_data = feature_2_attributes_df) 
    classes_to_be_removed <- setdiff(1:46, database_unique_classes)
    pca_results <- pca_results %>% 
      filter(!(classes %in% classes_to_be_removed))
    missing_classes <- setdiff(database_unique_classes, pca_results$classes)
    
    missing_classes_df <- matrix(
      NA, 
      nrow = length(missing_classes), 
      ncol = ncol(pca_results)
    ) %>% 
      data.frame()
    
    colnames(missing_classes_df) <- colnames(pca_results)
    missing_classes_df$classes <- missing_classes
    pca_results <- pca_results %>% 
      bind_rows(missing_classes_df)
    
    pca_results <- pca_results %>% 
      gather(-image_file, -classes, key = "PC", value = "value") %>%
      unite(col = PC_class, classes, PC) %>%
      spread(key = PC_class, value = value, fill = 0) %>%
      select(-image_file)
    
    output$feature_2_results <- DT::renderDataTable({
      feature_2_attributes_df_reac()
    })
    
    browser()
    
  })

  
 
  
  
  # output$feature_2_image <- renderUI({
  #   tagList(
  #     h5(id = paste0("feature_2_upload"), 
  #        tags$b("Shoe Upload:"),
  #        align = "center"),
  #     img(id = "feature_2_upload", 
  #         src = input$feature_2_upload$datapath, 
  #         style = image_style_shoe_selected_recommendation_tab)
  #   )
  # })
  
  
  

# Feature 3 ---------------------------------------------------------------


  
  
 
  observeEvent(input$feature_3_upload_body, {
    
    output$feature_3_outfit_spinner <- renderUI({
      withSpinner(
        imageOutput(
          "feature_3_image_body",
          height = "300px"
        )
      )
    }) 
    
  

    
    output$feature_3_shoe_box_and_spinner <- renderUI({
      box(
        fileInput(
          "feature_3_upload_shoe", 
          NULL, 
          buttonLabel = "Upload...", 
          multiple = FALSE
        ),
        imageOutput(
          "feature_3_image",
          height = "300px"
        ),
        textOutput("feature_2_shoe_pred"),
        
        textOutput("feature_3_cosine_similarity"),
        
        title = "Upload an image of your shoe",
        width = 12,
        id = "feature_3_shoe_box"
      )
    })
    
    
    
    
    
    # Enable the user to upload an image of a shoe only after a body shot has
    # already been provided
    toggleElement(
      id = "feature_3_shoe_box", 
      condition = !is.null(input$feature_3_upload_body)
    )
    
    
    output$feature_3_image_body <- renderImage({
      list(
        src = input$feature_3_upload_body$datapath,
        width = 200,
        height = 250
      )
    }, deleteFile = FALSE)
    

  })
  
  observeEvent(input$feature_3_upload_shoe, {
    
    if(is.null(input$feature_3_upload_body)){
      showModal(modalDialog(
        title = "Important message",
        "Provide an image of your outfit before you upload a shoe image"
      ))
    } else {
    
    
    output$feature_3_image <- renderImage({
      list(
        src = input$feature_3_upload_shoe$datapath,
        width = 200,
        height = 250
      )
    }, deleteFile = FALSE)
    
    
    
    
    output$feature_3_button_box_ui <- renderUI({
      box(
        id ="feature_3_button_box",
        actionButton(
          "action_button_feature_3",
          label = "Start"
        ),
        title = "Get Recommendations", 
        width = 12
      )
    })
    
    # Enable the user to start the calculations only after a body shot and 
    # shoe image have been provided
    toggleElement(
      id = "feature_3_button_box", 
      condition = !is.null(input$feature_3_upload_shoe)
    )
    
    }
    

    
  })
  
  
  observeEvent(input$action_button_feature_3, {
    
    browser()
    feature_3_image_body <- readJPEG(input$feature_3_upload_body$datapath)
    reticulate::source_python(here("scripts/fashionpedia_python_script.py"))
    feature_3_attributes <- extract_fashion_attibutes(
      model = "attribute_mask_rcnn",
      image_size = as.integer(640),
      in_app_use = TRUE,
      shoe_image_path = input$feature_3_upload_body$datapath
    )

    feature_3_attributes_df <<- do.call(rbind, feature_3_attributes) %>%
      extract_attributes_from_fashionpedia_raw()
    print("Feature 3 Fashionpedia Done")

    feature_3_image_shoe <- reactive({
      readJPEG(input$feature_3_upload_shoe$datapath)
    })
    torch <- import("torch")
    feature_3_tensor_shoe <- torch$Tensor(feature_3_image_shoe())
    feature_3_shoe_pred <- reactive({
      return_shoe_type(model_weights, feature_3_tensor_shoe)
    })
    output$feature_2_shoe_pred <- renderText({
      paste0("Predicted Shoe Type: ", feature_3_shoe_pred())
    })



    feature_3_results <- reactive({
      feature_3_coding(
        feature_3_attributes_df,
        feature_3_shoe_pred()
      )
    })

    output$feature_3_cosine_similarity <- renderText({
      paste0(
        "Cosine Similarity: ",
        feature_3_results()[[1]] %>%
          scales::percent(0.1)
      )
    })


    feature_3_diff_query <- feature_3_results() %>%
      extract2(2) %>%
      unite(
        col = "query",
        everything(),
        sep = " "
      ) %>%
      extract2("query")

    feature_3_further_queries <- feature_3_results() %>%
      extract2(3) %>%
      select(-Probability) %>%
      unite(
        col = "query",
        everything(),
        sep = " "
      ) %>%
      extract2("query")

    feature_3_diff_query_links <- reactive({
      req(
        input$feature_3_upload_shoe,
        input$feature_3_upload_body
      )
      feature_3_diff_query %>%
        cosine_similarity_to_recommendation() %>%
        extract2(1)
    })

    feature_3_further_queries_links <- reactive({
      req(
        input$feature_3_upload_shoe,
        input$feature_3_upload_body
      )
      feature_3_further_queries %>%
        cosine_similarity_to_recommendation() %>%
        extract2(1)
    })


    output$feature_3_recommended_items_class_1 <- renderUI({
      feature_3_diff_query_links() %>%
        create_image_objects_for_recommedation()
    })

    output$feature_3_recommended_items_class_2 <- renderUI({
      feature_3_further_queries_links() %>%
        .[1:3, ] %>%
        create_image_objects_for_recommedation()
    })

    output$feature_3_recommended_items_class_3 <- renderUI({
      feature_3_further_queries_links() %>%
        .[4:6, ] %>%
        create_image_objects_for_recommedation()
    })

    output$feature_3_recommended_items_class_4 <- renderUI({
      feature_3_further_queries_links() %>%
        .[7:9, ] %>%
        create_image_objects_for_recommedation()
    })
  })
  
  
  
  
  
  




}

# Run App -----------------------------------------------------------------

  
  
shinyApp(ui, server)
