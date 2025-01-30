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
library(sf)
library(leaflet)
library(mapview)
library(gridExtra)

list.of.packages <- c("shiny", "ggplot2", "dplyr", "tidyverse", "DT","mapview","gridExtra")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# DEFINE UI
ui <- fluidPage(
  titlePanel(title=div(img(src="unesco_banner.png", width="100%", align = "center"))),
    
  fileInput('inputdataset', label = 'Select your UNESCO data', accept = c(".tsv")),
  
  ##verbatimTextOutput("summary"),
  tableOutput("table"),
  plotOutput(
    "plot1",
    width = "100%",
    height = "200px",
    click = NULL,
    dblclick = NULL,
    hover = "plot_hover",
    brush = NULL,
    inline = FALSE
  ),
  
  selectInput('UNESCOhunters', label = 'Select your UNESCO traveller', choices = 'Nobody available yet; select an input file'),

  #tableOutput("dynamic"),
  
  leafletOutput(outputId = "map"),
  verbatimTextOutput("nonsense")

  
)

# SERVER OUTPUT 
server <- function(input, output, session) {

observeEvent(input$inputdataset, {
    
    mytable <- read.csv(input$inputdataset$datapath, header=T, sep='\t', quote="")
    
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
    sumtable$`Total number of sites`=as.numeric(sumtable$`Total number of sites`)
    sumtable$`Number of Countries`=as.numeric(sumtable$`Number of Countries`)
    sumtable$`Number of Regions`=as.numeric(sumtable$`Number of Regions`)
    sumtable$`Latest Year Inscribed`=as.numeric(sumtable$`Latest Year Inscribed`)
    
    
    
    output$table <- renderTable({
        sumtable
    })

    output$plot1 <- renderPlot({
      p1=ggplot(subset(sumtable, Traveller == "Summary"), aes(x=fct_reorder(`Traveller`, `Total number of sites`), y=`Total number of sites`))+geom_col()+theme_classic()+theme(axis.text.x = element_text(face = "bold"))+labs(x="")
      p2=ggplot(subset(sumtable, Traveller != "Summary"), aes(x=fct_reorder(`Traveller`, `Total number of sites`), y=`Total number of sites`))+geom_col()+theme_classic()+theme(axis.text.x = element_text(face = "bold"))+labs(x="", y="Sites visited")
      grid.arrange(p1,p2, ncol=2, widths=c(1,4))
    })
    
    updateSelectInput(session, "UNESCOhunters", label = "Select your UNESCO traveller", choices = colnames(mytable[, 16:ncol(mytable), drop = FALSE]))
    
    observeEvent(input$UNESCOhunters, {
      
      output$dynamic <- renderTable({
      mytable[str_detect(mytable[,input$UNESCOhunters],"Visited"),c("unique_number", "name_en", "short_description_en","states_name_en", "region_en")]
    })
    
      output$map <- renderLeaflet({
        
        specifictable=mytable[str_detect(mytable[,input$UNESCOhunters],"Visited"),c("unique_number", "name_en", "longitude","latitude","states_name_en", "region_en")]
        mapview(subset(specifictable, longitude != ""), xcol = "longitude", ycol = "latitude", crs = 4269, legend=FALSE, label="name_en")@map
        
      })
      
})
      
})
  

  
  
  
}  


# Run the application 
shinyApp(ui = ui, server = server)
