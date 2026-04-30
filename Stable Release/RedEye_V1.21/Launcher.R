# ---- RedEye Launcher Script --------- #


INPUT      <- "/Path/to/input/folder"     #<-- Path to your input directory
OUTPUT     <- "/Path/to/output/folder"    #<-- Your desired output folder
SYKO       <- FALSE                       #<-- if directly inputting an OVID dataset, set to TRUE
BATCH_SIZE <- 100                         #<-- number of PMIDS processed in each batch
CORES      <- parallel::detectCores() - 1 #<-- number of cores used by RedEye

#================================================================================================#
#===== First time running RedEye? Run the command below to install required CRAN packages ======#
#================================================================================================#

#install.packages(c("R.utils", "data.table", "future.apply", "progressr", "readr", "reticulate"))

library(R.utils)
library(data.table)
library(future.apply)
library(parallel)
library(progressr)
library(readr)
library(reticulate)
library(RedEye)

#==============================================================================#
#========================# Sourcing - Don't touch!!!! =========================#
#==============================================================================#

source(file.path(dirname(normalizePath(sys.frames()[[1]]$ofile)), "Director.R"))

# Daniel Fry 2026
# If you use this pipeline please cite it as:
# Fry, D. & Al Zahraa, W. RedEye pipeline (2025). DOI: 10.5281/zenodo.16996503
