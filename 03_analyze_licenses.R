#Analyze licenses for COVID initiative collections in PMC

#info on COVID initiative
#https://www.ncbi.nlm.nih.gov/pmc/about/covid-19/
#links to collections (part of PMC special collections)
#https://www.ncbi.nlm.nih.gov/pmc/journals/collections/?titles=current&search=journals


#install.packages("tidyverse")
library(tidyverse)

#define function to count licenses per collection
countLicenses <- function(file){
  res <- file %>%
    count(collection, 
          #publisher, #add to get info per publisher (incl societies!)
          license_url, 
          license_text)
  
  return(res)
}


#define function to classify licenses (prior to manual completion)
classifyLicenses <- function(file){
  res <- file %>%
    mutate(cc_license = case_when(
      grepl("commons", license_url, ignore.case = TRUE) ~TRUE,
      grepl("commons", license_text, ignore.case = TRUE) ~TRUE,
      TRUE ~ FALSE)) %>%
    mutate(cc_license_type = case_when(
      (cc_license == TRUE & grepl("/by/", license_url, ignore.case = TRUE)) ~ "CC-BY",
      (cc_license == TRUE & grepl("/by-nc/", license_url, ignore.case = TRUE)) ~ "CC-BY-NC",
      (cc_license == TRUE & grepl("/by-nc-nd/", license_url, ignore.case = TRUE)) ~ "CC-BY-NC-ND",
      (cc_license == TRUE & grepl("/by-nc-sa/", license_url, ignore.case = TRUE)) ~ "CC-BY-NC-SA",
      (cc_license == TRUE & grepl("/by-nc-nd/", license_url, ignore.case = TRUE)) ~ "CC-BY-NC-ND",
      TRUE ~ NA_character_)) %>%
    mutate(open_gov = FALSE,
           custom_permanent = FALSE,
           custom_temporary = FALSE,
           custom_other = FALSE,
           unknown = FALSE)
}

#define functions to add column license summary info to file with completed license info
addLicenseSummary <- function(file){
  res <- file %>%
    mutate(license_summary = case_when(
      cc_license & is.na(cc_license_type) ~ "CC-unknown",
      cc_license ~ cc_license_type,
      open_gov ~ "open_gov",
      custom_permanent ~ "custom_permanent",
      custom_temporary ~ "custom_temporary",
      custom_other ~ "custom_other",
      unknown ~ "unknown",
      TRUE ~ NA_character_))
}

#define functions to add column CC-BY to file with completed license info
addCCBY <- function(file){
  res <- file %>%
    mutate(cc_by = case_when(
      cc_license_type == "CC-BY" ~ "CC-BY",
      TRUE ~ NA_character_)) %>%
    select(license_url,
           license_text,
           cc_license,
           cc_license_type,
           cc_by,
           everything())
}

#define function to join license classification to collection licenses
joinLicenseClassification <- function(x, y, var){
  res <- x %>%
    bind_rows() %>%
    left_join(y, by = var) %>%
    select(-c(license_url,license_text))
}

#summarize counts by collection
summarizeLicense <- function(file){
  res <- file %>%
    group_by(collection) %>%
    summarize(total = sum(n),
              cc_license = sum(n[cc_license == TRUE]),
              cc_by = sum(n[!is.na(cc_by)]),
              open_gov = sum(n[open_gov == TRUE]),
              custom_permanent = sum(n[custom_permanent == TRUE]),
              custom_temporary = sum(n[custom_temporary == TRUE]),
              custom_other = sum(n[custom_other == TRUE]),
              unknown = sum(n[unknown == TRUE])) %>%
    na_if(0)
} 

#define function to rename collection names
renameCollections <- function(x, key = level_key){
#renameCollections <- function(x, key){  
  res <- x %>%
    mutate(collection = recode(collection, !!!key))
}

#define function to rename columns
#to do: dynamically insert date in column name
renameColumns <- function(x){
  res <- x %>%
    rename(`PMC Public Health Emergency collection` = collection,
           `number of papers (2022-08-28)` = total,
           `CC license` = cc_license,
           `CC-BY` = cc_by,
           `open government license` = open_gov,
           `custom license (perpetual access via PMC)` = custom_permanent,
           `custom license (temporary access)` = custom_temporary,
           `custom license (other)` = custom_other,
           `unknown` = unknown)
} 



#-------------------------------------------------------

#read file with unique licenses
filename <- paste0("output/licenses/license_unique.csv")
license_unique <- read_csv(filename)

#add license details
license_info <- classifyLicenses(license_unique)
#add id for matching back after export/import 
license_info <- license_info %>%
  mutate(id = 1:n()) %>%
  select(id, everything())

#write to csv
filename = paste0("output/licenses/license_info.csv")
write_csv(license_info, filename)

#------------------------------------------------------------
#enrich with previous manually added info

