# RedEye data scraping pipeline
### Please cite this repository if you use the software within

#### This is still actively under development - It is developed as a volunteer project when I have time (updates may be sporadic, but it is still under active development)


## RedEye
**RedEye** is an R package based on easyPubMed by [Damiano Fantini](https://cran.r-project.org/web/packages/easyPubMed/index.html). It is optimized towards extraction of email addresses for the purpose of cross sectional surveys.

 
### installation
RedEye is not available through CRAN - installation must be performed manually. 

After downloading [RedEye.tar.gz](https://github.com/Inebriateduck/Automated-PMID-Scraping/blob/main/Main-Package/RedEye/RedEye_0.1.0.tar.gz), open R and do the following Tools > Install Packages > Package Archive File > RedEye.tar.gz. 

### Using RedEye
Once installed, RedEye can be loaded in R and uses identical functions as easyPubMed. 

A specialized script for extraction of information for cross sectional surveys from the PubMed database is available [here](https://github.com/Inebriateduck/Automated-PMID-Scraping/blob/main/Main-Package/RedEye/Extraction%20Script.R). This script is designed to be easily scalable with the capabilities of the users hardware - the more CPU cores you have, the faster you'll be able to mine your target information from a list of PMIDs. Note that this script only reads CSV files, it does not read XLSX format.

To run the script: 
1. Load the script into your R instance
2. Replace 'Input pathway' with your desired input *folder* pathway.
3. Replace 'Output pathway' with your desired output *folder* pathway.
4. Run the script (My preferred shortcut is Ctrl + Shift + Enter)
5. The output files will be dumped in the designated output *folder* as individual files corresponding to each file processed.

*Note: The script assumes that the target PMIDs are located in the first column of the target CSV files. If they are not, you can enter the correct column on line 81 at "df[[1]]" (replace the 1 with the correct value)*

## Hex-Breaker.Py
**Hex-Breaker** is the second step in the pipeline. It is a python script that removes duplicate values (ie: email addresses) and cleans up scrambled outputs that are known to relpace special characters. I am currently attemting to integrate it into **RedEye_Extractor** using Reticulate. 


**All code Licensed under GPL-2**

C. Daniel Fry, 2025
