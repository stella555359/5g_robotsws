import csv


def parse_csv(file_path, field1, field2, field3, tddframe, output_file):
    try:
        with open(file_path, mode='r', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)

            # Check if the fields exist in the CSV
            if field1 not in reader.fieldnames or field2 not in reader.fieldnames:
                print(f"Error: Fields '{field1}' or '{field2}' not found in the CSV file.")
                return

            print(f"Extracting fields: {field1}, {field2}")
            # Open the output file for writing
            with open(output_file, mode='w', newline='', encoding='utf-8') as outfile:
                writer = csv.writer(outfile)
                writer.writerow([field1, field2, field3])  # Write header

                for row in reader:
                    if row[field1] in ['0', '1', '2', '3', '10', '11', '12', '13']:
                        if row[field3] not in ['0', '65534', '65535']:
                            if row[field2] not in ['']:
                                writer.writerow([row[field1], row[field2], row[field3]])  # Write filtered rows

            print(f"Filtered results written to '{output_file}' successfully.")
            #   print(f"{field1}: {row[field1]}, {field2}: {row[field2]}")
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


def validate_slot_muting(slotnum, tddframe, output_file, field1, field2):
    print(slotnum)
    print(tddframe)
    with (open(output_file, mode='r', newline='', encoding='utf-8') as csvfile):
        reader = csv.DictReader(csvfile)
        if tddframe == '1':
            if slotnum == '3':
                for row in reader:
                    print("Inrow", field1, field2)
                    if (row[field1] not in ['1', '2', '3', '11', '12', '13']):
                        print("SUCCESS_1")
                    if (row[field1] in ['0', '10']):
                        print("SUCCESS_2")
                    if (row[field2] in ['96.0', '40.0', '100.0', '57.0']):
                        print("SUCCESS_3")
                    if (
                        (row[field1] not in ['1', '2', '3', '11', '12', '13'])
                        and (row[field1] in ['0', '10'])
                        and (row[field2] in ['96.0', '40.0', '100.0', '57.0'])
                    ):
                        print("SUCCESS")
                        return 1
                    else:
                        print("FAIL")
                        return 0
            else:
                print("FAIL_2")
                return 0
        else:
            print("FAIL_3")
            return 0
