# Source additional helper functions
source(here("scripts/helper_functions.R"))


# Turn FP output into readable and manageable data
extract_attributes_from_fashionpedia_raw <- function(raw_fashionpedia_output){
  #colnames(raw_fashionpedia_output) <- c("image_file", "classes","probabilities","attributes","boxes","masks","height","width")
  class_prob_above_60 <- raw_fashionpedia_output[, "scores"] %>% 
    map(larger_than, 0.6) # Class probability has to be higher than 60%
  
  
  for(i in 1:nrow(raw_fashionpedia_output)){
    raw_fashionpedia_output[i, "classes"][["classes"]] <- 
      raw_fashionpedia_output[i, "classes"][["classes"]][class_prob_above_60[[i]]]
    raw_fashionpedia_output[i, "scores"][["scores"]] <- 
      raw_fashionpedia_output[i, "scores"][["scores"]][class_prob_above_60[[i]]]
    raw_fashionpedia_output[i, "attributes"][["attributes"]] <- 
      raw_fashionpedia_output[i, "attributes"][["attributes"]][class_prob_above_60[[i]],]
  }
  
  nrow(raw_fashionpedia_output)
  
  
  raw_fashionpedia_output <- cbind(raw_fashionpedia_output, raw_fashionpedia_output[, "classes"] %>% map(unique) %>% map_int(length))
  colnames(raw_fashionpedia_output)[9] <- "n_classes"

  
  attribute_df <- raw_fashionpedia_output[,c("image_file", "classes", "attributes")]

  
  if(length(attribute_df$classes) == 1){
    attributes_df <- attribute_df %>% 
      as.data.frame() %>% 
      add_column(names = paste0("attribute_", 1:294)) %>% 
      pivot_wider(
        names_from = names, 
        values_from = attributes) %>% 
      group_by(image_file, classes) %>% 
      slice(1)
  } else if(length(attribute_df$classes) == 0){
    attributes_df <- "no_classes" 
  } else {
    attributes_df <- attribute_df %>% 
      as.data.frame() %>% 
      group_by(image_file, classes) %>% slice(1)
    
    colnames(attributes_df) <- attributes_df %>% 
      colnames() %>% 
      str_replace_all("attributes.", "attribute_")
  }
  
  return(attributes_df)
}



# Cosine similarity / classes to add as output for outfit evaluation
feature_3_coding <- function(class_attr_vector, shoe_brand, recomm_amount = 3){
  
  
  # Match the classification to the database
  if (shoe_brand == "Asics Sneaker"){
    shoe_brand <- "Asics Tiger"
   } else if (shoe_brand == "Nike Sneaker"){
     shoe_brand <- "Nike Running"
   } else if (shoe_brand == "Ballerinas"){
     shoe_brand <- "sandals"
   } else if (shoe_brand == "Suit shoe"){
     shoe_brand <- "suit shoe"
   } else if (shoe_brand == "Lacoste sneaker"){
     shoe_brand <- "lacoste sneaker"
   } else if (shoe_brand == "Sandals"){
     shoe_brand <- "sandals"
   } else if (shoe_brand == "Vans classic slip on"){
     shoe_brand <- "vans classic slip on"
   } else if (shoe_brand == "Vans sneaker"){
     shoe_brand <- "vans sneaker"
   } else if (shoe_brand == "KSwiss Sneaker"){
     shoe_brand <- "Kswiss sneaker"
   } else if (shoe_brand == "UGG Boots"){
     shoe_brand <- "UGG boots"
   } else if (shoe_brand == "Winter Boot"){
     shoe_brand <- "Winter boot"
   } 
     
  
    # Drop irrelevant attributes first
  class_attr_vector <- class_attr_vector[,-c(117, 118, 164, 165, 166, 183, 251, 272, 273)]
  class_attr_vector <- class_attr_vector %>% 
    ungroup() %>% 
    select(-image_file)
  shoe_brand <- str_replace_all(shoe_brand, " ", "_")
  
  
  # filter database with respect to the given shoe + aggregations per class
  # Only use classes which were also found by fashionpedia to make them more comparable
  
  
  # Make the recommendation more accurate (drop irrelevant attributes)
  base_feat3 <- base_feat[,-c(118, 119, 165, 166, 167, 184, 252, 273, 274)]
  
  filtered_feat3 <- base_feat3 %>% 
    ungroup() %>% 
    filter(brand == shoe_brand) %>%
    select(-brand, -image_file) %>% 
    group_by(classes) %>%
    summarise_all(mean) %>% 
    semi_join(class_attr_vector, by = "classes") %>%
    as.vector()
  
  
  # Cosine similarity
  cosine_score <- rep(NA, nrow(filtered_feat3))
  
  for(i in 1:nrow(filtered_feat3)){
    cosine_score[i] <- cosine(filtered_feat3[i, 2:ncol(filtered_feat3)] %>% 
                                as.vector() %>% unlist(), 
                              class_attr_vector[i, 2:ncol(class_attr_vector)] %>% 
                                as.vector() %>% 
                                unlist())
  }
  
  # Average over the cosines of all found classes
  cosine_score_mean <- mean(cosine_score)
  
  
  # Check for largest deviation (which clothing item should have a different attribute)
  min_class <- which.min(cosine_score) %>% as.numeric()
  min_class <- filtered_feat3[min_class, ]
  max_class_attr <- 
    colnames(min_class[,2:ncol(min_class)])[apply(min_class[,2:ncol(min_class)], 1, which.max)]
  
  max_class_attr <- (substring(max_class_attr, regexpr("_", max_class_attr)+1) %>% 
                       as.numeric())-1 %>% as.data.frame()
  
  names(max_class_attr)[1] <- "id"
  max_class_attr <- max_class_attr %>% 
    inner_join(attr_info_1[,1:2], by = "id")
  
  # Biggest deviation of class with rather proper attribute
  class_attr_output <- cbind(min_class[,1], max_class_attr) %>% 
    inner_join(class_info, by="classes") %>% 
    select(description, name)
  
  
  
  # Give the user the feedback, which classes and attributes might be additionally suitable
  # 3 classes with the highest probabilities in class-attribute-combination
  
  # Therefore, unnecessary attributes are dropped again
  add_classes <- base_feat3 %>% 
    ungroup() %>% 
    filter(brand == shoe_brand) %>%
    select(-brand, -image_file) %>% 
    group_by(classes) %>%
    summarise_all(mean) %>% 
    anti_join(class_attr_vector, by = "classes")
  
  add_cols <- 
    colnames(add_classes[,2:ncol(add_classes)])[apply(add_classes[,2:ncol(add_classes)],1,which.max)]
  
  
  max_vals <- rep(NA, nrow(add_classes)) %>% as.data.frame()
  
  for (i in 1:nrow(add_classes)){
    max_vals[1,i] <- add_classes[i,add_cols[i]]
    names(max_vals)[i] <- paste0(add_cols[i])
  }
  max_vals <- max_vals[1,] %>% 
    unlist() %>% 
    as.data.frame()
  
  final_set <- cbind(add_classes[,1], add_cols, max_vals)
  names(final_set)[2] <- "id"
  names(final_set)[3] <- "Probability"
  
  final_set <- final_set %>% 
    top_n(recomm_amount, Probability) %>% 
    arrange(desc(Probability))
  
  final_set$id <- final_set$id %>% 
    str_remove("attribute_") %>% 
    as.numeric() %>% -1
  
  final_set <- final_set %>% 
    inner_join(attr_info_1[,1:2], by = "id") %>%
    inner_join(class_info, by = "classes") %>% 
    select(description, name, Probability)
  
  return(list(cosine_score_mean, class_attr_output, final_set))
  
}


