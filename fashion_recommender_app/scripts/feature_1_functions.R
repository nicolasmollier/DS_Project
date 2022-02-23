# load the needed packages
library(rvest)
library(httr)
library(tidyverse)
library(reticulate)



# translator function for queries from Python
deep_translator <- import("deep_translator")


    # Data Feature Outfit Recommendation --------------------------------------


# Import csv file with class + attribute recognition
class_info <- read.csv(here("data/fashionpedia_label_map.csv"), header = FALSE, sep = ":")
names(class_info)[1] <- "classes"
names(class_info)[2] <- "description"

attr_info <- read.csv(here("data/label_descriptions.csv"), header = TRUE, sep = ",")
attr_info$name <- gsub(" \\(.*", "", attr_info$name)


# Master database import
base_feat <- readRDS(here("data/fp_select_attrib_per_class_raw.rds"))


# Preparation for descriptives graphs in data exploration

# Master database for descriptives and matching procedure
descriptives_db <- base_feat

descriptives_db$new_classes <- mapvalues(descriptives_db$classes, 
                                 from = seq(1, 46), 
                                 to = new_classes)
descriptives_db$new_brand <- mapvalues(descriptives_db$brand, 
                                 from = unique(descriptives_db$brand), 
                                 to = new_brand)



# Drop the attributes "no non-textile material", no special manufacturing technique 
# asymmetrical, symmetrical possible recommendation
attr_info_1 <- attr_info[-c(115, 116, 162, 163, 164, 181, 249, 270, 271),]


# Omit class 24 (shoe) --> not relevant for recommendation
base_feat1 <- base_feat %>% filter(classes != 24)


# Drop the attributes which are not suitable for recommendations
base_feat1 <- base_feat1[,-c(118, 119, 165, 166, 167, 184, 252, 273, 274)]





# Obtain queries for chosen / uploaded shoe
feature_1_get_queries <- function(x, country, filter_opts = NULL){

  # Determine the relevant class figures for the query out of the filter option
  filter_opts_num <- filter_opts %>% as.data.frame()
  subset_feat1 <- subset(base_feat1, select = -image_file) %>% filter(brand == x)
  
  if (!is.null(filter_opts)) {
    names(filter_opts_num)[1] <- "description"
    filter_opts_num <- filter_opts_num %>%
      inner_join(class_info, by = "description") %>%
      select(classes)

    # Dataframe for the empty features
    print_statement <- rep(NA, nrow(filter_opts_num))
    
    # Check if desired fashion feature is included in database
    for (i in 1:nrow(filter_opts_num)) {
      if (length(which(subset_feat1[, 2] == filter_opts_num[i, 1])) > 0) {
        filter_opts_num[i, 1] <- filter_opts_num[i, 1]
      } else {
        filter_opts_num[i, 1] <- NA
        print_statement[i] <- paste0(filter_opts[i, 1], "characteristic not in database included")
      }
    }
    
    # Just keep non-missing rows
    filter_opts_num <- filter_opts_num[complete.cases(filter_opts_num), ] %>% as.data.frame()
    names(filter_opts_num)[1] <- "classes"
    print_statement <- print_statement[complete.cases(print_statement)]
    
    
  }
  
  # Look at most named classes
  if (nrow(filter_opts_num) == 0) {
    class_freq <- 5
  } else {
    class_freq <- 5 - nrow(filter_opts_num) %>% as.numeric()
  }
  
  class_relevant <- subset_feat1 %>%
    count(classes) %>%
    arrange(desc(n)) %>%
    head(class_freq) %>%
    select(classes) %>% 
    ungroup()
  
  if(!is.null(filter_opts_num)){
    class_relevant <- rbind(class_relevant, filter_opts_num)
  }
  
  
  # Filter the subset that only the relevant class observations are included
  class_attr <- subset_feat1 %>% 
    filter(classes %in% extract2(class_relevant, 1)) %>% 
    arrange(classes) %>% 
    group_by(brand, classes) %>% summarise_all(mean)
  
  # Determine the max probability for the attribute of a class
  max_val <- rep(NA, class_freq)
  for(i in 1:length(extract2(class_relevant, 1))){
    max_val[i] <- as.numeric(which.max(class_attr[i, 3:ncol(class_attr)]))
  }
  
  
  # Write the attribute + probability + flexibility in final vector
  flex_threshold <- 0.5
  
  class_score <- class_attr %>% select(brand, classes) %>% 
    mutate(attribute = max_val,
           attr_prob = NA,
           flexibility = NA)
  max_val_attr <- max_val +2
  
  for(i in 1:length(max_val_attr)){
    class_score[i,4] <- class_attr[i,max_val_attr[i]]
    if (class_score[i,4] > flex_threshold){
      class_score[i,5] <- 0
    } else {
      class_score[i,5] <- 1
    }
  }
  
  # Change classes and attributes to actual names
  class_score <- class_score %>% mutate(classes = as.character(classes),
                                        attribute = as.character(attribute))
  
  queries <- rep(NA, nrow(class_score))
  class_score_trans <- rep(NA, nrow(class_score)) 
  queries_trans <- rep(NA, nrow(class_score))
  
  
  for(i in 1:nrow(class_score)){
    
    class_score[i,2] <- class_info[as.numeric(class_score[i,2]), 2]
    class_score[i,3] <- attr_info_1[as.numeric(class_score[i,3]), 2]
    
    # remove attributes for class glasses
    if (class_score[i,2] %in% c("glasses", "watch", "sock", "bag, wallet", "tie")){ 
      class_score[i,3] <- " "
    }
    
    queries[i] <- gsub(",", "/",paste(class_score[i, 2], 
                                      class_score[i, 3]))
    
    
    # translate queries 
    if(!(country %in% c("us", "gb"))){
      class_score_trans[i] <- deep_translator$LingueeTranslator(
        source = 'en',
        target = country
      ) %>% 
        deep_translator$LingueeTranslator$translate(
          word = class_score[[2]][i]
        )
      queries_trans[i] <- gsub(",", "/",paste(class_score_trans[i], 
                                              class_score[i, 3]))
    }
  }
  
  
  
  return(
    if(!(country %in% c("us", "gb"))){
      list(queries_translated = queries_trans,
           classes = class_score[,2],
           attributes = class_score[,3])
    } else {
      list(queries_translated = queries, 
           classes = class_score[,2],
           attributes = class_score[,3])
    }
  )
}




