library(shiny)
library(reticulate)
torch <- import("torch")



source(here("scripts/Feature_coding.R"))
source(here("scripts/feature_1_query_downloader.R"))
source(here("scripts/js_html_for_app.R"))



feature1UI <- function(id, label = "feature 1"){
  ns <- NS(id)
  uiOutput(ns("recommende_shoe"))
}



# server

feature1Server <- function(id, last_click){
  moduleServer(
    id,
    function(input, output, session){
      file_name <- str_replace_all(last_click, " ", "_") %>% 
        paste0(".jpg")
      file_path <- paste0("img/", file_name)
      file_id <- "recommendation_shoe"
      
      current_img <- readJPEG(paste0("www/", file_path))
      current_img_tensor <- torch$Tensor(current_img)
      
      
      # #classifier_pred <- return_shoe_type(model, current_img_tensor)
      
      
      output$recommende_shoe <- renderUI({
        img(id = file_id, src = file_path, style = image_style_recommendation_shoe)
      })
      # updateTabItems(session, "side_bar_menue", "recommendation")
      # 
      # 
      # feature_1_queries <<- last_click %>%
      #   str_replace_all(" ", "_") %>%
      #   feature_1_get_queries() %>%
      #   str_remove_all("/") %>%
      #   str_replace_all(" ", "+")
      # 
      # temp_df = NULL
      # for(i in feature_1_queries){
      #   if(is.null(temp_df)){
      #     temp_df <- feature_1_scrape(i) %>%
      #       mutate(query = i)
      #   } else {
      #     temp_df <- temp_df %>%
      #       bind_rows(feature_1_scrape(i) %>%
      #                   mutate(query = i))
      #   }
      # }
      # 
      # output$test <- renderUI({
      #   img(id = file_id, src = "//images.asos-media.com/products/asos-design-christmas-wham-sweatshirt-in-white/201798842-1-white?$n_480w$&wid=476&fit=constrain ", style = image_style_recommendation_shoe)
      #   
      # })
    }
  )
}
