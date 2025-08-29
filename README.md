# RedEye data scraping pipeline
### Please cite this repository if you use the software within

#### This is still actively under development - It is developed as a volunteer project when I have time (updates may be sporadic, but it is still under active development)

## RedEye
**RedEye** is an R package based on easyPubMed by [Damiano Fantini](https://cran.r-project.org/web/packages/easyPubMed/index.html). It is optimized towards extraction of email addresses for the purpose of cross sectional surveys.
 
### installation
RedEye is not available through CRAN - installation must be performed manually. 

After downloading [RedEye.tar.gz](https://github.com/Inebriateduck/RedEye_Pipeline/tree/main/Stable%20Release/Single%20shot%20pipeline/RedEye), open R and do the following Tools > Install Packages > Package Archive File > RedEye.tar.gz. 

### RedEye Extractor & Hex Breaker
[RedEye Extractor](https://github.com/Inebriateduck/RedEye_Pipeline/tree/main/Stable%20Release/Single%20shot%20pipeline/RedEye) is a specialized script for extraction of information for cross sectional surveys from the PubMed database. This script is designed to be easily scalable with the capabilities of the users hardware - the more CPU cores you have, the faster you'll be able to mine your target information from a list of PMIDs. Note that this script only reads CSV files, it does not read XLSX format.

[Hex Breaker](https://github.com/Inebriateduck/RedEye_Pipeline/tree/main/Stable%20Release/Single%20shot%20pipeline/Hex%20Breaker) is the second step in the pipeline, and is automatically called by the R script using the reticulate package once it has completed it's portion of the job. It is a python script that removes duplicate values (ie: email addresses) and cleans up scrambled outputs that are known to relpace special characters. When removing duplicate emails, Hex Breaker will maintain the most recent instance of the address (for example, one found in 2024 will be removed in favour of one from 2025). 

## Using the pipeline

1. Ensure that you have [R](https://www.r-project.org/), [R studio](https://posit.co/download/rstudio-desktop/) and [Python](https://www.python.org/) installed on your machine
2. Download [RedEye Extractor](https://github.com/Inebriateduck/RedEye_Pipeline/tree/main/Stable%20Release/Single%20shot%20pipeline/RedEye)
3. Open R studio and install the RedEye package by doing the following: Tools > Install Packages > Package Archive File > RedEye.tar.gz.
4. Once installed, RedEye can be loaded in R and uses identical functions as easyPubMed.
5. Download [Hex Breaker](https://github.com/Inebriateduck/RedEye_Pipeline/tree/main/Stable%20Release/Single%20shot%20pipeline/Hex%20Breaker). Take note of the download path, it will be required later.
6. Create a new R script
7. Copy the [extraction script](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Unstable%20Release/Single%20shot%20pipeline/Unstable%20extractor.R) into your new script section
8. Replace 'Input pathway' with the pathway to the *folder* containing your PMID bearing CSV files
9. Replace 'Output pathway' with your desired output directory. If the specified file does not exist, RedEye will make a new file with that name at the target location
10. Replace 'Python input' with the path to the Hex Breaker file (including the file itself, it should have .py at the end)
11. Run the script (Ctrl + Shift + Enter is a useful shortcut)

**All code Licensed under GPL-2**

C. Daniel Fry, 2025
