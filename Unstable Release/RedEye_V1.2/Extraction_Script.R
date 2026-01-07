# Run line 2 to install the required packages (the RedEye package needs to be manually installed)
# install.packages(c("R.utils", "readr", "future.apply", "data.table", "progressr", "reticulate"))
library(R.utils)
library(RedEye)
library(readr)
library(future.apply)
library(data.table)
library(parallel)
library(progressr)
library(reticulate)

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RedEye Config @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

input_path  <- '/Input/path/here'        #<---- your input directory here

output_path <- '/Output/path/here'       #<--- if your specified output doesn't exist, RedEye will create it :)

use_orcs    <- TRUE                      # TRUE = run ORcS, FALSE = skip (set to FALSE unless you're using an OVID output)

if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)

scripts_folder <- "/Path/to/RedEye_V1.2/R.Scripts"   #<---- Path to the R scripts folder in the RedEye folder

invisible(lapply(list.files(scripts_folder, pattern = "\\.R$", full.names = TRUE), source))


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@ Function calls (Modify at your own risk) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

paths <- build_output_paths(input_path, output_path)

# ---- ORcS ----
if (use_orcs) {
  py_install(c("openpyxl", "xlrd"), pip = TRUE)
  orcs_files <- run_orcs(input_path, paths$orcs)
  pmid_input <- paths$orcs
} else {
  pmid_input <- input_path
}

# ---- PMID extraction ----
run_pmids(pmid_input, paths$pmid)

# ---- HexBreaker ----
py_install(c("pandas", "openpyxl", "tqdm"), pip = TRUE)
hb_excel <- run_hex_breaker(paths$pmid, paths$hb)

# ---- Email validation ----
py_install(c("pyIsEmail"), pip = TRUE)
final_file <- run_email_validation(hb_excel, paths$final)

