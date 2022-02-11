
source(here("scripts/helper_functions.R"))

extract_attributes_from_fashionpedia_raw <- function(raw_fashionpedia_output){
  #colnames(raw_fashionpedia_output) <- c("image_file", "classes","probabilities","attributes","boxes","masks","height","width")
  class_prob_above_60 <- raw_fashionpedia_output[, "scores"] %>% 
    map(larger_than, 0.6)
  
  
  for(i in 1:nrow(raw_fashionpedia_output)){
    raw_fashionpedia_output[i, "classes"][["classes"]] <- raw_fashionpedia_output[i, "classes"][["classes"]][class_prob_above_60[[i]]]
    raw_fashionpedia_output[i, "scores"][["scores"]] <- raw_fashionpedia_output[i, "scores"][["scores"]][class_prob_above_60[[i]]]
    raw_fashionpedia_output[i, "attributes"][["attributes"]] <- raw_fashionpedia_output[i, "attributes"][["attributes"]][class_prob_above_60[[i]],]
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



database <- readRDS("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/fp_select_attrib_per_class_raw.rds")

pca_on_database <- function(databse){
  
}




feature_3_coding <- function(class_attr_vector, shoe_brand, recomm_amount = 3){
  
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
    cosine_score[i] <- cosine(filtered_feat3[i,] %>% 
                                as.vector() %>% unlist(), 
                              class_attr_vector[i,] %>% 
                                as.vector() %>% 
                                unlist())
  }
  cosine_score_mean <- mean(cosine_score)
  
  # Check for largest deviation
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
  # 5 classes with the highest probabilities in class-attribute-combination
  
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


# feature_3_coding(class_attr_vector, shoe_brand)



# Output:
# Big box with similarity probability --> green / yellow / red
# Class with most differences --> which attribute proper?

# Adding classes and attributes of class which are mostly taken into account --> 
# picture from Asos






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