# Scrapes the image links, urls, prices and queries of the recommended items
feature_1_scrape <- function(query, country = "us", gender = "Men"){ 
  
  if(query != "Gucci+Ace"){
      # All class-attribute combinations but Gucci can be accessed at Asos
      url_current <- paste0("https://www.asos.com/", country, "/search/?page=1&q=", query, "+", gender)
  
      x <- GET(url_current, add_headers('user-agent' = 'Tom'))
  
      # In order to avoid errors when different countries are selected
      Sys.sleep(1)
      
      html_document <- read_html(x)
      
      # In order to avoid errors when different countries are selected
      Sys.sleep(1)
      
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
  
  } else {
    
    if(gender == "Men"){
      
      url_current <- paste0("https://www.gucci.com/us/en/st/newsearchpage?facetFilters=categoryLevel",
                            "1_en%3AMen&searchString=gucci%20sneaker%20ace&search-cat=header-search")
      
      price_vector <- c("$770", "$740", "$740")
      img_vector <- c("https://media.gucci.com/style/White_South_0_160_540x540/1638297991/687608_0FI60_9080_002_100_0000_Light.jpg",
                      "https://media.gucci.com/style/White_South_0_160_540x540/1625733906/429445_UIE10_1095_002_100_0000_Light.jpg",
                      "https://media.gucci.com/style/White_South_0_160_540x540/1586429104/548950_9N050_8465_002_100_0000_Light.jpg")
      
    } else {
      
      url_current <- paste0("https://www.gucci.com/us/en/st/newsearchpage?facetFilters=categoryLevel1_en%3A",
                            "Women&searchString=gucci%20sneaker%20ace&search-cat=header-search")
      
      price_vector <- c("$770", "$740", "$740")
      img_vector <- c("https://media.gucci.com/style/White_South_0_160_540x540/1638298915/687620_0FI60_9080_002_100_0000_Light.jpg",
                      "https://media.gucci.com/style/White_South_0_160_540x540/1582710303/431942_02JP0_9064_002_098_0000_Light.jpg",
                      "https://media.gucci.com/style/White_South_0_160_540x540/1582298106/550051_9N050_8465_002_098_0000_Light.jpg")
      
    }
    
  }
  
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
  feature_1_queries_base <- last_click %>%
    str_replace_all(" ", "_") %>%
    # get queries bases on the clicked image; the output are 5 fashionpedia attributes
    feature_1_get_queries(x = ., country, filter_opts)
  
  # get the queries for the recommendations
  feature_1_queries <- feature_1_queries_base %>%
    extract2("queries_translated") %>% 
    str_remove_all("/") %>%
    str_replace_all(" ", "+")
  
  # Get the respective titles for the UI
  class_title <- feature_1_queries_base %>%
    extract2("classes")
  
  attribute_title <- feature_1_queries_base %>%
    extract2("attributes")
  
  
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
  # Classes and attributes are determined separately - needs to be plugged into title in UI
  return(list(temp_df, feature_1_queries, class_title, attribute_title))
}


