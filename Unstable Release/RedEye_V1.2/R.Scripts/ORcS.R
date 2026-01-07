run_orcs <- function(input_path, orcs_outdir) {
  py_install(c("openpyxl", "xlrd"), pip = TRUE)
  source_python(ORcS_source)
  
  # Pass the **full path** to Python
  orcs_strip(
    input_dir     = input_path,
    output_subdir = orcs_outdir,
    extract_col   = as.integer(0),
    skip_top_rows = as.integer(2),
    rows_to_skip  = NULL,
    cols_to_skip  = as.integer(c(0,1,2,4,5,6,7,8,9,10))
  )
  
  # Return all CSVs written to that folder
  list.files(orcs_outdir, pattern = "\\.csv$", full.names = TRUE)
}

# If only you knew how much pain this module in particular caused me during integration 
