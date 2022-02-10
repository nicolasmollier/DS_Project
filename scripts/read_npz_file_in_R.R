library(reticulate)
library(tidyverse)
library(magrittr)

source("scripts/helper_functions.R")

np <- import("numpy")



#fashionpedia_results <- np$load("/media/nicolas/USB STICK/fp_results.npz", allow_pickle = TRUE)
fashionpedia_results <- np$load("/home/nicolas/Desktop/test.npz", allow_pickle = TRUE)
fashionpedia_results <- fashionpedia_results["x"] 

fashionpedia_results <- do.call(rbind, fashionpedia_results)

#fashionpedia_results <- np$load("data/fashionpedia_results.npz", allow_pickle = TRUE)
#fashionpedia_results$files
#fashionpedia_results <- fashionpedia_results[["x"]]

sample <- FALSE
if(sample == TRUE){
  fashionpedia_results <- fashionpedia_results %>% 
    head(5)
}

#colnames(fashionpedia_results) <- c("image_file", "classes","probabilities","attributes","boxes","masks","height","width")
class_prob_above_80 <- fashionpedia_results[, "scores"] %>% 
  map(larger_than, 0.8)


for(i in 1:nrow(fashionpedia_results)){
  fashionpedia_results[i, "classes"][["classes"]] <- fashionpedia_results[i, "classes"][["classes"]][class_prob_above_80[[i]]]
  fashionpedia_results[i, "scores"][["scores"]] <- fashionpedia_results[i, "scores"][["scores"]][class_prob_above_80[[i]]]
  fashionpedia_results[i, "attributes"][["attributes"]] <- fashionpedia_results[i, "attributes"][["attributes"]][class_prob_above_80[[i]],]
}

nrow(fashionpedia_results)


fashionpedia_results <- cbind(fashionpedia_results, fashionpedia_results[, "classes"] %>% map(unique) %>% map_int(length))
colnames(fashionpedia_results)[9] <- "n_classes"
#colnames(fashionpedia_results) <- c("image_file", "classes","probabilities","attributes","boxes","masks","height","width", "n_classes")
fashionpedia_results <- fashionpedia_results[fashionpedia_results[, "n_classes"] >=4,]
nrow(fashionpedia_results)


attribute_df <- fashionpedia_results[,c("image_file", "classes", "attributes")]


attributes_df <- attribute_df %>% 
  as.data.frame() %>% 
  unnest(cols = c(image_file, classes, attributes)) %>% 
  rowwise() %>% 
  mutate(attributes = list(as.character(attributes)),
         attributes = paste(attributes, collapse = ",")) %>% 
  separate(col = "attributes", sep = ",", into = paste0("attribute_", 1:294)) %>% 
  # deduplicate
  group_by(image_file, classes) %>% slice(1)


#fashionpedia_results[1, "attributes"][["attributes"]] %>% paste(collapse = ",")

x = fashionpedia_results[,"image_file"] %>% unlist()
x = str_remove_all(x, "/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images/low_resolution/")
str_remove_all(x, "/(.*)") %>% 
  unique()

attributes_df <- attributes_df %>% 
  mutate(brand = str_remove_all(image_file, "/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images/low_resolution/"),
         brand = str_remove_all(brand, "/(.*)")) %>% 
  relocate(brand, .before = classes)


library(tidymodels)
library(factoextra)
pca_results <- prcomp(attributes_df[,4:ncol(attributes_df)] %>% 
                        mutate_all(as.numeric), center = TRUE, scale. = TRUE)
summary(pca_results)

fviz_screeplot(pca_results, addlabels = TRUE, choice = "variance") 
plot(cumsum(pca_results$sdev^2 / sum(pca_results$sdev^2)), type="b") 


rec <- recipe( ~ ., data = attributes_df[,4:ncol(attributes_df)] %>% 
                 mutate_all(as.numeric))
pca_trans <- rec %>%
  step_normalize(all_numeric()) %>%
  step_pca(all_numeric(), num_comp = 10)
pca_estimates <- prep(pca_trans, training = attributes_df[,4:ncol(attributes_df)] %>% 
                        mutate_all(as.numeric))
pca_data <- bake(pca_estimates, attributes_df[,4:ncol(attributes_df)] %>% 
                   mutate_all(as.numeric))

attributes_df <- attributes_df[,1:3] %>% 
  bind_cols(pca_data)

attributes_df2 <- attributes_df %>% 
  gather(-image_file, -brand, -classes, key = "PC", value = "value") %>% 
  unite(col = PC_class, classes, PC) %>% 
  spread(key = PC_class, value = value, fill = 0)

saveRDS(attributes_df, "/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/output/attributes_original.rds")

saveRDS(attributes_df2, "/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/output/attributes.rds")


df <- data.frame(row = rep(c(1, 51), each = 3),
                 var = c("Sepal.Length", "Species", "Species_num"),
                 value = c(5.1, "setosa", 1, 7.0, "versicolor", 2))
df %>% spread(var, value)
