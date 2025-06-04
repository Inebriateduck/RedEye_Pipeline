# Automated-Contact-scraping pipeline
### This is still actively under development - It is developed as a volunteer project when I have time (updates may be sporadic, but it is still under active development)
### For citation information see Citation.cff

## RedEye
**RedEye** is an R package based on easyPubMed by Damiano Fantini (https://cran.r-project.org/web/packages/easyPubMed/index.html). It contains a modified email identification regex, allowing it to more effectively extract author email addresses from the PubMed database.

*For RedEye specific citation, please see the .cff file in the RedEye folder*
 
### installation
RedEye is not available through CRAN - installation must be performed manually. 

After downloading RedEye.tar.gz, open R and do the following Tools > Install Packages > Package Archive File > RedEye.tar.gz. 

### Using RedEye
Once installed, RedEye can be loaded in R and uses identical functions as easyPubMed. 

A specialized script for extraction of information for cross sectional surveys from the PubMed database is available in (directory TBD). This script is designed to be easily scalable with the capabilities of the users hardware - the more CPU cores you have, the faster you'll be able to mine your target information from a list of PMIDs. 

To run the script: 
1. Load the script into your R instance
2. On line 15, replace 'Input pathway' with your desired input *folder* pathway.
3. on line 16, replace 'Output pathway' with your desired output *folder* pathway.
4. On lines 110 and 111, input the desired first and last initials
5. On line 114, replace the "PMIDs_" with where you would like to begin naming the output file (This function preserves the base name of the file and adds a date to the output)
6.  Run the script (My preferred shortcut is Ctrl + Shift + Enter)
7. The output files will be dumped in the designated output *folder* as individual files corresponding to each file processed.

*Note: The script assumes that the target PMIDs are located in the first column of the target CSV files. If they are not, you can enter the correct column on line 81 at "df[[1]]" (replace the 1 with the correct value)*

## Hex-Breaker.Py
**Hex-Breaker** is a python script that allows partial cleanup and merging of the output files from **RedEye**. **Hex-Breaker** works by iterating through each file in a target folder and scanning for hex code outputs that often replace special characters, then translates them into their corresponding character and highlights the corrected cell. Finally, the program merges the individual CSV output files from **RedEye** into a single file.


**All code Licensed under GPL-2**

C. Daniel Fry, 2025
