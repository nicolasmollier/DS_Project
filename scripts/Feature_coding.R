library(tidyverse)
library(lsa)
library(SnowballC)
# library to call Python from R
library(reticulate)





################################################################################
###                               FEATURE I                                  ###
################################################################################



# Import csv file with class + attribute recognition
class_info <- read.csv(here("data/fashionpedia_label_map.csv"), header = FALSE, sep = ":")
names(class_info)[1] <- "classes"
names(class_info)[2] <- "description"

attr_info <- read.csv(here("data/label_descriptions.csv"), header = TRUE, sep = ",")
attr_info$name <- gsub(" \\(.*", "", attr_info$name)

# Drop the attributes "no non-textile material", no special manufacturing technique 
# asymmetrical, symmetrical possible recommendation
attr_info <- attr_info[-c(115, 116, 162, 163, 164, 181, 249, 270, 271),]

# Omit class 24 (shoe) --> not relevant for recommendation
base_feat1 <- readRDS(here("data/fp_select_attrib_per_class_raw.rds"))
base_feat1 <- base_feat1 %>% filter(classes != 24)

# Drop the attributes which are not suitable for recommendations
base_feat1 <- base_feat1[,-c(118, 119, 165, 166, 167, 184, 252, 273, 274)]



# Input of shoe brand from gallery or shoe upload classifier
# Linkage to gallery or upload result
# x <- "Adidas_Continental_80"

feature_1_get_queries <- function(x, filter_opts = NULL){
  # ANALYSIS
  
  # From front-end: just as an attempt
  # filter_opts <- c("jacket", "skirt", "cardigan") %>% as.vector()
  
  # Determine the relevant class figures for the query out of the filter option
  filter_opts_num <- filter_opts %>% as.data.frame()
  names(filter_opts_num)[1] <- "description"
  filter_opts_num <- filter_opts_num %>% inner_join(class_info, by = "description") %>%
    select(classes)
  
  # Filter manually for relevant brand
  # x <- "Adidas_Continental_80"
  
  subset_feat1 <- subset(base_feat1, select= -image_file) %>% filter(brand == x)
  
  # Test if the chosen attribute is in database (if recommendation is possible)
  
  # Dataframe for the empty features
  print_statement <- rep(NA, nrow(filter_opts_num))
  
  # Check if desired fashion feature is included in database
  for(i in 1:nrow(filter_opts_num)){
    if(length(which(subset_feat1[,2]==filter_opts_num[i,1]))>0){
      filter_opts_num[i,1] <- filter_opts_num[i,1]
    } else {
      filter_opts_num[i,1] <- NA
      print_statement[i] <- paste0(filter_opts[i,1], "characteristic not in database included")
    }
  }
  
  # Just keep non-missing rows
  filter_opts_num <- filter_opts_num[complete.cases(filter_opts_num), ] %>% as.data.frame()
  names(filter_opts_num)[1] <- "classes"
  print_statement <- print_statement[complete.cases(print_statement)]
  
  # Look at most named classes
  if (nrow(filter_opts_num) == 0){
    class_freq <- 5
  } else {
    class_freq <- 5 - nrow(filter_opts_num) %>% as.numeric()
  }
  
  class_relevant <- subset_feat1 %>% count(classes) %>% arrange(desc(n)) %>% 
    head(class_freq) %>% select(classes)
  class_relevant <- rbind(class_relevant, filter_opts_num)
  
  
  # Filter the subset that only the relevant class observations are included
  class_attr <- subset_feat1 %>% 
    filter(classes == class_relevant[1,1] | classes == class_relevant[2,1] | 
             classes == class_relevant[3,1] | classes == class_relevant[4,1] | 
             classes == class_relevant[5,1]) %>% arrange(classes) %>% 
    group_by(brand, classes) %>% summarise_all(mean)
  
  # Determine the max probability for the attribute of a class
  max_val <- rep(NA, class_freq)
  for(i in 1:nrow(class_relevant)){
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
  
  for(i in 1:nrow(class_score)){
    class_score[i,2] <- class_info[as.numeric(class_score[i,2]), 2]
    class_score[i,3] <- attr_info[as.numeric(class_score[i,3]), 2]
  }
  
  
  # Queries for Zalando
  queries <- rep(NA, nrow(class_score))
  for(i in 1:nrow(class_score)){
    if (class_score[i,2] != "glasses"){
      queries[i] <- gsub(",", "/",paste(class_score[i,2], class_score[i,3]))
    } else {
      queries[i] <- gsub(",", "/",paste(class_score[i,2]))
    }
  }
  
  return(queries, print_statement)
}


################################################################################
###                               FEATURE II                                 ###
################################################################################




################################################################################
###                               FEATURE III                                ###
################################################################################




################################################################################
###                               FEATURE IV                                 ###
################################################################################




