

# Packages ----------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinyFiles)

# Functions ---------------------------------------------------------------
source("dashboard_theme.R")
source("dashboard_logo.R")

# UI ----------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(
    title = customLogo,
    titleWidth = "270"
  ),
  dashboardSidebar(
    width = "270",
    sidebarSearchForm(textId = "searchbar", buttonId = "searchbtn", label = "Search..."),
    sidebarMenu(
      menuItem("Modeltraining", tabName = "model_training", icon = icon("dumbbell")),
      menuItem("Image Upload", tabName = "image_upload", icon = icon("camera")),
      menuItem("Model Performance", tabName = "model_performance", icon = icon("chart-line"))
    )
  ),
  dashboardBody(
    customTheme,
    tabItems(
      tabItem(
        tabName = "model_training",
        fluidRow(
          shinyDirButton("folder", "Select a folder", "Please select a folder", FALSE),
          textOutput("folder"),
          actionButton("start_straining", label = "Starte Modell-Training")
        )
      ),
      tabItem(
        tabName = "image_upload",
        fluidRow(
          fileInput("myFile", "Choose a file", accept = c("image/png", "image/jpeg"))
        ),
        mainPanel(
          div(id = "image-container", style = "display:flexbox")
        )
      ),
      tabItem(
        tabName = "model_performance"
      )
    )
  )
)

# Server ------------------------------------------------------------------

server <- function(input, output) {
  observeEvent(input$myFile, {
    inFile <- input$myFile
    if (is.null(inFile)) {
      return()
    }

    b64 <- base64enc::dataURI(file = inFile$datapath, mime = "image/png")
    insertUI(
      selector = "#image-container",
      where = "afterBegin",
      ui = img(src = b64, width = 250, height = 250)
    )
  })

  shinyDirChoose(
    input,
    "folder",
    roots = c(home = "~"),
    filetypes = c("", "txt", "bigWig", "tsv", "csv", "bw")
  )

  global <- reactiveValues(datapath = getwd())

  dir <- reactive(input$folder)
     
  output$folder <- renderText(global$datapath)
  observeEvent(
    ignoreNULL = TRUE,
    eventExpr = {
      input$folder
    },
    handlerExpr = {
      if (!"path" %in% names(dir())) {
        return()
      }
      home <- normalizePath("~")
      global$datapath <-
        file.path(home, paste(unlist(dir()$path[-1]), collapse = .Platform$file.sep))
    }
  )
}



# Run App -----------------------------------------------------------------

shinyApp(ui, server)
