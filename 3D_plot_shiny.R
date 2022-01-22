### Shiny 3D plot

library(shiny)
library(shinydashboard)
library(plotly)
library(shinyWidgets)


# load data

filename = "C:\\Users\\Study\\Documents\\Uni\\2_M_Sc_DataScience_in_Business_Economics\\3_WS_21_22\\1_Data_Science_Project\\data\\attributes_original.rds"
pca_result <- readRDS(filename)

# new column with mapped values
require(plyr)
unique(pca_result$brand) # look at current values
# map values to new column
pca_result$new_brand <- mapvalues(pca_result$brand, 
                          from = c("Adidas_Stan_Smith", "Adidas_Ultraboost",
                                   "Asics_Gel", "Birkenstock_Arizona", "Crocs",
                                   "Fila_Sneaker", "Louboutin_Shoes", "Puma_Sneaker",
                                   "vans_sneaker"), 
                          to = c("Sneaker", "Sneaker",
                                 "Sneaker", "Sandal", "Sandal",
                                 "Sneaker", "High-Heel", "Sneaker",
                                 "Sneaker"))


setwd("C:/Users/Study/Documents/Uni/2_M_Sc_DataScience_in_Business_Economics/3_WS_21_22/1_Data_Science_Project/")






# APP

ui <- fluidPage(
  
  # use a gradient in background
  #setBackgroundColor(
  #  color = c("#f197ef", "#b0b0f9"),
  #  gradient = "radial",
  #  direction = c("top", "left")
  #),
  
  tags$head(tags$style('h2 {color:black;}')),
  
  tabsetPanel(
    
    tabPanel("3D Plot",
             
             # Application title
             titlePanel("Visualization of differences in clothing attributes"),
             
             # sidebar layout
             sidebarLayout(
               
               # inputs
               sidebarPanel(
                 # select type of clothing that should be shown
                 radioButtons(inputId = "choice", label = "What type of apparel item are you interested in?", 
                              choices = c("Pullovers", "Shirts", "Dresses", "Pants")),
                 
                 # select type of shoe to be shown
                 checkboxGroupInput("variable", "Type of shoe to show:",
                                    c(as.character(sort(unique(pca_result$new_brand)))),
                                    selected = as.character(sort(unique(pca_result$new_brand)))[1],
                                    inline = F),
                 width = 2),
               
               # Output: show 3D plot
               mainPanel(
                 plotlyOutput(outputId = "plot", width = "100%", height = "100%"),
                 width = 8)
             )
             
    ),
    
    tabPanel("Recommendation",
             
             # sidebar layout
             sidebarLayout(
               
               # inputs
               sidebarPanel(
                 # select type of clothing that should be shown
                 radioButtons(inputId = "upload", label = "What do you want a recommendation for? -> upload here", 
                              choices = c("Upload")),
                 
                 width = 5),
               
               # Output: show recommendation
               mainPanel(
                 tabsetPanel(
                   tabPanel("Zalando",
                            fluidRow(img(src = "Zalando_Logo.jpg",
                                         height = 60)),
                            #fluidRow(
                            #  box(
                            #    title = "Item 1",
                            #    status = "primary",
                            #    solidHeader = T,
                            #    "Content", br(),
                            #    "More content",
                            #    collapsible = T,
                            #    plotlyOutput(outputId = "plot1", width = "100%", height = "100%")
                            #    ),
                            #  box(
                            #    title = "Item 2",
                            #    status = "warning",
                            #    solidHeader = T,
                            #    "Content", br(),
                            #    "More content",
                            #    collapsible = T,
                            #    plotlyOutput(outputId = "plot2", width = "100%", height = "100%")
                            #  ),
                            #  box(
                            #    title = "Item 3",
                            #    solidHeader = T,
                            #    "Content", br(),
                            #    "More content",
                            #    collapsible = T,
                            #    plotlyOutput(outputId = "plot3", width = "100%", height = "100%")
                            #  )
                            #  )
                   ),
                   tabPanel("About You",
                            fluidRow(img(src = "AY_Logo.png",
                                         height = 60),
                                     column(width = 12))   ,
                            fluidRow(
                              box(
                                title = "Item 1",
                                status = "primary",
                                solidHeader = T,
                                "Content", br(),
                                "More content",
                                collapsible = T,
                                plotOutput(outputId = "plot1", width = "100%", height = "100%")
                              )
                            )
                   ),
                   tabPanel("Asos",
                            fluidRow(img(src = "Asos_Logo.png",
                                         height = 60),
                                     column(width = 12))             
                   )
                 ), width = 7
               )
             )
    ),
    tabPanel("Lol",
             dashboardBody(
               fluidRow(
                 box(
                 title = "Histogram", status = "primary", solidHeader = TRUE,
                 collapsible = TRUE
                 )
               )
             )
    )
  )
)



server <- function(input, output) {
  
  
  output$plot <- renderPlotly(
    plot <- plot_ly(pca_result %>% filter(new_brand %in% input$variable), 
                    type = "scatter3d",
                    mode = "markers",
                    x = ~PC01, y = ~PC02, z = ~PC03,
                    color = ~new_brand,
                    colors = c("Sneaker" = "red",
                               "Sandal" = "blue",
                               "High-Heel" = "green"),
                    size = 0.7,
                    hoverinfo = "none",
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


# Run the application
shinyApp(ui, server)






