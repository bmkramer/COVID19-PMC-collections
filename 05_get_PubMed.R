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
#install.packages("rentrez")
library(tidyverse)
library(rentrez)


#set email in Renviron
#file.edit("~/.Renviron")
#add NCBI API key (request via MyNCBI account):
#ENTREZ_KEY = xxxxxxx
#save the file and restart your R session
#check presence in .Renviron
Sys.getenv("ENTREZ_KEY")


getSummaryData <- function(x){
  
  uid <- x$uid
  
  #convert existing list structure to extract doi
  articleid <- as.list(x$articleids$value)
  names(articleid) <- x$articleids$idtype
  #use pluck to select doi to accommodate missing values
  pmid <- pluck(articleid, "pmid", .default = NA)
  
  res <- list(uid = uid,
              pmid = pmid)
  
  return(res)
  
}  

getData <- function(ids){
  
  id_summary <- ids %>%
    entrez_summary(db = "pmc", 
                   id = .) %>%
    map_dfr(getSummaryData) %>%
    mutate(uid = paste0("PMC", uid)) %>%
    rename(pmcid = uid)

 data <- id_summary
  
  return(data)
}

  
#define function to add progress bar
#add progress bar 
getData_progress <- function(ids){
  pb$tick()$print()
  result <- getData(ids)
  
  return(result)
}


#-------------------------------------------------------
#set system date or set date manually
date <- Sys.Date()
#date <- "yyyy-mm-dd"
date <- "2022-01-10"

#load records
records_all <- read_csv("output/records_all_unique.csv")

records <- records_all %>%
  filter(is.na(removed)) %>%
  mutate(pmcid_clean = str_remove(pmcid, "PMC")) %>%
  select(collection, pmcid, pmcid_clean, journal)

pmcids <- records %>%
  pull(pmcid_clean)

#Could also run loop below per 10,000 of 50,000 ids
#TO DO: convert into mapping
ids <- pmcids[180001:length(pmcids)]
seq_ids <- seq(1, length(ids), 100)


for (i in seq_ids){
  ids_x <- ids[i:(i+99)]
  res_x <- getData(ids_x)
  
  #res_all <- res_x
  res_all <- bind_rows(res_all, res_x)
}

#some duplicated b/c PMCIDs retrieved from multiple collectiosn
res_all_unique <- res_all %>%
  distinct

filename <- paste0("data/PubMed/pmids_", date, ".csv")
write_csv(res_all_unique, filename)

#----------------------------------

#Join to records

#PMCIDs that could not be retrieved return NA for PMID; 
#PMCIDs without PMID return 0 for PMID

records_pubmed <- records %>%
  select(collection, pmcid, journal) %>%
  left_join(res_all_unique, by = "pmcid") %>%
  #filter PMCIDs that could not be retrieved (n=1)
  filter(!is.na(pmid)) %>%
  #change pmid value 0 into NA
  mutate(pmid = case_when(
    pmid == 0 ~ NA_character_,
    TRUE ~ pmid))

filename <- paste0("output/pubmed/records_pmids_", date, ".csv")
write_csv(records_pubmed, filename)
  
#-------------------------------------------

#Analyze results

#define function to rename collection names
renameCollections <- function(x, key = level_key){
  res <- x %>%
    mutate(collection = recode(collection, !!!key))
}

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

records_pubmed_all <- records_pubmed %>%
  summarize(pmcid = sum(!is.na(pmcid)),
            no_pmid = sum(is.na(pmid))) %>%
  mutate(`%` = round(100 * no_pmid / pmcid, 1))

records_pubmed_publishers <- records_pubmed %>%
  group_by(collection) %>%
  summarize(pmcid = sum(!is.na(pmcid)),
            no_pmid = sum(is.na(pmid))) %>%
  mutate(`%` = round(100 * no_pmid / pmcid, 1)) %>%
  arrange(desc(pmcid)) %>%
  renameCollections()

records_pubmed_journals <- records_pubmed %>%
  group_by(collection, journal) %>%
  summarize(pmcid = sum(!is.na(pmcid)),
            no_pmid = sum(is.na(pmid))) %>%
  mutate(`%` = round(100 * no_pmid / pmcid, 1)) %>%
  arrange(desc(no_pmid)) %>%
  renameCollections()

#write results to csv
filename <- paste0("output/pubmed/records_pmids_summary_all_", date, ".csv")
write_csv(records_pubmed_all, filename)

filename <- paste0("output/pubmed/records_pmids_summary_publishers_", date, ".csv")
write_csv(records_pubmed_publishers, filename)

filename <- paste0("output/pubmed/records_pmids_summary_journals_", date, ".csv")
write_csv(records_pubmed_journals, filename)

