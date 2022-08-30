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
#install.packages("XML")
#install.packages("rentrez")
library(tidyverse)
library(XML)
library(rentrez)


#set NCBI API key in Renviron
#file.edit("~/.Renviron")
#add NCBI API key (request via MyNCBI account):
#ENTREZ_KEY = xxxxxxx
#save the file and restart your R session
#check presence in .Renviron
Sys.getenv("ENTREZ_KEY")


#define function to get count & store IDs as NLM web history object
setIDs <- function(query){
  res <- entrez_search(db = "pmc",
                       term = query,
                       retmax = 0,
                       use_history = TRUE)
  
  res <- list(count = res$count,
              web_history = res$web_history)
  
  return(res)
  
}

#define (mini)function to extract year from pubdate in entrez summary data
getYear <- function(pubdate) {
  year <- pubdate %>%
    str_sub(1,4) %>%
    as.integer() 
}

getSummaryData <- function(x){
  
  uid <- x$uid
  source = x$source 
  pubdate = x$pubdate 
  pmclivedate = x$pmclivedate
  
  #convert existing list structure to extract doi
  articleid <- as.list(x$articleids$value)
  names(articleid) <- x$articleids$idtype
  #use pluck to select doi to accommodate missing values
  doi <- pluck(articleid, "doi", .default = NA)
  
  res <- list(uid = uid,
              doi = doi,
              source = source, 
              pubdate = pubdate, 
              pmclivedate = pmclivedate)
  
  return(res)
  
}  


#define function to extract elements from entrez fetch data
getFetchData <- function(x){
  publisher <- x$front$`journal-meta` %>%
    pluck("publisher", .default = NA) %>%
    pluck("publisher-name", .default = NA)
  
  license <- x$front$`article-meta`%>%
    pluck("permissions", .default = NA) %>%
    pluck("license", .default = NA) %>%
    pluck("license-p", .default = NA)
  
  license_url <- pluck(license, "ext-link", .default = NA) %>%
    pluck("text", .default = NA)
  
  if(!is.na(license[1])){ 
    license_text <- license %>%
      #collapse into 1 level list
      unlist() %>%
      as.list() %>%
      unlist() %>% 
      paste(collapse = " ")
  } else{
      license_text <- NA
    }
  
  res <- list(publisher = publisher, 
              license_url = license_url, 
              license_text = license_text)
  
  return(res)
  
}  
  
getData <- function(seq_start, history_object = entrez_history, collection = query_name){
  
  id_summary <- seq_start %>%
    entrez_summary(db = "pmc", 
                   web_history = history_object,
                   retmax = 100,
                   retstart = .) %>%
    map_dfr(getSummaryData) %>%
    mutate(uid = paste0("PMC", uid)) %>%
    mutate(pubdate = getYear(pubdate)) %>%
    rename(pmcid = uid,
           pmc_live_date = pmclivedate,
           pubyear = pubdate,
           journal = source)

  id_fetch <- seq_start %>%
    entrez_fetch(db = "pmc", 
                 web_history = history_object,
                 retmax = 100,
                 retstart = .,
                 rettype = NULL)  %>% #XML output
    xmlToList() %>%
    map_dfr(getFetchData)
  
  #bind, not join, as pmcid is hard to get from entrez_fetch
  #and same IDs are sourced for both id_summary and id_fetch
  data <- bind_cols(id_summary, id_fetch) %>%
    mutate(collection = collection) %>%
    select(collection,
           pmcid,
           doi,
           pmc_live_date,
           pubyear,
           journal ,
           publisher,
           license_url,
           license_text)
  
  return(data)
}

  
#define function to add progress bar
#add progress bar 
getData_progress <- function(seq_start){
  pb$tick()$print()
  result <- getData(seq_start)
  
  return(result)
}


#-------------------------------------------------------

#set system date or set date manually
date <- Sys.Date()
#date <- "yyyy-mm-dd"
date <- "2022-08-28"


#create folders
path <- paste0("data/",
               date)
dir.create(path)

path <- paste0("output/",
               date)
dir.create(path)

#set or read list of web history identifiers
web_history <- list()

filename = paste0("data/web_history_",
                  date,
                  ".RDS")
web_history <- readRDS(filename)

