import os
import pandas as pd
from openpyxl import load_workbook

def orcs_strip(
    input_dir,
    output_subdir="ORCS.out",
    extract_col=0,
    skip_top_rows=0,
    rows_to_skip=None,
    cols_to_skip=None
):
    """
    Extracts a column from Excel (.xls/.xlsx) or CSV files in input_dir,
    skipping a number of top rows and/or specific rows/columns,
    and writes output to a subdirectory.
    """
    outdir = os.path.join(input_dir, output_subdir)
    os.makedirs(outdir, exist_ok=True)
    
    for file in os.listdir(input_dir):
        file_lower = file.lower()
        infile = os.path.join(input_dir, file)
        
        try:
            # Try reading with pandas first (works for both .xls and .xlsx)
            if file_lower.endswith((".xls", ".xlsx")):
                # Use openpyxl engine for .xlsx, None for .xls (will try xlrd then others)
                engine = 'openpyxl' if file_lower.endswith('.xlsx') else None
                df = pd.read_excel(infile, header=None, engine=engine)
            elif file_lower.endswith(".csv"):
                df = pd.read_csv(infile, header=None)
            else:
                continue
                
        except Exception as e:
            print(f"ERROR reading '{file}': {e}")
            print("Attempting alternative read method...")
            
            # Fallback: read with openpyxl directly (ignores hyperlinks)
            try:
                wb = load_workbook(infile, data_only=True)
                ws = wb.active
                data = list(ws.values)
                df = pd.DataFrame(data)
            except Exception as e2:
                print(f"FAILED to read '{file}' with alternative method: {e2}")
                continue
        
        # Remove top rows
        if skip_top_rows > 0:
            df = df.iloc[skip_top_rows:, :]
        
        # Remove additional specific rows
        if rows_to_skip:
            df = df.drop(rows_to_skip, errors="ignore")
        
        # Remove specified columns
        if cols_to_skip:
            df = df.drop(columns=cols_to_skip, errors="ignore")
        
        # Extract target column
        if extract_col < df.shape[1]:
            extracted = df.iloc[:, [extract_col]]
        else:
            print(f"WARNING: File '{file}' only has {df.shape[1]} columns. Skipping.")
            continue
        
        # Construct output filename
        base = os.path.splitext(file)[0]
        outfile = os.path.join(outdir, f"{base}_ORCS.csv")
        extracted.to_csv(outfile, index=False, header=False)
        print(f"Saved: {outfile}")
    
    return outdir

