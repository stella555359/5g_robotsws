import csv
import os


ROBOT_LIBRARY_SCOPE = 'TEST SUITE'


def check_delay_values_in_range(csv_path):
    """
    Reads values  in the CSV.
    Divides each by 128, takes the integer part,
    and checks if it's in range [1, 1024].
    Returns PASS if any one value is valid.
    Returns FAIL with message if all are invalid or file missing.
    """
    if not os.path.exists(csv_path):
        print("\033[91m[ERROR] File not found / unreadable\033[0m")
        return "FAIL"

    total_checked = 0
    total_passed = 0
    total_failed = 0
    any_passed = False

    try:
        with open(csv_path, 'r') as file:
            reader = csv.reader(file)
            next(reader, None)  # Skip header

            for index, row in enumerate(reader, start=2):
                if not row or not row[0].strip():
                    print(f"\033[93m[SKIP] Row {index}: Empty or invalid\033[0m")
                    continue

                try:
                    value = float(row[0])
                    divided = value / 128
                    int_part = int(divided)
                    total_checked += 1

                    if 1 <= int_part <= 1024:
                        print(f"\033[92m[PASS] Row {index}: Value={value}, /128={divided:.4f}\033[0m")
                        print(f"\033[94mThe Row {index} values with CB013507 is verified \033[0m")
                        total_passed += 1
                        any_passed = True
                    else:
                        print(f"\033[91m[FAIL] Row {index}: Value={value}, /128={divided:.4f} \033[0m")
                        total_failed += 1

                except ValueError:
                    print(f"\033[91m[ERROR] Row {index}: Not a valid number '{row[0]}'\033[0m")
                    total_failed += 1

        # Final summary
        print(f"\n\033[96m--- Summary ---\033[0m")
        print(f"\033[96mTotal Checked : {total_checked}\033[0m")
        print(f"\033[92mTotal Passed  : {total_passed}\033[0m")
        print(f"\033[91mTotal Failed  : {total_failed}\033[0m")

        if any_passed:
            return "PASS"
        else:
            print("\033[91mCB013507 value is not in the range 1 to 1024\033[0m")
            return "FAIL"

    except Exception as e:
        print("\033[91mFile not found / unreadable\033[0m")
        return "FAIL"
