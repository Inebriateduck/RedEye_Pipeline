# Automated-Contact-scraping pipeline
### This is still actively under development - It is developed as a volunteer project when I have time (updates may be sporadic, but it is still under active development)
### For citation information see Citation.cff

## Scraper.R 
**Scraper** is an R script is designed to mine target PMIDs for data. It is designed to be easily scalable with the capabilities of the users hardware - the more CPU cores you have, the faster you'll be able to mine your target information from a list of PMIDs. It incorporates R.Utils as well as 2 other redundant failsafes in case the program runs into a issue when processing a target PMID, as well as automated post-extraction renaming to identify output file batches. 

### Running Scraper
1. Load the Scraper.R script into your R instance
2. On line 15, replace 'Input pathway' with your desired input *folder* pathway.
3. on line 16, replace 'Output pathway' with your desired output *folder* pathway. 

   *Note: pathways must use forward, not backslashes. If you have copied the pathway from a windows directory, replace the backslashes*
5. On lines 110 and 111, input the desired first and last initials
6. On line 114, replace the "PMIDs_" with where you would like to begin naming the output file (This function preserves the base name of the file and adds a date to the output)
7. Run the script (My preferred shortcut is Ctrl + Shift + Enter)
8. The output files will be dumped in the designated output *folder* as individual files corresponding to each file processed.

*Note: Scraper assumes that the target PMIDs are located in the first column of the target CSV files. If they are not, you can enter the correct column on line 81 at "df[[1]]" (replace the 1 with the correct value)*

## Hex-Breaker.Py
**Hex-Breaker** is a python script that allows partial cleanup and merging of the output files from **Scraper**. **Hex-Breaker** works by iterating through each file in a target folder and scanning for hex code outputs that often replace special characters, then translates them into their corresponding character and highlights the corrected cell. Finally, the program merges the individual CSV output files from **Scraper** into a single file.
