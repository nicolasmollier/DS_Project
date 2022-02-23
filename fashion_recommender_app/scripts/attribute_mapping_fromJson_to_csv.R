library(rjson)
library(tidyverse)

# Map the attributes from Fashionpedia output to make it readable as csv

json_file <- "data/label_descriptions.json"
json_data <- fromJSON(file = json_file)

mapping_categories <- json_data$categories %>% 
  map(unlist) %>% 
  bind_rows() 

mapping_attributes <- json_data$attributes %>% 
  map(unlist) %>% 
  bind_rows() 

mapping_classes <- json_data$categories %>% 
  map(unlist) %>% 
  bind_rows() %>% 
  mutate(id = as.numeric(id),
         id = id + 1)

mapping_attributes$id <- 0:293

write_csv(mapping_attributes, file = "/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/label_descriptions.csv")
