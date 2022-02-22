################################################################################
################################## INFERENCE ###################################
################################################################################


# Search for the amount of classes per brand with at least 10 appearances
class_inference <- data_original %>%
  group_by(brand) %>% count(classes) %>%
  mutate(n = as.numeric(n),
         classes = as.numeric(classes)) %>% 
  filter(n > 10) %>% # Just keep the classes with more than 10 appearances
  arrange(brand, desc(n))

# Import csv file with class recognition
class_info <- read.csv("fashionpedia_label_map.csv", header = FALSE, sep = ":")
names(class_info)[1] <- "classes"
names(class_info)[2] <- "description"


# Join the class information to the inference data frame
class_inference <- left_join(class_inference, class_info, by = "classes")
class_inference <- class_inference %>%
  select(brand, classes, description, n)


# Insert a higher level categorization
class_inference$Category[class_inference$brand == "Adidas_Stan_Smith"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Adidas_Ultraboost"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Asics_Gel"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Fila_Sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Puma_Sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "vans_sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Birkenstock_Arizona"] <- "Sandal"
class_inference$Category[class_inference$brand == "Crocs"] <- "Sandal"
class_inference$Category[class_inference$brand == "Adidas_Continental_80"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Adidas_Running"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Adidas_Shoe"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Adidas_Superstar"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Anzugsschuhe"] <- "Business"
class_inference$Category[class_inference$brand == "Asics_Tiger"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Automn_boot"] <- "Boot"
class_inference$Category[class_inference$brand == "Birkenstock_Gizeh"] <- "Sandal"
class_inference$Category[class_inference$brand == "Birkenstock_Madrid"] <- "Sandal"
class_inference$Category[class_inference$brand == "Converse_chucks_high"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Converse_chucks_low"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Dr._Marten_low-level_shoes"] <- "Boot"
class_inference$Category[class_inference$brand == "Dr._Martens_Boots"] <- "Boot"
class_inference$Category[class_inference$brand == "Flipflops"] <- "Sandal"
class_inference$Category[class_inference$brand == "Gucci_Ace"] <- "Sneaker"
class_inference$Category[class_inference$brand == "High_Heels"] <- "High-Heel"
class_inference$Category[class_inference$brand == "Louboutin_Shoes"] <- "High-Heel"
class_inference$Category[class_inference$brand == "Kswiss_sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "lacoste_sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "NewBalance_Sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Nike_AirforceOne"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Nike_Blazer"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Nike_Jordans"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Nike_Running"] <- "Sneaker"
class_inference$Category[class_inference$brand == "sandals"] <- "Sandal"
class_inference$Category[class_inference$brand == "Sketchers_Sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Steve_Madden_Sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "suit_shoe"] <- "Business"
class_inference$Category[class_inference$brand == "Timberland_Boots"] <- "Boot"
class_inference$Category[class_inference$brand == "Tommy_Hilfiger_Sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "UGG_boots"] <- "Boot"
class_inference$Category[class_inference$brand == "vans_classic_slip_on"] <- "Sneaker"
class_inference$Category[class_inference$brand == "vans_old_school"] <- "Sneaker"
class_inference$Category[class_inference$brand == "vans_sneaker"] <- "Sneaker"
class_inference$Category[class_inference$brand == "Winter_boot"] <- "Boot"
class_inference$Category[class_inference$brand == "Autumn_boot"] <- "Boot"
class_inference$Category[class_inference$brand == "Reebok_Sneaker"] <- "Sneaker"


class_inference <- class_inference %>%
  select(Category, brand, classes, description, n) %>% 
  arrange(desc(Category), brand, desc(n))

## TO DO !!!!
# Evaluate if in every image a shoe could be detected


# Compute relative frequency of the brand classes
class_inference <- class_inference %>% group_by(Category, brand) %>%
  mutate(Rel.Freq = round(n/sum(n)*100, digits=2))


# Compare the rel. frequency of different brands in one category (Sneaker)
sneaker_classes <- class_inference %>% filter(Category == "Sneaker") %>%
  group_by(brand) %>% top_n(n=7)


# Compute how often one class appeared for the group "Sneaker"
sneaker_classes <- sneaker_classes %>% group_by(description) %>% 
  mutate(AbsSum = sum(n)) %>% arrange(Category, brand, desc(AbsSum))




# Widen the analysis with respect to the attributes
data_PCA$Category[data_PCA$brand == "Adidas_Stan_Smith"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Adidas_Ultraboost"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Asics_Gel"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Fila_Sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Puma_Sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "vans_sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Birkenstock_Arizona"] <- "Sandal"
data_PCA$Category[data_PCA$brand == "Crocs"] <- "Sandal"
data_PCA$Category[data_PCA$brand == "Adidas_Continental_80"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Adidas_Running"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Adidas_Shoe"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Adidas_Superstar"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Anzugsschuhe"] <- "Business"
data_PCA$Category[data_PCA$brand == "Asics_Tiger"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Automn_boot"] <- "Boot"
data_PCA$Category[data_PCA$brand == "Birkenstock_Gizeh"] <- "Sandal"
data_PCA$Category[data_PCA$brand == "Birkenstock_Madrid"] <- "Sandal"
data_PCA$Category[data_PCA$brand == "Converse_chucks_high"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Converse_chucks_low"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Dr._Marten_low-level_shoes"] <- "Boot"
data_PCA$Category[data_PCA$brand == "Dr._Martens_Boots"] <- "Boot"
data_PCA$Category[data_PCA$brand == "Flipflops"] <- "Sandal"
data_PCA$Category[data_PCA$brand == "Gucci_Ace"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "High_Heels"] <- "High-Heel"
data_PCA$Category[data_PCA$brand == "Louboutin_Shoes"] <- "High-Heel"
data_PCA$Category[data_PCA$brand == "Kswiss_sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "lacoste_sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "NewBalance_Sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Nike_AirforceOne"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Nike_Blazer"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Nike_Jordans"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Nike_Running"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "sandals"] <- "Sandal"
data_PCA$Category[data_PCA$brand == "Sketchers_Sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Steve_Madden_Sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "suit_shoe"] <- "Business"
data_PCA$Category[data_PCA$brand == "Timberland_Boots"] <- "Boot"
data_PCA$Category[data_PCA$brand == "Tommy_Hilfiger_Sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "UGG_boots"] <- "Boot"
data_PCA$Category[data_PCA$brand == "vans_classic_slip_on"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "vans_old_school"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "vans_sneaker"] <- "Sneaker"
data_PCA$Category[data_PCA$brand == "Winter_boot"] <- "Boot"
data_PCA$Category[data_PCA$brand == "Autumn_boot"] <- "Boot"
data_PCA$Category[data_PCA$brand == "Reebok_Sneaker"] <- "Sneaker"

data_PCA <- data_PCA %>% ungroup() %>% select(Category, image_file, brand, everything())



# COSINE - MEAN

# take the mean of all PC-attribute-class combinations w.r.t category
attr_prob_category <- data_PCA %>% select(-image_file, -brand) %>% 
  group_by(Category) %>% summarise_all(mean)


# take the mean of all PC-attribute-class combinations w.r.t brand
attr_prob_brand <- data_PCA %>% select(-image_file, -Category) %>% 
  group_by(brand) %>% summarise_all(mean)


# Cosine similarity for categories
cosine_category <- attr_prob_category %>% select(-Category)
cosine_category <- matrix(unlist(cosine_category), ncol=460, byrow = TRUE) %>% t()

cosine_sim_categories_mean <- cosine(cosine_category) %>% as.data.frame()
names(cosine_sim_categories_mean)[1] <- "Boot"
names(cosine_sim_categories_mean)[2] <- "High-Heel"
names(cosine_sim_categories_mean)[3] <- "Sandal"
names(cosine_sim_categories_mean)[4] <- "Sneaker"
names(cosine_sim_categories_mean)[5] <- "Business"


# Cosine similarity for brands
cosine_brand <- attr_prob_brand %>% select(-brand)
cosine_brand <- matrix(unlist(cosine_brand), ncol=460, byrow = TRUE) %>% t()

cosine_sim_brand_mean <- cosine(cosine_brand) %>% as.data.frame()
names(cosine_sim_brand_mean)[1] <- "Adidas_Continental_80"
names(cosine_sim_brand_mean)[2] <- "Adidas_Running"
names(cosine_sim_brand_mean)[3] <- "Adidas_Shoe"
names(cosine_sim_brand_mean)[4] <- "Adidas_Stan_Smith"
names(cosine_sim_brand_mean)[5] <- "Adidas_Superstar"
names(cosine_sim_brand_mean)[6] <- "Adidas_Ultraboost"
names(cosine_sim_brand_mean)[7] <- "Anzugsschuhe"
names(cosine_sim_brand_mean)[8] <- "Asics_Gel"
names(cosine_sim_brand_mean)[9] <- "Asics_Tiger"
names(cosine_sim_brand_mean)[10] <- "Autumn_boot"
names(cosine_sim_brand_mean)[11] <- "Birkenstock_Arizona"
names(cosine_sim_brand_mean)[12] <- "Birkenstock_Gizeh"
names(cosine_sim_brand_mean)[13] <- "Birkenstock_Madrid"
names(cosine_sim_brand_mean)[14] <- "Converse_chucks_high"
names(cosine_sim_brand_mean)[15] <- "Converse_chucks_low"
names(cosine_sim_brand_mean)[16] <- "Crocs"
names(cosine_sim_brand_mean)[17] <- "Dr._Marten_low-level_shoes"
names(cosine_sim_brand_mean)[18] <- "Dr._Martens_Boots"
names(cosine_sim_brand_mean)[19] <- "Fila_Sneaker"
names(cosine_sim_brand_mean)[20] <- "Flipflops"
names(cosine_sim_brand_mean)[21] <- "Gucci_Ace"
names(cosine_sim_brand_mean)[22] <- "High_Heels"
names(cosine_sim_brand_mean)[23] <- "Kswiss_sneaker"
names(cosine_sim_brand_mean)[24] <- "lacoste_sneaker"
names(cosine_sim_brand_mean)[25] <- "Louboutin_Shoes"
names(cosine_sim_brand_mean)[26] <- "NewBalance_Sneaker"
names(cosine_sim_brand_mean)[27] <- "Nike_AirforceOne"
names(cosine_sim_brand_mean)[28] <- "Nike_Blazer"
names(cosine_sim_brand_mean)[29] <- "Nike_Jordans"
names(cosine_sim_brand_mean)[30] <- "Nike_Running"
names(cosine_sim_brand_mean)[31] <- "Puma_Sneaker"
names(cosine_sim_brand_mean)[32] <- "Reebok_Sneaker"
names(cosine_sim_brand_mean)[33] <- "sandals"
names(cosine_sim_brand_mean)[34] <- "Sketchers_Sneaker"
names(cosine_sim_brand_mean)[35] <- "Steve_Madden_Sneaker"
names(cosine_sim_brand_mean)[36] <- "suit_shoe"
names(cosine_sim_brand_mean)[37] <- "Timberland_Boots"
names(cosine_sim_brand_mean)[38] <- "Tommy_Hilfiger_Sneaker"
names(cosine_sim_brand_mean)[39] <- "UGG_boots"
names(cosine_sim_brand_mean)[40] <- "vans_classic_slip_on"
names(cosine_sim_brand_mean)[41] <- "vans_old_school"
names(cosine_sim_brand_mean)[42] <- "vans_sneaker"
names(cosine_sim_brand_mean)[43] <- "Winter_boot"


# COSINE MEDIAN

# take the median of all PC-attribute-class combinations w.r.t category
attr_prob_category <- data_PCA %>% select(-image_file, -brand) %>% 
  group_by(Category) %>% summarise_all(median)


# take the median of all PC-attribute-class combinations w.r.t brand
attr_prob_brand <- data_PCA %>% select(-image_file, -Category) %>% 
  group_by(brand) %>% summarise_all(median)



# Cosine similarity for categories
cosine_category <- attr_prob_category %>% select(-Category)
cosine_category <- matrix(unlist(cosine_category), ncol=460, byrow = TRUE) %>% t()

cosine_sim_categories_median <- cosine(cosine_category) %>% as.data.frame()
names(cosine_sim_categories_median)[1] <- "Boot"
names(cosine_sim_categories_median)[2] <- "High-Heel"
names(cosine_sim_categories_median)[3] <- "Sandal"
names(cosine_sim_categories_median)[4] <- "Sneaker"
names(cosine_sim_categories_median)[5] <- "Business"


# Cosine similarity for brands
cosine_brand <- attr_prob_brand %>% select(-brand)
cosine_brand <- matrix(unlist(cosine_brand), ncol=460, byrow = TRUE) %>% t()

cosine_sim_brand_median <- cosine(cosine_brand) %>% as.data.frame()
names(cosine_sim_brand_median)[1] <- "Adidas_Continental_80"
names(cosine_sim_brand_median)[2] <- "Adidas_Running"
names(cosine_sim_brand_median)[3] <- "Adidas_Shoe"
names(cosine_sim_brand_median)[4] <- "Adidas_Stan_Smith"
names(cosine_sim_brand_median)[5] <- "Adidas_Superstar"
names(cosine_sim_brand_median)[6] <- "Adidas_Ultraboost"
names(cosine_sim_brand_median)[7] <- "Anzugsschuhe"
names(cosine_sim_brand_median)[8] <- "Asics_Gel"
names(cosine_sim_brand_median)[9] <- "Asics_Tiger"
names(cosine_sim_brand_median)[10] <- "Autumn_boot"
names(cosine_sim_brand_median)[11] <- "Birkenstock_Arizona"
names(cosine_sim_brand_median)[12] <- "Birkenstock_Gizeh"
names(cosine_sim_brand_median)[13] <- "Birkenstock_Madrid"
names(cosine_sim_brand_median)[14] <- "Converse_chucks_high"
names(cosine_sim_brand_median)[15] <- "Converse_chucks_low"
names(cosine_sim_brand_median)[16] <- "Crocs"
names(cosine_sim_brand_median)[17] <- "Dr._Marten_low-level_shoes"
names(cosine_sim_brand_median)[18] <- "Dr._Martens_Boots"
names(cosine_sim_brand_median)[19] <- "Fila_Sneaker"
names(cosine_sim_brand_median)[20] <- "Flipflops"
names(cosine_sim_brand_median)[21] <- "Gucci_Ace"
names(cosine_sim_brand_median)[22] <- "High_Heels"
names(cosine_sim_brand_median)[23] <- "Kswiss_sneaker"
names(cosine_sim_brand_median)[24] <- "lacoste_sneaker"
names(cosine_sim_brand_median)[25] <- "Louboutin_Shoes"
names(cosine_sim_brand_median)[26] <- "NewBalance_Sneaker"
names(cosine_sim_brand_median)[27] <- "Nike_AirforceOne"
names(cosine_sim_brand_median)[28] <- "Nike_Blazer"
names(cosine_sim_brand_median)[29] <- "Nike_Jordans"
names(cosine_sim_brand_median)[30] <- "Nike_Running"
names(cosine_sim_brand_median)[31] <- "Puma_Sneaker"
names(cosine_sim_brand_median)[32] <- "Reebok_Sneaker"
names(cosine_sim_brand_median)[33] <- "sandals"
names(cosine_sim_brand_median)[34] <- "Sketchers_Sneaker"
names(cosine_sim_brand_median)[35] <- "Steve_Madden_Sneaker"
names(cosine_sim_brand_median)[36] <- "suit_shoe"
names(cosine_sim_brand_median)[37] <- "Timberland_Boots"
names(cosine_sim_brand_median)[38] <- "Tommy_Hilfiger_Sneaker"
names(cosine_sim_brand_median)[39] <- "UGG_boots"
names(cosine_sim_brand_median)[40] <- "vans_classic_slip_on"
names(cosine_sim_brand_median)[41] <- "vans_old_school"
names(cosine_sim_brand_median)[42] <- "vans_sneaker"
names(cosine_sim_brand_median)[43] <- "Winter_boot"




# COSINE MAX

# take the max of all PC-attribute-class combinations w.r.t category
attr_prob_category <- data_PCA %>% select(-image_file, -brand) %>% 
  group_by(Category) %>% summarise_all(max)


# take the max of all PC-attribute-class combinations w.r.t brand
attr_prob_brand <- data_PCA %>% select(-image_file, -Category) %>% 
  group_by(brand) %>% summarise_all(max)



# Cosine similarity for categories
cosine_category <- attr_prob_category %>% select(-Category)
cosine_category <- matrix(unlist(cosine_category), ncol=460, byrow = TRUE) %>% t()

cosine_sim_categories_max <- cosine(cosine_category) %>% as.data.frame()
names(cosine_sim_categories_max)[1] <- "Boot"
names(cosine_sim_categories_max)[2] <- "High-Heel"
names(cosine_sim_categories_max)[3] <- "Sandal"
names(cosine_sim_categories_max)[4] <- "Sneaker"
names(cosine_sim_categories_max)[5] <- "Business"


# Cosine similarity for brands
cosine_brand <- attr_prob_brand %>% select(-brand)
cosine_brand <- matrix(unlist(cosine_brand), ncol=460, byrow = TRUE) %>% t()

cosine_sim_brand_max <- cosine(cosine_brand) %>% as.data.frame()
names(cosine_sim_brand_max)[1] <- "Adidas_Continental_80"
names(cosine_sim_brand_max)[2] <- "Adidas_Running"
names(cosine_sim_brand_max)[3] <- "Adidas_Shoe"
names(cosine_sim_brand_max)[4] <- "Adidas_Stan_Smith"
names(cosine_sim_brand_max)[5] <- "Adidas_Superstar"
names(cosine_sim_brand_max)[6] <- "Adidas_Ultraboost"
names(cosine_sim_brand_max)[7] <- "Anzugsschuhe"
names(cosine_sim_brand_max)[8] <- "Asics_Gel"
names(cosine_sim_brand_max)[9] <- "Asics_Tiger"
names(cosine_sim_brand_max)[10] <- "Autumn_boot"
names(cosine_sim_brand_max)[11] <- "Birkenstock_Arizona"
names(cosine_sim_brand_max)[12] <- "Birkenstock_Gizeh"
names(cosine_sim_brand_max)[13] <- "Birkenstock_Madrid"
names(cosine_sim_brand_max)[14] <- "Converse_chucks_high"
names(cosine_sim_brand_max)[15] <- "Converse_chucks_low"
names(cosine_sim_brand_max)[16] <- "Crocs"
names(cosine_sim_brand_max)[17] <- "Dr._Marten_low-level_shoes"
names(cosine_sim_brand_max)[18] <- "Dr._Martens_Boots"
names(cosine_sim_brand_max)[19] <- "Fila_Sneaker"
names(cosine_sim_brand_max)[20] <- "Flipflops"
names(cosine_sim_brand_max)[21] <- "Gucci_Ace"
names(cosine_sim_brand_max)[22] <- "High_Heels"
names(cosine_sim_brand_max)[23] <- "Kswiss_sneaker"
names(cosine_sim_brand_max)[24] <- "lacoste_sneaker"
names(cosine_sim_brand_max)[25] <- "Louboutin_Shoes"
names(cosine_sim_brand_max)[26] <- "NewBalance_Sneaker"
names(cosine_sim_brand_max)[27] <- "Nike_AirforceOne"
names(cosine_sim_brand_max)[28] <- "Nike_Blazer"
names(cosine_sim_brand_max)[29] <- "Nike_Jordans"
names(cosine_sim_brand_max)[30] <- "Nike_Running"
names(cosine_sim_brand_max)[31] <- "Puma_Sneaker"
names(cosine_sim_brand_max)[32] <- "Reebok_Sneaker"
names(cosine_sim_brand_max)[33] <- "sandals"
names(cosine_sim_brand_max)[34] <- "Sketchers_Sneaker"
names(cosine_sim_brand_max)[35] <- "Steve_Madden_Sneaker"
names(cosine_sim_brand_max)[36] <- "suit_shoe"
names(cosine_sim_brand_max)[37] <- "Timberland_Boots"
names(cosine_sim_brand_max)[38] <- "Tommy_Hilfiger_Sneaker"
names(cosine_sim_brand_max)[39] <- "UGG_boots"
names(cosine_sim_brand_max)[40] <- "vans_classic_slip_on"
names(cosine_sim_brand_max)[41] <- "vans_old_school"
names(cosine_sim_brand_max)[42] <- "vans_sneaker"
names(cosine_sim_brand_max)[43] <- "Winter_boot"



# TO DO!!!
# ?hnlichkeit innerhalb einer KAtegorie vs au?erhalb der Kategorie 
