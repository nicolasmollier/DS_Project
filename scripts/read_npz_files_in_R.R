rm(list = ls())

library(reticulate)
library(tidyverse)
library(magrittr)

np <- import("numpy")

source("scripts/helper_functions.R")



### Load in files

# get names of files
fp_results <- list.files("data", pattern = "fashionpedia_results")

# load in files and the, to a list of files
datalist = list()
for (i in 1:length(fp_results)) {
  path <- paste0("data/", fp_results[i])
  fp_result <- np$load(path, allow_pickle = TRUE)
  fp_result <- fp_result["x"]
  fp_result <- do.call(rbind, fp_result)
  datalist[[i]] <- fp_result
  rm(fp_result)
}

# stack list elements rowwise
fp_result <- do.call(rbind, datalist)
rm(datalist)



#sample <- TRUE
#if(sample == TRUE){
#  fp_result <- fp_result %>% 
#    head(20)
#}


### Filter out elements where model was less than 80% sure about its prediction

class_prob_above_80 <- fp_result[, "scores"] %>% 
  map(larger_than, 0.8)

for(i in 1:nrow(fp_result)){
  fp_result[i, "classes"][["classes"]] <- fp_result[i, "classes"][["classes"]][class_prob_above_80[[i]]]
  fp_result[i, "scores"][["scores"]] <- fp_result[i, "scores"][["scores"]][class_prob_above_80[[i]]]
  fp_result[i, "attributes"][["attributes"]] <- fp_result[i, "attributes"][["attributes"]][class_prob_above_80[[i]],]
}


### Filter out any image that did not contain at least 4 different classes
### as it's unlikely to contain a body shot in that case

fp_result <- cbind(fp_result, fp_result[, "classes"] %>% map(unique) %>% map_int(length))
colnames(fp_result)[9] <- "n_classes"
fp_result <- fp_result[fp_result[, "n_classes"] >= 4,]


### Create data frame with attribute scores in columns

attribute_df <- fp_result[,c("image_file", "classes", "attributes")]

attributes_df <- attribute_df %>% 
  as.data.frame() %>% 
  unnest(cols = c(image_file, classes, attributes)) %>% 
  rowwise() %>% 
  mutate(attributes = list(as.character(attributes)),
         attributes = paste(attributes, collapse = ",")) %>% 
  separate(col = "attributes", sep = ",", into = paste0("attribute_", 1:294)) %>% 
  # deduplicate
  group_by(image_file, classes) %>% slice(1)


# Extract brand/type of shoe from image path
attributes_df <- attributes_df %>% 
  mutate(brand = str_remove_all(image_file, "/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images/low_resolution/"),
         brand = str_remove_all(brand, "/(.*)")) %>% 
  relocate(brand, .before = classes)

rm(attribute_df)


# make numeric what's supposed to be numeric
attributes_df <- attributes_df %>% 
  mutate_at(c(4:ncol(attributes_df)), as.numeric)


# save file
saveRDS(attributes_df, "output/fp_attrib_per_class_raw.rds")



# SELECT RELEVANT CLASSES
attributes_df_select <- attributes_df %>%
  filter(!classes %in% c(30, 31, 32, 33, 34, 35, 37, 46))

# save file
saveRDS(attributes_df_select, "output/fp_select_attrib_per_class_raw.rds")



