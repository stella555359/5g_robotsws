#!/usr/bin/env python3
"""
Script to merge multiple KPI CSV files into a single Excel pivot file.

Usage:
    python merge_nr_files.py <source_directory> [output_file.xlsx]
"""

import sys
import os
import re
import csv
from pathlib import Path
from collections import defaultdict
from openpyxl import Workbook
from openpyxl.styles import Font


INPUT_FILE_PATTERN = re.compile(
    r'^(?:NR_.*|SCOUT_NR_?\d+[a-z]?_.*|M\d+C\d+_.*)\.csv$'
)


def is_supported_input_file(file_path):
    """
    Check whether a file name matches one of the supported KPI CSV patterns.

    Supported examples:
    - NR_*.csv
    - SCOUT_NR_1234a_*.csv
    - SCOUT_NR1234a_*.csv
    - NR_1234a_*.csv
    - M55123C00001_*.csv
    """
    return file_path.is_file() and INPUT_FILE_PATTERN.match(file_path.name) is not None


def extract_kpi_name(value_a1):
    """
    Extract the KPI name from cell A1.
    Search for the part starting with 'NR_' or 'M55' (for counters like M55351C00001)

    Args:
        value_a1: Content of cell A1

    Returns:
        Extracted KPI name
    """
    value = str(value_a1)
    # First try to match NR_ pattern
    match = re.search(r'(NR_\S+)', value)
    if match:
        return match.group(1).strip()
    # Then try to match M pattern (counters like M55351C00001)
    match = re.search(r'(M\d+C\d+)', value)
    if match:
        return match.group(1).strip()
    # Also try MRBTS_ pattern
    match = re.search(r'(MRBTS_\S+)', value)
    if match:
        return match.group(1).strip()
    return value.strip()


def remove_kpi_version_suffix(kpi_name):
    """
    Remove alphabetic version suffix from KPI name.
    Example: NR_5004b -> NR_5004, NR_5013a -> NR_5013

    Args:
        kpi_name: KPI name (e.g., 'NR_5004b')

    Returns:
        KPI name without version suffix
    """
    # Remove trailing lowercase letters (version suffix)
    # Pattern: ends with one or more digits followed by one or more lowercase letters
    match = re.match(r'(.*\d+)[a-z]+$', kpi_name)
    if match:
        return match.group(1)
    return kpi_name


