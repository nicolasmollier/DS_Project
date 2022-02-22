
library(rvest)
library(httr)
library(tidyverse)

feature_1_scrape <- function(query, country = "us"){ # andere Features: Geschlecht
  url <- paste0("https://www.asos.com/", country, "/search/?page=1&q=", query)
  
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




  
