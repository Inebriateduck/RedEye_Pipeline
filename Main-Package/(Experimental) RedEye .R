# Uncomment line below if you need to install packages (RedEye needs a manual install)
# install.packages(setdiff(c("R.utils", "readr", "future.apply", "data.table", "progressr"), rownames(installed.packages())))

library(R.utils)      
library(RedEye)   
library(readr)        
library(future.apply) 
library(data.table)   
library(parallel)
library(progressr)

input_path <- 'C:/Users/awsms/Downloads/JT_test/RedEye test run'  # Directory containing input CSV files 
output_path <- 'C:/Users/awsms/Downloads/JT_test/RedEye test run'  # Directory to save output files

if (!dir.exists(output_path)) {
  dir.create(output_path)
}

input_files <- list.files(input_path, pattern = "\\.csv$", full.names = TRUE)

# PMID timeout processing
process_pmids_batch <- function(pmids) {
  print(paste("Processing batch of PMIDs:", paste(pmids, collapse = ", ")))  # Debugging line
  myquery <- paste(paste(pmids, '[PMID]', sep = ""), collapse = " OR ")
  
  # Fetch PubMed data for PMIDs
  pubmedID <- tryCatch({
    withTimeout({
      get_pubmed_ids(myquery)  # Fetch PubMed IDs
    }, timeout = 25, onTimeout = "error")  # Timeout set to 25 seconds
  }, error = function(e) {
    print(paste("Timeout or error for PMIDs:", paste(pmids, collapse = ", ")))  # Debugging line
    return(NULL)  # Return NULL if an error occurs
  })
  
  if (is.null(pubmedID)) {
    print(paste("No PubMed ID for PMIDs:", paste(pmids, collapse = ", ")))  # Debugging line
    return(NULL)
  }
  
  abstractXML <- fetch_pubmed_data(pubmedID)
  if (is.null(abstractXML) || length(abstractXML) == 0) {
    print(paste("No abstract data for PubMed IDs:", paste(pmids, collapse = ", ")))  # Debugging line
    return(NULL)
  }
  
  abstractlist <- articles_to_list(abstractXML)
  if (length(abstractlist) == 0) {
    print(paste("No articles found for PubMed IDs:", paste(pmids, collapse = ", ")))  # Debugging line
    return(NULL)
  }
  
  df_list <- lapply(abstractlist, function(article) {
    article_to_df(pubmedArticle = article, autofill = TRUE, max_chars = 10)
  })
  
  return(df_list)
}

# Process each input file
for (input_file in input_files) {
  file_base_name <- tools::file_path_sans_ext(basename(input_file))  
  df <- read_csv(input_file, col_names = FALSE)  
  
  print(paste("Processing file:", input_file))
  
  dfoutput <- data.table(
    pmid = character(), doi = character(), title = character(),
    abstract = character(), year = character(), month = character(),
    day = character(), jabbrv = character(), journal = character(),
    keywords = character(), lastname = character(), firstname = character(),
    affiliation = character(), email = character(),
    stringsAsFactors = FALSE
  )
  
  pmids <- df[[1]]  # Assumes PMIDs are in the first column
  
  # Parallel processing using future_lapply for batch processing
  plan(multisession, workers = detectCores() - 1)  # Adjust based on your system
  
  batch_size <- 100
  pmid_batches <- split(pmids, ceiling(seq_along(pmids) / batch_size))
  
  # Set up progress bar
  handlers(global = TRUE)
  handlers("txtprogressbar")  # Use "rstudio" for RStudio visual progress
  
  with_progress({
    p <- progressor(along = pmid_batches)
    
    results <- future_lapply(pmid_batches, function(batch_pmids) {
      p()  # Advance progress bar
      tryCatch({
        process_pmids_batch(batch_pmids)
      }, error = function(e) {
        message("Error processing batch of PMIDs: ", e$message)
        return(NULL)
      })
    }, future.seed = TRUE) 
  })
  
  valid_results <- unlist(results, recursive = FALSE)
  valid_results <- valid_results[!sapply(valid_results, is.null)]
  
  if (length(valid_results) > 0) {
    dfoutput <- rbindlist(valid_results, fill = TRUE)
  }
  
  current_date <- format(Sys.Date(), "%b%d%y")
  first_initial <- 'D'
  last_initial <- 'F'
  name_denom <- sub("^PMIDs_([A-Za-z0-9]+_[A-Za-z0-9]+)_.*", "\\1", file_base_name)
  
  output_file <- file.path(
    output_path,
    paste0("OUTPUT_", name_denom, "_", current_date, first_initial, last_initial, ".csv")
  )
  
  print(paste("Saving output to:", output_file))  
  fwrite(dfoutput, output_file)
  print(paste("Saved output to:", output_file))  
}

# Daniel Fry, 2024
