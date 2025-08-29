# RedEye single shot pipeline (a very quick how to)

## Things to do before you start
1. Download the [RedEye](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Unstable%20Release/Single%20shot%20pipeline/Unstable%20extractor.R) package
2. Download [Hex Breaker](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Unstable%20Release/Single%20shot%20pipeline/HB%20unstable%20call%20version.py)
3. Ensure that your versions of R, R studio and python are up to date

## Using the pipeline
1. Open R studio and install the RedEye package by doing the following: Tools > Install Packages > Package Archive File > RedEye.tar.gz.
2. Create a new R script
3. Copy the [extraction script](https://github.com/Inebriateduck/RedEye_Pipeline/blob/main/Unstable%20Release/Single%20shot%20pipeline/Unstable%20extractor.R) into your new script section
4. Replace 'Input pathway' with the pathway to the *folder* containing your PMID bearing CSV files
5. Replace 'Output pathway' with your desired output directory. If the specified file does not exist, RedEye will make a new file with that name at the target location
6. Replace 'Python input' with the path to the Hex Breaker file (including the file itself, it should have .py at the end)
7. Run the script (Ctrl + Shift + Enter is a useful shortcut)

*Note: The script assumes that the target PMIDs are located in the first column of the target CSV files. If they are not, you can enter the correct column on line 81 at "df[[1]]" (replace the 1 with the correct value)*
