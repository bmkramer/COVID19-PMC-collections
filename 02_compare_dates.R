#Get licenses for COVID initiative collections in PMC

#info on COVID initiative
#https://www.ncbi.nlm.nih.gov/pmc/about/covid-19/
#links to collections (part of PMC special collections)
#https://www.ncbi.nlm.nih.gov/pmc/journals/collections/?titles=current&search=journals

#info on using rentrez package:
#https://ropensci.org/tutorials/rentrez_tutorial/
#https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html
#https://www.ncbi.nlm.nih.gov/books/NBK25499/


#install.packages("tidyverse")
library(tidyverse)
library(lubridate)

#define function to read files
readFolder <- function(date, folder){
  files <- list.files(file.path(folder, date), 
                      pattern="csv", full.names=TRUE) %>%
    map_dfr(read_csv)
}

#--------------------------------------
date <- Sys.Date()
#or set manually
#date <- "yyyy-mm-dd"
date <- "2022-08-28"


#create vector with sampling dates
dates <- list.files(path = "data/", pattern = "^\\d{4}-\\d{2}-\\d{2}")

#----------------------------------------
#create df of records with presence on sample dates

#read files into list
list_records <- map(dates, ~readFolder(., 
                                     folder = "data"))
list_records <- set_names(list_records, dates)

#bind all rows, .id creates column with identifier, taken from list names
records_all <- bind_rows(list_records, .id = "date") %>%
  #remove AIP as not a declared PHE collection
  filter(collection != "AIP") %>%
  #reorder columns
  select(date, collection, pmcid, doi, everything())

#create interim matching table of PMCIDs and DOIs
dois <- records_all %>%
  select(pmcid, doi) %>%
  filter(!is.na(doi)) %>%
  distinct()

#transform into wide form keeping only collection and total
records_unique <- records_all %>%
  #including columns pmc_live_date, pubyear, license_text and/or journal gives duplicates as apparently multiple values
  #select(date, collection, pmcid, pmc_live_date, pubyear, license_text) %>%
  select(date, collection, pmcid) %>%
  mutate(included = TRUE) %>%
  distinct() %>%
  pivot_wider(names_from = date, values_from = included) %>%
  arrange(collection) %>%
  #add dois from interim matching table
  left_join(dois) %>%
  #reorder columns
  select(collection, pmcid, doi, everything())
#n=267100 of wich 266316 unique pmcids - some records are in multiple collections?

rm(dois, list_records)

#use results from one time step to get DOIs from from CORD19 for records removed prior to 2021-11-01
#done using script 02a_get_dois_CORD19.R
#from 2021-11-01 onwards, dois collected directly from PMC

CORD_ids <- read_csv("data/CORD19/CORDids_2021-11-01.csv") %>%
  rename(doi_cord = doi)

records_unique <- records_unique %>%
  left_join(CORD_ids, by = "pmcid") %>%
  mutate(doi = case_when(
    is.na(doi) ~ doi_cord,
    TRUE ~ doi)) %>%
  select(-doi_cord)

rm(CORD_ids)
#3639 dois added, 222 still missing (in November 2021)

#identify dropped/removed records over time
#sufficient to check which records are not present in latest collection!
#add new element for each added sample_date

#identify last column 
col_last <- ncol(records_unique)

records_removed <- records_unique %>%
  mutate(removed = case_when(
    is.na(.[[col_last]])  ~ "removed",
    TRUE ~ NA_character_)) %>%
  filter(!is.na(removed)) %>%
  select(pmcid, removed) %>%
  distinct()

records_unique <- records_unique %>%
  left_join(records_removed, by = "pmcid")

rm(records_removed)

#------------------------------------------------------------------

#add parameters from original collections
#as collected pmc_live_date, pubyear, license_text and/or journal were found to occasionally differ between dates (see 04.compare_dates.R)
#take additional parameters from last instance where record was present in collection

#add column with latest date present in collection
#NB some pmcids are present in multiple collections!

records_latest <- records_unique %>%
  select(-c(doi, removed)) %>%
  pivot_longer(!c(pmcid, collection), names_to = "version", values_to = "included") %>%
  #keep only versions with record included
  filter(!is.na(included)) %>%
  #convert version date to date format
  mutate(version = as_date(version)) %>%
  #keep only latest version
  group_by(pmcid, collection) %>%
  arrange(desc(version)) %>%
  slice(1) %>%
  ungroup() %>%
  #convert version date back to character for subsequent matching
  mutate(version = as.character(version)) %>%
  select(-included)

#add column to records with latest version in which record occurs 
records_unique <- records_unique %>%
  left_join(records_latest,
            by = c("collection", "pmcid")) %>%
  rename(version_latest = version)

rm(records_latest)

#----------------------------------------------

#add parameters from full records (exclude publisher as not needed in addition to collection)

records_all_join <- records_all %>%
  select(-c(doi, publisher))

records_unique <- records_unique %>%
  left_join(records_all_join,
            by = c("collection",
                   "pmcid", 
                   "version_latest" = "date")) %>%
  distinct()

rm(records_all_join)


#---------------------------------------------------
#quantification

records_count <- records_unique %>%
  select(-c(version_latest,
            pmc_live_date,
            pubyear,
            journal,
            license_url,
            license_text)) %>%
  group_by(collection) %>%
  summarise_all(~ sum(!is.na(.)))

#---------------------------------------------------
#write to csv

filename <- paste0("output/records_all_unique.csv")
write_csv(records_unique, filename)

filename <- paste0("output/records_count.csv")
write_csv(records_count, filename)

#--------------------------------------------------

#enrich data with longitudinal Unpaywall data through COKI 

#SQL query: sql/PMC_all_UPW_instances.sql
#data: data/Unpaywall/PMC_all_UPW_instances_2021-11-17.csv


#---------------------------------------------------

#create list of unique licenses 
#process further in 03_analyze_licenses.R
license_unique <- records_all %>%
  count(license_url, license_text) %>%
  select(-n)

filename <- paste0("output/licenses/license_unique.csv")
write_csv(license_unique, filename)
