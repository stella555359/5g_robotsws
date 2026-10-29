import csv


def read_column_values(file_path, column_name):
    """
        Gets values from a specified column in a CSV file.
        :param file_path (str): The path to the CSV file.
        :param column_name (str): The name of the column to read.
        :return A list of values from the specified column.
        :raises ValueError: If the specified column is not found in the CSV file.
        """
    values = []
    with open(file_path, mode='r', encoding='utf-8') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            if column_name in row:
                if row[column_name] != "":
                    values.append(row[column_name])
            else:
                raise ValueError(f"Column '{column_name}' not found in the CSV file.")
    return values
