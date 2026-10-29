import csv


def tti_check_filter_element_value(
        input_file, output_file, col_name, col_name_msg_filter,
        col_element_name, col_element_value):
    # Load the CSV file and define the column names to search for
    filter_type_col_name = col_name  # Column name for filter type
    element_col_name = col_element_name  # Column name for element value
    # Initialize a list to store the filtered rows
    filtered_rows = []
    # Open the CSV file and read it
    with open(input_file, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)  # Using DictReader to read the CSV as a dictionary
        # Find the column indices dynamically based on the header names
        fieldnames = reader.fieldnames  # List of all column names in the header
        # Check if required columns exist in the CSV file
        if (filter_type_col_name not in fieldnames or
                element_col_name not in fieldnames):
            print("Could not find the required columns in the CSV file.")
            return False
        # Iterate through each row in the CSV
        for row in reader:
            filter_type_value = row[filter_type_col_name]
            element_value = row[element_col_name]
            # Check if the filter type contains the filter string and element value is not as expected
            if (col_name_msg_filter in filter_type_value.strip() and
                    col_element_value not in element_value.strip()):
                filtered_rows.append(row)
    # Check if there are any filtered rows and write them to the output CSV
    if filtered_rows:
        with open(output_file, mode='w', newline='', encoding='utf-8') as outfile:
            # Create a DictWriter to write the dictionary rows to the new CSV file
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()  # Write the header row
            writer.writerows(filtered_rows)  # Write the filtered rows
            print(f"Filtered data has been saved to {output_file}.")
            return False
    else:
        print("No rows matched the filtering criteria.")
        return True
