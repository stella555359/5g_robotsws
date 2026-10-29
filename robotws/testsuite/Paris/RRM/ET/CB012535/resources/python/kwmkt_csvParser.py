import csv
from collections import defaultdict


def read_csv_and_count_occurrences(csv_file, column, filtered_column, value_checked):
    """
    This function reads a CSV file and counts the occurrences of values in a specific column based on a given filter.

    Args:
        csv_file (str): The path to the CSV file.
        column (str): The name of the column to analyze.
        filtered_column (str): The name of the column used as filter.
        value_checked (str): The value of the filter to apply.

    Returns:
        dict: A dictionary containing two keys:
            - 'non_empty_lines_count': the total number of non-empty lines in the CSV file.
            - 'occurrences': a dictionary containing the occurrences of values in the specified column
              that match the given filter.
    """
    # Initialize dictionary to store occurrences
    occurrences = defaultdict(int)

    # Counter for non-empty lines
    non_empty_lines_count = 0

    # Read the CSV file
    with open(csv_file, 'r', newline='', encoding='utf-8') as f:
        csv_reader = csv.DictReader(f, delimiter=';')

        # Check if the given column exists in the CSV file
        if column not in csv_reader.fieldnames:
            print(f"The column '{column}' does not exist in the CSV file.")
            return None

        # Check if the filter column exists in the CSV file
        if filtered_column not in csv_reader.fieldnames:
            print(f"The filter column '{filtered_column}' does not exist in the CSV file.")
            return None

        # Iterate through the CSV file lines
        for line in csv_reader:
            # Check if the value in the filter column equals the filter value
            if line[filtered_column] == value_checked:
                # Check if the value in the column is not empty
                if line[column]:
                    non_empty_lines_count += 1
                    # Increment the occurrence count of the value in the column
                    occurrences[line[column]] += 1

    return {'non_empty_lines_count': non_empty_lines_count, 'occurrences': dict(occurrences)}

# # Example Usage

# # Path to the CSV file
# csv_file = "/ebs/ftourlon/FRT/L1L2_pcapprocessed.csv"

# # Columns to use
# column = "UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag"
# # column = "UlData_puschReceiveReqGrant_t.numOfLayers"
# filtered_column = "3gpp.subcellid"
# value_checked = "0"

# # Function call
# result = read_csv_and_count_occurrences(csv_file, column, filtered_column, value_checked)

# # Display the result
# print("Number of non-empty lines:", result['non_empty_lines_count'])
# print("Occurrences of values:", result['occurrences'])
