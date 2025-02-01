
##itake the list of required libraries and install them if they are not already present
list.of.packages <- c("shiny", "ggplot2", "dplyr", "tidyverse", "DT","mapview","gridExtra","UpSetR")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)


##load the libraries necessary
library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(DT)
library(sf)
##for map
library(leaflet)
library(mapview)
##for grid.arrange
library(gridExtra)
##for upset plot
library(UpSetR)
#library(ggplotify)

# DEFINE UI
ui <- fluidPage(
  ##define some styles used for the dropdown boxes
  tags$head(
    tags$style(HTML('
      .file-input-container {
        position: relative;
        width: 400px;
        height: 100px;
        margin: 20px auto;
        padding: 5px;
        border: 2px dashed #0087F7;
        border-radius: 5px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: space-around; /* Distribute space around items */
      }
      .file-input-text {
        text-align: center;
        font-size: 1.2em;
        margin-top: 20px; /* Add space above the text */
        margin-bottom: 20px; /* Add space below the text */
      }
      #file1 {
        text-align: center; 
        display: block; 
        margin: auto; 
      }
    '))
  ),
  
  ##in the header add a banner created of the UNESCO emblem
  titlePanel(title=div(img(src="unesco_banner.png", width="100%", align = "center"))),
  
  ##select bar for choosing the file 'inputdataset'
  div(class = "file-input-container", fileInput('inputdataset', label = 'Select your UNESCO data', accept = c(".tsv"))),
  
  ##verbatimTextOutput("summary"),
  ## a table output to summarise the basics for all individuals
  tableOutput("table"),
  ## plotting the total visited for each individual
  #plotOutput(
  #  "plot1",
  #  width = "100%",
  #  height = "200px",
  #  click = NULL,
  #  dblclick = NULL,
  #  hover = "plot_hover",
  #  brush = NULL,
  #  inline = FALSE
  #),
  ##an upset plot looking at the overlap in all the individuals per site/countries
  plotOutput(
    "plot2",
    width = "100%",
    height = "400px",
    click = NULL,
    dblclick = NULL,
    hover = "plot_hover",
    brush = NULL,
    inline = FALSE
  ),
  
  ##a select bar for choosing each of the individuals
  div(class = "file-input-container", selectInput('UNESCOhunters', label = 'Select your UNESCO traveller', choices = 'Nobody available yet; select an input file')),
  
  ##map to show the locations visited by each traveller
  leafletOutput(outputId = "map"),
  #verbatimTextOutput("nonsense")
  
  ##add some space to the bottom of the page so that the last rendered item doesn't hit the edge
  HTML("<br><br><br>")  
)

# SERVER OUTPUT 
server <- function(input, output, session) {
  
  ##allow for the selection of a tsv file then
  ##modify the following depending on the file uploaded
  observeEvent(input$inputdataset, {
    
    ##read is a tsv file using the drop down selector 'inputdataset'
    mytable <- read.csv(input$inputdataset$datapath, header=T, sep='\t', quote="")
    
    #create a table with summary information for the UNESCO file
    #the latest year (old or new sites)
    #the number of UNESCO sites
    #the number of countries
    #the number of sites visited
    ## create empty data frame with columns names
    sumtable=setNames(data.frame(matrix(nrow = 0, ncol = 5)), c("Traveller","Latest Year Inscribed","Total number of sites","Number of Countries", "Number of Regions"))
    ##generate summary stats for the entire dataset
    sumtable[nrow(sumtable) + 1,] = paste(c("Summary", max(mytable$date_inscribed), nrow(mytable), length(unique(mytable$states_name_en)), length(unique(mytable$region_en))))
    ##generate summary stats for each traveller
    ##get list of travellers in the table
    travellers=colnames(mytable[, 16:ncol(mytable), drop = FALSE])
    ##for loop for each traveller
    ##here also create a list of the unique number sites/countries for each individual
    ##create empty list
    sites=list()
    countries=list()
    ##now loop through individuals
    for ( indi in travellers) {
      
      ##create temp file with only lines containing visited for the individuals column
      temp=mytable[str_detect(mytable[,indi],"Visited"),]
      ##now add a new row to the sumtable with the stats desired
      sumtable[nrow(sumtable) + 1,] = paste(c(indi, max(temp$date_inscribed), nrow(temp), length(unique(temp$states_name_en)), length(unique(temp$region_en)))) 
      
      ##add the unique numbers of sites/countries to the list for each individual
      sites[[indi]]=mytable[str_detect(mytable[,indi],"Visited"),]$unique_number
      countries[[indi]]=unique(mytable[str_detect(mytable[,indi],"Visited"),]$states_name_en)
      
    }
    ##change the values to numbers for plotting etc
    sumtable$`Total number of sites`=as.numeric(sumtable$`Total number of sites`)
    sumtable$`Number of Countries`=as.numeric(sumtable$`Number of Countries`)
    sumtable$`Number of Regions`=as.numeric(sumtable$`Number of Regions`)
    sumtable$`Latest Year Inscribed`=as.numeric(sumtable$`Latest Year Inscribed`)
    
    
    ##render the simple summary stats table 'table'
    output$table <- renderTable({
      sumtable
    }, align = "c", width="100%", digits = 0)
    ##render the simple summary stats plots 'plot1'
    #output$plot1 <- renderPlot({
    #  p1=ggplot(subset(sumtable, Traveller == "Summary"), aes(x=fct_reorder(`Traveller`, `Total number of sites`), y=`Total number of sites`))+geom_col()+theme_classic()+theme(axis.text.x = element_text(face = "bold"))+labs(x="")
    #  p2=ggplot(subset(sumtable, Traveller != "Summary"), aes(x=fct_reorder(`Traveller`, `Total number of sites`), y=`Total number of sites`))+geom_col()+theme_classic()+theme(axis.text.x = element_text(face = "bold"))+labs(x="", y="Sites visited")
    #  grid.arrange(p1,p2, ncol=2, widths=c(1,4))
    #})
    
    ##should make this a drop down that can select sites, countries or regions
    #render a upset plot using the list of unique numbers for each site (for now)
    output$plot2 <- renderPlot({
      upset(fromList(sites), order.by = "freq", sets.x.label = "Total sites visited")
      #p3=upset(fromList(sites), order.by = "freq", sets.x.label = "Total sites visited")
      #p4=upset(fromList(countries), order.by = "freq", sets.x.label = "Total countries visited")
      #grid.arrange(p3,p4, ncol=2)
    })
    
    
    ##drop down box for selecting the list of travellers
    updateSelectInput(session, "UNESCOhunters", label = "Select your UNESCO traveller", choices = colnames(mytable[, 16:ncol(mytable), drop = FALSE]))
    
    ##modify the following depending on the traveller selected
    observeEvent(input$UNESCOhunters, {
      
      ##render a map using mapview with the regions the traveller visited indicated by the long-lang coordinates
      output$map <- renderLeaflet({
        
        specifictable=mytable[str_detect(mytable[,input$UNESCOhunters],"Visited"),c("unique_number", "name_en", "longitude","latitude","states_name_en", "region_en")]
        mapview(subset(specifictable, longitude != ""), xcol = "longitude", ycol = "latitude", crs = 4269, legend=FALSE, label="name_en")@map
        
      })
      
    })
    
  })
  
  
  
  
  
}  


# Run the application 
shinyApp(ui = ui, server = server)
