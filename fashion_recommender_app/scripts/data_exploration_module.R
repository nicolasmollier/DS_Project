
### Shiny 3D plot

library(shiny)
library(shinydashboard)
library(plotly)
library(shinyWidgets)


# load data

setwd("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project")
pca_result <- readRDS("data/fp_select_attrib_per_class_pca.rds")

# new column with mapped values
require(dplyr)
unique(pca_result$brand) # look at current values
# map values to new column
pca_result$new_brand <- plyr::mapvalues(pca_result$brand, 
                                  from = c("Adidas_Stan_Smith", "Adidas_Ultraboost",
                                           "Asics_Gel", "Birkenstock_Arizona", "Crocs",
                                           "Fila_Sneaker", "Louboutin_Shoes", "Puma_Sneaker",
                                           "vans_sneaker"), 
                                  to = c("Sneaker", "Sneaker",
                                         "Sneaker", "Sandal", "Sandal",
                                         "Sneaker", "High-Heel", "Sneaker",
                                         "Sneaker"))



explorationUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    # select type of shoe to be shown
    checkboxGroupInput(ns("variable"), "Type of shoe to show:",
                       c(as.character(sort(unique(pca_result$new_brand)))),
                       selected = as.character(sort(unique(pca_result$new_brand)))[1],
                       inline = F),
    
    plotlyOutput(outputId = ns("scatter_3D"), width = "100%", height = "100%")
  )

}


explorationServer <- function(id){
  moduleServer(
    id,
    function(input, output, session){
      
      pca_result_reac <- reactive({
        pca_result %>% 
          filter(new_brand %in% input$variable)
      })
      
      output$scatter_3D <- renderPlotly(
        DDD_plot <- plot_ly(pca_result %>% filter(new_brand %in% input$variable), 
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
  )
}


  
  
