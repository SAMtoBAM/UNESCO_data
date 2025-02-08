# <ins> An R shiny app for tracking UNESCO sites visited </ins>

### <ins> Step 1: Get the table with the UNESCO site data </ins> <br/>

<ins> Simple option: </ins> <br/>
Download the tab-seperated-values (tsv) table from [here](https://drive.google.com/file/d/1b35NXsE1byxTfPNQv4frB-2Eol95HAO1/view?usp=sharing) <br/>

<ins> Harder option: </ins> <br/>
Download the (current) 2024 world hertiage sites list from the UNESCO website <br/>
Comes as a XLSX file, so convert this to a simple TSV file for processing <br/>
Create an english version (file has multiple languages) to reduce information and simplify (currently app is designed for english headers) <br/>

You can try automate the process as below in bash

      #Download
      wget https://whc.unesco.org/en/list/xlsx/whc-sites-2024.xlsx
      #Convert to XLSX to TSV
      #need xlsx2csv installed 'sudo apt install xlsx2csv'
      xlsx2csv -d '\t' whc-sites-2024.xlsx whc-sites-2024.tsv
      ##extract just the english parts
      ##and correct some formatting issues that seem to be a hand over from other formats
      cat whc-sites-2024.tsv | awk -F "\t" '{print $1"\t"$2"\t"$4"\t"$10"\t"$16"\t"$18"\t"$23"\t"$24"\t"$25"\t"$37"\t"$38"\t"$39"\t"$45"\t"$47"\t"$48}' | sed 's/<.*>//g' > whc-sites-2024.en.tsv

### <ins> Step 2: Fill in your data </ins> <br/>   

You can then open the table in tools such as microsoft excel/libreoffice calc/google sheets and fill in your column <br/>
Put your name at the top of the far right column then put 'Visited' if you have been to the corresponding UNESCO site in that row as below <br/>
![Screenshot 2025-02-08 105723](https://github.com/user-attachments/assets/3b892c75-907e-4ad5-bb0a-4838174f7e39) 
Any additional person can put fill out a column to the right and so forth <br/>
You can then save this file/export it as a tsv (the original file format and common option for saving with above tools)

      
### <ins> Step 3: Visualise your data using the app </ins> <br/>      
Now you need to run the app and import your table

<ins> Simple option: </ins> <br/>
Use the online version at hosted by [shinyapps.io](https://mumandco.shinyapps.io/unesco_app/) <br/>

<ins> Harder option: </ins> <br/>
Install R then run the shiny app locally <br/>
To do this launch the app project in R and run the app file

      ##in R
      library(shiny)
      ##then run the app putting the path to the app downloaded
      runApp(appDir = "UNESCO_app/")


