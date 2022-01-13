#Analyze records removed from PMC Public Health collections

#install.packages("tidyverse")
library(tidyverse)
library(lubridate)
library(jsonlite)

#---------------------------------------

#define function to run different mini-analyses

AnalyzeRemoved <- function(publisher, df){
  
  #count (incl doi) - only for removed records
  removed_count <- df %>%
    filter(collection %in% publisher) %>%
    filter(!is.na(removed)) %>% 
    summarise(pmcid = sum(!is.na(pmcid)),
              doi = sum(!is.na(doi)))

  #latest version - only for removed records
  removed_latest <- df %>%
    filter(collection %in% publisher) %>%
    filter(!is.na(removed)) %>% #only for removed records
    count(version_latest) 

  #publication year - compare all and removed records
  removed_pubyear <- df %>%
    filter(collection %in% publisher) %>%
    #filter(!is.na(removed)) %>%
    group_by(pubyear) %>%
    summarise(all = sum(!is.na(pmcid)),
              removed = sum(!is.na(removed))) %>%
    arrange(desc(pubyear))

  #license - compare all and removed records
  removed_license <- df %>%
    filter(collection %in% publisher) %>%
    #filter(!is.na(removed)) %>%
    group_by(license_summary) %>%
    summarise(all = sum(!is.na(pmcid)),
              removed = sum(!is.na(removed)))

  #publication type - compare all and removed records  
  removed_type <- df %>%
    filter(collection %in% publisher) %>%
    #filter(!is.na(removed)) %>%
    group_by(publication_type) %>%
    summarise(all = sum(!is.na(pmcid)),
              removed = sum(!is.na(removed)))

  #oa-status - compare all and removed records
  removed_oa_status <- df %>%
    filter(collection %in% publisher) %>%
    #filter(!is.na(removed)) %>%
    group_by(upw_current) %>%
    summarise(all = sum(!is.na(pmcid)),
              removed = sum(!is.na(removed)))

  #journals with removed records, compare all w removed
  removed_journal_names <- df %>%
    filter(collection %in% publisher) %>%
    filter(!is.na(removed)) %>%
    pull(journal) %>%
    unique()

  removed_journals <- df %>%
    filter(collection %in% publisher) %>%
    filter(journal %in% removed_journal_names) %>%
    group_by(journal) %>%
    summarise(all = sum(!is.na(pmcid)),
              removed = sum(!is.na(removed))) %>%
    arrange(desc(removed))

  #collect results into list
  res <- list(removed_count = removed_count,
              removed_latest = removed_latest,
              removed_pubyear = removed_pubyear,
              removed_license = removed_license,
              removed_type = removed_type,
              removed_oa_status = removed_oa_status,
              removed_journals = removed_journals
              )

  return(res)

}

#--------------------------------------

#read files
records_all <- read_csv("output/records_all_unique.csv")
records_upw <- read_csv("data/Unpaywall/PMC_all_UPW_instances_2021-11-17.csv")

#for reference
records_count <- read_csv("output/records_count.csv")

#-------------------------------------

#identify publishers with removed records
removed_publishers <- records_count %>%
  #set cutoff manually depending on need
  filter(removed > 100) %>%
  pull(collection)


#create joined df with all relevant variables
records_upw_join <- records_upw %>%
  select(doi_pmc, 
         publication_type,
         upw_current,
         upw_green_pmc_current,
         last_updated_current) %>%
  #deduplicate because some records are in multiple collections
  distinct()

records_analyze <- records_all %>%
  select(-c(license_url, license_text)) %>%
  left_join(records_upw_join, by = c("doi" = "doi_pmc"))
  


#run analyses
res <- map(removed_publishers, ~ AnalyzeRemoved(., df = records_analyze))
#add publisher names to list
res_names <- set_names(res, removed_publishers)


# Save as json file
res_names_json <- toJSON(res_names, pretty = TRUE, auto_unbox = TRUE)
write(res_names_json, "output/removed_records/removed_records_analysis.json")

# Read json file 
# NB without readLines step, errors with UTF8 encoding are reported 
readlines <- readLines("output/removed_records/removed_records_analysis.json", warn = FALSE)
res_removed <- fromJSON(readlines)
rm(readlines)




  



