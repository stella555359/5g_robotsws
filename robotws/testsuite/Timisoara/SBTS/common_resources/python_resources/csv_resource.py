import csv


def append_to_csv_file(filepath, data):
    with open(filepath, 'a') as f:
        obj1 = csv.writer(f)
        obj1.writerow(data)
