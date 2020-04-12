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
renameColumns <- function(x){
  res <- x %>%
    rename(`PMC Public Health Emergency collection` = collection,
           `number of papers (2020-04-11)` = total,
           `CC license` = cc_license,
           `CC-BY` = cc_by,
           `open government license` = open_gov,
           `custom license (perpetual access via PMC)` = custom_permanent,
           `custom license (temporary access)` = custom_temporary,
           `custom license (other)` = custom_other,
           `unknown` = unknown)
} 




#-------------------------------------------------------

#key for renaming collections
level_key <- c(ACS = "American Chemical Society",
               BMJ = "BMJ",
               CUP = "Cambridge University Press",
               ELS = "Elsevier",
               IOP = "IOP",
               SN = "Springer Nature",
               OUP = "Oxford University Press",
               SAGE = "Sage",
               TF = "Taylor and Francis",
               AIP = "AIP")


#read all files
filename <- "output/license_count.csv"
license_count <- read_csv(license_count, filename)

#adapt column names and names of collection
#replace NA with "-" for readability
license_count_table <- license_count %>%
  renameCollections() %>%
  renameColumns() %>%
  replace(is.na(.), "-")
  

#write_to_csv
filename <- "output/license_count_table.csv"
write_csv(license_count_table, filename)

