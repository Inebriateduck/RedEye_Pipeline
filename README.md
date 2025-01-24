# Automated-Contact-scraping
### This is still actively under development - currently working on merging Scraper and Hex-breaker into a unified pipeline.
**Scraper** is R script is designed to mine target PMIDs for data. It is designed to be easily scalable with the capabilities of the users hardware - the more CPU cores you have, the faster you'll be able to mine your target information from a list of PMIDs. It incorporates R.Utils as well as 2 other redundant failsafes in case the program runs into a issue when processing a target PMID, as well as post-extraction renaming to allow automation.  

Post extraction renaming assumes that the input files follow the following naming format: PMIDs_PRAttitudesofAIC_XXXX-XXXX_MMMDDYYXY where XY = initials. This section is not strictly necessary for the code to function and can be replaced with a different function to simply rename the file as an output of the target file. 
                    
  To do so, replace:   
  
                       # Remove "PMIDs_" and date/initials suffix from the base file name
                       base_name <- sub("^PMIDs_", "", file_base_name)
                       base_name <- sub("_Nov.*", "", base_name)
     
                       # Generate the new output file name
                       current_date <- format(Sys.Date(), "%b%d%y") # Get current date in MMMDDYY format
                       first_initial <- "D"  # Replace with your first initial
                       last_initial <- "F"   # Replace with your last initial
                       output_file <- file.path(output_path, paste0(
                       "PMID_Output_", base_name, "_", current_date, first_initial, last_initial, ".csv"
                       ))


With:                 
                
                       # Generate a default output file name using the input file base name
                       output_file <- file.path(output_path, paste0(file_base_name, "_output.csv"))
    
**Hex-Breaker** is a python script that allows cleanup and merging of the output files from **Scraper**. **Hex-Breaker** works by iterating through each file in a target folder and scanning for hex code outputs that often replace special characters, then translates them into their corresponding character and highlights the corrected cell. Finally, the program merges the individual CSV output files from **Scraper** into a single file.
