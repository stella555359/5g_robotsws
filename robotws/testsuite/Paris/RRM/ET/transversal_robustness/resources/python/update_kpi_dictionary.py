import sys
import csv


def update_kpi_dictionary(file_path, new_value):
    with open(file_path, 'r') as file:
        reader = csv.reader(file, delimiter=';')
        rows = list(reader)

    updated_rows = []
    removed_rows = []
    new_rows = []
    for row in rows:
        if row[0].startswith('#'):
            print(f"line removed from the kpi dictionary: {row}")
            removed_rows.append(["REMOVED line:"] + row)
            continue  # Ignore rows starting with '#'
        new_row = [item.replace('PERIOD_DURATION*60', str(new_value)) for item in row]
        if new_row != row:
            updated_rows.append(["OLD value:"] + row)
            updated_rows.append(["NEW value:"] + new_row)
        new_rows.append(new_row)

    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file, delimiter=';')
        writer.writerows(new_rows)

    updated_rows = removed_rows + updated_rows
    return updated_rows


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <file_path> <new_value>")
    else:
        file_path = sys.argv[1]
        new_value = sys.argv[2]
        updated_rows = update_kpi_dictionary(file_path, new_value)
        for row in updated_rows:
            print(row)