#COVID-19 initiative collections
collections <- list(AAAS = "AAAS Public Health Emergency Collection[filter]",
                    ACS = "American Chemical Society Public Health Emergency Collection[filter]",
                    ACP = "American College of Physicians Public Health Emergency Collection[filter]",
                    AOSIS = "AOSIS Public Health Emergency Collection[filter]",
                    ASME = "ASME Public Health Emergency Collection[filter]",
                    BMJ = "BMJ Public Health Emergency Collection[filter]",
                    CUP = "Cambridge University Press Public Health Emergency Collection[filter]",
                    ELS = "Elsevier Public Health Emergency Collection[filter]",
                    IEEE = "IEEE Public Health Emergency Collection[filter]",
                    IOP = "IOP Publishing Public Health Emergency Collection[filter]",
                    JMIR = "JMIR Publications Public Health Emergency Collection[filter]",
                    KARGER = "Karger Publishers Public Health Emergency Collection[filter]",
                    SN = "Nature Public Health Emergency Collection[filter]",
                    NEJM = "NEJM Group Public Health Emergency Collection[filter]",
                    OUP = "OUP Public Health Emergency Collection[filter]",
                    RS = "Radiological Society Public Health Emergency Collection[filter]",
                    SAGE = "Sage Public Health Emergency Collection[filter]",
                    TF = "Taylor and Francis Public Health Emergency Collection[filter]",
                    THIEME = "Thieme Public Health Emergency Collection[filter]",
                    UTORONTO = "University of Toronto Press Public Health Emergency Collection[filter]",
                    WILEY = "Wiley Public Health Emergency Collection[filter]", 
                    WK= "Wolters Kluwer Public Health Emergency Collection[filter]")


#2022-08-28
#done 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
#not done 
#not yet

query_name <- names(collections)[11]
query <- collections[[query_name]]

#---------------------------
#For > 100,000 records (ELS and SN) split up by year (PMC Live date)
#NB earliest PMC Live Date is 2001, no future PMC Live Dates
#Manual check confirms all records captured
pmc_years <- list("(2000[PMC Live Date]:2019[PMC Live Date])",
              "2020[PMC Live Date]",
              "2021[PMC Live Date]",
              "2022[PMC Live Date]")
              
pmc_year <- pmc_years[4]
query <- paste0(collections[[query_name]]," AND ", pmc_year)
#then run per 10,000 (see below)
#----------------------------

#search Entrez, get count and web_history for stored IDs
res <- setIDs(query)
count <- res$count
entrez_history <- res$web_history

#----------------------------------------
#if re-using existing web history element
list_name <- paste0(query_name,"_",date)
#for ELS and SN, adjust manually for now
list_name <- paste0(query_name,"_PMC2022_",date)

entrez_history <- web_history[[list_name]]$web_history
count <- web_history[[list_name]]$count
#----------------------------------------

#set count for use in seq_start (keep original count for storing with web history)
#if count is exact multiple of 100, reduce by 1 to prevent downstream error
if(count%%100 == 0){
  count_seq <- count - 1
} else{
  count_seq <- count
}

#get data in chunks of 100
seq_start <- seq(0, count_seq, 100)
pb <- progress_estimated(length(seq_start))

data <- map_dfr(seq_start, getData_progress)

#------------------
#for >10000 records, do per 10000
seq_start <- seq(0, count_seq, 100)

#seq_start_x <- seq_start[101:150] 
seq_start_x <- seq_start[151:length(seq_start)]
pb <- progress_estimated(length(seq_start_x))

data_x <- map_dfr(seq_start_x, getData_progress)

rm(pb,seq_start_x)

#TEMP
data_check <- data_x %>%
  distinct() %>%
  nrow()

#initialize or read object 'data'
#data <- data_x
#data <- read_csv("data/data.csv",
#                 col_types = cols(pmc_live_date = col_character()))

data <- bind_rows(data, data_x)


#write to file for temporary storage/backup
write_csv(data, "data/data.csv")
rm(data_x, data_check)

#--------------------------------------

#write data to file
filename = paste0("data/",date,"/PMC_",query_name,"_",date,".csv")
write_csv(data, filename)

#store web_history

list_name <- paste0(query_name,"_",date)
#for ELS and SN, adjust manually for now
list_name <- paste0(query_name,"_PMC2022_",date)

web_history_element <- list(collection = query_name,
                            web_history = entrez_history,
                            date = date,
                            count = count)

web_history[[list_name]] <- c(web_history[[list_name]], 
                             web_history_element)

filename = paste0("data/web_history_",
                  date,
                  ".RDS")
saveRDS(web_history, filename)

#remove files
rm(query_name, query, res, count, entrez_history,
   count_seq, seq_start, pb, data, filename,
   list_name, web_history_element)

#remove temporary data file when used 
unlink("data/data.csv", recursive = FALSE)

