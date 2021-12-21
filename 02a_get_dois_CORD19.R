#One time script to get DOIs of removed records from CORD19 
#NB From 2021-11-01 sample dates onwards, initial data collection from PMC includes dois

#Information on CORD19 dataset (inlcluding release dates and download links)
#https://www.semanticscholar.org/cord19/download
#https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/historical_releases.html


#install.packages("tidyverse")
library(tidyverse)

#define functions to import CORD19 data
seeCORD <- function(url){
  df <- read_csv(url,
                 n_max=10)
  
  return(df)
} 

getCORDids <- function(url){
  df <- read_csv(url, 
                 col_types = cols_only(
                   pmcid = col_character(),
                   doi = col_character()
                 ))
  
  return(df)
}



#-------------------------------------------------------
#use dataset from 04_compare_dates.R (one time only)

records_CORD <- records

#Iteratively repeat from here until all dois are found (or earliest CORD version checked)
pmcids <- records_CORD %>%
  filter(is.na(doi)) %>%
  pull(pmcid)

#import CORD19 dataset
cord19_date <- "2021-11-01"
#cord19_date <- "2021-05-31"
#cord19_date <- "2020-12-12"
#cord19_date <- "2020-10-06"
#cord19_date <- "2020-04-24"

url <- paste0("https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/",
              cord19_date,
              "/metadata.csv") 

#see first rows to check variables
#CORD_see <- seeCORDfull(url)
#get full CORD19 data
CORD_ids <- getCORDids(url)

CORD_select <- CORD_ids %>%
  filter(pmcid %in% pmcids) %>%
  rename(doi_cord = doi)

#toggle for first and subsequent iterations
CORD_select_all <- CORD_select
CORD_select_all <- c(CORD_select_all, CORD_select)

records_CORD <- records_CORD %>%
  left_join(CORD_select) %>%
  mutate(doi = case_when(
    is.na(doi) ~ doi_cord,
    TRUE ~ doi)) %>%
  select(-doi_cord)

rm(CORD_ids)

#Repeat iteratively with earlier CORD-dates (matched to PMC sample dates)
#until all dois are found (or earliest CORD version checked)
#Result: 3881 of 4103 DOIs retrieved, 222 not retrieved

#TO DO write into function to call with map

#write retrieved ids to file 
write_csv(CORD_select_all, "data/CORD19/CORDids_2021-11-01.csv")


