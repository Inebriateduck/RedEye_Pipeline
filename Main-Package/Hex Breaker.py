import os
import re
from openpyxl import load_workbook, Workbook
from openpyxl.styles import PatternFill
from datetime import datetime

def combine_and_process_excel_files():
    
    input_folder = r'XXXXXXXX'  # Change this to your folder path (your output will also be here)

    unicode_pattern = re.compile(r'&#x([0-9a-fA-F]+);')

    highlight_fill = PatternFill(start_color="FFFF00", end_color="FFFF00", fill_type="solid")

    # Creates a new workbook
    combined_wb = Workbook()
    combined_ws = combined_wb.active
    combined_ws.title = "Combined Data"

    # Iterates over all files in the input folder
    for file_name in os.listdir(input_folder):
        if file_name.endswith(".xlsx"):  # Process only .xlsx files
            file_path = os.path.join(input_folder, file_name)
            wb = load_workbook(file_path)
            
            # Iterates over all sheets in the current workbook
            for sheet in wb.worksheets:
                for row in sheet.iter_rows(values_only=True):  # Read row values only
                    # Append rows to the combined worksheet
                    combined_ws.append(row)

    # Processes the combined worksheet for Unicode hex codes
    for row in combined_ws.iter_rows():
        for cell in row:
            if cell.value and isinstance(cell.value, str):
                matches = unicode_pattern.findall(cell.value)
                if matches:
                    for match in matches:
                        # Replace hex code with the corresponding Unicode character
                        unicode_char = chr(int(match, 16))
                        cell.value = unicode_pattern.sub(unicode_char, cell.value, 1)
                    cell.fill = highlight_fill  # Highlight the cell

    # Generates an output file name
    folder_name = os.path.basename(input_folder)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    output_file = os.path.join(input_folder, f"{folder_name}_output_{timestamp}.xlsx")

    combined_wb.save(output_file)

    print(f"Processing complete. The output file has been saved as: {output_file}")

# Run the function
combine_and_process_excel_files()

