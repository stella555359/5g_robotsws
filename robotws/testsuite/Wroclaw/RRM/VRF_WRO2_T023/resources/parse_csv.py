from collections import defaultdict
import csv


def parse_and_group_csv(file_path, columnX, columnY='lcrId'):
    """
    Parses a CSV file and groups values from columnX by columnY, skipping empty cells.

    :param file_path: Path to the CSV file.
    :param columnX: The name of the column from which to extract values.
    :param columnY: The name of the column to group the values by.
    :return: A dictionary with keys from columnY and lists of values from columnX.
    """
    grouped_data = defaultdict(list)

    with open(file_path, mode='r', encoding='utf-8') as file:
        csv_reader = csv.DictReader(file)

        for row in csv_reader:
            valueX = row[columnX].strip()
            if valueX:  # Skip empty cells
                grouped_data[row[columnY]].append(valueX)

    return dict(grouped_data)
