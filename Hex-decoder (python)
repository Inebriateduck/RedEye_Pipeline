import os
import re
from openpyxl import load_workbook, Workbook
from openpyxl.styles import PatternFill
from datetime import datetime

def combine_and_process_excel_files():
    # Define the input folder directly here
    input_folder = r'XXXXXXXX'  # Change this to your folder path

    # Regex pattern to match Unicode hex code form &#xNNNN;
    unicode_pattern = re.compile(r'&#x([0-9a-fA-F]+);')

    # Define a fill style for highlighting
    highlight_fill = PatternFill(start_color="FFFF00", end_color="FFFF00", fill_type="solid")

    # Create a new workbook for the combined data
    combined_wb = Workbook()
    combined_ws = combined_wb.active
    combined_ws.title = "Combined Data"

    # Iterate over all files in the input folder
    for file_name in os.listdir(input_folder):
        if file_name.endswith(".xlsx"):  # Process only .xlsx files
            file_path = os.path.join(input_folder, file_name)
            wb = load_workbook(file_path)
            
            # Iterate over all sheets in the current workbook
            for sheet in wb.worksheets:
                for row in sheet.iter_rows(values_only=True):  # Read row values only
                    # Append rows to the combined worksheet
                    combined_ws.append(row)

    # Process the combined worksheet for Unicode hex codes
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

    # Generate an output file name based on the folder name and current timestamp
    folder_name = os.path.basename(input_folder)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    output_file = os.path.join(input_folder, f"{folder_name}_output_{timestamp}.xlsx")

    # Save the processed data to the generated output file
    combined_wb.save(output_file)

    # Display the output file name once done
    print(f"Processing complete. The output file has been saved as: {output_file}")

# Run the function
combine_and_process_excel_files()

