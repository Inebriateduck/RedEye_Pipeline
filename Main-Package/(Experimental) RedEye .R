# Load required packages
library(R.utils)
library(RedEye)
library(readr)
library(future.apply)
library(data.table)
library(parallel)

# Set input and output directories
input_path <- "C:/Users/awsms/Downloads/Truncation test"     # ← Change this to your input directory
output_path <- "C:/Users/awsms/Downloads/Truncation test"   # ← Change this to your output directory

if (!dir.exists(output_path)) {
  dir.create(output_path)
}

# List all input CSV files
input_files <- list.files(input_path, pattern = "\\.csv$", full.names = TRUE)

# Function to process a batch of PMIDs with timeout and debugging
process_pmids_batch <- function(pmids) {
  print(paste("Processing batch of PMIDs:", paste(pmids, collapse = ", ")))
  myquery <- paste(paste(pmids, '[PMID]', sep = ""), collapse = " OR ")

  pubmedID <- tryCatch({
    withTimeout({
      print("Fetching PubMed IDs...")
      get_pubmed_ids(myquery)
    }, timeout = 25, onTimeout = "error")
  }, error = function(e) {
    print(paste("Timeout or error for PMIDs:", paste(pmids, collapse = ", ")))
    print(paste("Error message:", e$message))
    return(NULL)
  })

  if (is.null(pubmedID)) {
    print(paste("No PubMed ID for PMIDs:", paste(pmids, collapse = ", ")))
    return(NULL)
  }

  print(paste("PubMed IDs fetched:", paste(pubmedID, collapse = ", ")))

  abstractXML <- fetch_pubmed_data(pubmedID)
  if (is.null(abstractXML) || length(abstractXML) == 0) {
    print(paste("No abstract data for PubMed IDs:", paste(pmids, collapse = ", ")))
    return(NULL)
  }

  print(paste("Raw XML data for PMIDs:", paste(pmids, collapse = ", ")))
  print(abstractXML)

  abstractlist <- articles_to_list(abstractXML)
  if (length(abstractlist) == 0) {
    print(paste("No articles found for PubMed IDs:", paste(pmids, collapse = ", ")))
    return(NULL)
  }

  print(paste("Articles list for PMIDs:", paste(pmids, collapse = ", ")))
  print(abstractlist)

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

  # Parallel batch processing
  plan(multisession, workers = detectCores() - 1)
  batch_size <- 100
  pmid_batches <- split(pmids, ceiling(seq_along(pmids) / batch_size))

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
    dfoutput <- rbindlist(valid_results, fill = TRUE)
  }

  # Naming the output file
  current_date <- format(Sys.Date(), "%b%d%y")  # e.g., May3125
  first_initial <- 'X'  # Replace with your first initial
  last_initial <- 'Y'   # Replace with your last initial
  name_denom <- sub("^PMIDs_([A-Za-z0-9]+_[A-Za-z0-9]+)_.*", "\\1", file_base_name)

  output_file <- file.path(
    output_path,
    paste0("OUTPUT_", name_denom, "_", current_date, first_initial, last_initial, ".csv")
  )

  print(paste("Saving output to:", output_file))
  fwrite(dfoutput, output_file)
  print(paste("Saved output to:", output_file))
}

