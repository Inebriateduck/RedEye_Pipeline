# Automated-Contact-scraping

This is a heavily modified version of a contact information mining script coded by Phi-Yen Nguyen.
The R script has been modified to increase scalability by enabling automated processing of CSV files within a single folder as opposed to manuall processing files one by one. The R.Utils library has also been added to prevent the script from hanging when it encounters a faulty PMID, alongside redundant checks to ensure that there are articles and data contained within the target file / PMID. 

The script has also been modified to allow automated renaming of output files in a specific format. This process assumes that the input files follow the following naming format: PMIDs_PRAttitudesofAIC_XXXX-XXXX_MMMDDYYXY where XY = initials. This section is not strictly necessary for the code to function and can be replaced with a different function to simply rename the file as an output of the target file. 
                    
  To do so, replace:   
  
                       # Extract the base name of the input file, removing "PMIDs_" and any suffix with a date/initials
                       base_name <- sub("^PMIDs_", "", file_base_name)
                       base_name <- sub("_Nov.*", "", base_name)
     
                       # Generate the new output file name
                       current_date <- format(Sys.Date(), "%b%d%y") # Get current date in MMMDDYY format
                       first_initial <- "D"  # Replace with your first initial
                       last_initial <- "F"   # Replace with your last initial
                       output_file <- file.path(output_path, paste0(
                       "PMID_Output_", base_name, "_", current_date, first_initial, last_initial, ".csv"
                       ))
     
                       # Save the output DataFrame to a CSV file
                       write_csv(dfoutput, output_file)
                       print(paste("Saved output to:", output_file))

With:                 
                
                       # Generate a default output file name using the input file base name
                       output_file <- file.path(output_path, paste0(file_base_name, "_output.csv"))
     
                       # Save the output DataFrame to a CSV file
                       write_csv(dfoutput, output_file)
                       print(paste("Saved output to:", output_file))
