# Install and load necessary packages (uncomment if not installed)
# install.packages("R.utils")
# install.packages("readr")
# install.packages("easyPubMed")
# install.packages("future.apply")
# install.packages("data.table")

library(R.utils)      
library(easyPubMed)   
library(readr)        
library(future.apply) 
library(data.table)   
library(parallel)

input_path <- 'Input pathway'  # Directory containing input CSV files 
output_path <- 'Output pathway'  # Directory to save output files

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
    return(NULL)  # Skip if fetching PubMed IDs fails
  }
  
  # Fetch abstracts
  abstractXML <- fetch_pubmed_data(pubmedID)
  if (is.null(abstractXML) || length(abstractXML) == 0) {
    print(paste("No abstract data for PubMed IDs:", paste(pmids, collapse = ", ")))  # Debugging line
    return(NULL)  # Skip if no data is fetched
  }
  
  # Convert XML data to a list of articles
  abstractlist <- articles_to_list(abstractXML)
  if (length(abstractlist) == 0) {
    print(paste("No articles found for PubMed IDs:", paste(pmids, collapse = ", ")))  # Debugging line
    return(NULL)  # Skip if no articles are found
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
  
  # Splits the PMIDs into batches for faster processing
  batch_size <- 100  # Process 100 PMIDs at a time
  pmid_batches <- split(pmids, ceiling(seq_along(pmids) / batch_size))
  
  # Processes all batches in parallel
  results <- future_lapply(pmid_batches, function(batch_pmids) {
    tryCatch({
      process_pmids_batch(batch_pmids)
    }, error = function(e) {
      message("Error processing batch of PMIDs: ", e$message)
      return(NULL)
    })
  }, future.seed = TRUE) 
  
  valid_results <- unlist(results, recursive = FALSE)
  valid_results <- valid_results[!sapply(valid_results, is.null)]
  
  if (length(valid_results) > 0) {
    # Bind all data frames from each batch into one final output
    dfoutput <- rbindlist(valid_results, fill = TRUE)
  }
  
  # Generate new output file name: replace PMIDs_ and truncate after second underscore
  current_date <- format(Sys.Date(), "%b%d%y")  # e.g., May3125
  first_initial <- 'X'  # Replace with your first initial
  last_initial <- 'Y'   # Replace with your last initial
  
  # Extract NAME_DENOMINATOR part only
  name_denom <- sub("^PMIDs_([A-Za-z0-9]+_[A-Za-z0-9]+)_.*", "\\1", file_base_name) #Replace "PMIDs" with where you want to start file renaming
  
  output_file <- file.path(
    output_path,
    paste0("OUTPUT_", name_denom, "_", current_date, first_initial, last_initial, ".csv")
  )
  
  # Saves the output to a CSV file
  print(paste("Saving output to:", output_file))  
  fwrite(dfoutput, output_file)
  print(paste("Saved output to:", output_file))  
}

# Daniel Fry, 2024
