## This tutorial will teach you how to run RedEye on different input data types

### Pre-requisites

Ensure that you have [R](https://www.r-project.org/), [R studio](https://posit.co/download/rstudio-desktop/) and [Python](https://www.python.org/) installed on your machine

### Data Types

RedEye accepts both manually compiled lists of PMIDs and direct output files from OVID. If using a manually compiled list ensure that it is in csv format. 

### Using the pipeline on test data

1. Download [RedEye.zip](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Stable%20Release/V1.2/RedEye_V1.2.zip)
2. Unzip the folder. You should see the following files:
    ```
   Scripts
   Test_set
   Director.R
   Launcher.R
   RedEye_0.1.0.tar.gz
     ```
3. Open R studio and install the RedEye package by doing the following: ```Tools > Install Packages > Package Archive File > RedEye.tar.gz```
4. Once installed, RedEye can be loaded in R using the command ```library(RedEye)``` and uses identical functions as the easyPubMed package.
5. Navigate back to your unzipped RedEye folder. In the Test_set folder there should be 2 subfolders
   ```
   OVID_Test_Input
   PMID_Test_Input
   ```
7. Copy the directory path to ```OVID_Test_Input```
8. Open ```Launcher.R```
9. Replace ```'/Input/path/here'``` with the pathway to ```OVID_Test_Input```
10. Replace ```'Output pathway'``` with your desired output directory. If it does not exist, RedEye will make it. This will be where all your data is dumped.
11. Set the line ```SYKO <- FALSE``` to ```SYKO <- TRUE```
12. Run the launcher script (Ctrl + Shift + Enter)
13. Once the script finishes, your final list of metadata will be stored as follows:
  ```
├───Final_Output
|             └─── PMID_Data_ULTRA_Output_2026-05-19_23-25-06_validated
└───Interim_Data
    ├───PMID_Data
    ├───SYKO
    └───ULTRA
  ```
13. The file stored under Final_Ouput is your validated and cleaned output. Interim files will be stored under the remaining subdirectories.
14. If you would like to run raw lists of PMIDs (ie, from manual extractions), simply leave the value of ```SYKO``` as ```FALSE``` 