#import previous completed license info
filename = paste0("output/licenses/license_info_complete.csv")
license_info_previous <- read_csv(filename) %>%
  select(-c(license_summary, id))

#identify incomplete records
license_info_enriched <- license_info %>%
  #identify incomplete records
  mutate(complete = rowSums(across(where(is.logical)))) %>%
  mutate(cc_complete = case_when(
    cc_license == TRUE & is.na(cc_license_type) ~ 0,
    TRUE ~ 1)) %>%
  #filter on incomplete records
  filter(complete == 0 | cc_complete == 0) %>%
  select(id, license_url, license_text) %>%
  #join to previous info
  left_join(license_info_previous,
            by = c("license_url", "license_text")) %>%
  distinct() %>%
  #filter on records with previous info added
  filter(!is.na(cc_license))

#create vector with enriched ids
id_enriched <- license_info_enriched %>%
  pull(id)

#remove enriched ids from original data, add enriched df back in
license_info <- license_info %>%
  filter(!id %in% id_enriched) %>%
  bind_rows(license_info_enriched) %>%
  arrange(id)

rm(license_info_previous, license_info_enriched, id_enriched)         

#identify remaining missing info
license_info_missing <- license_info %>%
  mutate(complete = rowSums(across(where(is.logical)))) %>%
  mutate(cc_complete = case_when(
    cc_license == TRUE & is.na(cc_license_type) ~ 0,
    TRUE ~ 1)) %>%
  #filter on incomplete records
  filter(complete == 0 | cc_complete == 0) %>%
  select(-c(complete, cc_complete))

filename = paste0("output/licenses/license_info_missing.csv")
write_csv(license_info_missing, filename)

#--------------------------------------------
#manually inspect and complete missing license classification
#store as license_info_manual.csv
#read in completed file
filename = paste0("output/licenses/license_info_manual.csv")
license_info_manual <- read_csv(filename) %>%
  #remove columns for joining to original license info
  select(-c(license_url, license_text))

#create vector with manually enriched ids
id_manual <- license_info_manual %>%
  pull(id)

#create subset of license_info with manually added info
license_info_subset <- license_info %>%
  filter(id %in% id_manual) %>%
  select(id, license_url, license_text) %>%
  left_join(license_info_manual, 
            by = "id") %>%
  distinct

#add back to subset of other license info
license_info_complete <- license_info %>%
  filter(!id %in% id_manual) %>%
  bind_rows(license_info_subset) %>%
  arrange(id)

rm(license_info_missing, 
   license_info_manual, 
   license_info_subset,
   id_manual)

unlink("output/licenses/license_info_missing.csv")
unlink("output/licenses/license_info_manual.csv")
#NB Manually added info can still be checked by comparing license_info to license_info_complete
      

#add column with license summary
license_info_complete <- license_info_complete %>%
  addLicenseSummary()

filename = paste0("output/licenses/license_info_complete.csv")
write_csv(license_info_complete, filename)

#-----------------------------------------------------------------
# add license summary to file with all unique records

#read all records_unique
records_all_unique <- read_csv("output/records_all_unique.csv")

#add license summary
license_summary <- license_info_complete %>%
  select(license_url, license_text, license_summary)

records_all_unique <- records_all_unique %>%
  left_join(license_summary)

#write to file
filename = "output/records_all_unique.csv"
write_csv(records_all_unique, filename)


#-----------------------------------------------------------------
#create license count table for current sampling date
#generated from file with all unique records
#still using 'old' code which is a bit roundabout - consider refactoring

#date <- Sys.Date()
#or set manually
#date <- "yyyy-mm-dd"
date <- "2022-08-28"

#add column for CC-BY to license info
license_info_complete <- license_info_complete %>%
  addCCBY()

#read records_all_unique, filter on current date
filename = "output/records_all_unique.csv"
records_all_unique <- read_csv(records_all_unique, filename)

data_current <- records_all_unique %>%
  filter(version_latest == date)

#count licenses per collection
license_current <- data_current %>%
  countLicenses()

#join licenses info (on license_url and license_text)
join_columns <- c("license_url", "license_text")

license_type_current <- license_current %>%
  joinLicenseClassification(license_info_complete, join_columns)

#summarize number of records, NA for zero
license_count_current <- summarizeLicense(license_type_current)

#write_to_csv
filename = paste0("output/",
                  date,
                  "/license_count.csv")
write_csv(license_count_current, filename)

#-----------------------------------------------------------------
#Prettify table for display in Readme

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

#adapt column names and names of collection
#replace NA with "-" for readability
license_count_current_table <- license_count_current %>%
  renameCollections() %>%
  renameColumns() %>%
  #need to change type integer to character type 
  #for replacement in next line to work
  mutate_if(is.integer,as.character) %>%
  mutate(across(everything(), replace_na, replace = "-"))

#write_to_csv
filename <- paste0("output/",
                   date,
                   "/license_count_table.csv")
write_csv(license_count_current_table, filename)

