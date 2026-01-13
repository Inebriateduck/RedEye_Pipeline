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

input_path  <- "Input folder path" #<---- Path to input folder (OVID files must be .XLS, PMID lists must be .CSV)
output_path <- "Output folder Path" #<---- Path to your desired output folder (If it doesn't exist, RedEye will make it)
use_orcs    <- FALSE #<---- ORcS toggle - if you are using a PMID list instead of an OVID file, change to FALSE

if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)

SCRIPTS_ROOT <- normalizePath("Path to scripts here") #<----- Path to scripts folder (can be found in the unzipped RedEye folder)
assign("SCRIPTS_ROOT", SCRIPTS_ROOT, envir = .GlobalEnv)

r_files <- list.files(path = SCRIPTS_ROOT, pattern = "\\.[Rr]$", full.names = TRUE)
invisible(lapply(r_files, source))

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@ Function calls (Modify at your own risk) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
paths <- build_output_paths(input_path, output_path)
ORcS_source        <- file.path(SCRIPTS_ROOT, "ORcS.py")
Hex_Breaker_source <- file.path(SCRIPTS_ROOT, "Hex_breaker.py")
Email_check_source <- file.path(SCRIPTS_ROOT, "Email_check.py")

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



