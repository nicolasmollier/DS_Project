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
    tabItem(tabName = "landing_page",
      mainPanel(tabsetPanel(type="tabs",
        tabPanel("Benefits",

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
      "
                         ))),

                         fluidRow(
                           slickROutput("slickr"),
                           align = "center"
                         ),

                         fluidRow(
                           # reactivecontain necessary to get to feature 1
                           box(width = 12, height = 100, status = "info", align = "center",
                               actionButton("get_started_button", "Get started now >>",
                                            style = "color: #ffffff; background-color: #0093ff; border-color: #2e6da4"))

                         ),

                         fluidRow(
                           box(width = 4, align = "center", status = "primary",
                               div(img(src = "img/Icon_outfit.png", height = "70px", width = "70px"))),
                           box(width = 4, align = "center", status = "primary",
                               div(img(src = "img/Icon_shoe.png", height = "70px", width = "70px"))),
                           box(width = 4, align = "center", status = "primary",
                               div(img(src = "img/Icon_recomm.png", height = "70px", width = "70px")))
                         ),

                         fluidRow(
                           box(width = 4, align = "center", status = "primary",
                               h3("> 6.000 outfits analyzed", style = "color:black")),
                           box(width = 4, align = "center", status = "primary",
                               h3("> 40 shoe brands and types", style = "color:black")),
                           box(width = 4, align = "center", status = "primary",
                               h3("Truly outfit-based recommendations", style = "color:black"))
                         ),

                         fluidRow(
                           box(width = 4, align = "center", status = "primary",
                               h4("To ensure best possible recommendations, we‘ve carefully built a large database of fashionable outfits.
                Based on this rich data set we trained state-of-the-art machine learning models to ensure best possible
                recommendations.")),
                           box(width = 4, align = "center", status = "primary",
                               h4("We know people love shoes. They are an integral part of any outfit. Therefore, we have made sure that our
             data contain the most important shoe brands and types. Due to our unique data set and state-of-the-art
             machine learning models we are able to provide meaningful brand-level shoe recommendations.")),
                           box(width = 4, align = "center", status = "primary",
                               h4("Unlike common techniques, we provide you with recommendations that take the entire outfit into account.
             This ensures that all parts of your style are always aligned and up-to-date.")),
                         ),


                         fluidRow(

                           box(width = 12, height = 80, status = "primary")

                         ),


                         fluidRow(
                           box(width = 12, status = "info",
                               box(width = 4, height = 400, align = "center", status = "info",
                                   img(src = "www/Icon_outfit_recomm.png", height = "85%", width = "85%"),
                                   style = "text-align: center;"
                               ),
                               box(width = 8, height = 400, align = "center", status = "info",
                                   h2("Outfit recommendation", style = "text-align: left; color: black;"),
                                   h4("Our outfit recommendation engine gives you the opportunity to get
             recommendations for various clothing items, ranging from pants and dresses
             to accessories such as glasses and handbags. All items are chosen such that
             they match your preferred brand or type of shoe.", style = "text-align : left;"),
                                   actionLink("button_outfit_feat1", "Get personalized outfit recommendation",
                                              style = "color: #0093ff;"),
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
                           box(width = 12, status = "info",
                               box(width = 8, height = 400, align = "center", status = "info",
                                   h2("Shoe recommendation", style = "text-align: left; color: black;"),
                                   tags$div(tags$h4("In order to find out which shoe fits perfect to your outfit of interest, simply upload
                                            a picture of the outfit. Next, a state-of-the-art algorithm will identify all clothing items and their respective attributes of the
                                            uploaded outfit. Based on this data, we use an advanced and specifically trained
                                              machine learning algorithm to recommend the perfect shoe.", style = "text-align : left;"),
                                            tags$a(href="https://fashionpedia.github.io/home/", "Check out Fashionpedia")),
                                   br(),
                                   actionLink("button_shoe_feat2", "Get personalized shoe recommendation",
                                              style = "color: #0093ff;"),
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
                               box(width = 4, height = 400, align = "center", status = "info",
                                   div(img(src = "Icon_shoe_recomm.png", height = "85%", width = "85%"),
                                       style = "text-align: center;")
                               ), style = "border-bottom: 2px solid;"
                           ),
                           box(width = 12, status = "info",
                               box(width = 4, height = 400, align = "center", status = "info",
                                   div(img(src = "www/Icon_outfit_eval.png", height = "85%", width = "85%"),
                                       style = "text-align: center;")
                               ),
                               box(width = 8, height = 400, align = "center", status = "info",
                                   h2("Outfit evaluation", style = "text-align: left; color: black;"),
                                   h4("Our outfit evaluation engine gives you the opportunity to get a
                                      measure of how well-suited your overall outfit is.
                                      The service provides you with the clothing item which is most different to our representative data base
                                      and with further clothing attributes to complement your outfit.", style = "text-align : left;"),
                                   actionLink("button_eval_feat3", "Get outfit evaluation",
                                              style = "color: #0093ff;"),
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
                tabPanel("Methodology",

                         tags$head(tags$style(HTML("
                              .box.box-solid.box-primary.box-header{
                              background-color:#888888;
                              }
                              .box.box-solid.box-primary{
                              border:none;
                              }
                              .box.box-solid.box-warning.box-header{
                              background-color:#9c9c9c
                              }
                              "
                         ))),

                         fluidRow(

                           box(
                             title = "1.) Build database", status = "primary", solidHeader = TRUE,
                             collapsible = TRUE, collapsed = FALSE,
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Scrape images from Google", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("We used Google images and automatically scraped query results with respect to 43 different shoe types.
                                    We wanted to make sure that we do not only scrape the shoe itself but to get an entire body shot with the clothings worn.
                                    Therefore, the queries were selected to optimize the results. All in all, we scraped more than 17,000 images to obtain
                                    a representative data base.")
                             ),
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Deep Learning algorithm Fashionpedia", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("We adjusted the algorithm of Fashionpedia to make it usable in our case.
                                    Applying this algorithm to the scraped images, we received information about what different clothing items
                                    the person is wearing (out of 46 different clothing classes) and the probability of each clothing item that it has
                                    a certain attribute. The algorithm is capable of detecting 294 different attributes (e.g. cargo, plain, etc.).")
                             ),
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Final data base", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("In order to make the data base usable, a lot of data cleaning was necessary.
                                    Most importantly, we dropped all image observations
                                    containing lass than 4 classes with a threshold of 80%. In this way, we made sure
                                    that no 'angle-shots' are contained in the database and only full-body shots are
                                    taken into account. We conducted PCA analyses to tackle the dimensionality issue such that
                                    each image was finally represented by a 330-dimensional vector."),

                             ),
                             box(status = "primary", width = 12, height = 20),

                           ),
                           box(
                             title = "2.) Modelling and EDA", status = "primary", solidHeader = TRUE,
                             collapsible = TRUE, collapsed = FALSE,
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Convolutional Neural Network (CNN)", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("In order to classify the brand and the type of a shoe, respectively,
                                    we built a CNN shoe classifier. We used a pre-trained ResNet-152 model
                                    and fine-tuned it to classify the 43 different shoe types we scraped from
                                    Google. With the state-of-the-art classifier, we achieved an average
                                    accuracy of 95% on the test images.")
                             ),
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Random Forest", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("In order to obtain suitable shoe recommendations based on the uploaded
                                    body shot, we trained a random forest algorithm to cluster the detected
                                    classes and the probabilities for certain attributes to similar outfits of our data base.
                                    We then select the 3 most probable shoe types and brands with respect to the most similar
                                    outfits.")
                             ),
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "EDA", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("The application complements with the possibility for the user to get to know the
                                    data base better. In a 3D-simulation, the user can detect differences for the different
                                    shoe types with respect to different clothing types.")
                             ),
                             box(status = "primary", width = 12, height = 20),
                           )
                         ),

                         box(status = "primary", width = 12, height = 50),

                         fluidRow(

                           box(
                             title = "3.) Design & implement recommendation engines ", status = "primary", solidHeader = TRUE,
                             collapsible = TRUE, collapsed = FALSE,
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Outfit recommendation", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("After the user has uploaded a shoe and chose a shoe from the displayed gallery,
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
                             box(width = 12,
                                 title = "Shoe recommendation", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("After the user has uploaded the body shot, the Fashionpedia algorithm runs over it to
                                    detect the classes and corresponding attributes. With the random forest algorithm, we find
                                    the three most similar outfit combinations in the data base and retrieve the corresponding shoe types.
                                    Those shoe types are than sent via a query to Asos as well in order to get the 3 first hits on the
                                    webpage which are once again embedded in the output window.")
                             ),
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Outfit evaluation", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("After the body shot and the shoe image are uploaded, Fashionpedia and the shoe classifier
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
                             title = "4.) Design & implement application", status = "primary", solidHeader = TRUE,
                             collapsible = TRUE, collapsed = FALSE,
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Recommended fashion items", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("We chose a grid representation with the price attribute for the different fashion items.
                                    The setting is selected to be very similar to an online shopping experience.
                                    Furthermore, the user can click on the respective image to obtain immediately access to the online shop.")
                             ),
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "User experience", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("The application is built up in a way, that it is very intuitive and understandable which
                                    inputs have to be made. Moreover, links in the app refer to the different features to facilitate the
                                    application handling. Through the automated queries to Asos, the application renews the recommendations
                                    each day through adjustments of Asos when new items are uploaded.")
                             ),
                             box(status = "primary", width = 12, height = 20),
                             box(width = 12,
                                 title = "Cloud hosting", status = "warning", solidHeader = TRUE,
                                 collapsible = TRUE, collapsed = TRUE,
                                 h1("In order to make the application accessible for all users and increase traffic, we hosted the website on
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
                tabPanel("About",

                         fluidRow(
                           box(width = 12, height = 100, status = "info",
                               h1("The Project", align = "center"))
                         ),

                         fluidRow(
                           box(width = 12, status = "info",
                               box(width = 4, height = 400, align = "center", status = "info",
                              img(src = "https://uni-tuebingen.de/fileadmin/_processed_/9/7/csm_DS_mit_Hintergrund_4bd4e57cd6.png",
                                                            height = "75%", width = "75%"),
                                   style = "text-align: center;"
                               ),
                            box(width = 8, height = 400, align = "center", status = "info",
                                   h2("This web app was created as part of a seminar of the program", tags$br(), "
                          'Data Science in Business & Economics' at the University of Tübingen",
                                      style = "text-align: left; color: black;"),
                                   h4("The basic idea of this module is that students independently and in groups design
                       and program the entire process of a data science project. A particular focus is
                       automation, i.e. acquisition of data, structuring, importing, validating,
                       modifying, and evaluating data occurs without the supervision of an analyst or user of the analysis.",
                                      style = "text-align : left;"),
                                   tags$a(href = "https://uni-tuebingen.de/de/144465", "View program...",
                                          style = "color:  #0093ff"),
                                   style = "font-size: 15px; text-align: left;"),
                            style = "border-bottom: 2px solid; border-top: 2px solid;")
                         ),

                         fluidRow(
                           box(width = 12, height = 70, status = "primary"),
                           box(width = 12, height = 100, status = "info",
                               h1("Meet The Team", align = "center")
                           ),
                           box(width = 12, status = "info",
                               box(width = 4, height = 250, align = "center", status = "info",
                                   div(img(src = "max.jpg", height = "85%", width = "85%"),
                                       style = "text-align: center;")
                               ),
                               box(width = 4, height = 250, align = "center", status = "info",
                                   div(img(src = "Nicolas.png", height = "85%", width = "85%"),
                                       style = "text-align: center;")
                               ),
                               box(width = 4, height = 250, align = "center", status = "info",
                                   div(img(src = "Cornelius.jpeg", height = "85%", width = "85%"),
                                       style = "text-align: center;")
                               ), style = "border-top: 2px solid;"

                           )
                         ),

                         fluidRow(
                           box(width = 4, align = "center", status = "primary",
                               h3("Max Kneißler"),
                               h6("M.Sc. Data Science in Business & Economics (3rd semester)"),
                               h6("Working student at Porsche AG"),
                               tags$a(href = "https://www.linkedin.com/in/max-knei%C3%9Fler-235499171/", "View LinkedIn profile...",
                                      style = "color:  #0093ff"),
                               style = "text-align: center;"
                           ),
                           box(width = 4, align = "center", status = "primary",
                               h3("Nicolas Mollier"),
                               h6("M.Sc. Data Science in Business & Economics (3rd semester)"),
                               h6("Working student at eoda GmbH"),
                               tags$a(href = "https://www.linkedin.com/in/nicolas-mollier-84a20b198/", "View LinkedIn profile...",
                                      style = "color:  #0093ff"),
                               style = "text-align: center;"
                           ),
                           box(width = 4, align = "center", status = "primary",
                               h3("Cornelius Widmaier"),
                               h6("M.Sc. Data Science in Business & Economics (3rd semester)"),
                               h6("Working student at Layer7 AI GmbH"),
                               h6("RA at Yale SOM"),
                               tags$a(href = "https://www.linkedin.com/in/cornelius-w-8720041a4/", "View LinkedIn profile...",
                                      style = "color:  #0093ff"),
                               style = "text-align: center;"
                           ), style = "border-bottom: 2px solid;"
                         )

                )
              ))),


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
          #     br(), br(), br(),
          #     conditionalPanel(
          #       "!is.null(output.recommended_items_class_2)",
          #       selectizeInput(
          #         "feature_2_filter_gender",
          #         label = "Change your gender",
          #         choices = c("Men", "Women", "Diverse"),
          #         selected = "Men",
          #         width = "230px"
          #       )
          #     ),
          #     br(),
          #     conditionalPanel(
          #       "input.side_bar_menue == 'recommendation2'",
          #       selectizeInput(
          #         "feature_2_filter_country",
          #         label = "Change country of origin",
          #         choices = c("de", "es", "fr", "gb", "it", "us"),
          #         selected = "us",
          #         width = "230px"
          #   )
          # )
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


    #   tabItem(
    #     tabName = "evaluation",
    #     column(
    #       2,
    #       br(), br(),
    #       conditionalPanel(
    #         "input.side_bar_menue == 'evaluation'",
    #         fluidRow(
    #           useShinyjs(), # Set up shinyjs
    #           
    #           box(
    #             id = "feature_3_outfit_box",
    #             fileInput(
    #               "feature_3_upload_body",
    #               NULL,
    #               buttonLabel = "Upload...",
    #               multiple = FALSE
    #             ),
    #             uiOutput("feature_3_outfit_spinner"),
    #             title = "Upload an image of your outfit",
    #             width = 12
    #           ),
    #           uiOutput("feature_3_shoe_box_and_spinner"),
    #           br(), br(),
    #           # Added for Info when waiting for FP
    #           selectizeInput(
    #             "feature_3_filter_gender",
    #             label = "Change your gender",
    #             choices = c("Men", "Women", "Diverse"),
    #             selected = "Men",
    #             width = "230px"
    #           ),
    #           uiOutput("feature_3_button_box_ui")
    #         )
    #       )
    #     ),
    #     column(
    #       2,
    #       withSpinner(uiOutput("feature_3_recommended_items_class_1"), size = 0)
    #     ),
    #     column(
    #       2,
    #       withSpinner(
    #         uiOutput("feature_3_recommended_items_class_2"),
    #         id = "feature_3_spinner",
    #         color = "#4F4F4F"
    #       )
    #     ),
    #     column(
    #       2,
    #       withSpinner(uiOutput("feature_3_recommended_items_class_3"), size = 0)
    #     ),
    #     column(
    #       2,
    #       withSpinner(uiOutput("feature_3_recommended_items_class_4"), size = 0)
    #     ),
    #     
    #     # Java code for set-up of vogue information
    #     tags$style(HTML("
    #           .col-sm-8{
    #           padding-left: 0px;
    #           }
    #           .box.box-primary>.box-header {
    #           display: none
    #           }
    #           .box.box-primary{
    #           border-top: 0px;
    #           margin-bottom: 0px;
    #           -webkit-box-shadow: none;
    #           -moz-box-shadow: none;
    #           box-shadow: none;
    #           }
    #           .modal-header{
    #           border-bottom: 3px solid;
    #           }
    #           .modal-dialog{
    #           width: 500px;
    #           overflow-y: auto;
    #           }
    #           .modal-title{
    #           font-size: 23px;
    #           font-weight: bold;
    #           }
    #           .shiny-notification{
    #           color:#ffffff;
    #           background-color: #40c300;
    #           border: #2a7b02;
    #           }
    #           .container-fluid{
    #           max-height: calc(80vh - 210px);
    #           overflow-y: auto;
    #           padding-right: 40px;
    #           padding-left: 40px;
    #           }")),
    #     
    #     
    #     # Vogue information - to figure out if a page needs to be added
    #     # To be implemented for feature 2 as well!
    #     
    #     # Has to be displayed when the action button was clicked
    #     bsModal(id = "pop", title = "While we're analyzing your outfit, why don't you 
    #       check out the latest fashion trends...?",
    #             trigger = "feature_3_button_box_ui",
    #             
    #             fluidPage(
    #               
    #               fluidRow(
    #                 
    #                 lapply(1:nrow(vogue_df), function(i) {
    #                   
    #                   fluidRow(
    #                     
    #                     box(
    #                       status = "primary", width = 8, title = NULL, headerBorder = NULL,
    #                       tags$div(
    #                         tags$a(href=vogue_df$link[i], 
    #                                vogue_df$header[i], style = "color: #000000")
    #                       ), style = "font-size: 18px; text-align: left;"),
    #                     box(
    #                       status = "primary", width = 4,
    #                       div(uiOutput(paste0('pic', i)), style = "text-align: right"),
    #                     ), style = "border-bottom: 1px solid"
    #                   )
    #                 }), theme = "bootstrap.css"
    #                 )
    #               )
    #             )
    #         
    #   ),
    
    
    

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
