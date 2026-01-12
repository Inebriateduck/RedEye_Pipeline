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

input_path  <- "/Path/to/input/folder" #<------ Directory to your input folder. Files must be .XLS format if ORcS = TRUE, otherwise they must be .CSV format
output_path <- "/Path/to/output/folder" #<------ Directory to your desired output folder. If it doesn't exist, RedEye will make it.
use_orcs    <- TRUE #<----- OVID file processing toggle. Change to FALSE if you're using a list of PMIDs instead of an OVID output.

if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)

SCRIPTS_ROOT <- normalizePath("/Path/to/RedEye_V1.2/Scripts") #<----- Directory to your scripts here
assign("SCRIPTS_ROOT", SCRIPTS_ROOT, envir = .GlobalEnv)




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