def search_kpi_description_in_constraints(kpi_name, constraint_dir):
    """
    Search recursively for KPI description in constraint CSV files.

    Args:
        kpi_name: KPI name to search for (e.g., 'NR_5482')
        constraint_dir: Directory containing constraint CSV files

    Returns:
        Description string or None if not found
    """
    if not os.path.exists(constraint_dir):
        return None

    # Search recursively for .csv files
    for root, dirs, files in os.walk(constraint_dir):
        for filename in files:
            if not filename.endswith('.csv'):
                continue

            filepath = os.path.join(root, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    reader = csv.reader(f, delimiter=';')
                    for line in reader:
                        # Skip comment lines, empty lines, and headers
                        if not line or len(line) < 6:
                            continue
                        if line[0].strip().startswith('#'):
                            continue

                        # Column 1: Counter_or_KPI
                        counter_kpi = line[1].strip()

                        # Check if this is our KPI (exact match)
                        if counter_kpi == kpi_name:
                            # Column 5: Comment from MIND/JUMP
                            description = line[5].strip()
                            if description:
                                return description
            except Exception as e:
                # Ignore files that cannot be read
                continue

    return None


def add_kpi_reference_sheet(workbook, kpi_names, kpi_mapping, constraint_dir):
    """
    Add a 'RefToDescription' sheet with KPI reference table.

    Args:
        workbook: The openpyxl Workbook object
        kpi_names: Set of unique KPI names found in NR files (with suffixes)
        kpi_mapping: Dict mapping original KPI names to KPI names without suffix
        constraint_dir: Directory to search for constraint files
    """
    print(f"\nAdding RefToDescription sheet...")
    print(f"  Searching in constraint directory: {constraint_dir}")

    # Create new sheet
    ws_ref = workbook.create_sheet("RefToDescription")

    # Headers
    ws_ref.cell(1, 1, "Counter_or_KPI")
    ws_ref.cell(1, 2, "Comment from MIND/JUMP")

    # Make headers bold
    ws_ref.cell(1, 1).font = Font(bold=True)
    ws_ref.cell(1, 2).font = Font(bold=True)

    # Sort KPI names for consistent output
    sorted_kpi_names = sorted(kpi_names)

    # For each KPI, search for description
    row_idx = 2
    found_count = 0
    for kpi_name in sorted_kpi_names:
        # Use KPI without suffix for searching
        kpi_to_search = kpi_mapping[kpi_name]
        description = search_kpi_description_in_constraints(kpi_to_search, constraint_dir)

        # Write original KPI name (with suffix)
        ws_ref.cell(row_idx, 1, kpi_name)
        ws_ref.cell(row_idx, 1, kpi_name)

        # Write description (or "No description found" if not found)
        if description:
            ws_ref.cell(row_idx, 2, description)
            found_count += 1
        else:
            ws_ref.cell(row_idx, 2, "No description found")

        row_idx += 1

    # Adjust column widths
    ws_ref.column_dimensions['A'].width = 20
    ws_ref.column_dimensions['B'].width = 60

    print(f"  - {len(kpi_names)} unique KPIs added")
    print(f"  - {found_count} descriptions found in constraint files")
    print(f"  - {len(kpi_names) - found_count} KPIs without description")


def merge_nr_files(source_directory, output_file=None):
    """
    Merge all supported KPI CSV files from the directory into a single Excel pivot file.

    Args:
        source_directory: Path to the directory containing supported KPI CSV files
        output_file: Output file name (optional)

    Returns:
        Path to the created file
    """
    folder = Path(source_directory)

    if not folder.exists():
        error_msg = f"ERROR: The folder does not exist: {folder}"
        print(error_msg)
        raise FileNotFoundError(error_msg)

    # Search for supported KPI CSV files
    files_nr = sorted(file_path for file_path in folder.iterdir() if is_supported_input_file(file_path))

    if not files_nr:
        error_msg = (
            f"ERROR: No supported KPI CSV files found in {folder} "
            f"(expected patterns like NR_*.csv, SCOUT_NR_1234a_*.csv, SCOUT_NR1234a_*.csv, "
            f"NR_1234a_*.csv, M55123C00001_*.csv)"
        )
        print(error_msg)
        raise FileNotFoundError(error_msg)

    print(f"Found {len(files_nr)} supported KPI CSV file(s)")

    # Data structures
    dict_lines = {}  # (kpi_name, object_name) -> row number
    dict_dates = {}   # date_val -> column number
    records = []      # List of (kpi_name, object_name, date_val, value)
    unique_kpi_names = set()  # Track unique KPI names for reference sheet

    # 1) Collect data from all files
    for file in files_nr:
        print(f"Reading of {file.name}...")

        try:
            # Read CSV file
            with open(file, 'r', encoding='utf-8') as f:
                lines = f.readlines()

                if len(lines) < 3:
                    print(f"  Empty or incomplete file: {file.name}")
                    continue

                # Extract kpi_name from the first line
                kpi_name = extract_kpi_name(lines[0].strip())
                unique_kpi_names.add(kpi_name)  # Track unique KPI name

                # Read data from line 3 (index 2)
                for line in lines[2:]:
                    parts = line.strip().split(',')
                    if len(parts) < 3:
                        continue

                    date_val = parts[0].strip()  # Column A: date
                    object_name = parts[1].strip()  # Column B: object

                    # Ignore lines with object_name = "level"
                    if object_name.lower() == "level":
                        continue

                    value = parts[2].strip() if len(parts) > 2 else ''

                    # Replace empty value with "None"
                    if not value or value == '':
                        value = "None"

                    # Unique keys
                    key_line = (kpi_name, object_name)
                    if key_line not in dict_lines:
                        dict_lines[key_line] = len(dict_lines) + 2  # +2 because row 1 = header

                    if date_val not in dict_dates:
                        dict_dates[date_val] = True

                    # Store the record
                    records.append((kpi_name, object_name, date_val, value))

        except Exception as e:
            print(f"Error reading {file.name}: {e}")
            continue

    if not records:
        error_msg = "ERROR: No data found in any NR files."
        print(error_msg)
        raise ValueError(error_msg)

    print(f"Total: {len(records)} records collected")

    # 2) Sort dates
    sorted_dates = sorted(dict_dates.keys())
    print(f"Period: from {sorted_dates[0]} to {sorted_dates[-1]}")

    # Reindex columns after sorting
    dict_dates = {date: idx + 3 for idx, date in enumerate(sorted_dates)}  # +3 because col A,B = kpi,object

    # 3) Create output file
    wb = Workbook()
    ws = wb.active

    # Headers
    ws.cell(1, 1, "kpi_name")
    ws.cell(1, 2, "object_name")

    for date, col_idx in dict_dates.items():
        ws.cell(1, col_idx, date)

    # Make first row bold
    for cell in ws[1]:
        cell.font = Font(bold=True)

    # 4) Write data
    data_written = defaultdict(dict)  # To avoid duplicates

    for kpi_name, object_name, date_val, value in records:
        key_line = (kpi_name, object_name)
        row_idx = dict_lines[key_line]

        # Write kpi_name and object_name
        ws.cell(row_idx, 1, kpi_name)
        ws.cell(row_idx, 2, object_name)

        # Write value in corresponding column
        if date_val in dict_dates:
            col_idx = dict_dates[date_val]

            # Avoid overwriting if already a value (take the last one)
            ws.cell(row_idx, col_idx, value)

    # 5) Adjust column widths
    for column in ws.columns:
        max_length = 0
        column_letter = column[0].column_letter
        for cell in column:
            try:
                if cell.value:
                    max_length = max(max_length, len(str(cell.value)))
            except Exception:
                pass
        adjusted_width = min(max_length + 2, 50)
        ws.column_dimensions[column_letter].width = adjusted_width

    # 6) Add KPI Reference sheet
    # Determine constraint directory (relative to script location)
    script_path = Path(__file__).resolve()
    # From script: resources/python/merge_scout_histo_nr_files.py
    # Go up to transversal_robustness, then down to config/counter/constraint
    constraint_dir = script_path.parent.parent.parent / "config" / "counter" / "constraint"

    # Remove version suffixes from KPI names for searching in constraints
    # Map: original KPI name -> KPI name without suffix
    kpi_mapping = {}
    kpi_names_without_suffix = set()
    for kpi in unique_kpi_names:
        kpi_without_suffix = remove_kpi_version_suffix(kpi)
        kpi_mapping[kpi] = kpi_without_suffix
        kpi_names_without_suffix.add(kpi_without_suffix)

    add_kpi_reference_sheet(wb, unique_kpi_names, kpi_mapping, str(constraint_dir))

    # 7) Save
    if output_file is None:
        output_file = folder / "NR_Summary.xlsx"
    else:
        # If output_file is relative, place it in source_directory
        output_file = Path(output_file)
        if not output_file.is_absolute():
            output_file = folder / output_file

    wb.save(output_file)
    print(f"\n✓ Merge is ended : {output_file}")
    print(f"  - {len(dict_lines)} lines (KPI x Object)")
    print(f"  - {len(dict_dates)} columns of dates")

    return output_file


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python merge_nr_files.py <source_directory> [output_file.xlsx]")
        print("\nExamples:")
        print("  python merge_nr_files.py /path/to/folder")
        print("  python merge_nr_files.py /path/to/folder output.xlsx")
        sys.exit(1)

    source_directory = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        merge_nr_files(source_directory, output_file)
    except (FileNotFoundError, ValueError) as e:
        print(f"\n{str(e)}")
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
