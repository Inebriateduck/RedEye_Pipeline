run_SYKO <- function(input_path, SYKO_outdir) {
  py_install(c("openpyxl", "xlrd"), pip = TRUE)
  source_python(file.path(SCRIPTS_ROOT, "SYKO.py"))
  
  SYKO_strip(
    input_dir     = input_path,
    output_subdir = SYKO_outdir,
    extract_col   = as.integer(0),
    skip_top_rows = as.integer(2),
    rows_to_skip  = NULL,
    cols_to_skip  = as.integer(c(0,1,2,4,5,6,7,8,9,10))
  )
  
  list.files(SYKO_outdir, pattern = "\\.csv$", full.names = TRUE)
}

# If only you knew how much pain this module in particular caused me during integration 

# SYKO was a cryptography tool used by UK forces in the second world war, just in case you're wondering where the name comes from
# I have literally 0 reason to name this module after apart from I thought it was cool and I was running with the cryptography theme after
# renaming hexbreaker to ULTRA (a WWII cryptography program)
