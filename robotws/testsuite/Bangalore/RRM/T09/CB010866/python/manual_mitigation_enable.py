import csv
import os


def check_manual_mitigation_slots(file_name):
    """
    Check that forbidden slots (2, 3, 12, 13) do NOT exist in dlFdSchedData.csv.

    Returns:
        True  -> if NONE of the forbidden slots are found
        False -> if any forbidden slot is present
    """

    forbidden_slots = {"2", "3", "12", "13"}
    found_slots = set()
    slot_rows = {slot: [] for slot in forbidden_slots}  # track row numbers

    try:
        with open(file_name, newline="") as csv_file:
            csv_reader = csv.DictReader(csv_file)

            # Ensure 'slot' column exists
            if "slot" not in csv_reader.fieldnames:
                raise ValueError("Error: 'slot' column not found in CSV")

            # Loop through rows with row number (header = row 1)
            for idx, row in enumerate(csv_reader, start=2):
                slot = row.get("slot", "").strip()
                if slot in forbidden_slots:
                    found_slots.add(slot)
                    slot_rows[slot].append(idx)

    except FileNotFoundError:
        raise FileNotFoundError(f"Error: CSV file not found: {file_name}")

    except Exception as e:
        raise RuntimeError(f"Error: Unexpected issue while parsing CSV: {e}")

    # Check if any forbidden slot is present
    if found_slots:
        print(f"FAIL: Forbidden slots found in dlFdSchedData: {', '.join(sorted(found_slots))}")
        # The following block can be uncommented for detailed row info:
        # for slot, rows in slot_rows.items():
        #     if rows:
        #         print(f"   Slot {slot} present at rows: {rows}")
        return False

    print("PASS: Forbidden slots (2, 3, 12, 13) are NOT present in slot column")
    return True


# For standalone testing
if __name__ == "__main__":
    test_file = "ttitrace.pcap00_0000_dlFdSchedData.csv"
    check_manual_mitigation_slots(test_file)


def merge_multiple_csv(filepath, dire):
    import pandas as pd
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        expected_file = f"output_{dire}_formated_{i}.csv"
        if expected_file in csv_file_list:
            print("file", expected_file)
            df_list.append(pd.read_csv(os.path.join(filepath, expected_file), low_memory=False))
            os.remove(os.path.join(filepath, expected_file))

    df = pd.concat(df_list, ignore_index=True)
    filename = f"output_{dire}_formated.csv"
    df.to_csv(os.path.join(filepath, filename), index=False)
