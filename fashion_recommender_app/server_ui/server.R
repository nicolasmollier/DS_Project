


# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  hide("feature_3_shoe_box")
  hide("feature_3_button_box")
  hide("feature_1_spinner")
  hide("feature_3_spinner")




  # Landing Page ------------------------------------------------------------

  output$slickr <- renderSlickR({
    #imgs <- list.files("www/", pattern = ".png", full.names = TRUE)
    imgs <- c("www/shutter1_edit.png", "www/shutter2_edit.png", "www/shutter3_edit.png")
    slickR(imgs,
           slideId = 'myslick',
           slideType = "img",
           height = 430) +
      settings(slidesToShow = 1,centerMode = F,autoplay = T,
               autoplaySpeed = 5000, speed = 800, dots = T,
               arrows = F)
    })

  # Get started button to Feature 1
  observeEvent(input$get_started_button, {
    updateTabItems(session, "side_bar_menue", "recommendation")
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


  # Explanation Text box in sidebar
  # observeEvent(input$tabName, {
  #   if (input$tabName == "recommendation"){
  #
  #   output$expl_text_box <- renderText({
  #     tags$div(
  #       tags$ul(
  #         tags$li("Upload shoe / Choose from gallery"),
  #         tags$li("Select gender"),
  #         tags$li("Select country"),
  #         tags$li("Select desired clothing items (optional)")
  #       )
  #     )
  #   })
  #
  # } else if (input$tabName == "recommendation2"){
  #
  #   output$expl_text_box <- renderText({
  #     tags$div(
  #       tags$ul(
  #         tags$li("Upload outfit"),
  #         tags$li("Select gender"),
  #         tags$li("Select country")
  #       )
  #     )
  #   })
  #
  # } else if (input$tabName == "evaluation"){
  #
  #   output$expl_text_box <- renderText({
  #     tags$div(
  #       tags$ul(
  #         tags$li("Upload outfit"),
  #         tags$li("Upload shoe"),
  #         tags$li("Select gender"),
  #         tags$li("Select country")
  #       )
  #     )
  #   })
  # }})





  # Feature 1 ---------------------------------------------------------------


  # When an image in the gallery is clicked, we switch to the Outfit
  # Recommendation tab, where the clicked image is displayed together with the
  # recommended items
  observeEvent(input$last_click, {

    hide("recommended_items_class_1")
    hide("recommended_items_class_2")
    hide("recommended_items_class_3")
    hide("recommended_items_class_4")
    hide("recommended_items_class_5")

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

    toggleElement(
      id = "feature_1_spinner",
      condition = !is.null(isolate(input$action_button_feature_1))
    )

    #recommendation_links_and_prices <<- image_click_to_recommendation(input$last_click)[[1]]
    recommendation_links_and_prices <- reactive({
      req(input$last_click,
          input$feature_1_filter_gender,
          input$feature_1_filter_country)
      image_click_to_recommendation(isolate(input$last_click),
                                    country = isolate(input$feature_1_filter_country),
                                    gender = isolate(input$feature_1_filter_gender),
                                    filter_opts = isolate(input$feature_1_filter_items_class))[[1]]
    })


    # create_image_objects_for_recommedation outputs classes + attributes separately - bring it in front-end
    output$recommended_items_class_1 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[1:3, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_2 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[4:6, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_3 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[7:9, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_4 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[10:12, ] %>%
        create_image_objects_for_recommedation()
    })

    output$recommended_items_class_5 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[13:15, ] %>%
        create_image_objects_for_recommedation()
    })

    show("recommended_items_class_1")
    show("recommended_items_class_2")
    show("recommended_items_class_3")
    show("recommended_items_class_4")
    show("recommended_items_class_5")


  })



  # Exploration -------------------------------------------------------------



  #explorationServer("exploration")
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

    colnames(pca_results) <- pca_results %>%
      colnames() %>%
      paste0("class_", .)




    feature_2_recommended_shoes <- make_recomm_feature2(rf_final, pca_results)

    recommendation_links_and_prices_feature_2 <- reactiveValues(
      recommendation_1 = feature_2_recommended_shoes[1] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape(),
      recommendation_2 = feature_2_recommended_shoes[2] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape(),
      recommendation_3 = feature_2_recommended_shoes[3] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape()
    )

    output$feature_2_recommended_items_class_1 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_1 %>%
        create_image_objects_for_recommedation(feature = 2)
    })

    output$feature_2_recommended_items_class_2 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_2 %>%
        create_image_objects_for_recommedation(feature = 2)
    })

    output$feature_2_recommended_items_class_3 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_3 %>%
        create_image_objects_for_recommedation(feature = 2)
    })

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


      # Information when FP is loading
      if (input$feature_3_filter_gender == "Diverse"){
        vogue_df <- rbind(scrape_news("Men"), scrape_news("Women"))
      } else {
        vogue_df <- scrape_news(input$feature_3_filter_gender)
      }

      lapply(1:nrow(vogue_df), function(i) {
        output[[paste0('pic', i)]] <- renderUI({
          tags$img(src = vogue_df$link_pic[i], width = 110)
        })
      })

      observeEvent(input$button_analyze,
                   {
                     showNotification("Yay! We're finished analyzing your outfit.
                                  Get your personalized recommendations now!",
                                      type = "message", duration = 500)
                   }



      )


    }


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

  })


  observeEvent(input$action_button_feature_3, {

    hide("feature_3_recommended_items_class_1")
    hide("feature_3_recommended_items_class_2")
    hide("feature_3_recommended_items_class_3")
    hide("feature_3_recommended_items_class_4")

    # toggleElement(
    #   id = "feature_3_spinner",
    #   condition = !is.null(isolate(input$action_button_feature_3))
    # )

    show("feature_3_spinner")

    feature_3_image_body <- readJPEG(isolate(input$feature_3_upload_body$datapath))
    feature_3_attributes <- extract_fashion_attibutes(
      model = "attribute_mask_rcnn",
      image_size = as.integer(640),
      in_app_use = TRUE,
      shoe_image_path = isolate(input$feature_3_upload_body$datapath)
    )

    feature_3_attributes_df <- do.call(rbind, feature_3_attributes) %>%
      extract_attributes_from_fashionpedia_raw()
    print("Feature 3 Fashionpedia Done")

    feature_3_image_shoe <- reactive({
      readJPEG(isolate(input$feature_3_upload_shoe$datapath))
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
      isolate(feature_3_diff_query_links()) %>%
        create_image_objects_for_recommedation(feature = 3)
    })

    output$feature_3_recommended_items_class_2 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[1:3, ] %>%
        create_image_objects_for_recommedation(feature = 3)
    })

    output$feature_3_recommended_items_class_3 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[4:6, ] %>%
        create_image_objects_for_recommedation(feature = 3)
    })

    output$feature_3_recommended_items_class_4 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[7:9, ] %>%
        create_image_objects_for_recommedation(feature = 3)
    })

    show("feature_3_recommended_items_class_1")
    show("feature_3_recommended_items_class_2")
    show("feature_3_recommended_items_class_3")
    show("feature_3_recommended_items_class_4")
  })



  # Back-end for vogue information while FP is running
  lapply(1:nrow(vogue_df), function(i) {
    output[[paste0('pic', i)]] <- renderUI({
      tags$img(src = vogue_df$link_pic[i], width = 110)
    })
  })
  

        ## Feature 4 - Server ------------------------------------------------------


    dataInput_feat4 <- isolate(reactive({
    if (input$choice_cloth == "Entire outfit") {
      df_plot <- pca_result_image
    } else {
      df_plot <- pca_result_classes
    }
    df_plot <- df_plot %>% filter(new_brand %in% input$variable_shoe & new_classes %in% input$choice_cloth)
    df_plot$new_brand <- as.character(df_plot$new_brand)
    return(df_plot)
  }))
  
  
  output$plot_feat4 <- renderPlotly(
    plot_feat4 <- plot_ly(dataInput_feat4(),
                    type = "scatter3d",
                    mode = "markers",
                    x = ~PC01, y = ~PC02, z = ~PC03,
                    color = ~new_brand,
                    colors = c("red", "green", "blue"),
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
  
  
}
