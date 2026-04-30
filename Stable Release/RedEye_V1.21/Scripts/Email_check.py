#!/usr/bin/env python3
"""
Email Validator using pyIsEmail
Processes Excel file output from Hex_breaker and validates email addresses
"""

import pandas as pd
import sys
from pathlib import Path
from tqdm import tqdm

try:
    from pyisemail import is_email
except ImportError:
    print("Installing pyIsEmail...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pyIsEmail"])
    from pyisemail import is_email


def validate_emails(input_excel_path):
    """
    Validate email addresses in Excel file from Hex_breaker output
    
    Args:
        input_excel_path: Path to Excel file from Hex_breaker
        
    Returns:
        Path to output Excel file with validation results
    """
    input_path = Path(input_excel_path)
    
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_excel_path}")
    
    print(f"Reading Excel file: {input_path}")
    df = pd.read_excel(input_path, engine='openpyxl')
    
    print(f"Columns found: {df.columns.tolist()}")
    print(f"Total rows: {len(df)}")
    
    # Find email column (case-insensitive)
    email_col = None
    for col in df.columns:
        if col.lower() == 'email':
            email_col = col
            break
    
    if email_col is None:
        print("Warning: 'email' column not found in DataFrame")
        print(f"Available columns: {df.columns.tolist()}")
        # Create output without validation
        output_path = input_path.parent / f"{input_path.stem}_validated.xlsx"
        df.to_excel(output_path, index=False, engine='openpyxl')
        return str(output_path)
    
    print(f"Using email column: '{email_col}'")
    
    # Track validation results
    valid_emails = []
    invalid_count = 0
    
    print(f"Validating {len(df)} email addresses...")
    
    # Validate each email
    for idx in tqdm(df.index, desc="Validating emails"):
        email = df.loc[idx, email_col]
        is_valid = False
        
        # Handle missing or non-string values
        if pd.isna(email) or not isinstance(email, str):
            invalid_count += 1
        else:
            # Strip whitespace
            email = email.strip()
            
            if not email:
                invalid_count += 1
            else:
                # Validate using pyIsEmail
                is_valid = is_email(email, check_dns=False)
                if not is_valid:
                	    invalid_count += 1
        
        # Store whether this email is valid
        valid_emails.append(is_valid)
    
    # Add validation column temporarily
    df['email_valid'] = valid_emails
    
    # Count before filtering
    total_before = len(df)
    
    # Remove rows with invalid emails
    df_cleaned = df[df['email_valid'] == True].copy()
    
    # Remove the temporary validation column
    df_cleaned = df_cleaned.drop(columns=['email_valid'])
    
    # Generate output path
    output_path = input_path.parent / f"{input_path.stem}_validated.xlsx"
    
    # Save cleaned data
    print(f"Saving cleaned data to: {output_path}")
    df_cleaned.to_excel(output_path, index=False, engine='openpyxl')
    
    # Print summary statistics
    valid_count = len(df_cleaned)
    print(f"\nValidation Summary:")
    print(f"  Total records (before): {total_before}")
    print(f"  Valid emails (kept): {valid_count}")
    print(f"  Invalid emails (removed): {invalid_count}")
    print(f"  Retention rate: {valid_count/total_before*100:.2f}%")
    
    return str(output_path)


def main():
    """Main entry point for command line usage"""
    if len(sys.argv) != 2:
        print("Usage: python email_validator.py <input_excel_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    try:
        output_file = validate_emails(input_file)
        print(f"\nSuccess! Output file: {output_file}")
        return output_file
    except Exception as e:
        print(f"Error during validation: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


# Don't auto-run when imported by R
# if __name__ == "__main__":
#     main()