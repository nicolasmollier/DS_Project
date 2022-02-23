# Packages ----------------------------------------------------------------

if (!require("pacman")){
  install.packages("pacman")
} 

library(pacman)

p_load(shiny, shinydashboard, dashboardthemes, shinyFiles, plyr, lsa, SnowballC,
       tidyverse, shinyjs, htmlwidgets, readr, reticulate, jpeg, here, ggplot2,
       magrittr, waiter, shinycssloaders, shinybusy, shinyBS, scales, slickR, 
       tidymodels, plotly)


# Python Packages
#torch <- import("torch")
np <- import("numpy")



# java script and html ----------------------------------------------------

source(here::here("scripts/js_html_for_app.R"))


# Data --------------------------------------------------------------------

pca_result_classes <- readRDS(here::here("data/fp_select_attrib_per_class_pca.rds"))
pca_result_image <- readRDS(here::here("data/fp_select_image_per_row_pca.rds"))
umap_result_classes <- readRDS(here::here("data/fp_select_attrib_per_class_umap.rds"))
umap_result_image <- readRDS(here::here("data/fp_select_image_per_row_umap.rds"))



# Define new classes for data exploration
new_classes <- c("shirt / blouse", "top / t-shirt / sweatshirt",
                 "sweater", "cardigan", "jacket", "vest", "pants",
                 "shorts", "skirt", "coat", "dress", "jumpsuit",
                 "cape", "glasses", "hat", "hair accessory", 
                 "tie", "glove", "watch", "belt", "leg warmer", 
                 "tights / stockings", "sock", "shoe",
                 "bag / wallet", "scarf", "umbrella", "hood", "collar",
                 "lapel", "epaulette", "sleeve", "pocket", "neckline", 
                 "buckle", "zipper", "applique", "bead", "bow", 
                 "flower", "fringe", "ribbon", "rivet", "ruffle",
                 "sequin", "tassel")

# Define new brands for data exploration
new_brand <- c("Adidas sneaker", "Adidas sneaker", "Adidas sneaker", "Adidas sneaker",
               "Adidas sneaker", "Adidas sneaker", "Business shoe", "Asics sneaker",
               "Asics sneaker", "Autumn Boot", "Birkenstock Arizona", "Birkenstock Gizeh",
               "Birkenstock Madrid", "Converse Chucks", "Converse Chucks", "Crocs",
               "Dr. Martens shoe", "Dr. Martens Boot", "Fila sneaker", "Flipflop",
               "Gucci sneaker", "High Heel", "Kswiss sneaker", "Lacoste sneaker",
               "Louboutin High Heel", "New Balance sneaker", "Nike sneaker",
               "Nike sneaker", "Nike sneaker", "Nike sneaker", "Puma sneaker",
               "Reebok sneaker", "Sandal", "Sketcher sneaker", "Steve Madden sneaker",
               "Business shoe", "Timberland Boot", "Tommy Hilfiger sneaker",
               "UGG Boot", "Vans sneaker", "Vans sneaker", "Vans sneaker", "Winter Boot")

# Map values to new column (PCA)
pca_result_classes$new_classes <- plyr::mapvalues(pca_result_classes$classes, 
                                                  from = seq(1, 46), 
                                                  to = new_classes)

pca_result_classes$new_brand <- mapvalues(pca_result_classes$brand, 
                                          from = unique(pca_result_classes$brand), 
                                          to = new_brand)

pca_result_image$new_brand <- mapvalues(pca_result_image$brand, 
                                        from = unique(pca_result_image$brand), 
                                        to = new_brand)

pca_result_image$new_classes <- "Entire outfit"


# change col names for plotting
colnames(pca_result_image)[3:5] <- c("PC01", "PC02", "PC03")
colnames(pca_result_classes)[4:6] <- c("PC01", "PC02", "PC03")


# Map values to new column (UMAP)
umap_result_classes$new_classes <- plyr::mapvalues(umap_result_classes$classes, 
                                                  from = seq(1, 46), 
                                                  to = new_classes)

umap_result_classes$new_brand <- mapvalues(umap_result_classes$brand, 
                                          from = unique(umap_result_classes$brand), 
                                          to = new_brand)

umap_result_image$new_brand <- mapvalues(umap_result_image$brand, 
                                        from = unique(umap_result_image$brand), 
                                        to = new_brand)

umap_result_image$new_classes <- "Entire outfit"




# Load all unique classes
database_unique_classes <- readRDS(here::here("data/database_unique_classes.rds"))




# Functions ---------------------------------------------------------------

# Theme and Logo of the App
source(here::here("scripts/dashboard_theme.R"))
source(here::here("scripts/dashboard_logo.R"))


# dynamically create the html img tags from the image files to be displayed
source(here("scripts/create_img_tags.R"))
img_html <- read_file(here::here("scripts/img_html"))


# Load the Classifier including pre-trained weights for Classifying uploaded 
# Shoe images
#source_python(here("scripts/Inference_Shoe_Type_Classifier.py"))
source_python(here("scripts/inference_onnx.py"))

# Load Random Forest Model for Feature 2 including pre-trained weights
# source_python(here("scripts/RF_prediction.py"))
source(here::here("scripts/RF_prediction_function.R"))
load(here::here("model_weights/RF_model_feature2.RData"))


# Fashionpedia
reticulate::source_python(here("scripts/fashionpedia_python_script.py"))



# Functions for the different features
source(here::here("scripts/feature_1_functions.R"))
source(here::here("scripts/feature_2_and_3_functions.R"))


# Define the vogue links for waiting queue
vogue_df <- scrape_news()
