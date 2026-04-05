![Header](./RedEye_Banner.png)

# Overview
RedEye is a data scraping pipeline intended for use in cross sectional surveys by users with limited programming expertise. It is designed to rapidly extract author-linked metadata (ie; emails, institutions, etc...) from a list of provided PMIDs or an OVID output file. RedEye is designed with scalability in mind, employing aggressive multithreading to enable extremely rapid extractions of metadata - at default settings this is n-1 cores, where n is the number of threads available in the system, but this can be modified at will. 

#### Please cite this repository if you use the software within
```
Fry, D., Al-Khafaji, W. RedEye Pipeline [Software]. (V1.0). Toronto: Daniel Fry (2025). [Accession date] Retrieved from https://github.com/Inebriateduck/RedEye_Pipeline
DOI: 10.5281/zenodo.16996504
```

## Pre-requisites

Ensure that you have [R](https://www.r-project.org/), [R studio](https://posit.co/download/rstudio-desktop/) and [Python](https://www.python.org/) installed on your machine

## Using the pipeline

1. Download [RedEye.zip](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Stable%20Release/V1.2/RedEye_V1.2.zip)
2. Unzip the file
3. Open R studio and install the RedEye package by doing the following: ```Tools > Install Packages > Package Archive File > RedEye.tar.gz```
4. Once installed, RedEye can be loaded in R usinfg the command ```library(RedEye)``` and uses identical functions as the easyPubMed package.
5. Open ```Extraction_Script.R```
6. Run line 2 of the script to install all requisite packages
7. Replace ```'/Input/path/here'``` with the pathway to your folder containing your OVID files or PMID list(s) (PMID lists must be in CSV format)
8. Replace ```'Output pathway'``` with your desired output directory. If the specified file does not exist, RedEye will make a new file with that name at the target location
9. Replace ```'/Path/to/RedEye_V1.2/R.Scripts'``` with the path the the ```R.Scripts``` subfolder in the ```RedEye_V1.2``` folder
10. Run the script (Ctrl + Shift + Enter)

# Technical notes
## Pipeline 
![](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Stable%20Release/V1.2/RedEye_V1.2.flowchart.png)

## Pipeline Components
### OVID recursive Scraper (ORcS)
ORcS is an optional module upstream of the main extraction loop. and provides functionality required to extract metadata directly from OVID output files in XLS format. ORcS processes the OVID files to extract a list of PMIDs that is then fed into RedEye.R module of the pipeline for data extraction. 

### RedEye.R
**RedEye.R** is an R package based on easyPubMed by [Damiano Fantini](https://cran.r-project.org/web/packages/easyPubMed/index.html). It contains greedier regular expressions optimized towards the extraction of email addresses from provided PMIDs. RedEye.R is not available through CRAN and must be manually installed through the tar.gz file found in this repo or the RedEye V1.2 .zip file.

### HexBreaker
HexBreaker is a module downstream of RedEye.R - as RedEye.R cannot process certain characters, it outputs them as UTF-8 hex code. HexBreaker converts these back into their respective characters to clean up the output. Additionally, this module concatenates all output files into a single master sheet, then searches for duplicate email addresses. To prevent researchers from accidentally spamming potential survey participants when using metadata derived via RedEye in downstream surveys, only the email linked to the most recent publication is conserved, with all others removed from the final output. 

### Email check
The final module in the pipeline uses PyisEmail to verify that the remaining emails are valid. Invalid emails are removed from the master sheet. 

#### This is still actively under development - It is developed as a volunteer project when I have time (updates may be sporadic)
**All code Licensed under GPL-2**

C. Daniel Fry, 2025
