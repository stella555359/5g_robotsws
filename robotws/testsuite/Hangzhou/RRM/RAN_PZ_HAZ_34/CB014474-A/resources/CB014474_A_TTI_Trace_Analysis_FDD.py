# -*- coding: utf-8 -*

"""
Author:         Wu Pengliang
Contact Mail:   pengliang.wu@nokia.com
Description:    This py file to get TTI data and check PRB ratio and dyn rat0 slot.
"""
import csv
import os


TTI_Columns = [
    'hfnTickCount',
    'sfn',
    'slot',
    'rnti',
    'physCellId',
    'dlFdSchedData.numOfPrb',
    'dlFdSchedData.startPrb',
    'dlFdSchedData.rat0Bitmap',
    'dlFdSchedData.remainingBytesPerBearerInFdEoBuffer[4]'
]


def aggregate_data_by_group(input_file_path, target_columns=TTI_Columns):
    """
    Aggregate data by hfnTickCount, sfn, slot, physCellId and sum dlFdSchedData.numOfPrb

    Args:
        input_file_path (str): Path to input CSV file
        target_columns (list): List of column names to extract

    Returns:
        dict: Aggregated data dictionary
    """
    aggregated_data = {}

    try:
        # Check if input file exists
        if not os.path.exists(input_file_path):
            print(f"Error: Input file '{input_file_path}' not found!")
            return {}

        # Read input CSV file
        with open(input_file_path, 'r', encoding='utf-8', newline='') as input_file:
            csv_reader = csv.DictReader(input_file)

            # Get all available columns
            available_columns = csv_reader.fieldnames
            # print(f"Available columns in CSV: {len(available_columns)} columns")

            # Check which target columns exist in the file
            existing_columns = []
            for col in target_columns:
                if col in available_columns:
                    existing_columns.append(col)

            if not existing_columns:
                print("Error: None of the target columns found in CSV file!")
                return {}

            print(f"Processing columns: {existing_columns}")

            # Process each row
            row_count = 0
            valid_row_count = 0

            for row in csv_reader:
                # Extract only the existing target columns
                filtered_row = {col: row.get(col, '') for col in existing_columns}

                # Check if all target columns have data (not empty)
                all_columns_have_data = all(
                    filtered_row[col] != '' and filtered_row[col] is not None
                    for col in existing_columns
                )

                # Only process row if all columns have data
                if all_columns_have_data:
                    # Extract key fields
                    hfnTickCount = filtered_row['hfnTickCount']
                    sfn = filtered_row['sfn']
                    slot = filtered_row['slot']
                    physCellId = filtered_row['physCellId']
                    rnti = filtered_row['rnti']

                    # Extract numeric values
                    try:
                        numOfPrb = float(filtered_row.get('dlFdSchedData.numOfPrb', '0'))
                        rat0Bitmap = float(filtered_row.get('dlFdSchedData.rat0Bitmap', '0'))
                    except ValueError:
                        continue

                    # Create group key
                    group_key = f'hfn_{hfnTickCount}_pci_{physCellId}_sfn_{sfn}_slot_{slot}'

                    # Initialize group if not exists
                    if group_key not in aggregated_data:
                        aggregated_data[group_key] = {
                            'hfnTickCount': hfnTickCount,
                            'sfn': sfn,
                            'slot': slot,
                            'physCellId': physCellId,
                            'numOfPrb': 0,
                            'rat0Bitmap': 0,
                            'rat0Bitmap_rnti': None
                        }

                    # Sum numOfPrb
                    aggregated_data[group_key]['numOfPrb'] += numOfPrb

                    # Sum rat0Bitmap
                    aggregated_data[group_key]['rat0Bitmap'] += rat0Bitmap

                    # Set rat0Bitmap_rnti if rat0Bitmap > 0 and not already set
                    if rat0Bitmap > 0 and aggregated_data[group_key]['rat0Bitmap_rnti'] is None:
                        aggregated_data[group_key]['rat0Bitmap_rnti'] = rnti

                    valid_row_count += 1

                row_count += 1

            print(f"Successfully processed {row_count} total rows")
            print(f"Valid rows with all data: {valid_row_count}")
            print(f"Unique groups created: {len(aggregated_data)}")

        return aggregated_data

    except Exception as e:
        print(f"Error processing CSV file: {str(e)}")
        return {}


