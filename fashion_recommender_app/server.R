server <- function(input, output, session) {
  
  
  # Hide different items which should be displayed after some observation
  
  hide("feature_3_shoe_box")
  hide("feature_3_button_box")
  hide("feature_1_spinner")
  hide("feature_3_spinner")
  hide("feature_2_spinner")
  hide("feature_3_select_box")
  hide("feature_3_adjust")
  hide("feature_3_additional")
  hideTab(inputId = "feature_1_tabs", target = "Shoe Recommendation")

  
  
  # Landing Page ------------------------------------------------------------
  
  
  # Slider on Landing Page
  output$slickr <- renderSlickR({
    #imgs <- list.files("www/", pattern = ".png", full.names = TRUE)
    imgs <- c("shutter1_edit.png", "shutter2_edit.png", "shutter3_edit.png")
    slickR(imgs,
           slideId = 'myslick',
           slideType = "img",
           height = 480) +
      settings(slidesToShow = 1,centerMode = F,autoplay = T,
               autoplaySpeed = 5000, speed = 800, dots = T,
               arrows = F)
  })
  
  
  # Get started button to Feature 1
  observeEvent(input$get_started_button, {
    updateTabItems(session, "side_bar_menue", selected = "recommendation")
  })
  
  
  # Link to Feature 1
  observeEvent(input$button_outfit_feat1, {
    updateTabItems(session, "side_bar_menue", "recommendation")
  })
  
  
  # Link to Feature 2
  observeEvent(input$button_shoe_feat2, {
    updateTabItems(session, "side_bar_menue", "recommendation2")
  })
  
  
  # Link to Feature 3
  observeEvent(input$button_eval_feat3, {
    updateTabItems(session, "side_bar_menue", "evaluation")
  })
  
  
 
  # Feature 1 ---------------------------------------------------------------
  
  # Not yet implemented 
  # observeEvent(input$feature_1_upload_shoe, {
  #   # Predict the uploaded shoe type
  #   feature_1_image_shoe <- reactive({
  #     readJPEG(isolate(input$feature_1_upload_shoe$datapath))
  #   })
  #   
  #   feature_1_shoe_pred <<- predict_shoe(feature_1_image_shoe())
  #   feature_1_shoe_pred_reac <- reactive({
  #     feature_1_shoe_pred
  #   })
  #   output$feature_1_shoe_pred <- renderText({
  #     paste("Predicted Shoe Type: ", feature_1_shoe_pred_reac(), sep = "\n")
  #   })
  # 
  # 
  # # When an image is uploaded, we switch to the Outfit
  # # Recommendation tab, where the image is displayed together with the
  # # recommended items
  # observeEvent(input$action_button_feature_1_upload, {
  #   
  #   hide("recommended_items_class_1")
  #   hide("recommended_items_class_2")
  #   hide("recommended_items_class_3")
  #   hide("recommended_items_class_4")
  #   hide("recommended_items_class_5")
  #   
  #   showTab("feature_1_tabs", "Shoe Recommendation")
  #   
  #   # Shoe recommendation is shown after update
  #   updateTabsetPanel(
  #     session, 
  #     inputId = "feature_1_tabs", 
  #     selected = "Shoe Recommendation"
  #   )
  #   
  #   # current_img <- readJPEG(paste0("www/", file_path))
  #   # current_img_tensor <- torch$Tensor(current_img)
  #   # classifier_pred <- return_shoe_type(model, current_img_tensor)
  #   # pred_class <- return_shoe_type(model, current_img_tensor)
  #   
  #   file_path <- image_click_to_path(feature_1_shoe_pred)
  #   
  #   output$selected_shoe <- renderUI({
  #     tagList(
  #       h5(id = paste0("selected_image"),
  #          align = "center"),
  #       img(id = "recommendation_shoe",
  #           src = file_path,
  #           style = image_style_shoe_selected_recommendation_tab)
  #     )
  #   })
  #   output$feature_1_selected_shoe <- renderText({
  #     feature_1_shoe_pred
  #   })
  # })
  # })
  # 
  # 
  # # The recommendation engine starts to run after the activation button is pressed
  # observeEvent(input$action_button_feature_1, {
  #   
  #   toggleElement(
  #     id = "feature_1_spinner",
  #     condition = !is.null(isolate(input$action_button_feature_1))
  #   )
  #   # Obtain the links and prices of the items to be displayed
  #   recommendation_links_and_prices <- reactive({
  #     req(
  #         input$feature_1_filter_gender,
  #         input$feature_1_filter_country)
  #     image_click_to_recommendation(feature_1_shoe_pred,
  #                                   country = isolate(input$feature_1_filter_country),
  #                                   gender = isolate(input$feature_1_filter_gender),
  #                                   filter_opts = isolate(input$feature_1_filter_items_class))
  #   })
  #   
  #   
  #   
  #   # Create the objects displayed in the UI with its formatting / titles
  #   output$recommended_items_class_1 <- renderUI({
  #     isolate(recommendation_links_and_prices()) %>%
  #       create_image_objects_for_recommedation(col = 1)
  #   })
  #   
  #   output$recommended_items_class_2 <- renderUI({
  #     isolate(recommendation_links_and_prices()) %>%
  #       create_image_objects_for_recommedation(col = 2)
  #   })
  #   
  #   output$recommended_items_class_3 <- renderUI({
  #     isolate(recommendation_links_and_prices()) %>%
  #       create_image_objects_for_recommedation(col = 3)
  #   })
  #   
  #   output$recommended_items_class_4 <- renderUI({
  #     isolate(recommendation_links_and_prices()) %>%
  #       create_image_objects_for_recommedation(col = 4)
  #   })
  #   
  #   output$recommended_items_class_5 <- renderUI({
  #     isolate(recommendation_links_and_prices()) %>%
  #       create_image_objects_for_recommedation(col = 5)
  #   })
  #   
  #   show("recommended_items_class_1")
  #   show("recommended_items_class_2")
  #   show("recommended_items_class_3")
  #   show("recommended_items_class_4")
  #   show("recommended_items_class_5")
  #   
  # })
  
  
  # When an image in the gallery is clicked, we switch to the Outfit
  # Recommendation tab, where the clicked image is displayed together with the
  # recommended items
  observeEvent(input$last_click, {
    
    hide("recommended_items_class_1")
    hide("recommended_items_class_2")
    hide("recommended_items_class_3")
    hide("recommended_items_class_4")
    hide("recommended_items_class_5")
    
    showTab("feature_1_tabs", "Shoe Recommendation")

    # Shoe recommendation is shown after update
    updateTabsetPanel(
      session, 
      inputId = "feature_1_tabs", 
      selected = "Shoe Recommendation"
    )
    
    # current_img <- readJPEG(paste0("www/", file_path))
    # current_img_tensor <- torch$Tensor(current_img)
    # classifier_pred <- return_shoe_type(model, current_img_tensor)
    # pred_class <- return_shoe_type(model, current_img_tensor)
    
    file_path <- image_click_to_path(input$last_click)
    
    output$selected_shoe <- renderUI({
      tagList(
        h5(id = paste0("selected_image"),
           align = "center"),
        img(id = "recommendation_shoe",
            src = file_path,
            style = image_style_shoe_selected_recommendation_tab)
      )
    })
    output$feature_1_selected_shoe <- renderText({
      input$last_click
    })
  })
  
  
  # The recommendation engine starts to run after the activation button is pressed
  observeEvent(input$action_button_feature_1, {
    
    toggleElement(
      id = "feature_1_spinner",
      condition = !is.null(isolate(input$action_button_feature_1))
    )
    
    # Obtain the links and prices of the items to be displayed
    recommendation_links_and_prices <- reactive({
      req(input$last_click,
          input$feature_1_filter_gender,
          input$feature_1_filter_country)
      image_click_to_recommendation(isolate(input$last_click),
                                    country = isolate(input$feature_1_filter_country),
                                    gender = isolate(input$feature_1_filter_gender),
                                    filter_opts = isolate(input$feature_1_filter_items_class))
    })
    
    
    
    # Create the objects displayed in the UI with its formatting / titles
    output$recommended_items_class_1 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        create_image_objects_for_recommedation(col = 1)
    })
    
    output$recommended_items_class_2 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        create_image_objects_for_recommedation(col = 2)
    })
    
    output$recommended_items_class_3 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        create_image_objects_for_recommedation(col = 3)
    })
    
    output$recommended_items_class_4 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        create_image_objects_for_recommedation(col = 4)
    })
    
    output$recommended_items_class_5 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        create_image_objects_for_recommedation(col = 5)
    })
    
    show("recommended_items_class_1")
    show("recommended_items_class_2")
    show("recommended_items_class_3")
    show("recommended_items_class_4")
    show("recommended_items_class_5")
    
    })
  
  
  
  # Feature 2 ---------------------------------------------------------------
  
  
  # Procedure when an image is uploaded
  observeEvent(input$feature_2_upload, {
    feature_2_image <- readJPEG(input$feature_2_upload$datapath)
    
    # Display the image
    output$feature_2_image <- renderImage({
      list(
        src = input$feature_2_upload$datapath,
        width = 200,
        height = 250,
        style = image_style_outfit_selected_recommendation_tab
      )
    }, deleteFile = FALSE)
    
    # Filter options for country and gender
    output$feature_2_select_box <- renderUI({
      box(
        id = "feature_2_select_box",
        selectizeInput(
          "feature_2_filter_gender",
          label = "Select gender",
          choices = c("Men", "Women", "Diverse"),
          selected = "Men",
          width = "230px"
        ),
        selectizeInput(
          "feature_2_filter_country",
          label = "Select country of origin",
          choices = c("de", "es", "fr", "gb", "it", "us"),
          selected = "us",
          width = "230px"
        ),
        width = 12
      )
      

    })
    
    
    # Action button to activate recommendation engine
    output$feature_2_button_box_ui <- renderUI({
      box(
        id ="feature_2_button_box",
        actionButton(
          "action_button_feature_2",
          label = "Start Calculations"
        ),
        title = "Get Recommendations",
        width = 12
      )
    })
    
  })
  
  
  # Procedure, when activation button is pressed
  observeEvent(input$action_button_feature_2, {
    
    hide("feature_2_recommended_items_class_1")
    hide("feature_2_recommended_items_class_2")
    hide("feature_2_recommended_items_class_3")

    
    # Spinner to show that the server is running
    show("feature_2_spinner")

    
    # Extract corresponding vogue images to vogue titles
        lapply(1:nrow(vogue_df), function(i) {
      output[[paste0('pic', i)]] <- renderUI({
        tags$img(src = vogue_df$link_pic[i], width = 110)
      })
    })
    
    # Modal of vogue titles and images
      showModal(modalDialog(
        id = "pop2", 
        title = "While we're analyzing your outfit, why don't you
            check out the latest fashion trends...?",
        easyClose = TRUE,
        fluidPage(
          
          fluidRow(
            
            lapply(1:nrow(vogue_df), function(i) {
              
              fluidRow(
                
                box(
                  status = "primary", width = 8, title = NULL, headerBorder = NULL,
                  tags$div(
                    tags$a(href=vogue_df$link[i],
                           vogue_df$header[i], style = "color: #000000")
                  ), style = "font-size: 18px; text-align: left;"),
                box(
                  status = "primary", width = 4,
                  div(uiOutput(paste0('pic', i)), style = "text-align: right"),
                ), style = "border-bottom: 1px solid; padding: 5px;"
              )
            }), theme = "bootstrap.css"
          )
        )
      ))


    # Analyze the uploaded image with respect to classes and attributes
    reticulate::source_python(here("scripts/fashionpedia_python_script.py"))
    feature_2_attributes <- extract_fashion_attibutes(
      model = "attribute_mask_rcnn",
      image_size=as.integer(640),
      in_app_use=TRUE,
      shoe_image_path=input$feature_2_upload$datapath
    )
    
    # Preparation steps before random forest is applicable
    feature_2_attributes_df <- do.call(rbind, feature_2_attributes) %>%
      extract_attributes_from_fashionpedia_raw()
    feature_2_attributes_df_reac <- reactive({
      feature_2_attributes_df
    })
    
    # Call PCA estimates
    pca_estimates <- readRDS(here("data/pca_estimates.rds"))
    pca_results <- pca_estimates %>%
      bake(new_data = feature_2_attributes_df)
    classes_to_be_removed <- setdiff(1:46, database_unique_classes)
    pca_results <- pca_results %>%
      filter(!(classes %in% classes_to_be_removed))
    missing_classes <- setdiff(database_unique_classes, pca_results$classes)
    
    # Include zeros such that all classes are included
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
    
    # Collect PCA results
    pca_results <- pca_results %>%
      gather(-image_file, -classes, key = "PC", value = "value") %>%
      unite(col = PC_class, classes, PC) %>%
      spread(key = PC_class, value = value, fill = 0) %>%
      select(-image_file)
    
    colnames(pca_results) <- pca_results %>%
      colnames() %>%
      paste0("class_", .)
    
    
    # Recommendation algorithm is conducted based on the features extracted
    feature_2_recommended_shoes <- make_recomm_feature2(rf_final, pca_results)
    
    # Scrape the information from Asos
    recommendation_links_and_prices_feature_2 <- reactiveValues(
      recommendation_1 = feature_2_recommended_shoes[1] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape(
          country = input$feature_2_filter_country,
          gender = input$feature_2_filter_gender
        ),
      recommendation_2 = feature_2_recommended_shoes[2] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape(
          country = input$feature_2_filter_country,
          gender = input$feature_2_filter_gender
        ),
      recommendation_3 = feature_2_recommended_shoes[3] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape(
          country = input$feature_2_filter_country,
          gender = input$feature_2_filter_gender
        )
    )
    
    # Display the scraped information in the UI
    output$feature_2_recommended_items_class_1 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_1 %>%
        create_image_objects_for_recommedation(
          feature = 2, 
          shoe_title = feature_2_recommended_shoes[1]
        )
    })
    
    output$feature_2_recommended_items_class_2 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_2 %>%
        create_image_objects_for_recommedation(
          feature = 2,
          shoe_title = feature_2_recommended_shoes[2]
        )
    })
    
    output$feature_2_recommended_items_class_3 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_3 %>%
        create_image_objects_for_recommedation(
          feature = 2,
          shoe_title = feature_2_recommended_shoes[3]
        )
    })
    
    
    show("feature_2_recommended_items_class_1")
    show("feature_2_recommended_items_class_2")
    show("feature_2_recommended_items_class_3")
    
  })
  
  
  # Feature 3 ---------------------------------------------------------------
  
  
  # Display the body shot
  observeEvent(input$feature_3_upload_body, {
    output$feature_3_outfit_spinner <- renderUI({
      withSpinner(
        imageOutput(
          "feature_3_image_body",
          height = "320px"
        )
      )
    })
    

    # Display the shoe upload, cosine similarity and the shoe type prediction
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
          height = "320px"
        ),
        textOutput("feature_3_shoe_pred"),
        textOutput("feature_3_cosine_similarity"),
        
        title = "Upload a Shoe",
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
    

    
    # How the body shot should be displayed
    output$feature_3_image_body <- renderImage({
      list(
        src = input$feature_3_upload_body$datapath,
        width = 200,
        height = 250,
        style = image_style_outfit_selected_recommendation_tab
      )
    }, deleteFile = FALSE)
    
  })
  

  # Case query if a shoe is uploaded
  observeEvent(input$feature_3_upload_shoe, {

    if(is.null(input$feature_3_upload_body)){
      showModal(modalDialog(
        title = "Important message",
        "Provide an image of your outfit before you upload a shoe image",
        easyClose = TRUE
      ))
    } else {
      
      # Shoe is indeed uploaded
      output$feature_3_outfit <- renderImage({
        list(
          src = input$feature_3_upload_body$datapath,
          width = 200,
          height = 250,
          style = image_style_outfit_selected_recommendation_tab
        )
      }, deleteFile = FALSE)
      
      # Gender and country selection
      output$feature_3_select_box <- renderUI({
        box(
          id = "feature_3_select_box",
          selectizeInput(
            "feature_3_filter_gender",
            label = "Select gender",
            choices = c("Men", "Women", "Diverse"),
            selected = "Men",
            width = "230px"
          ),
          selectizeInput(
            "feature_3_filter_country",
            label = "Select country of origin",
            choices = c("de", "es", "fr", "gb", "it", "us"),
            selected = "us",
            width = "230px"
          ),
          width = 12
        )
      })
      
      toggleElement(
        id = "feature_3_select_box",
        condition = !is.null(input$feature_3_upload_shoe)
      )
      
      # How to display the uploaded shoe
      output$feature_3_image <- renderImage({
        list(
          src = input$feature_3_upload_shoe$datapath,
          width = 200,
          height = 250,
          style = image_style_outfit_selected_recommendation_tab
        )
      }, deleteFile = FALSE)
      
    }
    
    # Activation button to call the recommandation system
    output$feature_3_button_box_ui <- renderUI({
      box(
        id ="feature_3_button_box",
        actionButton(
          "action_button_feature_3",
          label = "Start Calculations"
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
    
  })
  
  # Test to display vogue images before FP is running
  rv <- reactiveValues()
  rv$run <- 10
  
  # When the activation button is pressed
  observeEvent(input$action_button_feature_3, {
    hide("feature_3_adjust")
    hide("feature_3_additional")
    hide("feature_3_recommended_items_class_1")
    hide("feature_3_recommended_items_class_2")
    hide("feature_3_recommended_items_class_3")
    hide("feature_3_recommended_items_class_4")
    
    
    # Vogue information when FP is loading
    lapply(1:nrow(vogue_df), function(i) {
      output[[paste0('pic', i)]] <- renderUI({
        tags$img(src = vogue_df$link_pic[i], width = 110)
      })
      if(i == nrow(vogue_df)){
        showModal(modalDialog(
          id = "pop3", 
          title = "While we're analyzing your outfit, why don't you
            check out the latest fashion trends...?",
          easyClose = TRUE,
          fluidPage(
            
            fluidRow(
              
              lapply(1:nrow(vogue_df), function(i) {
                
                fluidRow(
                  
                  box(
                    status = "primary", width = 8, title = NULL, headerBorder = NULL,
                    tags$div(
                      tags$a(href=vogue_df$link[i],
                             vogue_df$header[i], style = "color: #000000")
                    ), style = "font-size: 18px; text-align: left;"),
                  box(
                    status = "primary", width = 4,
                    div(uiOutput(paste0('pic', i)), style = "text-align: right"),
                  ), style = "border-bottom: 1px solid; padding: 5px;"
                )
              }), theme = "bootstrap.css"
            )
          )
        ))
        rv$run <- rv$run + 1
      }
    })
    observeEvent(rv$run, {
    # Has to be displayed when the action button was clicked
    
    show("feature_3_spinner")
    
    # Extract classes and attributes from uploaded body shot
    feature_3_image_body <- readJPEG(isolate(input$feature_3_upload_body$datapath))
    reticulate::source_python(here("scripts/fashionpedia_python_script.py"))
    feature_3_attributes <- extract_fashion_attibutes(
      model = "attribute_mask_rcnn",
      image_size = as.integer(640),
      in_app_use = TRUE,
      shoe_image_path = isolate(input$feature_3_upload_body$datapath)
    )
    
    
    # Preparation work for the analysis
    feature_3_attributes_df <- do.call(rbind, feature_3_attributes) %>%
      extract_attributes_from_fashionpedia_raw()
    print("Feature 3 Fashionpedia Done")
    check_fp_done_feature3 <- 1
    
    
    # Predict the uploaded shoe type
    feature_3_image_shoe <- reactive({
      readJPEG(isolate(input$feature_3_upload_shoe$datapath))
    })
    #torch <- reticulate::import("torch")
    #feature_3_tensor_shoe <- torch$Tensor(feature_3_image_shoe())
    feature_3_shoe_pred <- reactive({
      predict_shoe(feature_3_image_shoe())
    })
    output$feature_3_shoe_pred <- renderText({
      paste("Predicted Shoe Type: ", feature_3_shoe_pred(), sep = "\n")
    })
    
    
    # Get the class to change and further clothing items to recommend (Feature 3 analysis)
    feature_3_results <- reactive({
      feature_3_coding(
        feature_3_attributes_df,
        feature_3_shoe_pred()
      )
    })
    
    # Output the similarity score
    output$feature_3_cosine_similarity <- renderText({
      paste0(
        "Fit of Shoe and Outfit: ",
        feature_3_results()[[1]] %>%
          scales::percent(0.1)
      )
    })

    # Combine class and attribute of class, which the user should rather change
    feature_3_diff_query <- feature_3_results() %>%
      extract2(2) %>%
      unite(
        col = "query",
        everything(),
        sep = " "
      ) %>%
      extract2("query")
    
    # Extract title information in UI
    feature_3_diff_query_header <- feature_3_results() %>%
      extract2(2) 
    
    # Combine class and attribute of complementary recommendation
    feature_3_further_queries <- feature_3_results() %>%
      extract2(3) %>%
      select(-Probability) %>%
      unite(
        col = "query",
        everything(),
        sep = " "
      ) %>%
      extract2("query")
    
    # Titles for complements
    feature_3_further_queries_header <- feature_3_results() %>%
      extract2(3) %>%
      select(-Probability)
    
    # Query to the class_diff recommendation
    feature_3_diff_query_links <- reactive({
      req(
        input$feature_3_upload_shoe,
        input$feature_3_upload_body
      )
      feature_3_diff_query %>%
        cosine_similarity_to_recommendation(
          country = input$feature_3_filter_country,
          gender = input$feature_3_filter_gender
        ) %>%
        extract2(1)
    })

    # Queries to complement recommendation
    feature_3_further_queries_links <- reactive({
      req(
        input$feature_3_upload_shoe,
        input$feature_3_upload_body
      )
      feature_3_further_queries %>%
        cosine_similarity_to_recommendation(
          country = input$feature_3_filter_country,
          gender = input$feature_3_filter_gender
        ) %>%
        extract2(1)
    })
    
    # Create output object for UI
    output$feature_3_recommended_items_class_1 <- renderUI({
      isolate(feature_3_diff_query_links()) %>%
        create_image_objects_for_recommedation(feature = 3, col = 1, feat_3_header = feature_3_diff_query_header)
    })
    
    output$feature_3_recommended_items_class_2 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[1:3, ] %>%
        create_image_objects_for_recommedation(feature = 3, col = 2, feat_3_header = feature_3_further_queries_header[1,])
    })
    
    output$feature_3_recommended_items_class_3 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[4:6, ] %>%
        create_image_objects_for_recommedation(feature = 3, col = 3, feat_3_header = feature_3_further_queries_header[2,])
    })
    
    output$feature_3_recommended_items_class_4 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[7:9, ] %>%
        create_image_objects_for_recommedation(feature = 3, col = 4, feat_3_header = feature_3_further_queries_header[3,])
    })
    
  
    
    show("feature_3_adjust")
    show("feature_3_additional")
    show("feature_3_recommended_items_class_1")
    show("feature_3_recommended_items_class_2")
    show("feature_3_recommended_items_class_3")
    show("feature_3_recommended_items_class_4")
  })
  })
  
  
  # Titles to distinguish between difference and complements
  output$feature_3_adjust <- renderUI({
      h4("Adjust the following item")
  })
  output$feature_3_additional <- renderUI({
    h4("Current fashion trends add ..")
  })
  
  
  
  ## Feature 4 - Server ------------------------------------------------------
  
  
  # Data input for the dimensionality reduction
  dataInput_feat4 <- isolate(reactive({
    if (input$choice_cloth == "Entire outfit") {
      df_plot <- umap_result_image
    } else {
      df_plot <- umap_result_classes
    }
    df_plot <- df_plot %>% filter(new_brand %in% input$variable_shoe & new_classes %in% input$choice_cloth)
    df_plot$new_brand <- as.character(df_plot$new_brand)
    return(df_plot)
  }))
  
  
  # Output plot dimensionality reduction
  output$plot_feat4 <- renderPlotly(
    plot_feat4 <- plot_ly(dataInput_feat4(),
                          type = "scatter3d",
                          mode = "markers",
                          x = ~UMAP1, y = ~UMAP2, z = ~UMAP3,
                          color = ~new_brand,
                          colors = c("orangered", "green3", "royalblue3"),
                          size = 0.7,
                          hoverinfo = "text",
                          text = paste(dataInput_feat4()$new_brand),
                          height = 800, width = 1200) %>%
      layout(scene = list(xaxis = list(showticklabels = F, title = "",
                                       showgrid = T, zeroline = F, showspikes = F),
                          yaxis = list(showticklabels = F, title = "",
                                       showgrid = T, zeroline = F, showspikes = F),
                          zaxis = list(showticklabels = F, title = "",
                                       showgrid = T, zeroline = F, showspikes = F)),
             legend = list(x = 0, y = 1,
                           title = list(text = "<b> Shoes selected </b>")))
  )
  
  
  data_Input_bar_interactive <- isolate(reactive({
    
    df_bar_plot <- descriptives_db %>%
    # makes sure to only count one class per image but should be the case anyway due to prev. processing
    group_by(image_file, new_brand, new_classes) %>%
    dplyr::summarize() %>%
    ungroup() %>%
    select(-image_file) %>%
    #
    group_by(new_brand) %>%
    dplyr::mutate(count_brand = n()) %>%
    ungroup() %>%
    group_by(new_brand, new_classes) %>%
    dplyr::summarize(count = n(),
                     count_brand = mean(count_brand)) %>%
    mutate(rel = count / count_brand) %>%
    filter(new_brand %in% input$var_shoe) %>%
    filter(new_classes %in% input$var_cloth)
    return(df_bar_plot)
  }))
  
  # plot
  output$plot_bar_interactive <- renderPlot({
  ggplot(data_Input_bar_interactive(), aes(fill = new_brand, y = rel, x = new_classes)) + 
    geom_bar(position = "dodge", stat = "identity") + 
    ylab("Relative Frequency") + 
    labs(fill = "Shoe brand / type") + 
    scale_fill_manual(values=c("orangered", "green3", "royalblue3", "mediumpurple3", "lightsteelblue1")) + 
    theme(axis.text.x = element_text(angle = 315, hjust = 0.5, vjust = 0.5),
          panel.background = element_blank(),
          panel.grid.major.y = element_line(size = 0.3, linetype = 'solid',
                                            colour = "gray"),
          panel.grid.major.x = element_blank(),
          axis.title.y = element_text(color = "black", size = 14, margin = margin(r=15)),
          axis.line.x = element_line(color = "black"),
          axis.line.y = element_line(color = "black"),
          axis.text = element_text(color = "black", size = 12),
          axis.title.x = element_blank())
  })

  
  
  # Plot for descriptives to get to know the configuration of the database
  
  # Information on shoe type distribution
  output$plot_descr_shoe <- renderPlot({
    descriptives_db %>% group_by(image_file) %>% slice(1) %>%
    ggplot(aes(x = fct_infreq(new_brand))) +
      geom_bar(stat = "count", width = 0.7, fill = "#4F4F4F") +
      scale_y_continuous(name = "count") + 
      theme(axis.text.x = element_text(angle = 270, hjust = 0, vjust = 0.5),
            panel.background = element_blank(),
            panel.grid.major.y = element_line(size = 0.3, linetype = 'solid',
                                              colour = "gray"),
            panel.grid.major.x = element_blank(),
            axis.line.x = element_line(color = "black"),
            axis.line.y = element_line(color = "black"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(color = "black", size = 12, margin = margin(r=10)),
            axis.text = element_text(color = "black"))
  })
  
  # Information on clothing item distribution
  output$plot_descr_cloth <- renderPlot({
    ggplot(descriptives_db, aes(x = fct_infreq(new_classes))) +
      geom_bar(stat = "count", width = 0.7, fill = "#4F4F4F") +
      scale_y_continuous(name = "count", limits = c(0, 5500), breaks = seq(0, 5500, 1000)) + 
      theme(axis.text.x = element_text(angle = 270, hjust = 0, vjust = 0.5),
            panel.background = element_blank(),
            panel.grid.major.y = element_line(size = 0.3, linetype = 'solid',
                                              colour = "gray"),
            panel.grid.major.x = element_blank(),
            axis.line.x = element_line(color = "black"),
            axis.line.y = element_line(color = "black"),
            axis.title.x = element_blank(),            
            axis.title.y = element_text(color = "black", size = 12, margin = margin(r=10)),
            axis.text = element_text(color = "black"))
  })
  
  
  
  
  
  
  
  
  
}