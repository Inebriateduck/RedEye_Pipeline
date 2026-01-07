run_pmids <- function(input, pmid_outdir) {
  
  # Determine input files
  if (dir.exists(input)) {
    files <- list.files(input, pattern = "\\.csv$", full.names = TRUE)
  } else {
    files <- input
  }
  
  plan(multisession, workers = detectCores() - 1)
  handlers(global = TRUE)
  handlers("txtprogressbar")
  
  for (file in files) {
    df <- read_csv(file, col_names = FALSE)
    pmids <- df[[1]]
    
    batches <- split(pmids, ceiling(seq_along(pmids) / 100))
    
    results <- with_progress({
      p <- progressor(along = batches)
      future_lapply(batches, function(b) {
        out <- process_pmids_batch(b)
        p()
        out
      }, future.seed = TRUE)
    })
    
    valid <- unlist(results, recursive = FALSE)
    valid <- valid[!sapply(valid, is.null)]
    
    if (length(valid) > 0) {
      out_file <- file.path(pmid_outdir, basename(file))
      fwrite(rbindlist(valid, fill = TRUE), out_file)
    }
  }
}

