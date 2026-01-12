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

input_path  <- "/Users/awsms1/Downloads/RedEye_v.1.13 testbed"
output_path <- "/Users/awsms1/Downloads/RedEye_v.1.13 testbed/output"
use_orcs    <- TRUE

if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)

SCRIPTS_ROOT <- normalizePath("/Users/awsms1/Downloads/RedEye_V1.2/Scripts")
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