def export_aggregated_data_to_csv(aggregated_data, output_file_path):
    """
    Export aggregated data dictionary to CSV file

    Args:
        aggregated_data (dict): Aggregated data dictionary
        output_file_path (str): Path to output CSV file

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        if not aggregated_data:
            print("Error: No aggregated data to export!")
            return False

        # Get the keys from the first item to determine column headers
        first_key = next(iter(aggregated_data))
        column_headers = ['group_key'] + list(aggregated_data[first_key].keys())

        # Write to CSV file
        with open(output_file_path, 'w', encoding='utf-8', newline='') as csvfile:
            csv_writer = csv.writer(csvfile)

            # Write header row (column names)
            csv_writer.writerow(column_headers)

            # Write data rows
            for group_key, group_data in aggregated_data.items():
                row = [group_key]
                for col in column_headers[1:]:  # Skip 'group_key' column
                    row.append(group_data.get(col, ''))
                csv_writer.writerow(row)

        print(f"📊 Aggregated data exported to: {output_file_path}")
        print(f"📁 Total groups exported: {len(aggregated_data)}")

        # Display file statistics
        file_size = os.path.getsize(output_file_path)
        print(f"📄 File size: {file_size} bytes")

        return True

    except Exception as e:
        print(f"Error exporting aggregated data: {str(e)}")
        return False


def check_prb_ratio(aggregated_data, target_prb_count, threshold=0.9):
    """
    Check if the ratio of specified PRB count in aggregated data is above threshold

    Args:
        aggregated_data (dict): Aggregated data dictionary
        target_prb_count (float): Target PRB count to check (e.g., 106)
        threshold (float): Threshold ratio (default: 0.9 for 90%)

    Returns:
        bool: True if ratio > threshold, False otherwise
    """
    try:
        if not aggregated_data:
            print("Error: No aggregated data provided!")
            return False

        total_groups = len(aggregated_data)
        target_prb_sum = 0  # Sum of all target PRB values
        total_prb_sum = 0  # Sum of all PRB values
        matching_groups = 0

        # Calculate PRB sums
        for group_key, group_data in aggregated_data.items():
            prb_value = group_data.get('numOfPrb', 0)
            total_prb_sum += prb_value

            if prb_value == target_prb_count:
                target_prb_sum += prb_value
                matching_groups += 1

        # Calculate ratio based on PRB values, not group count
        ratio = target_prb_sum / total_prb_sum if total_prb_sum > 0 else 0

        print(f"PRB Analysis for {target_prb_count}:")
        print(f"  Total groups: {total_groups}")
        print(f"  Groups with {target_prb_count} PRBs: {matching_groups}")
        print(f"  Sum of {target_prb_count} PRBs: {target_prb_sum}")
        print(f"  Sum of all PRBs: {total_prb_sum}")
        print(f"  PRB Ratio: {ratio:.4%}")
        print(f"  Threshold: {threshold:.1%}")
        print(f"  Result: {'PASS' if ratio > threshold else 'FAIL'}")

        return ratio > threshold

    except Exception as e:
        print(f"Error checking PRB ratio: {str(e)}")
        return False


def check_rat0bitmap_slot_coverage(aggregated_data, required_slots_str=None):
    """
    Check if RAT0Bitmap > 0 cases cover required slots (must include slot0 and slot5)

    Args:
        aggregated_data (dict): Aggregated data dictionary
        required_slots (set): Required slots that must be present (default: {'0', '5'})

    Returns:
        bool: True if all required slots are covered, False otherwise
    """
    required_slots_list = required_slots_str.split(',')
    required_slots = set(required_slots_list)
    try:
        if required_slots is None:
            required_slots = {'0', '5'}  # Default: must include slot0 and slot5

        if not aggregated_data:
            print("Error: No aggregated data provided!")
            return False

        # Collect all slots where rat0Bitmap > 0
        active_rat0_slots = set()
        total_rat0_groups = 0

        for group_key, group_data in aggregated_data.items():
            rat0_bitmap = group_data.get('rat0Bitmap', 0)
            if rat0_bitmap > 0:
                slot = group_data.get('slot', '')
                if slot:  # Only add non-empty slots
                    active_rat0_slots.add(str(slot))
                    total_rat0_groups += 1

        # Check if all required slots are present
        missing_slots = required_slots - active_rat0_slots
        coverage_complete = len(missing_slots) == 0

        print(f"RAT0Bitmap Slot Coverage Analysis:")
        print(f"  Total groups with RAT0Bitmap > 0: {total_rat0_groups}")
        print(f"  Active RAT0 slots: {sorted(active_rat0_slots)}")
        print(f"  Required slots: {sorted(required_slots)}")
        print(f"  Missing slots: {sorted(missing_slots) if missing_slots else 'None'}")
        print(f"  Coverage complete: {'YES' if coverage_complete else 'NO'}")
        print(f"  Result: {'PASS' if coverage_complete else 'FAIL'}")

        return coverage_complete

    except Exception as e:
        print(f"Error checking RAT0Bitmap slot coverage: {str(e)}")
        return False


def extract_csv_columns(input_file_path, output_file_path, target_columns=TTI_Columns):
    """
    Extract specific columns from CSV file and save to new CSV file

    Args:
        input_file_path (str): Path to input CSV file
        output_file_path (str): Path to output CSV file
        target_columns (list): List of column names to extract

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Check if input file exists
        if not os.path.exists(input_file_path):
            print(f"Error: Input file '{input_file_path}' not found!")
            return False

        # Read input CSV file
        with open(input_file_path, 'r', encoding='utf-8', newline='') as input_file:
            # Create CSV reader
            csv_reader = csv.DictReader(input_file)

            # Get all available columns
            available_columns = csv_reader.fieldnames
            # print(f"Available columns in CSV: {available_columns}")

            # Check which target columns exist in the file
            existing_columns = []
            missing_columns = []

            for col in target_columns:
                if col in available_columns:
                    existing_columns.append(col)
                else:
                    missing_columns.append(col)

            if missing_columns:
                print(f"Warning: Missing columns: {missing_columns}")

            if not existing_columns:
                print("Error: None of the target columns found in CSV file!")
                return False

            print(f"Extracting columns: {existing_columns}")

            # Write output CSV file
            with open(output_file_path, 'w', encoding='utf-8', newline='') as output_file:
                # Create CSV writer with existing columns only
                csv_writer = csv.DictWriter(output_file, fieldnames=existing_columns)

                # Write header
                csv_writer.writeheader()

                # Process each row
                row_count = 0
                valid_row_count = 0
                for row in csv_reader:
                    # Extract only the existing target columns
                    filtered_row = {col: row.get(col, '') for col in existing_columns}

                    # Check if all target columns have data (not empty)
                    all_columns_have_data = all(
                        filtered_row[col] != '' and filtered_row[col] is not None
                        for col in existing_columns
                    )

                    # Only write row if all columns have data
                    if all_columns_have_data:
                        csv_writer.writerow(filtered_row)
                        valid_row_count += 1

                    row_count += 1

                print(f"Successfully processed {row_count} total rows")
                print(f"Valid rows with all data: {valid_row_count}")
                print(f"Skipped rows (missing data): {row_count - valid_row_count}")
                print(f"Output saved to: {output_file_path}")

        return True

    except Exception as e:
        print(f"Error processing CSV file: {str(e)}")
        return False
