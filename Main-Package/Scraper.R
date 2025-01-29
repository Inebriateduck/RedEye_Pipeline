# Install and load necessary packages (uncomment if not installed)
# install.packages("R.utils")
# install.packages("readr")
# install.packages("easyPubMed")
# install.packages("future.apply")
# install.packages("data.table")

library(R.utils)      # Contains timeout handling function
library(easyPubMed)   # Accesses PubMed data
library(readr)        # Reads + writes CSV files
library(future.apply) # Optimized parallel processing
library(data.table)   # For fast data handling
library(parallel)

# Define input and output directories
input_path <- '[input path here]'  # Directory containing input CSV files
output_path <- '[output path here]'  # Directory to save output files

if (!dir.exists(output_path)) {
  dir.create(output_path)
}

# Get list of input CSV files from the input directory
input_files <- list.files(input_path, pattern = "\\.csv$", full.names = TRUE)

# PMID timeout processing to prevent hang-crash issues with faulty PMIDs
process_pmids_batch <- function(pmids) {
  print(paste("Processing batch of PMIDs:", paste(pmids, collapse = ", ")))  # Debugging line
  myquery <- paste(paste(pmids, '[PMID]', sep = ""), collapse = " OR ")

  # Fetch PubMed data for multiple PMIDs at once
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

  # Fetch abstracts for all PubMed IDs in the batch
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

  # Convert each article to a DataFrame
  df_list <- lapply(abstractlist, function(article) {
    article_to_df(pubmedArticle = article, autofill = TRUE, max_chars = 10)
  })
  
  return(df_list)
}

# Process each input file
for (input_file in input_files) {
  file_base_name <- tools::file_path_sans_ext(basename(input_file))  # Get the base name of the file
  df <- read_csv(input_file, col_names = FALSE)  # Read the input CSV file without headers

  print(paste("Processing file:", input_file))

  # Initialize the output DataFrame
  dfoutput <- data.table(
    pmid = character(), doi = character(), title = character(),
    abstract = character(), year = character(), month = character(),
    day = character(), jabbrv = character(), journal = character(),
    keywords = character(), lastname = character(), firstname = character(),
    affiliation = character(), email = character(),
    stringsAsFactors = FALSE
  )

  # Extract PMIDs from the CSV
  pmids <- df[[1]]  # Assuming PMIDs are in the first column

  # Parallel processing using future_lapply for batch processing
  plan(multisession, workers = detectCores() - 1)  # Adjust based on your system

  # Split the PMIDs into batches for faster processing
  batch_size <- 100  # Process 100 PMIDs at a time
  pmid_batches <- split(pmids, ceiling(seq_along(pmids) / batch_size))

  # Process all batches in parallel
  results <- future_lapply(pmid_batches, function(batch_pmids) {
    tryCatch({
      process_pmids_batch(batch_pmids)
    }, error = function(e) {
      message("Error processing batch of PMIDs: ", e$message)
      return(NULL)
    })
  }, future.seed = TRUE)  # Ensures randomness is consistent across workers

  # Combine results and filter out NULLs
  valid_results <- unlist(results, recursive = FALSE)
  valid_results <- valid_results[!sapply(valid_results, is.null)]

  if (length(valid_results) > 0) {
    # Bind all data frames from each batch into one final output
    dfoutput <- rbindlist(valid_results, fill = TRUE)
  }

  # Remove "PMIDs_" and date/initials suffix from the base file name
  base_name <- sub("^PMIDs_", "", file_base_name)
  base_name <- sub("_Nov.*", "", base_name)

  # Generate the new output file name
  current_date <- format(Sys.Date(), "%b%d%y")  # Get current date in MMMDDYY format
  first_initial <- 'X'  # Replace with your first initial
  last_initial <- 'Y'   # Replace with your last initial
  output_file <- file.path(output_path, paste0(
    "PMID_Output_", base_name, "_", current_date, first_initial, last_initial, ".csv"
  ))

  # Save the output DataFrame to a CSV file
  print(paste("Saving output to:", output_file))  # Debugging line
  fwrite(dfoutput, output_file)
  print(paste("Saved output to:", output_file))  # Debugging line
}

# Daniel Fry, 2024
