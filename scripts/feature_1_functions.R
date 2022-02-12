
library(rvest)
library(httr)
library(tidyverse)
library(reticulate)

deep_translator <- import("deep_translator")

# Scrapes the image links, urls, prices and queries of the recommended items

feature_1_scrape <- function(query, country = "us", gender = "Men"){ 
  
  url_current <- paste0("https://www.asos.com/", country, "/search/?page=1&q=", query, "+", gender)
  
  x <- GET(url_current, add_headers('user-agent' = 'Tom'))
  
  html_document <- read_html(x)
  
  img_xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "_2r9Zh0W", " " ))]'
  price_xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "_16nzq18", " " ))]'
  
  price_vector <- html_document %>% 
    html_elements(xpath = price_xpath) %>% 
    html_text() %>% 
    head(3)
  
  img_vector <- html_document %>% 
    html_elements(xpath = img_xpath) %>% 
    html_attr("src") %>% 
    head(3)
  
  result <- list(img_vector, price_vector)
  
  if(length(result[[1]]) == 3 & length(result[[1]]) == 3){
    result_df <- result %>% 
      data.frame(link = .[[1]], price = .[[2]], url = url_current) %>% 
      select(3, 4, 5)
    
  } else {
    falty_url <<- url_current
    result_df <- NULL
  }
  
  return(result_df)
  
  


}





# Takes last clicked/selected image and returns a data frame with image links 
# and prices of recommended items for that selected image

image_click_to_recommendation <- function(last_click, country = "us", gender = "Men", filter_opts = NULL){

  # get the queries for the recommendations
  feature_1_queries <- last_click %>%
    str_replace_all(" ", "_") %>%
    # get queries bases on the clicked image; the output are 5 fashionpedia attributes
    feature_1_get_queries(x = ., country, filter_opts) %>%
    extract2("queries_translated") %>% 
    str_remove_all("/") %>%
    str_replace_all(" ", "+")
  
  # save the image links and prices of the recommended items in a data frame
  temp_df = NULL
  for(i in feature_1_queries){
    index <- i
    current_scrape <- feature_1_scrape(i, country, gender) 
    if(is.null(temp_df)){
      temp_df <- current_scrape
      if(!is.null(temp_df)){
        temp_df <- temp_df %>% 
          mutate(query = i)
      }
    } else {
      if(!is.null(current_scrape)){
        temp_df <- temp_df %>%
          bind_rows(current_scrape %>%
                      mutate(query = i))
      }
    }
  }
  
  return(list(temp_df, feature_1_queries))
}


# Takes last clicked/selected image and returns the path to that image

image_click_to_path <- function(image_click){
  
  file_name <- str_replace_all(image_click, " ", "_") %>% 
    paste0(".jpg")
  
  file_path <- paste0("img/", file_name)
  
  return(file_path)
}



create_image_objects_for_recommedation <- function(df, feature = 1){
  loading_complete <<- FALSE
  link <- df$link
  url <- df$url
  price <- as.character(df$price)
  query <- df %>% 
    extract2("query") %>% 
    str_replace_all("\\+", " ")
  
  recommendation_list <- list()
  
  for(i in seq_along(link)){
    current_link <<- link[i]
    current_url <<- url[i]
    current_price <<- price[i]
    current_query <<- query[i]
    
    if(!is.na(current_price)){
      
    recommendation_list[[i]] <- tagList(
      
      # create headers on top of the columns that contains each contain three images (rows)
      if(i %in% c(1,4,7,11) & feature != 2){
        h5(id = paste0("feature_", feature, "_item_class", i), 
           tags$b(current_query),
           align = "center")
      },
      
      img(
        id = paste0("feature_", feature, "_recommendation_image_", i), 
        src = current_link, 
        style = image_style_recommendation_shoe
      ) %>% 
      a(href = current_url),
      
      div(id = paste0("feature_", feature, "_price_", i), current_price)
    )
    }
  }
  
  return(recommendation_list)
  
  loading_complete <<- TRUE
}


