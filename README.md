# UNESCO_data
Data for keeping up to date UNESCO data with manually added sites visited by 1 or more individuals





Download the (current) 2024 world hertiage sites list from the UNESCO website <br/>
Comes as a XLSX file, so convert this to a simple TSV file for processing <br/>
Create an english version (file has multiple languages) to reduce information and simplify <br/>

This has already been done for 2024 and can be downloaded from [here](https://drive.google.com/file/d/1b35NXsE1byxTfPNQv4frB-2Eol95HAO1/view?usp=sharing)


Alternatively you can try automate the process as below in bash

      #Download
      wget https://whc.unesco.org/en/list/xlsx/whc-sites-2024.xlsx
      #Convert to XLSX to TSV
      #need xlsx2csv installed 'sudo apt install xlsx2csv'
      xlsx2csv -d '\t' whc-sites-2024.xlsx whc-sites-2024.tsv
      ##extract just the english parts
      ##and correct some formatting issues that seem to be a hand over from other formats
      cat whc-sites-2024.tsv | awk -F "\t" '{print $1"\t"$2"\t"$4"\t"$10"\t"$16"\t"$18"\t"$23"\t"$24"\t"$25"\t"$37"\t"$38"\t"$39"\t"$45"\t"$47"\t"$48}' | sed 's/<.*>//g' > whc-sites-2024.en.tsv
      
      
Once you have the tsv file, add a row per individual and then in each row you have visited write "Visited" 

Now you need to have R installed and be able to run a shiny app <br/>
You can run the following below in R

```{r}
      options(repos = c(CRAN = "https://cran.rstudio.com"))
      library(shiny)
      library(ggplot2)
      library(dplyr)
      library(tidyverse)
```

Now import the tsv into R and use the shiny app to visualise the data



