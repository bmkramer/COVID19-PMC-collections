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


#-------------------------------------------------------

#read all files
dir_path <- "data/"
data <- list.files("data", pattern = "*.csv") %>%
  map(~read_csv(paste0(dir_path, .)))

#count licenses per collection
license <- data %>%
  map(~countLicenses(.))

#get unique licenses
license_unique <- license %>%
  bind_rows() %>%
  count(license_url, license_text) %>%
  select(-n)

#add license details
license_info <- classifyLicenses(license_unique)

#write to csv
filename = "output/license_info.csv"
write_csv(license_info, filename)
  
#manually inspect and complete license classification
filename = "output/license_info_complete.csv"
license_info_complete <- read_csv(filename)

#add column for CC-BY
license_info_complete <- license_info_complete %>%
  addCCBY()
    
#join to collection licenses (on license_url and license_text)
join_columns <- c("license_url", "license_text")

license_type <- license %>%
  joinLicenseClassification(license_info_complete, join_columns)

#summarize number of records, NA for zero
license_count <- summarizeLicense(license_type)

#write_to_csv
filename <- "output/license_count.csv"
write_csv(license_count, filename)


