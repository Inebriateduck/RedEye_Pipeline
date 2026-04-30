# ---- RedEye Director ----
# Do not edit this script. Configure runs via launch.R only.

# ---- Resolve scripts root from director's own location ----
SCRIPTS_ROOT <- normalizePath(file.path(dirname(sys.frame(1)$ofile), "Scripts"))
assign("SCRIPTS_ROOT", SCRIPTS_ROOT, envir = .GlobalEnv)

# ---- Validate launcher variables ----
if (!exists("SYKO"))   stop("SYKO is not defined. Please set it in launch.R")
if (!exists("INPUT"))  stop("INPUT is not defined. Please set it in launch.R")
if (!exists("OUTPUT")) stop("OUTPUT is not defined. Please set it in launch.R")

if (!dir.exists(INPUT)) stop(paste("INPUT path does not exist:", INPUT))

# ---- Libraries ----
library(R.utils)
library(RedEye)
library(readr)
library(future.apply)
library(data.table)
library(parallel)
library(progressr)
library(reticulate)

# ---- Python script paths ----
SYKO_source        <- file.path(SCRIPTS_ROOT, "SYKO.py")
ULTRA_source <- file.path(SCRIPTS_ROOT, "ULTRA.py")
Email_check_source <- file.path(SCRIPTS_ROOT, "Email_check.py")

# ---- Source all R scripts in scripts folder ----
r_files <- list.files(path = SCRIPTS_ROOT, pattern = "\\.[Rr]$", full.names = TRUE)
r_files <- r_files[!grepl("director\\.R$", r_files)]  # exclude self
invisible(lapply(r_files, source))

# ---- Build output folder structure ----
if (!dir.exists(OUTPUT)) dir.create(OUTPUT, recursive = TRUE)
paths <- build_output_paths(INPUT, OUTPUT)

# ---- SYKO (conditional) ----
if (SYKO) {
  py_install(c("openpyxl", "xlrd"), pip = TRUE)
  SYKO_files <- run_SYKO(INPUT, paths$SYKO)
  pmid_input <- paths$SYKO
} else {
  pmid_input <- INPUT
}

# ---- PMID extraction ----
invisible(capture.output(run_pmids(pmid_input, paths$pmid)))

# ---- ULTRA ----
py_install(c("pandas", "openpyxl", "tqdm"), pip = TRUE)
ULTRA_excel <- run_ULTRA(paths$pmid, paths$ULTRA)

# ---- Email validation ----
py_install("pyIsEmail", pip = TRUE)
final_file <- run_email_validation(ULTRA_excel, paths$final)

message("Pipeline complete. Output: ", final_file)