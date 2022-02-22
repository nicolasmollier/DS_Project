# Packages ----------------------------------------------------------------

if (!require("pacman")){
  install.packages("pacman")
} 

library(pacman)

p_load(shiny, shinydashboard, dashboardthemes, shinyFiles, plyr, lsa, SnowballC,
       tidyverse, shinyjs, htmlwidgets, readr, reticulate, jpeg, here,
       magrittr, waiter, shinycssloaders, shinybusy, shinyBS, scales, slickR, tidymodels,
       plotly)


# Python Packages
torch <- import("torch")
np <- import("numpy")



# java script and html ----------------------------------------------------

source(here::here("scripts/js_html_for_app.R"))



# Data --------------------------------------------------------------------

pca_result_classes <- readRDS(here::here("data/fp_select_attrib_per_class_pca.rds"))
pca_result_image <- readRDS(here::here("data/fp_select_image_per_row_pca.rds"))

# ToDo: Außerhalb der App machen (vorher)
# define new classes
new_classes <- c("shirt / blouse", "top / t-shirt / sweatshirt",
                 "sweater", "cardigan", "jacket", "vest", "pants",
                 "shorts", "skirt", "coat", "dress", "jumpsuit",
                 "cape", "glasses", "hat", "headband /head covering / hair accessory", 
                 "tie", "glove", "watch", "belt", "leg warmer", 
                 "tights / stockings", "sock", "shoe",
                 "bag / wallet", "scarf", "umbrella", "hood", "collar",
                 "lapel", "epaulette", "sleeve", "pocket", "neckline", 
                 "buckle", "zipper", "applique", "bead", "bow", 
                 "flower", "fringe", "ribbon", "rivet", "ruffle",
                 "sequin", "tassel")

# define new brands
new_brand <- c("Adidas sneaker", "Adidas sneaker", "Adidas sneaker", "Adidas sneaker",
               "Adidas sneaker", "Adidas sneaker", "business shoe", "Asics sneaker",
               "Asics sneaker", "Autumn Boot", "Birkenstock Arizona", "Birkenstock Gizeh",
               "Birkenstock Madrid", "Converse Chucks", "Converse Chucks", "Crocs",
               "Dr. Martens shoe", "Dr. Martens boot", "Fila sneaker", "Flipflop",
               "Gucci sneaker", "high heel", "Kswiss sneaker", "Lacoste sneaker",
               "Louboutin high heel", "New Balance sneaker", "Nike sneaker",
               "Nike sneaker", "Nike sneaker", "Nike sneaker", "Puma sneaker",
               "Reebok sneaker", "sandal", "Sketcher sneaker", "Steve Madden sneaker",
               "business shoe", "Timberland boot", "Tommy Hilfiger sneaker",
               "UGG boot", "Vans sneaker", "Vans sneaker", "Vans sneaker", "Winter boot")

# map values to new column
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
source_python(here("scripts/RF_prediction.py"))
source(here::here("scripts/RF_prediction_function.R"))
load(here::here("model_weights/RF_model_feature2.RData"))


# Fashionpedia
reticulate::source_python(here("scripts/fashionpedia_python_script.py"))
#setwd("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/fashion_recommender_app_cloud/")




# Functions for Feature 1: Get recommended items and load respective images
# from the web
source(here::here("scripts/feature_1_functions.R"))
source(here::here("scripts/feature_2_and_3_functions.R"))

# Define the vogue links
vogue_df <- scrape_news()



# Source UI and Server ----------------------------------------------------

