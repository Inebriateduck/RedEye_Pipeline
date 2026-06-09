![Header](./RedEye_Banner.png)

# Overview
RedEye is a metadata scraping pipeline for use in cross sectional surveys, and is designed with accessibility for users with limited programming expertise in mind. By leveraging multi-threading, it is able to rapidly extracted author linked metadata (ie; author emails, institutions, etc...) from a provided list of PMIDs or an OVID output file. Via these methods, the contact information of tens of thousands of authors can be extracted within minutes. To learn how to use RedEye, please see the attached [tutorial](RedEye_Tutorial.md)

#### Please cite this repository if you use the software within
```
Fry, D., Al-Khafaji, W. RedEye Pipeline [Software]. (V1.0). Toronto: Daniel Fry (2025). [Accession date] Retrieved from https://github.com/Inebriateduck/RedEye_Pipeline
10.5281/zenodo.16996503
```

# Technical notes
## Pipeline 
![](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Stable%20Release/V1.2/RedEye_V1.2.flowchart.png)

## Pipeline Components
### SYKO
SYKO is an optional module upstream of the main extraction loop. and provides functionality required to extract metadata directly from OVID output files in XLS format. SYKO processes the OVID files to extract a list of PMIDs that is then fed into RedEye.R module of the pipeline for data extraction. The module's name is derived from a British [cypher](https://en.wikipedia.org/wiki/Syko_Cipher_Device). 

### RedEye.R
**RedEye.R** is an R package based on easyPubMed by [Damiano Fantini](https://cran.r-project.org/web/packages/easyPubMed/index.html). It contains greedier regular expressions optimized towards the extraction of email addresses from provided PMIDs. RedEye.R is not available through CRAN and must be manually installed through the tar.gz file found in this repo or the RedEye V1.2 .zip file.

### ULTRA
ULTRA is a module downstream of RedEye.R - as RedEye.R cannot extract certain characters due to quirks in how PubMed stores data, it outputs them as UTF-8 hex code. ULTRA converts these back into their respective characters to clean up the output. Additionally, this module concatenates all output files into a single master sheet, then searches for duplicate email addresses. To prevent researchers from accidentally spamming potential survey participants when using metadata derived via RedEye in downstream surveys, only the email linked to the most recent publication is conserved, with all others removed from the final output. It's name is derived from a British codebreaking [program](https://en.wikipedia.org/wiki/Ultra_(cryptography))

### Email check
The final module in the pipeline uses PyisEmail to verify that the remaining emails are valid. Invalid emails are removed from the master sheet. 

#### This is still actively under development - It is developed as a volunteer project when I have time (updates may be sporadic)
**All code Licensed under GPL-2**

C. Daniel Fry, 2025
