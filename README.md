# UNESCO_data
Data for keeping up to date UNESCO data with manually added sites visited by 1 or more individuals <br/>
The data visualiation has been made easy with an R shiny app

### Step 1: <br/>

You need to put your name at the top of the far right column then put 'Visited' if you have been to the corresponding UNESCO site in that row

Simple option: <br/>
Download the tab-seperated-values (tsv) table from [here](https://drive.google.com/file/d/1b35NXsE1byxTfPNQv4frB-2Eol95HAO1/view?usp=sharing) <br/>

Harder option: <br/>
Download the (current) 2024 world hertiage sites list from the UNESCO website <br/>
Comes as a XLSX file, so convert this to a simple TSV file for processing <br/>
Create an english version (file has multiple languages) to reduce information and simplify <br/>

You can try automate the process as below in bash

      #Download
      wget https://whc.unesco.org/en/list/xlsx/whc-sites-2024.xlsx
      #Convert to XLSX to TSV
      #need xlsx2csv installed 'sudo apt install xlsx2csv'
      xlsx2csv -d '\t' whc-sites-2024.xlsx whc-sites-2024.tsv
      ##extract just the english parts
      ##and correct some formatting issues that seem to be a hand over from other formats
      cat whc-sites-2024.tsv | awk -F "\t" '{print $1"\t"$2"\t"$4"\t"$10"\t"$16"\t"$18"\t"$23"\t"$24"\t"$25"\t"$37"\t"$38"\t"$39"\t"$45"\t"$47"\t"$48}' | sed 's/<.*>//g' > whc-sites-2024.en.tsv
      
### Step 2: <br/>      
Now to run the app and input your table (make sure is is still in tsv format (common output option etc or just don't change the formatting):

Simple option: <br/>
Use the online version at hosted by [shinyapps.io] (https://mumandco.shinyapps.io/unesco_app/) <br/>

Harder option: <br/>
Install R then run the shiny app locally <br/>
To do this launch the app project in R and run the app file

      ##in R
      library(shiny)
      ##then run the app putting the path to the app downloaded
      runApp(appDir = "UNESCO_app/")


