#Visualize licenses for COVID initiative collections in PMC

#info on COVID initiative
#https://www.ncbi.nlm.nih.gov/pmc/about/covid-19/
#links to collections (part of PMC special collections)
#https://www.ncbi.nlm.nih.gov/pmc/journals/collections/?titles=current&search=journals


#install.packages("tidyverse")
library(tidyverse)


#define function to rename collection names
renameCollections <- function(x, key = level_key){
  res <- x %>%
    mutate(collection = recode(collection, !!!key))
}

#define function to rename columns
#to do: dynamically insert date in column name
renameColumns <- function(x){
  res <- x %>%
    rename(`PMC Public Health Emergency collection` = collection,
           `number of papers (2021-11-01)` = total,
           `CC license` = cc_license,
           `CC-BY` = cc_by,
           `open government license` = open_gov,
           `custom license (perpetual access via PMC)` = custom_permanent,
           `custom license (temporary access)` = custom_temporary,
           `custom license (other)` = custom_other,
           `unknown` = unknown)
} 




#-------------------------------------------------------

date <- Sys.Date()
#or set manually
#date <- "yyyy-mm-dd"
date <- "2021-11-01"

#key for renaming collections
level_key <- c(AAAS = "AAAS",
               ACS = "ACS",
               ACP = "American College of Physicians",
               AOSIS = "AOSIS",
               ASME = "ASME",
               BMJ = "BMJ",
               CUP = "Cambridge University Press",
               ELS = "Elsevier",
               IEEE = "IEEE",
               IOP = "IOP",
               JMIR = "JMIR",
               KARGER = "Karger",
               NEJM = "NEJM",
               SN = "Springer Nature",
               OUP = "Oxford University Press",
               RS = "Radiological Society",
               SAGE = "Sage",
               TF = "Taylor & Francis",
               THIEME = "Thieme",
               UTORONTO = "University of Toronto Press",
               WILEY = "Wiley",
               WK = "Wolters Kluwer")


#read file
filename <- paste0("output/",
                   date,
                   "/license_count.csv")
license_count <- read_csv(filename)

#adapt column names and names of collection
#replace NA with "-" for readability
license_count_table <- license_count %>%
  renameCollections() %>%
  renameColumns() %>%
  mutate(across(everything(), replace_na, replace = "-"))
  
  

#write_to_csv
filename <- paste0("output/",
                   date,
                   "/license_count_table.csv")
write_csv(license_count_table, filename)