# Get data frame for the depiction in output window
cosine_similarity_to_recommendation <- function(last_click, country = "us", gender = "Men"){
  
  # get the queries for the recommendations
  feature_2_queries <- last_click %>%
    # get queries bases on the clicked image; the output are 5 fashionpedia attributes
    str_remove_all("/") %>%
    str_replace_all(" ", "+")
  
  # save the image links and prices of the recommended items in a data frame
  temp_df = NULL
  for(i in feature_2_queries){
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
  
  return(list(temp_df, feature_2_queries))
}



# Retrieves news articles from vogue while FP is loading
scrape_news <- function() {
  
  links_vogue <- c("https://www.vogue.com/fashion/trends",
                   "https://www.vogue.com/tag/misc/menswear")
  
  # scrape vogue trends
  for (i in 1:length(links_vogue)) {
    
    # retrieve information
    vogue <- read_html(links_vogue[i])
    
    # extract header of article
    headers <- vogue %>%
      html_nodes('.summary-item__hed') %>% 
      html_text()
    # extract category (trend, runway, etc.)
    category <- vogue %>% 
      html_nodes('.FsKDn') %>% 
      html_text()
    # extract link to put it into app
    links <- vogue %>%
      html_nodes('.summary-item__hed-link') %>% 
      html_attr("href")
    # extract link to picture
    pics <- vogue %>%
      html_nodes(".euhqUD") %>%
      html_nodes(".ijxzGh .ResponsiveImageContainer-dlOMGF") %>%
      html_attr("src")
    
    # if gender = men -> disregard first 4 entries
    if (i == 2) {
      lengths = length(headers)
      headers <- headers[5:lengths]
      category <- category[5:lengths]
      links <- links[5:lengths]
    }
    
    # combine to data frame to make filtering easier
    df_scraped <- 
      data.frame(link = links,
                 header = headers,
                 category = category,
                 link_pic = pics) %>%
      mutate(link = paste0("https://www.vogue.com", link)) %>%
      filter(category %in% c("Trends", "Fashion"))
    
    # define name
    assign(paste0("vogue_df", i), df_scraped)
  }
  
  # rbind dfs
  vogue_df <- rbind(vogue_df1, vogue_df2)
  
  # randomly re-order rows
  rows <- sample(nrow(vogue_df))
  vogue_df <- vogue_df[rows, ]
  
  return(vogue_df)
  
}