# Takes last clicked/selected image and returns the path to that image
image_click_to_path <- function(image_click){
  
  file_name <- str_replace_all(image_click, " ", "_") %>% 
    paste0(".jpg")
  
  file_path <- paste0("img/", file_name)
  
  return(file_path)
}


# Function to create the formatting of how the recommendations should be displayed
create_image_objects_for_recommedation <- 
  function(object, col = 1, feature = 1, shoe_title = NULL, feat_3_header = NULL){
  
  # Determine the row index  
  row_index <- if(col == 1){
    1:3
  } else if (col == 2){
    4:6
  } else if (col == 3){
    7:9
  } else if (col == 4){
    10:12
  } else if (col == 5){
    13:15
  }
  if(feature == 1){
    df <- object[[1]][row_index,]
  } else{
    df <- object
  }
  
  loading_complete <<- FALSE
  link <- df$link
  url <- df$url
  price <- as.character(df$price)
  query <- df %>% 
    extract2("query") %>% 
    str_replace_all("\\+", " ")
  
  recommendation_list <- list()
  
  # Feature 3 already has the title information
  if(feature == 3){
    class_title <- feat_3_header$description
    attribute_title <- feat_3_header$name
  }
  
  for(i in seq_along(link)){
    current_link <- link[i]
    current_url <- url[i]
    current_price <- price[i]
    current_query <- query[i]
    
    # Title query for feature 2 
    if(feature == 2){
      current_query <- shoe_title
    } else if(feature == 1) {
      if(all(row_index == 1:3)){
        class_title <- object[[3]]$classes[i]
        attribute_title <- object[[4]]$attribute[i]
      } else if(all(row_index == 4:6)){
        class_title <- object[[3]]$classes[2]
        attribute_title <- object[[4]]$attribute[2]
      } else if(all(row_index == 7:9)){
        class_title <- object[[3]]$classes[3]
        attribute_title <- object[[4]]$attribute[3]
      } else if(all(row_index == 10:12)){
        class_title <- object[[3]]$classes[4]
        attribute_title <- object[[4]]$attribute[4]
      } else if(all(row_index == 13:15)){
        class_title <- object[[3]]$classes[5]
        attribute_title <- object[[4]]$attribute[5]
      }
      
      # If attribute was omitted, fashion is added in the front-end
      if(attribute_title == " "){
        attribute_title <- "fashion"
      }
    }
    
    if(!is.na(current_price)){
      
    recommendation_list[[i]] <- tagList(
      
      # create headers on top of the columns that contains each contain three images (rows)
      if(i == 1 & feature %in% c(1, 3)){
        p(
          id = paste0("feature_", feature, "_item_class", i), 
          tags$b(class_title),
          tags$br(),
          paste0("(", attribute_title, ")"),
          align = "center",
          style = "margin-top: 10px;"
        )
      } else if(i == 1 & feature == 2) {
        p(
          id = paste0("feature_", feature, "_item_class", i), 
          tags$b(current_query),
          align = "center",
          style = "margin-top: 10px;")
      },
      
      img(
        id = paste0("feature_", feature, "_recommendation_image_", i), 
        src = current_link, 
        style = image_style_recommendation_shoe
      ) %>% 
      a(href = current_url),
      
      p(id = paste0("feature_", feature, "_price_", i), current_price, style = "margin-bottom: 7px;")
    )
    }
  }
  
  return(recommendation_list)
  loading_complete <<- TRUE
}


