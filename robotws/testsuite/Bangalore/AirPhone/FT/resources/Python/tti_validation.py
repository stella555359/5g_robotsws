import os
import csv


def count_string_in_column(file_path, column_name, target_string):
    # Load the CSV file
    with open(file_path, 'r', newline='') as csvfile:
        df = csv.reader(csvfile)
    # Check if the column exists
    if column_name not in df.columns:
        print(f"Column '{column_name}' does not exist in the CSV file.")
        return
    # Count occurrences of the target string in the specified column
    count = df[column_name].fillna('').str.count(target_string).sum()
    print(f"The string '{target_string}' occurs {count} times in column '{column_name}'.")
    return count