ui <- dashboardPage(
  dashboardHeader(
    title = customLogo,
    titleWidth = "270"
  ),
  dashboardSidebar(
    width = "310",
    sidebarMenu(
      id = "side_bar_menue",
      br(), br(),
      menuItem("Home", tabName = "landing_page", icon = icon("globe")),
      menuItem("Shoe Gallery", tabName = "image_selection", icon = icon("camera")),
      menuItem("Outfit Recommendation", tabName = "recommendation", icon = icon("user-tie")),
      menuItem("Shoe Recommendation", tabName = "recommendation2", icon = icon("shoe-prints")),
      menuItem("Outfit Evaluation", tabName = "evaluation", icon = icon("chart-pie")),
      menuItem("Data Exploration", tabName = "data_exploration", icon = icon("wpexplorer"))
    ),
    br(),
    br(),
    # Explanation text for the different features --> discuss how it could be displayed
    conditionalPanel(
      'input.side_bar_menue == "recommendation"',
      tags$div(
        tags$ul(
          tags$li("Upload shoe / Choose from gallery"),
          tags$li("Select gender"),
          tags$li("Select country"),
          tags$li("Select desired clothing items (optional)")
        )
      )
    ),
    conditionalPanel(
      'input.side_bar_menue == "recommendation2"',
      tags$div(
        tags$ul(
          tags$li("Upload outfit"),
          tags$li("Select gender"),
          tags$li("Select country")
        )
      )
    ),
    conditionalPanel(
      'input.side_bar_menue == "evaluation"',
      tags$div(
        tags$ul(
          tags$li("Upload outfit"),
          tags$li("Upload shoe"),
          tags$li("Select gender"),
          tags$li("Select country")
        )
      )
    )
    
  ),
  dashboardBody(
    customTheme,
    
    
    ## Landing Page ------------------------------------------------------------
    
    tabItems(
      tabItem(
        tabName = "landing_page",
        mainPanel(width = 12, tabsetPanel(
          type = "tabs",
          tabPanel(
            "Benefits",
            tags$head(tags$style(HTML("
      .box.box-primary{
      -webkit-box-shadow: none;
      -moz-box-shadow: none;
      box-shadow: none;
      border-top: none;
      margin-bottom: 0px;
      }
      .box-body{
      padding: 0px;
      }
      .box.box-info{
      -webkit-box-shadow: none;
      -moz-box-shadow: none;
      box-shadow: none;
      border-top: none;
      margin-bottom: 0px;
      margin-top: 0px;
      display: flex;
      align-items: center;
      justify-content: center;
      align-content: center;
      }
      .skin-blue .left-side, .skin-blue .main-sidebar, .skin-blue .wrapper {
        background-color: white;
      }
      "))),
            fluidRow(
              slickROutput("slickr"),
              align = "center"
            ),
            fluidRow(
              # reactivecontain necessary to get to feature 1
              box(
                width = 12, height = 100, status = "info", align = "center",
                actionButton("get_started_button", "Get started now >>",
                  style = "color: #ffffff; background-color: #0093ff; border-color: #2e6da4"
                )
              )
            ),
            fluidRow(
              box(
                width = 4, align = "center", status = "info",
                div(img(src = "Icon_outfit.png", height = "70px", width = "70px"))
              ),
              box(
                width = 4, align = "center", status = "info",
                div(img(src = "Icon_shoe.png", height = "70px", width = "70px"))
              ),
              box(
                width = 4, align = "center", status = "info",
                div(img(src = "Icon_recomm.png", height = "70px", width = "70px"))
              )
            ),
            fluidRow(
              box(
                width = 4, align = "center", status = "primary",
                h3("> 6.000 outfits analyzed", style = "color:black")
              ),
              box(
                width = 4, align = "center", status = "primary",
                h3("> 40 shoe brands and types", style = "color:black")
              ),
              box(
                width = 4, align = "center", status = "primary",
                h3("Truly outfit-based recommendations", style = "color:black")
              )
            ),
            fluidRow(
              box(
                width = 4, align = "center", status = "primary",
                h4("To ensure best possible recommendations, we‘ve carefully built a large database of fashionable outfits.
                Based on this rich data set we trained state-of-the-art machine learning models to ensure best possible
                recommendations.")
              ),
              box(
                width = 4, align = "center", status = "primary",
                h4("We know people love shoes. They are an integral part of any outfit. Therefore, we have made sure that our
             data contain the most important shoe brands and types. Due to our unique data set and state-of-the-art
             machine learning models we are able to provide meaningful brand-level shoe recommendations.")
              ),
              box(
                width = 4, align = "center", status = "primary",
                h4("Unlike common techniques, we provide you with recommendations that take the entire outfit into account.
             This ensures that all parts of your style are always aligned and up-to-date.")
              ),
            ),
            fluidRow(
              box(width = 12, height = 80, status = "primary")
            ),
            fluidRow(
              box(
                width = 12, status = "info",
                box(
                  width = 4, height = 400, align = "center", status = "info",
                  img(src = "Icon_outfit_recomm.png", height = "85%", width = "85%"),
                  style = "text-align: center;"
                ),
                box(
                  width = 8, height = 400, align = "center", status = "info",
                  h2("Outfit recommendation", style = "text-align: left; color: black;"),
                  h4("Our outfit recommendation engine gives you the opportunity to get
             recommendations for various clothing items, ranging from pants and dresses
             to accessories such as glasses and handbags. All items are chosen such that
             they match your preferred brand or type of shoe.", style = "text-align : left;"),
                  actionLink("button_outfit_feat1", "Get personalized outfit recommendation",
                    style = "color: #0093ff;"
                  ),
                  h3("Here's how it works:", style = "text-align: left;"),
                  tags$div(
                    tags$ul(
                      tags$li("Either upload a picture of a shoe or select one from the gallery"),
                      tags$li("Adjust gender specification"),
                      tags$li("Select for which type of clothing item you'd like a recommendation (optional)"),
                      tags$li("Choose your country of origin"),
                      tags$li("Get your personalized recommendations based on your favorite shoe")
                    )
                  ), style = "font-size: 15px; text-align: left;",
                ), style = "border-bottom: 2px solid; border-top: 2px solid;"
              ),
              box(
                width = 12, status = "info",
                box(
                  width = 8, height = 400, align = "center", status = "info",
                  h2("Shoe recommendation", style = "text-align: left; color: black;"),
                  tags$div(
                    tags$h4("In order to find out which shoe fits perfect to your outfit of interest, simply upload
                                            a picture of the outfit. Next, a state-of-the-art algorithm will identify all clothing items and their respective attributes of the
                                            uploaded outfit. Based on this data, we use an advanced and specifically trained
                                              machine learning algorithm to recommend the perfect shoe.", style = "text-align : left;"),
                    tags$a(href = "https://fashionpedia.github.io/home/", "Check out Fashionpedia")
                  ),
                  br(),
                  actionLink("button_shoe_feat2", "Get personalized shoe recommendation",
                    style = "color: #0093ff;"
                  ),
                  h3("Here's how it works:", stye = "text-align: left;"),
                  tags$div(
                    tags$ul(
                      tags$li("Upload a picture of the outfit you want to get shoe recommendations for"),
                      tags$li("Adjust gender specification"),
                      tags$li("Choose your country of origin"),
                      tags$li("Get your personalized shoe recommendations based on your specific outfit")
                    )
                  ), style = "font-size: 15px; text-align: left;",
                ),
                box(
                  width = 4, height = 400, align = "center", status = "info",
                  div(img(src = "Icon_shoe_recomm.png", height = "85%", width = "85%"),
                    style = "text-align: center;"
                  )
                ), style = "border-bottom: 2px solid;"
              ),
              box(
                width = 12, status = "info",
                box(
                  width = 4, height = 400, align = "center", status = "info",
                  div(img(src = "Icon_outfit_eval.png", height = "85%", width = "85%"),
                    style = "text-align: center;"
                  )
                ),
                box(
                  width = 8, height = 400, align = "center", status = "info",
                  h2("Outfit evaluation", style = "text-align: left; color: black;"),
                  h4("Our outfit evaluation engine gives you the opportunity to get a
                                      measure of how well-suited your overall outfit is.
                                      The service provides you with the clothing item which is most different to our representative data base
                                      and with further clothing attributes to complement your outfit.", style = "text-align : left;"),
                  actionLink("button_eval_feat3", "Get outfit evaluation",
                    style = "color: #0093ff;"
                  ),
                  h3("Here's how it works:", style = "text-align: left;"),
                  tags$div(
                    tags$ul(
                      tags$li("Upload a picture of your outfit"),
                      tags$li("Upload a picture of your shoe"),
                      tags$li("Adjust gender specification"),
                      tags$li("Choose your country of origin"),
                      tags$li("Get your personalized recommendation on how to fit your clothing better to your shoe"),
                      tags$li("You will also receive a score that indicates how well your outfit fits the shoe"),
                      tags$li("Get further fashion items to complement your outift")
                    )
                  ), style = "font-size: 15px; text-align: left;"
                ), style = "border-bottom: 2px solid;"
              )
            )
          ),
          tabPanel(
            "Methodology",
            tags$head(tags$style(HTML("
                              .box.box-solid.box-warning > .box-header h3, .box.box-warning > .box-header h3 {
                                color: white;
                              }
                              .box-header .box-title {
                                font-size: 16px;
                              }
                              .h3, h3 {
                                font-size: 20px;
                              }
                              .h3, h3 {
                                margin-top: 0px;
                                margin-bottom: 0px;
                              }
                              .box-body {
                                padding: 10px;
                              }
                              .h5, h5 {
                                font-size: 16px;
                              }
                              "))),
            fluidRow(
              br(),
              box(
                title = h3("1.) Build database"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Scrape images from Google", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("We used Google images and automatically scraped query results with respect to 43 different shoe types.
                                    We wanted to make sure that we do not only scrape the shoe itself but to get an entire body shot with the clothings worn.
                                    Therefore, the queries were selected to optimize the results. All in all, we scraped more than 17,000 images to obtain
                                    a representative data base.")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Deep Learning algorithm Fashionpedia", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("We adjusted the algorithm of Fashionpedia to make it usable in our case.
                                    Applying this algorithm to the scraped images, we received information about what different clothing items
                                    the person is wearing (out of 46 different clothing classes) and the probability of each clothing item that it has
                                    a certain attribute. The algorithm is capable of detecting 294 different attributes (e.g. cargo, plain, etc.).")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Final data base", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("In order to make the data base usable, a lot of data cleaning was necessary.
                                    Most importantly, we dropped all image observations
                                    containing lass than 4 classes with a threshold of 80%. In this way, we made sure
                                    that no 'angle-shots' are contained in the database and only full-body shots are
                                    taken into account. We conducted PCA analyses to tackle the dimensionality issue such that
                                    each image was finally represented by a 330-dimensional vector."),
                ),
                box(status = "primary", width = 12, height = 20),
              ),
              box(
                title = h3("2.) Modelling and EDA"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Convolutional Neural Network (CNN)", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("In order to classify the brand and the type of a shoe, respectively,
                                    we built a CNN shoe classifier. We used a pre-trained ResNet-152 model
                                    and fine-tuned it to classify the 43 different shoe types we scraped from
                                    Google. With the state-of-the-art classifier, we achieved an average
                                    accuracy of 95% on the test images.")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Random Forest", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("In order to obtain suitable shoe recommendations based on the uploaded
                                    body shot, we trained a random forest algorithm to cluster the detected
                                    classes and the probabilities for certain attributes to similar outfits of our data base.
                                    We then select the 3 most probable shoe types and brands with respect to the most similar
                                    outfits.")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "EDA", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("The application complements with the possibility for the user to get to know the
                                    data base better. In a 3D-simulation, the user can detect differences for the different
                                    shoe types with respect to different clothing types.")
                ),
                box(status = "primary", width = 12, height = 20),
              )
            ),
            box(status = "primary", width = 12, height = 50),
            fluidRow(
              box(
                title = h3("3.) Design & implement recommendation engines"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Outfit recommendation", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("After the user has uploaded a shoe and chose a shoe from the displayed gallery,
                                    respectively, there are filter options with repesct to the gender, the country of
                                    origin, and if certain fashion items are explicitly desired.
                                    We then filter our database with repect to the shoe type and filter for the most
                                    found clothing items and the most corresponding attribute. The 5 most class-attribute-combinations
                                    are then sent via an automated query to the online shopping website Asos. If a different country
                                    was selected, the query is first translated. We then automatically and live (data is not stored locally)
                                    scrape the first 3 hits of each combination with the respective price of the fashion item and embed
                                    the results in the output window.")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Shoe recommendation", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("After the user has uploaded the body shot, the Fashionpedia algorithm runs over it to
                                    detect the classes and corresponding attributes. With the random forest algorithm, we find
                                    the three most similar outfit combinations in the data base and retrieve the corresponding shoe types.
                                    Those shoe types are than sent via a query to Asos as well in order to get the 3 first hits on the
                                    webpage which are once again embedded in the output window.")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Outfit evaluation", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("After the body shot and the shoe image are uploaded, Fashionpedia and the shoe classifier
                                    run over the two images, respectively. The database is then filtered with respect to the shoe type
                                    and the classes found in the body shot upload. With respect to each class, the cosine similarity is computed and
                                    then averages over all scores to determine how similar the outfit is to the findings in the database.
                                    For the lowest cosine score, a more proper attribute combination is sent in a query to Asos and displayed
                                    in the output window. Furthermore, 3 classes which were not found in the image upload are combined
                                    with the most-seen attribute to give the user an understanding which further clothing items might be suitable.")
                ),
                box(status = "primary", width = 12, height = 20),
              ),
              box(
                title = h3("4.) Design & implement application"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Recommended fashion items", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("We chose a grid representation with the price attribute for the different fashion items.
                                    The setting is selected to be very similar to an online shopping experience.
                                    Furthermore, the user can click on the respective image to obtain immediately access to the online shop.")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "User experience", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("The application is built up in a way, that it is very intuitive and understandable which
                                    inputs have to be made. Moreover, links in the app refer to the different features to facilitate the
                                    application handling. Through the automated queries to Asos, the application renews the recommendations
                                    each day through adjustments of Asos when new items are uploaded.")
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Cloud hosting", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5("In order to make the application accessible for all users and increase traffic, we hosted the website on
                                    the bwCloud. The performance, especially when applying the Fashionpedia algorithm is therefore limited
                                    since GPU-computations are not offered. Moreover, the storage space is very limited such that other
                                    solutions are taken into consideration when widening the application.")
                ),
                box(status = "primary", width = 12, height = 20),
              )
            )



            #          column(width = 6,
            #            box(width = 12, height = 100, status = "info",
            #                h1("1.) Build database", align = "center"),
            #                style = "border-bottom: 1px solid"),
            #         box(width = 12, status = "info",
            #          box(width = 12,
            #            title = "Scrape images of outfits", status = "success", solidHeader = TRUE,
            #            collapsible = TRUE, collapsed = TRUE,
            #            plotOutput("plot3", height = 250)
            #          ),
            #          box(width = 12,
            #              title = "Analyze images using fashionpedia", status = "success", solidHeader = TRUE,
            #              collapsible = TRUE, collapsed = TRUE,
            #              plotOutput("plot3", height = 250)
            #          )
            #         )
            # )
          ),
          tabPanel(
            "About",
            fluidRow(
              box(
                width = 12, height = 100, status = "info",
                h1("The Project", align = "center")
              )
            ),
            fluidRow(
              box(
                width = 12, status = "info",
                box(
                  width = 4, height = 400, align = "center", status = "info",
                  img(
                    src = "https://uni-tuebingen.de/fileadmin/_processed_/9/7/csm_DS_mit_Hintergrund_4bd4e57cd6.png",
                    height = "60%", width = "60%"
                  ),
                  style = "text-align: center;"
                ),
                box(
                  width = 8, height = 400, align = "center", status = "info",
                  h2("This web app was created as part of a seminar of the program", tags$br(), "
                          'Data Science in Business & Economics' at the University of Tübingen",
                    style = "text-align: left; color: black;"
                  ),
                  h4("The basic idea of this module is that students independently and in groups design
                       and program the entire process of a data science project. A particular focus is
                       automation, i.e. acquisition of data, structuring, importing, validating,
                       modifying, and evaluating data occurs without the supervision of an analyst or user of the analysis.",
                    style = "text-align : left;"
                  ),
                  tags$a(
                    href = "https://uni-tuebingen.de/de/144465", "View program...",
                    style = "color:  #0093ff"
                  ),
                  style = "font-size: 15px; text-align: left;"
                ),
                style = "border-bottom: 2px solid; border-top: 2px solid;"
              )
            ),
            fluidRow(
              box(width = 12, height = 70, status = "primary"),
              box(
                width = 12, height = 100, status = "info",
                h1("Meet The Team", align = "center")
              ),
              box(
                width = 12, status = "info",
                box(
                  width = 4, height = 250, align = "center", status = "info",
                  div(img(src = "max.jpg", height = "25%", width = "25%"),
                    style = "text-align: center;"
                  )
                ),
                box(
                  width = 4, height = 250, align = "center", status = "info",
                  div(img(src = "Nicolas.png", height = "25%", width = "25%"),
                    style = "text-align: center;"
                  )
                ),
                box(
                  width = 4, height = 250, align = "center", status = "info",
                  div(img(src = "Cornelius.jpeg", height = "25%", width = "25%"),
                    style = "text-align: center;"
                  )
                ), style = "border-top: 2px solid;"
              )
            ),
            fluidRow(
              box(
                width = 4, align = "center", status = "primary",
                h3("Max Kneißler"),
                h4("M.Sc. Data Science in Business & Economics (3rd semester)"),
                h4("Working student at Porsche AG"),
                tags$a(
                  href = "https://www.linkedin.com/in/max-knei%C3%9Fler-235499171/", "View LinkedIn profile...",
                  style = "color:  #0093ff"
                ),
                style = "text-align: center;"
              ),
              box(
                width = 4, align = "center", status = "primary",
                h3("Nicolas Mollier"),
                h4("M.Sc. Data Science in Business & Economics (3rd semester)"),
                h4("Working student at eoda GmbH"),
                tags$a(
                  href = "https://www.linkedin.com/in/nicolas-mollier-84a20b198/", "View LinkedIn profile...",
                  style = "color:  #0093ff"
                ),
                style = "text-align: center;"
              ),
              box(
                width = 4, align = "center", status = "primary",
                h3("Cornelius Widmaier"),
                h4("M.Sc. Data Science in Business & Economics (3rd semester)"),
                h4("Working student at Layer7 AI GmbH"),
                h4("RA at Yale SOM"),
                tags$a(
                  href = "https://www.linkedin.com/in/cornelius-w-8720041a4/", "View LinkedIn profile...",
                  style = "color:  #0093ff"
                ),
                style = "text-align: center;"
              ),
              style = "border-bottom: 2px solid;"
            )
          )
        ))
      ),
      
      
      ## Feature 1 - UI ----------------------------------------------------------
      
      
      
      # feature 1: Image Selection in Gallery
      tabItem(
        tabName = "image_selection",
        conditionalPanel("input.side_bar_menue == 'image_selection'",
                         fluidRow(
                           useShinyjs(),
                           tags$head(tags$script(HTML(js))),
                           HTML(img_html),
                         )),
        mainPanel(
          div(id = "image-container", style = "display:flexbox")
        )
      ),
      tabItem(
        tabName = "recommendation",
        conditionalPanel(
          "input.side_bar_menue == 'recommendation'",
          column(
            2,
            fluidRow(
              withSpinner(uiOutput("selected_shoe"), size = 0)
            ),
            br(), br(), br(),
            conditionalPanel(
              "!is.null(output.recommended_items_class_2)",
              selectizeInput(
                "feature_1_filter_gender",
                label = "Change your gender",
                choices = c("Men", "Women", "Diverse"),
                selected = "Men",
                width = "230px"
              )
            ),
            br(),
            conditionalPanel(
              "input.side_bar_menue == 'recommendation'",
              selectizeInput(
                "feature_1_filter_country",
                label = "Change country of origin",
                choices = c("de", "es", "fr", "gb", "it", "us"),
                selected = "us",
                width = "230px"
              )
            ),
            conditionalPanel(
              "input.side_bar_menue == 'recommendation'",
              selectizeInput(
                "feature_1_filter_items_class",
                label = "Which items do you want recommendations for?",
                choices = c(
                  "shirt, blouse", "top, t-shirt, sweatshirt",
                  "sweater", "cardigan", "jacket", "vest", "pants",
                  "shorts", "skirt", "coat", "dress", "jumpsuit",
                  "glasses", "hat", "tie"
                ) %>%
                  sort(),
                width = "230px",
                multiple = TRUE,
                options = list(maxItems = 5)
              )
            ),
            br(), br(),
            box(
              id = "feature_1_button_box",
              actionButton(
                inputId = "action_button_feature_1",
                label = "Start Calculations"
              ),
              title = "Get Recommendations",
              width = 9
            )
          ),
          column(
            2,
            withSpinner(
              uiOutput("recommended_items_class_1"),
              size = 0
            )
          ),
          column(
            2,
            withSpinner(
              uiOutput("recommended_items_class_2"),
              id = "feature_1_spinner",
              color = "#4F4F4F"
            )
          ),
          column(
            2,
            withSpinner(
              uiOutput("recommended_items_class_3"),
              size = 0
            )
          ),
          column(
            2,
            withSpinner(
              uiOutput("recommended_items_class_4"),
              size = 0
            )
          ),
          column(
            2,
            withSpinner(
              uiOutput("recommended_items_class_5"),
              size = 0
            )
          )
        )
      ),
      
      
      
      
      
      ## Feature 2 - UI ----------------------------------------------------------
      
      
      tabItem(
        tabName = "recommendation2",
        column(
          2,
          br(), br(),
          conditionalPanel(
            "input.side_bar_menue == 'recommendation2'",
            fluidRow(
              useShinyjs(), # Set up shinyjs
              
              box(
                id = "feature_2_outfit_box",
                fileInput("feature_2_upload", NULL, buttonLabel = "Upload...", multiple = TRUE),
                imageOutput("feature_2_image"),
                title = "Upload an image of your outfit",
                width = 12
              ))),
        ),
        
        column(
          2,
          uiOutput("feature_2_recommended_items_class_1")
        ),
        column(
          2,
          uiOutput("feature_2_recommended_items_class_2")
        ),
        column(
          2,
          uiOutput("feature_2_recommended_items_class_3")
        ),
      ),
      
      
      
      
      ## Feature 3 - UI ----------------------------------------------------------
      
      
        tabItem(
          tabName = "evaluation",
          column(
            2,
            br(), br(),
            conditionalPanel(
              "input.side_bar_menue == 'evaluation'",
              fluidRow(
                useShinyjs(), # Set up shinyjs

                box(
                  id = "feature_3_outfit_box",
                  fileInput(
                    "feature_3_upload_body",
                    NULL,
                    buttonLabel = "Upload...",
                    multiple = FALSE
                  ),
                  uiOutput("feature_3_outfit_spinner"),
                  title = "Upload an image of your outfit",
                  width = 12
                ),
                uiOutput("feature_3_shoe_box_and_spinner"),
                br(), br(),
                # Added for Info when waiting for FP
                selectizeInput(
                  "feature_3_filter_gender",
                  label = "Change your gender",
                  choices = c("Men", "Women", "Diverse"),
                  selected = "Men",
                  width = "230px"
                ),
                uiOutput("feature_3_button_box_ui")
              )
            )
          ),
          column(
            2,
            h4("Adjust the following clothing item"),
            withSpinner(uiOutput("feature_3_recommended_items_class_1"), size = 0)
          ),
          column(2),
          column(
            2,
            h4("x", style = "color:white;"),
            withSpinner(
              uiOutput("feature_3_recommended_items_class_2"),
              id = "feature_3_spinner",
              color = "#4F4F4F"
            )
          ),
          column(
            2,
            conditionalPanel(
              condition = FALSE,
              h4("Current fashion trends would add ..")
              ),
            withSpinner(uiOutput("feature_3_recommended_items_class_3"), size = 0)
            
          ),
          column(
            2,
            h4("x", style = "color:white;"),
            withSpinner(uiOutput("feature_3_recommended_items_class_4"), size = 0)
          ),

          # Java code for set-up of vogue information
          tags$style(HTML("
                .col-sm-8{
                padding-left: 0px;
                }
                .box.box-primary>.box-header {
                display: none
                }
                .box.box-primary{
                border-top: 0px;
                margin-bottom: 0px;
                -webkit-box-shadow: none;
                -moz-box-shadow: none;
                box-shadow: none;
                }
                .modal-header{
                border-bottom: 3px solid;
                }
                .modal-dialog{
                width: 500px;
                overflow-y: auto;
                }
                .modal-title{
                font-size: 23px;
                font-weight: bold;
                }
                .shiny-notification{
                color:#ffffff;
                background-color: #40c300;
                border: #2a7b02;
                }
                .container-fluid{
                max-height: calc(80vh - 210px);
                overflow-y: auto;
                padding-right: 40px;
                padding-left: 40px;
                }")),


          # Vogue information - to figure out if a page needs to be added
          # To be implemented for feature 2 as well!

          # Has to be displayed when the action button was clicked
          bsModal(id = "pop", title = "While we're analyzing your outfit, why don't you
            check out the latest fashion trends...?",
                  trigger = "feature_3_button_box_ui",

                  fluidPage(

                    fluidRow(

                      lapply(1:nrow(vogue_df), function(i) {

                        fluidRow(

                          box(
                            status = "primary", width = 8, title = NULL, headerBorder = NULL,
                            tags$div(
                              tags$a(href=vogue_df$link[i],
                                     vogue_df$header[i], style = "color: #000000")
                            ), style = "font-size: 18px; text-align: left;"),
                          box(
                            status = "primary", width = 4,
                            div(uiOutput(paste0('pic', i)), style = "text-align: right"),
                          ), style = "border-bottom: 1px solid"
                        )
                      }), theme = "bootstrap.css"
                      )
                    )
                  )

        ),

      
      
      
      ## Feature 4 - UI ----------------------------------------------------------
      
      tabItem(
        tabName = "data_exploration",
        # Application title
        titlePanel("Differences in clothing attributes for different shoe types"),
        
        # sidebar layout
        sidebarLayout(
          
          # inputs
          sidebarPanel(
            # select type of clothing that should be shown
            selectInput(inputId = "choice_cloth", label = "What type of apparel item are you interested in?", 
                        choices = c("Entire outfit", "bag / wallet", "cardigan", "coat", "dress", 
                                    "glasses", "hat", "jacket", "jumpsuit", "pants",
                                    "scarf", "shirt / blouse", "shorts", "skirt", "sweater",
                                    "top / t-shirt / sweatshirt", "watch"),
                        selected = "Entire outfit"),
            
            # select type of shoe to be shown
            selectizeInput("variable_shoe", "Select type / brand:",
                           choices = c(as.character(sort(unique(pca_result_classes$new_brand)))),
                           selected = as.character(sort(unique(pca_result_classes$new_brand)))[1],
                           multiple = T,
                           options = list(maxItems = 3, placeholder = 'type here...')),
            width = 2),
          
          # Output: show 3D plot
          mainPanel(
            plotlyOutput(outputId = "plot_feat4", width = "100%", height = "100%"),
            width = 8)
        ) 
      )
    )
    
  )
)







# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  hide("feature_3_shoe_box")
  hide("feature_3_button_box")
  hide("feature_1_spinner")
  hide("feature_3_spinner")
  
  
  
  
  # Landing Page ------------------------------------------------------------
  
  output$slickr <- renderSlickR({
    #imgs <- list.files("www/", pattern = ".png", full.names = TRUE)
    imgs <- c("shutter1_edit.png", "shutter2_edit.png", "shutter3_edit.png")
    slickR(imgs,
           slideId = 'myslick',
           slideType = "img",
           height = 625) +
      settings(slidesToShow = 1,centerMode = F,autoplay = T,
               autoplaySpeed = 5000, speed = 800, dots = T,
               arrows = F)
  })
  
  # Get started button to Feature 1
  observeEvent(input$get_started_button, {
    updateTabItems(session, "side_bar_menue", "recommendation")
  })
  
  # Link to Feature 1
  observeEvent(input$button_outfit_feat1, {
    updateTabItems(session, "side_bar_menue", "recommendation")
  })
  
  # Link to Feature 2
  observeEvent(input$button_shoe_feat2, {
    updateTabItems(session, "side_bar_menue", "recommendation2")
  })
  
  # Link to Feature 3
  observeEvent(input$button_eval_feat3, {
    updateTabItems(session, "side_bar_menue", "evaluation")
  })
  
  
  # Explanation Text box in sidebar
  # observeEvent(input$tabName, {
  #   if (input$tabName == "recommendation"){
  #
  #   output$expl_text_box <- renderText({
  #     tags$div(
  #       tags$ul(
  #         tags$li("Upload shoe / Choose from gallery"),
  #         tags$li("Select gender"),
  #         tags$li("Select country"),
  #         tags$li("Select desired clothing items (optional)")
  #       )
  #     )
  #   })
  #
  # } else if (input$tabName == "recommendation2"){
  #
  #   output$expl_text_box <- renderText({
  #     tags$div(
  #       tags$ul(
  #         tags$li("Upload outfit"),
  #         tags$li("Select gender"),
  #         tags$li("Select country")
  #       )
  #     )
  #   })
  #
  # } else if (input$tabName == "evaluation"){
  #
  #   output$expl_text_box <- renderText({
  #     tags$div(
  #       tags$ul(
  #         tags$li("Upload outfit"),
  #         tags$li("Upload shoe"),
  #         tags$li("Select gender"),
  #         tags$li("Select country")
  #       )
  #     )
  #   })
  # }})
  
  
  
  
  
  # Feature 1 ---------------------------------------------------------------
  
  
  # When an image in the gallery is clicked, we switch to the Outfit
  # Recommendation tab, where the clicked image is displayed together with the
  # recommended items
  observeEvent(input$last_click, {
    
    hide("recommended_items_class_1")
    hide("recommended_items_class_2")
    hide("recommended_items_class_3")
    hide("recommended_items_class_4")
    hide("recommended_items_class_5")
    
    updateTabItems(session, "side_bar_menue", "recommendation")
    
    # current_img <- readJPEG(paste0("www/", file_path))
    # current_img_tensor <- torch$Tensor(current_img)
    # classifier_pred <- return_shoe_type(model, current_img_tensor)
    # pred_class <- return_shoe_type(model, current_img_tensor)
    
    file_path <- image_click_to_path(input$last_click)
    
    output$selected_shoe <- renderUI({
      tagList(
        h5(id = paste0("selected_image"),
           tags$b("selected shoe:"),
           align = "center"),
        img(id = "recommendation_shoe",
            src = file_path,
            style = image_style_shoe_selected_recommendation_tab)
      )
    })
    
    
  })
  
  
  observeEvent(input$action_button_feature_1, {
    
    toggleElement(
      id = "feature_1_spinner",
      condition = !is.null(isolate(input$action_button_feature_1))
    )
    
    #recommendation_links_and_prices <<- image_click_to_recommendation(input$last_click)[[1]]
    recommendation_links_and_prices <- reactive({
      req(input$last_click,
          input$feature_1_filter_gender,
          input$feature_1_filter_country)
      image_click_to_recommendation(isolate(input$last_click),
                                    country = isolate(input$feature_1_filter_country),
                                    gender = isolate(input$feature_1_filter_gender),
                                    filter_opts = isolate(input$feature_1_filter_items_class))[[1]]
    })
    
    
    # create_image_objects_for_recommedation outputs classes + attributes separately - bring it in front-end
    output$recommended_items_class_1 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[1:3, ] %>%
        create_image_objects_for_recommedation()
    })
    
    output$recommended_items_class_2 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[4:6, ] %>%
        create_image_objects_for_recommedation()
    })
    
    output$recommended_items_class_3 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[7:9, ] %>%
        create_image_objects_for_recommedation()
    })
    
    output$recommended_items_class_4 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[10:12, ] %>%
        create_image_objects_for_recommedation()
    })
    
    output$recommended_items_class_5 <- renderUI({
      isolate(recommendation_links_and_prices()) %>%
        .[13:15, ] %>%
        create_image_objects_for_recommedation()
    })
    
    show("recommended_items_class_1")
    show("recommended_items_class_2")
    show("recommended_items_class_3")
    show("recommended_items_class_4")
    show("recommended_items_class_5")
    
    
  })
  
  
  
  # Exploration -------------------------------------------------------------
  
  
  
  #explorationServer("exploration")
  df <- data.frame(x = c(1,2,3), y = c(3,4,5), z = c(5, 9, 2))
  p <- df %>%
    ggplot(aes(x,y)) +
    geom_point()
  output$test_plot <- renderPlotly(
    p %>%
      ggplotly()
  )
  
  output$test_plot2 <- renderPlotly({
    plot <- plot_ly(df,
                    type = "scatter3d",
                    mode = "markers",
                    x = ~x, y = ~y, z = ~z
                    
    )
  })
  
  
  
  # Feature 2 ---------------------------------------------------------------
  
  
  
  observeEvent(input$feature_2_upload, {
    feature_2_image <<- readJPEG(input$feature_2_upload$datapath)
    
    output$feature_2_image <- renderImage({
      list(
        src = input$feature_2_upload$datapath,
        width = 200,
        height = 250
      )
    }, deleteFile = FALSE)
    
    
    
    reticulate::source_python(here("scripts/fashionpedia_python_script.py"))
    feature_2_attributes <- extract_fashion_attibutes(
      model = "attribute_mask_rcnn",
      image_size=as.integer(640),
      in_app_use=TRUE,
      shoe_image_path=input$feature_2_upload$datapath
    )
    feature_2_attributes_df <<- do.call(rbind, feature_2_attributes) %>%
      extract_attributes_from_fashionpedia_raw()
    feature_2_attributes_df_reac <- reactive({
      feature_2_attributes_df
    })
    pca_estimates <- readRDS(here("data/pca_estimates.rds"))
    pca_results <- pca_estimates %>%
      bake(new_data = feature_2_attributes_df)
    classes_to_be_removed <- setdiff(1:46, database_unique_classes)
    pca_results <- pca_results %>%
      filter(!(classes %in% classes_to_be_removed))
    missing_classes <- setdiff(database_unique_classes, pca_results$classes)
    
    missing_classes_df <- matrix(
      NA,
      nrow = length(missing_classes),
      ncol = ncol(pca_results)
    ) %>%
      data.frame()
    
    colnames(missing_classes_df) <- colnames(pca_results)
    missing_classes_df$classes <- missing_classes
    pca_results <- pca_results %>%
      bind_rows(missing_classes_df)
    
    pca_results <- pca_results %>%
      gather(-image_file, -classes, key = "PC", value = "value") %>%
      unite(col = PC_class, classes, PC) %>%
      spread(key = PC_class, value = value, fill = 0) %>%
      select(-image_file)
    
    colnames(pca_results) <- pca_results %>%
      colnames() %>%
      paste0("class_", .)
    
    
    
    
    feature_2_recommended_shoes <- make_recomm_feature2(rf_final, pca_results)
    
    recommendation_links_and_prices_feature_2 <- reactiveValues(
      recommendation_1 = feature_2_recommended_shoes[1] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape(),
      recommendation_2 = feature_2_recommended_shoes[2] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape(),
      recommendation_3 = feature_2_recommended_shoes[3] %>%
        str_replace_all(" ", "+") %>%
        feature_1_scrape()
    )
    
    output$feature_2_recommended_items_class_1 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_1 %>%
        create_image_objects_for_recommedation(feature = 2)
    })
    
    output$feature_2_recommended_items_class_2 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_2 %>%
        create_image_objects_for_recommedation(feature = 2)
    })
    
    output$feature_2_recommended_items_class_3 <- renderUI({
      recommendation_links_and_prices_feature_2$recommendation_3 %>%
        create_image_objects_for_recommedation(feature = 2)
    })
    
  })
  
  
  
  
  
  # output$feature_2_image <- renderUI({
  #   tagList(
  #     h5(id = paste0("feature_2_upload"),
  #        tags$b("Shoe Upload:"),
  #        align = "center"),
  #     img(id = "feature_2_upload",
  #         src = input$feature_2_upload$datapath,
  #         style = image_style_shoe_selected_recommendation_tab)
  #   )
  # })
  
  
  
  
  # Feature 3 ---------------------------------------------------------------
  
  
  
  
  
  observeEvent(input$feature_3_upload_body, {
    
    output$feature_3_outfit_spinner <- renderUI({
      withSpinner(
        imageOutput(
          "feature_3_image_body",
          height = "300px"
        )
      )
    })
    
    
    
    
    output$feature_3_shoe_box_and_spinner <- renderUI({
      box(
        fileInput(
          "feature_3_upload_shoe",
          NULL,
          buttonLabel = "Upload...",
          multiple = FALSE
        ),
        imageOutput(
          "feature_3_image",
          height = "300px"
        ),
        textOutput("feature_2_shoe_pred"),
        
        textOutput("feature_3_cosine_similarity"),
        
        title = "Upload an image of your shoe",
        width = 12,
        id = "feature_3_shoe_box"
      )
    })
    
    
    
    
    
    # Enable the user to upload an image of a shoe only after a body shot has
    # already been provided
    toggleElement(
      id = "feature_3_shoe_box",
      condition = !is.null(input$feature_3_upload_body)
    )
    
    
    output$feature_3_image_body <- renderImage({
      list(
        src = input$feature_3_upload_body$datapath,
        width = 200,
        height = 250
      )
    }, deleteFile = FALSE)
    
    
  })
  
  observeEvent(input$feature_3_upload_shoe, {
    
    if(is.null(input$feature_3_upload_body)){
      showModal(modalDialog(
        title = "Important message",
        "Provide an image of your outfit before you upload a shoe image"
      ))
    } else {
      
      
      output$feature_3_image <- renderImage({
        list(
          src = input$feature_3_upload_shoe$datapath,
          width = 200,
          height = 250
        )
      }, deleteFile = FALSE)
      
      
      # Information when FP is loading
      lapply(1:nrow(vogue_df), function(i) {
        output[[paste0('pic', i)]] <- renderUI({
          tags$img(src = vogue_df$link_pic[i], width = 110)
        })
      })
      
      observeEvent(input$button_analyze,
                   {
                     showNotification("Yay! We're finished analyzing your outfit.
                                  Get your personalized recommendations now!",
                                      type = "message", duration = 500)
                   }
                   
                   
                   
      )
      
      
    }
    
    
    output$feature_3_button_box_ui <- renderUI({
      box(
        id ="feature_3_button_box",
        actionButton(
          "action_button_feature_3",
          label = "Start"
        ),
        title = "Get Recommendations",
        width = 12
      )
    })
    
    # Enable the user to start the calculations only after a body shot and
    # shoe image have been provided
    toggleElement(
      id = "feature_3_button_box",
      condition = !is.null(input$feature_3_upload_shoe)
    )
    
  })
  
  
  observeEvent(input$action_button_feature_3, {
    
    hide("feature_3_recommended_items_class_1")
    hide("feature_3_recommended_items_class_2")
    hide("feature_3_recommended_items_class_3")
    hide("feature_3_recommended_items_class_4")
    
    # toggleElement(
    #   id = "feature_3_spinner",
    #   condition = !is.null(isolate(input$action_button_feature_3))
    # )
    
    show("feature_3_spinner")
    
    feature_3_image_body <- readJPEG(isolate(input$feature_3_upload_body$datapath))
    feature_3_attributes <- extract_fashion_attibutes(
      model = "attribute_mask_rcnn",
      image_size = as.integer(640),
      in_app_use = TRUE,
      shoe_image_path = isolate(input$feature_3_upload_body$datapath)
    )
    
    feature_3_attributes_df <- do.call(rbind, feature_3_attributes) %>%
      extract_attributes_from_fashionpedia_raw()
    print("Feature 3 Fashionpedia Done")
    
    feature_3_image_shoe <- reactive({
      readJPEG(isolate(input$feature_3_upload_shoe$datapath))
    })
    #torch <- import("torch")
    #feature_3_tensor_shoe <- torch$Tensor(feature_3_image_shoe())
    browser()
    feature_3_shoe_pred <- reactive({
      predict_shoe(feature_3_image_shoe())
    })
    output$feature_2_shoe_pred <- renderText({
      paste0("Predicted Shoe Type: ", feature_3_shoe_pred())
    })
    
    
    
    feature_3_results <- reactive({
      feature_3_coding(
        feature_3_attributes_df,
        feature_3_shoe_pred()
      )
    })
    
    output$feature_3_cosine_similarity <- renderText({
      paste0(
        "Cosine Similarity: ",
        feature_3_results()[[1]] %>%
          scales::percent(0.1)
      )
    })
    
    
    feature_3_diff_query <- feature_3_results() %>%
      extract2(2) %>%
      unite(
        col = "query",
        everything(),
        sep = " "
      ) %>%
      extract2("query")
    
    feature_3_further_queries <- feature_3_results() %>%
      extract2(3) %>%
      select(-Probability) %>%
      unite(
        col = "query",
        everything(),
        sep = " "
      ) %>%
      extract2("query")
    
    feature_3_diff_query_links <- reactive({
      req(
        input$feature_3_upload_shoe,
        input$feature_3_upload_body
      )
      feature_3_diff_query %>%
        cosine_similarity_to_recommendation() %>%
        extract2(1)
    })
    
    feature_3_further_queries_links <- reactive({
      req(
        input$feature_3_upload_shoe,
        input$feature_3_upload_body
      )
      feature_3_further_queries %>%
        cosine_similarity_to_recommendation() %>%
        extract2(1)
    })
    
    
    output$feature_3_recommended_items_class_1 <- renderUI({
      isolate(feature_3_diff_query_links()) %>%
        create_image_objects_for_recommedation(feature = 3)
    })
    
    output$feature_3_recommended_items_class_2 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[1:3, ] %>%
        create_image_objects_for_recommedation(feature = 3)
    })
    
    output$feature_3_recommended_items_class_3 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[4:6, ] %>%
        create_image_objects_for_recommedation(feature = 3)
    })
    
    output$feature_3_recommended_items_class_4 <- renderUI({
      isolate(feature_3_further_queries_links()) %>%
        .[7:9, ] %>%
        create_image_objects_for_recommedation(feature = 3)
    })
    
    show("feature_3_recommended_items_class_1")
    show("feature_3_recommended_items_class_2")
    show("feature_3_recommended_items_class_3")
    show("feature_3_recommended_items_class_4")
  })
  
  
  
  # Back-end for vogue information while FP is running
  lapply(1:nrow(vogue_df), function(i) {
    output[[paste0('pic', i)]] <- renderUI({
      tags$img(src = vogue_df$link_pic[i], width = 110)
    })
  })
  
  
  ## Feature 4 - Server ------------------------------------------------------
  
  
  dataInput_feat4 <- isolate(reactive({
    if (input$choice_cloth == "Entire outfit") {
      df_plot <- pca_result_image
    } else {
      df_plot <- pca_result_classes
    }
    df_plot <- df_plot %>% filter(new_brand %in% input$variable_shoe & new_classes %in% input$choice_cloth)
    df_plot$new_brand <- as.character(df_plot$new_brand)
    return(df_plot)
  }))
  
  
  output$plot_feat4 <- renderPlotly(
    plot_feat4 <- plot_ly(dataInput_feat4(),
                          type = "scatter3d",
                          mode = "markers",
                          x = ~PC01, y = ~PC02, z = ~PC03,
                          color = ~new_brand,
                          colors = c("red", "green", "blue"),
                          size = 0.7,
                          hoverinfo = "text",
                          text = paste(dataInput_feat4()$new_brand),
                          height = 800, width = 1200) %>%
      layout(scene = list(xaxis = list(showticklabels = F, title = "",
                                       showgrid = T, zeroline = F, showspikes = F),
                          yaxis = list(showticklabels = F, title = "",
                                       showgrid = T, zeroline = F, showspikes = F),
                          zaxis = list(showticklabels = F, title = "",
                                       showgrid = T, zeroline = F, showspikes = F)),
             legend = list(x = 0, y = 1,
                           title = list(text = "<b> Shoes selected </b>")))
  )
  
  
}


# Run App -----------------------------------------------------------------


# shinyApp(ui, server)
shinyApp(ui = ui, server = server)
