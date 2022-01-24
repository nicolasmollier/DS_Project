
library(rvest)
library(httr)
library(tidyverse)


# Scrapes the image links, urls, prices and queries of the recommended items

feature_1_scrape <- function(query, country = "us", gender = "Men"){ 
  
  url <- paste0("https://www.asos.com/", country, "/search/?page=1&q=", query, "+", gender)
  
  x <- GET(url, add_headers('user-agent' = 'Tom'))
  
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
  
  result_df <- result %>% 
    data.frame(link = .[[1]], price = .[[2]], url = url) %>% 
    select(3, 4, 5)
  
  return(result_df)
  
}





# Takes last clicked/selected image and returns a data frame with image links 
# and prices of recommended items for that selected image

image_click_to_recommendation <- function(last_click, country = "us", gender = "Men"){

  # get the queries for the recommendations
  feature_1_queries <- last_click %>%
    str_replace_all(" ", "_") %>%
    feature_1_get_queries() %>%
    str_remove_all("/") %>%
    str_replace_all(" ", "+")
  
  # save the image links and prices of the recommended items in a data frame
  temp_df = NULL
  for(i in feature_1_queries){
    if(is.null(temp_df)){
      temp_df <- feature_1_scrape(i, country, gender) %>%
        mutate(query = i)
    } else {
      temp_df <- temp_df %>%
        bind_rows(feature_1_scrape(i, country, gender) %>%
                    mutate(query = i))
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



create_image_objects_for_recommedation <- function(df){
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
      
    recommendation_list[[i]] <- tagList(
      
      # create headers on top of the columns that contains each contain three images (rows)
      if(i %in% c(1,4,7,11)){
        h5(id = paste0("item_class", i), 
           tags$b(current_query),
           align = "center")
      },
      
      img(
        id = paste0("recommendation_image_", i), 
        src = current_link, 
        style = image_style_recommendation_shoe
      ) %>% 
      a(href = current_url),
      
      div(id = paste0("price_", i), current_price)
    )
  }
  
  return(recommendation_list)
}


