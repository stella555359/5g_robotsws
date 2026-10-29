import csv
import os


def install_and_import_pandas():
    """
    Helper function to ensure pandas is available.
    Dynamically installs pandas if not already present.
    """
    try:
        import pandas as pd
        return pd
    except ImportError:
        import subprocess
        import sys
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])
        import pandas as pd
        return pd


def check_manual_mitigation_slots(file_name):
    """
    Check that required slots (2, 3, 12, 13) exist in dlFdSchedData.csv.

    Returns:
        True  -> if ALL required slots are found
        False -> if any required slot is missing
    """

    required_slots = {"2", "3", "12", "13"}
    found_slots = set()
    slot_rows = {slot: [] for slot in required_slots}  # Track row numbers

    try:
        with open(file_name, newline="") as csv_file:
            csv_reader = csv.DictReader(csv_file)

            # Ensure 'slot' column exists
            if "slot" not in csv_reader.fieldnames:
                raise ValueError("Error: 'slot' column not found in CSV")

            # Loop through rows with row number (header = row 1)
            for idx, row in enumerate(csv_reader, start=2):
                slot = row.get("slot", "").strip()
                if slot in required_slots:
                    found_slots.add(slot)
                    slot_rows[slot].append(idx)

    except FileNotFoundError:
        raise FileNotFoundError(f"Error: CSV file not found: {file_name}")

    except Exception as e:
        raise RuntimeError(f"Error: Unexpected issue while parsing CSV: {e}")

    # Check if all required slots are present
    missing = required_slots - found_slots
    if missing:
        print(f"FAIL: Missing required slots in dlFdSchedData: {', '.join(sorted(missing))}")
        return False

    print("PASS: All required slots (2, 3, 12, 13) are present in slot column")
    # for slot, rows in slot_rows.items():
    #     print(f"   Slot {slot} found at rows: {rows}")
    return True


# For standalone testing
if __name__ == "__main__":
    test_file = "ttitrace.pcap00_0000_dlFdSchedData.csv"
    check_manual_mitigation_slots(test_file)


def merge_multiple_csv(filepath, dire):
    """
    Merge multiple formatted CSV files (output_<dire>_formated_*.csv)
    into a single combined file output_<dire>_formated.csv.
    """
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("CSV files found:", csv_file_list)

    for i in range(0, len(csv_file_list)):
        expected_file = f'output_{dire}_formated_{i}.csv'
        if expected_file in csv_file_list:
            print('Merging file:', expected_file)
            df_list.append(pd.read_csv(os.path.join(filepath, expected_file), low_memory=False))
            os.remove(os.path.join(filepath, expected_file))

    if not df_list:
        raise FileNotFoundError(f"No matching CSV files found in {filepath} for direction '{dire}'")

    df = pd.concat(df_list, ignore_index=True)
    filename = f'output_{dire}_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)
    print(f"Successfully merged into {filename}")
