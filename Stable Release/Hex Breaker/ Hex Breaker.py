# Note that you CANNOT have the target file open while running this script; doing so will result in an error
# Your output file will be dumped in the same folder as your inputs and be titled "HB output"
# Input files MUST be in CSV format!

import os
import re
import sys

required_packages = ['pandas', 'openpyxl', 'tqdm']

def check_package(package):
    try:
        __import__(package)
    except ImportError:
        print("\033[1;31m" + "="*50)  
        print(f"\033[1;31mERROR: Package '{package}' is missing!")
        print(f"\033[1;31mPlease install it using the following command:")
        print(f"\033[1;33mpip install {package}\033[1;31m")
        print("="*50 + "\033[0m")  
        sys.exit(1)

for package in required_packages:
    check_package(package)

import pandas as pd
from datetime import datetime
from tqdm import tqdm


def unicode_hex_to_char(text):
    """Replace HTML unicode codes like &#xNNNN; with actual characters."""
    if pd.isna(text):
        return text
    return re.sub(r'&#x([0-9a-fA-F]+);', lambda m: chr(int(m.group(1), 16)), str(text))


def combine_and_process_csv_files():
    input_folder = r'YOUR PATHWAY HERE (ie:/Users/inebriatedduck/Documents/RedEye_Target'
    output_file = os.path.join(
        input_folder,
        f"{os.path.basename(input_folder)}_HBOutput_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx"
    )

    csv_files = [f for f in os.listdir(input_folder) if f.endswith(".csv")]
    if not csv_files:
        print("No CSV files found.")
        return

    combined_df = pd.DataFrame()
    print("Reading and combining CSV files...")
    for file_name in tqdm(csv_files, desc="Reading CSVs", dynamic_ncols=True):
        file_path = os.path.join(input_folder, file_name)
        try:
            df = pd.read_csv(file_path, dtype=str)
            combined_df = pd.concat([combined_df, df], ignore_index=True)
        except Exception as e:
            tqdm.write(f"Skipping {file_name} due to error: {e}")

    if combined_df.empty:
        print("No valid data to write.")
        return

   
    combined_df.columns = combined_df.columns.str.strip().str.lower()

    if "email" not in combined_df.columns:
        print("No 'email' column found in the data. Aborting.")
        return

    combined_df = combined_df.applymap(unicode_hex_to_char)


    before_cleaning = len(combined_df)
    combined_df = combined_df[combined_df["email"].notna() & (combined_df["email"].str.strip() != "")]

    # Remove duplicate emails (keep first)
    combined_df = combined_df.drop_duplicates(subset="email", keep="first")
    after_cleaning = len(combined_df)
    print(f"Removed {before_cleaning - after_cleaning} rows with empty or duplicate emails.")

    print("Writing to Excel...")
    try:
        with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
            combined_df.to_excel(writer, sheet_name='Combined Data', index=False)
        print(f"Done. Output saved to: {output_file}")
    except Exception as e:
        print(f"Failed to save Excel file: {e}")


combine_and_process_csv_files()


#(C) Daniel Fry, 2025




