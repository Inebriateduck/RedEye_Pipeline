# Your target files MUST be CSV files. RedEye cannot read XLS / XLSX files
# Run line 2 to install the required packages (Red eye needs manual install)
# install.packages(c("R.utils", "readr", "future.apply", "data.table", "progressr", "reticulate"))

library(R.utils)      
library(RedEye)   
library(readr)        
library(future.apply) 
library(data.table)   
library(parallel)
library(progressr)
library(reticulate)

input_path <- 'input directory'  
output_path <- 'output directory'  

if (!dir.exists(output_path)) {
  dir.create(output_path)
}

input_files <- list.files(input_path, pattern = "\\.csv$", full.names = TRUE)

# ---- PMIDs ----
process_pmids_batch <- function(pmids) {
  print(paste("Processing batch of PMIDs:", paste(pmids, collapse = ", ")))  
  myquery <- paste(paste(pmids, '[PMID]', sep = ""), collapse = " OR ")
  
  pubmedID <- tryCatch({
    withTimeout({
      get_pubmed_ids(myquery) 
    }, timeout = 25, onTimeout = "error")  
  }, error = function(e) {
    print(paste("Timeout or error for PMIDs:", paste(pmids, collapse = ", "))) 
    return(NULL)  
  })
  
  if (is.null(pubmedID)) return(NULL)
  
  abstractXML <- fetch_pubmed_data(pubmedID)
  if (is.null(abstractXML) || length(abstractXML) == 0) return(NULL)
  
  abstractlist <- articles_to_list(abstractXML)
  if (length(abstractlist) == 0) return(NULL)
  
  df_list <- lapply(abstractlist, function(article) {
    article_to_df(pubmedArticle = article, autofill = TRUE, max_chars = 10)
  })
  
  return(df_list)
}

# ---- Data extraction ----
for (input_file in input_files) {
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
  
  pmids <- df[[1]]  
  total_pmids <- length(pmids)
  failed_pmids_count <- 0       
  
  plan(multisession, workers = detectCores() - 1)
  
  batch_size <- 100
  pmid_batches <- split(pmids, ceiling(seq_along(pmids) / batch_size))
  
  handlers(global = TRUE)
  handlers("txtprogressbar")
  
  results <- with_progress({
    p <- progressor(along = pmid_batches)
    
    future_lapply(pmid_batches, function(batch_pmids) {
      tryCatch({
        out <- process_pmids_batch(batch_pmids)
        p()
        out
      }, error = function(e) {
        message("Error processing batch of PMIDs: ", e$message)
        p()
        NULL
      })
    }, future.seed = TRUE)
  })
  
  for (i in seq_along(results)) {
    if (is.null(results[[i]])) failed_pmids_count <- failed_pmids_count + length(pmid_batches[[i]])
  }
  
  valid_results <- unlist(results, recursive = FALSE)
  valid_results <- valid_results[!sapply(valid_results, is.null)]
  
  if (length(valid_results) > 0) dfoutput <- rbindlist(valid_results, fill = TRUE)
  
  # ---- Output & failures ----
  output_file <- file.path(output_path, basename(input_file))
  
  print(paste("Saving output to:", output_file))  
  fwrite(dfoutput, output_file)
  print(paste("Saved output to:", output_file))  
  
  print(paste0("Summary for file ", basename(input_file), ":"))
  print(paste("Total PMIDs:", total_pmids))
  print(paste("Failed PMIDs:", failed_pmids_count))
  print(paste("Successfully processed PMIDs:", total_pmids - failed_pmids_count))
}

# ---- Hex Breaker call ----
output_path <- normalizePath(output_path)
writeLines(output_path, "output_path.txt")

py_install(c("pandas", "openpyxl", "tqdm"))
source_python("/path/to/Hex_Breaker.py") #<--- replace with file path (includes file)

excel_file <- combine_and_process_csv_files(output_path)
cat("Final Excel file created at:", excel_file, "\n")

