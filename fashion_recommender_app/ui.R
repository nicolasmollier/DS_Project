# Define the UI of the application

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
      # Different menu items in the sidebar
      menuItem("Home", tabName = "landing_page", icon = icon("globe")),
      #menuItem("Shoe Gallery", tabName = "image_selection", icon = icon("camera")),
      menuItem("Outfit Recommendation", tabName = "recommendation", icon = icon("user-tie")),
      menuItem("Shoe Recommendation", tabName = "recommendation2", icon = icon("shoe-prints")),
      menuItem("Outfit Evaluation", tabName = "evaluation", icon = icon("chart-pie")),
      menuItem("Data Exploration", tabName = "data_exploration", icon = icon("binoculars")),
      br(), br(), br(), br(), br(), br(), br(), br(),
      # How to use this feature
      conditionalPanel(
        'input.side_bar_menue == "recommendation"',
        box(tags$div(
          style = "color: black;font-size:13px;",
          tags$ul(
            tags$li("Upload / select shoe"),
            tags$li("Select gender"),
            tags$li("Select country"),
            tags$li("Filter desired fashion item (optional)")
          )), 
          collapsible = TRUE, collapsed = TRUE, width = 12, title = span("How to use this Feature", style = "font-size: 14px;")
          
        )
      ),
      conditionalPanel(
        'input.side_bar_menue == "recommendation2"',
        box(tags$div(
          style = "color: black;font-size:13px;",
          tags$ul(
            tags$li("Upload outfit"),
            tags$li("Select gender"),
            tags$li("Select country")
          )), 
          collapsible = TRUE, collapsed = TRUE, width = 12, title = span("How to use this Feature", style = "font-size: 14px;")
          
        )
      ),
      conditionalPanel(
        'input.side_bar_menue == "evaluation"',
        box(tags$div(
          style = "color: black;font-size:13px;",
            tags$ul(
              tags$li("Upload outfit"),
              tags$li("Upload shoe"),
              tags$li("Select gender"),
              tags$li("Select country")
            )),
          collapsible = TRUE, collapsed = TRUE, width = 12, title = span("How to use this Feature", style = "font-size: 14px;")
          
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
        br(), 
        mainPanel(width = 12, tabsetPanel(
          type = "tabs",
          tabPanel(
            "Getting started",
            
            # HTML formatting
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
      a {
        color: #4F4F4F;
      }
      element {
        width: 100%;
        height: 250px;
        visibility: visible;
      }
      "))),
            fluidRow(
              slickROutput("slickr", width = '98.1%'),
              align = "center"
            ),
            fluidRow(
              box(
                width = 12, height = 100, status = "info", align = "center",
                actionButton("get_started_button", "Get started now >>",
                             style = "color: #ffffff; background-color: #0093ff; border-color: #2e6da4"
                )
              )
            ),
            fluidRow(style = "padding: 15px;",
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
                h3("> 6,000 outfits analyzed", style = "color:black")
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
                style = "padding-left: 15px; padding-right: 15px;",
                h4("To ensure best possible recommendations, we‘ve carefully built a large database of fashionable 
                outfits.Based on this rich data set we trained state-of-the-art machine learning models and 
                recommendation engines to ensure best possible results.")
              ),
              box(
                width = 4, align = "center", status = "primary",
                style = "padding-left: 15px; padding-right: 15px;",
                h4("We know people love shoes. They are an integral part of any outfit. Therefore, we have made 
                sure that our data contain the most important shoe brands and types. Due to our unique data set 
                and state-of-the-art machine learning models we are able to provide meaningful brand-level 
                shoe recommendations.")
              ),
              box(
                width = 4, align = "center", status = "primary",
                style = "padding-left: 15px; padding-right: 15px;",
                h4("Unlike common techniques, we provide you with recommendations that take the entire outfit 
                into account. This ensures that all parts of your style are always aligned and up-to-date.")
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
                  ), br(), br(),
                  h3("Here's how it works:", style = "text-align: left;"),
                  tags$div(
                    tags$ul(
                      tags$li("Either upload a picture of a shoe or select one from the gallery"),
                      tags$li("Select yout gender"),
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
                    a picture of the outfit. Next, a state-of-the-art algorithm will identify all clothing items 
                    and their respective attributes of the uploaded outfit. Based on this data, we use an 
                    advanced and specifically trained machine learning algorithm to recommend the perfect shoe.", 
                            style = "text-align : left;"),
                    tags$a(href = "https://fashionpedia.github.io/home/", "Check out Fashionpedia")
                  ),
                  br(),
                  actionLink("button_shoe_feat2", "Get personalized shoe recommendation",
                             style = "color: #0093ff;"
                  ), br(), br(),
                  h3("Here's how it works:", stye = "text-align: left;"),
                  tags$div(
                    tags$ul(
                      tags$li("Upload a picture of the outfit you want to get shoe recommendations for"),
                      tags$li("Select yout gender"),
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
                      measure of how well your overall outfit compares to the stylish 
                      outfits in our database.
                      The service provides you with the clothing item that is most different to our 
                      representative data. It also points you to further clothing attributes that could 
                     complement your outfit.", style = "text-align : left;"),
                  actionLink("button_eval_feat3", "Get outfit evaluation",
                             style = "color: #0093ff;"
                  ), br(), br(),
                  h3("Here's how it works:", style = "text-align: left;"),
                  tags$div(
                    tags$ul(
                      tags$li("Upload a picture of your outfit"),
                      tags$li("Upload a picture of your shoe"),
                      tags$li("Select your gender"),
                      tags$li("Choose your country of origin"),
                      tags$li("Get your personalized recommendation on how to fit your clothing better to your shoe"),
                      tags$li("You will also receive a score that indicates how well your outfit fits the shoe"),
                      tags$li("Get further fashion items to complement your outift")
                    )
                  ), style = "font-size: 15px; text-align: left;"
                ), style = "border-bottom: 2px solid;"
              )
            ), br(), br(),
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
                                padding: 0px;
                              }
                              .h5, h5 {
                                font-size: 16px;
                              }
                              "))),
            fluidRow(
              br(),
              box(style = "padding-right: 20px; padding-left: 20px;",
                title = h3("1.) Build database"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12, style = "padding-right: 20px; padding-left: 20px;",
                  title = "Scrape images from Google", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("(Automatically) scraped images of stylish outfits from Google"),
                      tags$li("Outfits for 42 different shoe types / brands were considered"),
                      tags$li("All in all, more than 17,000 images were scraped to obtain a representative database"),
                      tags$li("We made sure to only include body shots (images that contain entire outfits) in the database and disregarded 'ankle shots'"))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Analyze outfits using deep learning algorithm 'Fashionpedia'", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("We needed to adjust Fashionpedia Deep Learning model to extract clothing items and attributes for thousands of images"),
                      tags$li("Fashionpedia model returns information about clothing items (out of 46 different clothing classes) and the corresponding 
                              probabilities for different attributes of the clothing class (out of 294 different attributes, e.g. cargo, plain, etc.)"),
                      tags$li("Since it is a Masked-RCNN model it can also locate clothing items in the image, but we could neglect this information 
                              for further processing steps"))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Build final database", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("Restructuring of data returned by Fashionpedia was necessary
                              to convert data into clean and machine-readable format"),
                      tags$li("Images in which less than 4 classes could be detected (threshold of 80%) were 
                              dropped to omit all 'ankle-shots' that were returned by Google search results"),
                      tags$li("PCA analysis was conducted to tackle the large dimensions of Fashionpedia output such 
                              that each image could finally be represented by a 330-dimensional vector
                              (rather than 13,524 dimensional vector (13,524 = 46 (classes) * 294 (attributes) )"))))
                ),
                box(status = "primary", width = 12, height = 20),
              ),
              box(style = "padding-right: 20px; padding-left: 20px;",
                title = h3("2.) Modelling and explorative data analysis (EDA)"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Convolutional Neural Network (CNN)", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("CNN classifier was built to detect the shoe brand / type of uploaded 
                              images to enhance user experience"),
                      tags$li("Pre-trained ResNet-152 model was used and fine-tuned 
                              to classify the all different shoe types in the database"),
                      tags$li("With this state-of-the-art classifier, an average 
                              accuracy of roughly 95% is achieved on validation images"))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Random Forest", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("Random forest algorithm was trained in order to 
                              obtain suitable shoe recommendations based on the 
                              outfit (body shot) uploaded by user"),
                      tags$li("The algorithm clusters similar outfits"),
                      tags$li("Finally, the 3 most probable shoe types / brands 
                              are recommended with respect to the most similar outfits"))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "EDA", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("Data exploration allows the user to get to know the 
                              database and find differences between outfits worn for different shoe types"),
                      tags$li("3D-visualization can be used to detect differences between 
                              outfits that are worn for different shoe types"))))
                ),
                box(status = "primary", width = 12, height = 20),
              )
            ),
            
            fluidRow(
              box(style = "padding-right: 20px; padding-left: 20px;",
                title = h3("3.) Design & implement recommendation engines"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Outfit recommendation", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("Shoe on which recommendations are based can either be
                              selected from gallery or uploaded"),
                      tags$li("Optional possibility to select specific clothing items for which 
                              recommendations should be obtained"),
                      tags$li("Database is filtered with respect to the shoe brand / type to search for the most-frequently worn 
                              clothing items and the corresponding highest attribute probability"),
                      tags$li("5 most-plausible class-attribute-combinations are sent to online shopping website Asos"),
                      tags$li("Automatically, the first 3 hits of each combination with the respective image 
                      and price are scraped and embedded in the output window of the application (data is not stored locally), "))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Shoe recommendation", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("Fashionpedia analyzes the uploaded body shot image to 
                              extract clothing classes and respective likelihood for specific attributes"),
                      tags$li("The random forest algorithm finds the most similar outfits 
                              in the database and retreives the three most freuqently occurring
                              shoe types in the respective terminal node"),
                      tags$li("Shoe brands / types are sent to Asos to obtain 
                              the first 3 hits which are embedded in the output window"))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Outfit evaluation", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("Fashionpedia and CNN algorithm analyze uploaded body shot and shoe, respectively, 
                              to detect clothing items and attributes as well as the shoe type / brand"),
                      tags$li("Database is filtered with respect to the shoe type and the classes 
                              found in the uploaded image"),
                      tags$li("With respect to each class, the cosine similarity between the upload 
                              and the aggregated and filtered database is computed and averaged
                              over all classes to obtain a score of how well the outfit fits"),
                      tags$li("For the lowest cosine score, a better attribute for the 
                              respective class is recommended"),
                      tags$li("Additionally, 3 class-attribute-combinations that are not detected 
                              in the upload but occur in the database are recommended to complement the outfit with 
                              current trends"))))
                ),
                box(status = "primary", width = 12, height = 20),
              ),
              box(style = "padding-right: 20px; padding-left: 20px;",
                title = h3("4.) Design & implement application"),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Recommended fashion items", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("We chose a grid representation of clothing images 
                              with the corresponding price attribute for the output window"),
                      tags$li("The setting is selected to remind the user of an online shopping experience"),
                      tags$li("By clicking on the respective image, the user immediately accesses the online shop with the respective query"))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "User experience", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("The application is built in a way to make it intuitive 
                              and understandable where inputs are necessary"),
                      tags$li("Links in the application can be used to access different 
                              features to make navigating the app easier"),
                      tags$li("The application automatically renews the displayed 
                              recommendations whenever Asos re-ranks their search results"))))
                ),
                box(status = "primary", width = 12, height = 20),
                box(
                  width = 12,
                  title = "Cloud hosting", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE, collapsed = TRUE,
                  h5(tags$div(
                    tags$ul(
                      tags$li("The application is hosted on bwCloud to make it accessible 
                              to users all over the world and increase website traffic"),
                      tags$li("Performance, expecially when applying the fashionpedia model 
                              is limited due to the CPU-only restriction"),
                      tags$li("The storage space is very limited as well (12 GB) 
                              such that other solutions will be considered in upcoming updates"))))
                ),
                box(status = "primary", width = 12, height = 20),
              )
            )
          ),
          
          tabPanel(
            "About",
            tags$head(
              tags$style(
                HTML(
                  ".col-sm-12, .col-sm-4 {
                  position: relative;
                  min-height: 1px;
                  padding-right: 0px;
                  padding-left: 0px;
                }"
                )
              )
            ),
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
                    height = "70%", width = "70%"
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
                style = "border-bottom: 2px solid; border-top: 2px solid; padding: 0px;"
              )
            ),
            fluidRow(
              br(), br(),
              box(
                width = 12, height = 100, status = "info",
                h1("Meet the Team", align = "center")
              ),
              box(
                width = 12, status = "info",
                box(
                  width = 4, height = 250, align = "center", status = "info",
                  div(img(src = "max.jpg", height = "30%", width = "30%"),
                      style = "text-align: center;"
                  )
                ),
                box(
                  width = 4, height = 250, align = "center", status = "info",
                  div(img(src = "nicolas.jpg", height = "32%", width = "32%"),
                      style = "text-align: center;"
                  )
                ),
                box(
                  width = 4, height = 250, align = "center", status = "info",
                  div(img(src = "cornelius.jpg", height = "30%", width = "30%"),
                      style = "text-align: center;"
                  )
                ), style = "border-top: 2px solid;"
              )
            ),
            fluidRow(
              box(
                width = 4, align = "center", status = "primary",
                h3("Max Kneißler"),
                h5("M.Sc. Data Science in Business & Economics (3rd semester)"),
                h5("Working student at Porsche AG"),
                tags$a(
                  href = "https://www.linkedin.com/in/max-knei%C3%9Fler-235499171/", "View LinkedIn profile...",
                  style = "color:  #0093ff"
                ),
                style = "text-align: center;"
              ),
              box(
                width = 4, align = "center", status = "primary",
                h3("Nicolas Mollier"),
                h5("M.Sc. Data Science in Business & Economics (3rd semester)"),
                h5("Working student at eoda GmbH"),
                tags$a(
                  href = "https://www.linkedin.com/in/nicolas-mollier-84a20b198/", "View LinkedIn profile...",
                  style = "color:  #0093ff"
                ),
                style = "text-align: center;"
              ),
              box(
                width = 4, align = "center", status = "primary",
                h3("Cornelius Widmaier"),
                h5("M.Sc. Data Science in Business & Economics (3rd semester)"),
                h5("Working student at Layer7 AI GmbH"),
                h5("RA at Yale SOM"),
                tags$a(
                  href = "https://www.linkedin.com/in/cornelius-w-8720041a4/", "View LinkedIn profile...",
                  style = "color:  #0093ff"
                ),
                h5(""),
                style = "text-align: center;"
              ),
              style = "border-bottom: 2px solid;"
            )
          )
        ), br(), br()
        )
      ),
      
      
      ## Feature 1 - UI ----------------------------------------------------------
      
      
      # Feature 1: Recommendation 
      tabItem(
        tabName = "recommendation",
        tabsetPanel(
          id = "feature_1_tabs",
          type = "tabs",
          tabPanel(
            "Shoe Gallery",
            tags$head(
              tags$style(
                HTML(
                ".col-lg-1, .col-lg-10, .col-lg-11, .col-lg-12, .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-5, .col-lg-6, .col-lg-7, .col-lg-8, .col-lg-9, .col-md-1, .col-md-10, .col-md-11, .col-md-12, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-7, .col-md-8, .col-md-9, .col-sm-1, .col-sm-10, .col-sm-11, .col-sm-2, .col-sm-3, .col-sm-5, .col-sm-6, .col-sm-7, .col-sm-8, .col-sm-9, .col-xs-1, .col-xs-10, .col-xs-11, .col-xs-12, .col-xs-2, .col-xs-3, .col-xs-4, .col-xs-5, .col-xs-6, .col-xs-7, .col-xs-8, .col-xs-9 {
                  position: relative;
                  min-height: 1px;
                  padding-right: 15px;
                  padding-left: 0px;
                }"
                )
              )
            ),
            br(), 
            # box(
            #   title = "Upload shoe image here or select from the gallery below",
            #   collapsible = TRUE,
            #   collapsed = TRUE,
            #   width = 11,
            #   fileInput(
            #     "feature_1_upload_shoe",
            #     NULL,
            #     buttonLabel = "Upload...",
            #     multiple = FALSE
            #   ),
            #   textOutput("feature_1_shoe_pred"),
            #   actionButton("action_button_feature_1_upload", "Show recommendations"),
            #   style = "padding-left: 0px;"
            # ),
            fluidRow(
              useShinyjs(),
              tags$head(tags$script(HTML(js))),
              HTML(img_html),
              style = "margin-right: -10px;margin-left: -0px;"
            ),

            mainPanel(
              div(id = "image-container", style = "display:flexbox;")
            )
          ),
          tabPanel(
            "Shoe Recommendation",
            conditionalPanel(
              "input.side_bar_menue == 'recommendation'",
              column(
                2,
                fluidRow(
                  withSpinner(uiOutput("selected_shoe"), size = 0),
                  style = "margin-top: -5px;"
                ),
                textOutput("feature_1_selected_shoe"),
                br(), br(),
                conditionalPanel(
                  "!is.null(output.recommended_items_class_2)",
                  selectizeInput(
                    "feature_1_filter_gender",
                    label = "Select gender",
                    choices = c("Men", "Women", "Diverse"),
                    selected = "Men",
                    width = "230px"
                  )
                ),
                conditionalPanel(
                  "input.side_bar_menue == 'recommendation'",
                  selectizeInput(
                    "feature_1_filter_country",
                    label = "Select country of origin",
                    choices = c("de", "es", "fr", "gb", "it", "us"),
                    selected = "us",
                    width = "230px"
                  )
                ),
                conditionalPanel(
                  "input.side_bar_menue == 'recommendation'",
                  selectizeInput(
                    "feature_1_filter_items_class",
                    label = "Particular items to include",
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
                br(), 
                box(
                  id = "feature_1_button_box",
                  actionButton(
                    inputId = "action_button_feature_1",
                    label = "Start Calculations"
                  ),
                  title = "Get Recommendations",
                  width = 12
                )
              ),
              column(
                2,
                align = "center",
                withSpinner(
                  uiOutput("recommended_items_class_1"),
                  size = 0
                )
              ),
              column(
                2,
                align = "center",
                withSpinner(
                  uiOutput("recommended_items_class_2"),
                  id = "feature_1_spinner",
                  color = "#4F4F4F"
                )
              ),
              column(
                2,
                align = "center",
                withSpinner(
                  uiOutput("recommended_items_class_3"),
                  size = 0
                )
              ),
              column(
                2,
                align = "center",
                withSpinner(
                  uiOutput("recommended_items_class_4"),
                  size = 0
                )
              ),
              column(
                2,
                align = "center",
                withSpinner(
                  uiOutput("recommended_items_class_5"),
                  size = 0
                )
              )
            )
          )
        )
      ),
      
      
      
      ## Feature 2 - UI ----------------------------------------------------------
      
      
      tabItem(
        tabName = "recommendation2",
        column(
          2,
          align = "left",
          br(), br(),
          conditionalPanel(
            "input.side_bar_menue == 'recommendation2'",
            fluidRow(
              useShinyjs(), # Set up shinyjs
              
              box(
                id = "feature_2_outfit_box",
                fileInput("feature_2_upload", NULL, buttonLabel = "Upload...", 
                          multiple = TRUE),
                imageOutput("feature_2_image", height = "320px"),
                title = "Upload an Outfit",
                width = 12
              ),
              uiOutput("feature_2_select_box"),
              uiOutput("feature_2_button_box_ui")
            )
          )
        ),
        
        column(
          2,
          align = "center",
          withSpinner(
            uiOutput("feature_2_recommended_items_class_1"),
            size = 0
          )
        ),
        column(
          2,
          align = "center",
          withSpinner(
            uiOutput("feature_2_recommended_items_class_2"),
            id = "feature_2_spinner",
            color = "#4F4F4F"
          )
        ),
        column(
          2,
          align = "center",
          withSpinner(
            uiOutput("feature_2_recommended_items_class_3"),
            size = 0
          )
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
                title = "Upload an Outfit",
                width = 12
              ),
              
              uiOutput("feature_3_shoe"),
              uiOutput("feature_3_shoe_box_and_spinner"),
              uiOutput("feature_3_select_box"),
              
              
              uiOutput("feature_3_button_box_ui")
            )
          )
        ),
        column(
          2,
          align = "center",
          #h4("Adjust the following item"),
          uiOutput("feature_3_adjust"),
          withSpinner(uiOutput("feature_3_recommended_items_class_1"), size = 0)
        ),
        column(2),
        column(
          2,
          align = "center",
          uiOutput("feature_3_additional"),
          withSpinner(
            uiOutput("feature_3_recommended_items_class_2"),
            id = "feature_3_spinner",
            color = "#4F4F4F"
          )
        ),
        column(
          2,
          align = "center",
          h4("x", style = "color:white;"),
          withSpinner(uiOutput("feature_3_recommended_items_class_3"), size = 0)
        ),
        column(
          2,
          align = "center",
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
        
      ),
      
    
      
      ## Feature 4 - UI ----------------------------------------------------------
      
      tabItem(
        tabName = "data_exploration",
        tabsetPanel(
          type = "tabs",
          tabPanel(
            "Outfit clusters",

        # Application title
        titlePanel(h3("Differences in clothing attributes for different shoe types",
                   align = "center")),
          
          # inputs
          sidebarPanel(
            # select type of clothing that should be shown
            box(selectizeInput(inputId = "choice_cloth", 
                        label = "Which type of apparel item are you interested in?", 
                        choices = c("Entire outfit", "bag / wallet", "cardigan", "coat", "dress", 
                                    "glasses", "hat", "jacket", "jumpsuit", "pants",
                                    "scarf", "shirt / blouse", "shorts", "skirt", "sweater",
                                    "top / t-shirt / sweatshirt", "watch"),
                        selected = "Entire outfit"), width = 12),
            
            # select type of shoe to be shown
            box(selectizeInput("variable_shoe", "Select type / brand:",
                           choices = c(sort(as.character(unique(umap_result_classes$new_brand)))),
                           selected = sort(as.character(unique(umap_result_classes$new_brand)))[1],
                           multiple = T,
                           options = list(maxItems = 3, placeholder = 'type here...')), width = 12),
            width = 2),
          
          # Output: show 3D plot
          mainPanel(
            plotlyOutput(outputId = "plot_feat4", width = "100%", height = "100%"),
            width = 8)
      ),
      tabPanel(
        "Clothing items across shoe brands / types",
        
        tags$style(HTML(".well {
          min-height: 20px;
          padding: 19px;
          margin-bottom: 20px;
          background-color: white;
            border: 1px solid white;
          border-radius: 4px;
          -webkit-box-shadow: inset 0 1px 1px rgb(0 0 0 / 5%);
          box-shadow: inset 0 0 0 rgb(0 0 0 / 5%);
        }")),
        
        sidebarPanel(
          br(), br(),
          box(
            selectizeInput(inputId = "var_shoe", 
                      label = "Which shoe type do you want to look at?", 
                      choices = unique(new_brand),
                      selected = unique(new_brand)[1:3],
                      multiple = T,
                      options = list(maxItems = 5)), width = 12),
          
          # select type of shoe to be shown
          box(
            selectizeInput("var_cloth", 
                         label = "Which clothing items are you interested in?",
                         choices = c("bag / wallet", "cardigan", "coat", "dress", 
                                     "glasses", "hat", "jacket", "jumpsuit", "pants",
                                     "scarf", "shirt / blouse", "shorts", "skirt", "sweater",
                                     "top / t-shirt / sweatshirt", "watch"),
                         selected = c("shirt / blouse", "top / t-shirt / sweatshirt",
                                      "pants", "skirt"),
                         multiple = T,
                         options = list(maxItems = 5)), width = 12),
          
          width = 2),
        mainPanel(
          br(), br(), br(),
        box(plotOutput("plot_bar_interactive"), 
            width = "100%", height = "100%",  title = "Co-occurence of clothing items for different outfits"), 
        width = 8)
      ),
      tabPanel(
        "Descriptives",
        br(), br(), br(),
        box(plotOutput("plot_descr_shoe"), width = 10, 
            title = "Distribution of shoes in database (total of 6,006)"),
        box(plotOutput("plot_descr_cloth"), width = 10, 
            title = "Distribution of clothing items in  database (total of 22,651)")
      )
      ))
    )
  )
)