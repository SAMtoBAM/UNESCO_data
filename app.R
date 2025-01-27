#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(DT)

# DEFINE UI
ui <- fluidPage(
  
    
  fileInput('inputdataset', label = 'Select your UNESCO data', accept = c(".tsv")),

  verbatimTextOutput("summary"),
  tableOutput("table"),
  
  selectInput('UNESCOhunters', label = 'Select your UNESCO traveller', choices = 'Nobody available yet; select an input file'),
  
  #selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
  
  verbatimTextOutput("nonsense"),
  tableOutput("dynamic")
  
)

# SERVER OUTPUT 
server <- function(input, output, session) {

observeEvent(input$inputdataset, {
    
    mytable <- read.csv(input$inputdataset$datapath, header=T, sep='\t', quote="")
    
    #output$summary <- renderPrint({
    #    summary(mytable)
    #})
    
    output$table <- renderTable({
        #create a table with summary information for the UNESCO file
        #the latest year
        #max(mytable$date_inscribed)
        #the number of UNESCO sites
        #nrow(mytable)
        #the number of countries
        #length(unique(mytable$states_name_en))
        #the number of sites visited
        # ????
        ## create empty data frame with columns names
        sumtable=setNames(data.frame(matrix(nrow = 0, ncol = 5)), c("Traveller","Latest Year Inscribed","Total number of sites","Number of Countries", "Number of Regions"))
        ##generate summary stats for the entire dataset
        sumtable[nrow(sumtable) + 1,] = paste(c("Summary", max(mytable$date_inscribed), nrow(mytable), length(unique(mytable$states_name_en)), length(unique(mytable$region_en))))
        ##generate summary stats for each traveller
        ##get list of travellers in the table
        travellers=colnames(mytable[, 16:ncol(mytable), drop = FALSE])
        ##for loop for each traveller
        for ( indi in travellers) {
          temp=mytable[str_detect(mytable[,indi],"Visited"),]
          sumtable[nrow(sumtable) + 1,] = paste(c(indi, max(temp$date_inscribed), nrow(temp), length(unique(temp$states_name_en)), length(unique(temp$region_en)))) 
          
        }
        
        
        sumtable
    })

    updateSelectInput(session, "UNESCOhunters", label = "Select your UNESCO traveller", choices = colnames(mytable[, 16:ncol(mytable), drop = FALSE]))
    
    observeEvent(input$UNESCOhunters, {
      
      output$dynamic <- renderTable({
      mytable[str_detect(mytable[,input$UNESCOhunters],"Visited"),1:15]
    })
    
})
      
})
  

  
  
  
}  


# Run the application 
shinyApp(ui = ui, server = server)
