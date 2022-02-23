# Different dimensionality reduction algorithms for the data exploration tab


library(tidymodels)
library(embed)
library(Rtsne)


### PCA

# see how many components we wan to keep
#library(factoextra)
#pca_results <- prcomp(attributes_df[,4:ncol(attributes_df)] %>% 
#                        mutate_all(as.numeric), center = TRUE, scale. = TRUE)
## look at summary and plots to decide on number of components
#summary(pca_results)
#fviz_screeplot(pca_results, addlabels = TRUE, choice = "variance") 
#plot(cumsum(pca_results$sdev^2 / sum(pca_results$sdev^2)), type="b") 

# actually perform PCA with tidymodels
pca_rec <- recipe( ~ ., data = attributes_df_select) %>% 
  update_role(image_file, brand, classes, new_role = "id") %>%
  step_normalize(all_predictors()) %>%
  step_pca(all_predictors(), num_comp = 10)

pca_prep <- prep(pca_rec)

# get data frame with 10 PCs (all classes in a single column) 
df_pca_classes <- juice(pca_prep)

# get data frame with 10 PCs (all class attrib combinations in a single column) 
df_pca_attrib <- df_pca_classes %>% 
  gather(-image_file, -brand, -classes, key = "PC", value = "value") %>% 
  unite(col = PC_class, classes, PC) %>% 
  spread(key = PC_class, value = value, fill = 0)


saveRDS(df_pca_classes, "output/fp_select_attrib_per_class_pca.rds")

saveRDS(df_pca_attrib, "output/fp_select_class_per_image_pca.rds")



### UMAP

# perform UMAP
umap_rec <- recipe( ~ ., data = attributes_df) %>% 
  update_role(image_file, brand, classes, new_role = "id") %>%
  step_normalize(all_predictors()) %>%
  embed::step_umap(all_predictors(), num_comp = 10)

umap_prep <- prep(umap_rec)

# get data frame with 10 PCs (all classes in a single column) 
df_umap_classes <- juice(umap_prep)


# get data frame with 10 PCs (all class attrib combinations in a single column) 
df_umap_attrib <- df_umap_classes %>% 
  gather(-image_file, -brand, -classes, key = "PC", value = "value") %>% 
  unite(col = PC_class, classes, PC) %>% 
  spread(key = PC_class, value = value, fill = 0)



### T-SNE

set.seed(42) # for reproducibility
df <- attributes_df
tsne <- Rtsne(df[!duplicated(df[, c(4:ncol(attributes_df))]), c(4:ncol(attributes_df))], dims = 3, perplexity=30, verbose=TRUE, max_iter = 1000)

df_tsne_classes <- df[!duplicated(df[, c(4:ncol(attributes_df))]), 1:3] %>% 
  bind_cols(as.data.frame(tsne[["Y"]]))


# get data frame with 10 PCs (all class attrib combinations in a single column) 
df_tsne_attrib <- df_tsne_classes %>% 
  gather(-image_file, -brand, -classes, key = "PC", value = "value") %>% 
  unite(col = PC_class, classes, PC) %>% 
  spread(key = PC_class, value = value, fill = 0)
