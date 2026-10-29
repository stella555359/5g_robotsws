#!/usr/bin/env python3
"""
Script to remove duplicate constraints from file1 that exist in file2.
Removes lines from file1 where the (oam_id, Counter_or_KPI) pair exists in file2.

Usage:
    python remove_constraint_duplicates.py <file1> <file2> [output_file]

Example:
    python remove_constraint_duplicates.py bkg_16UEs_SFE_TMO_VoNR_HO_15min_ext01.csv bkg_16UEs_SFE_TMO_VoNR_HO_15min.csv
"""

import sys
import csv
from pathlib import Path


def parse_constraint_file(filepath):
    """
    Parse constraint file and extract (oam_id, counter) pairs.

    Returns:
        tuple: (header_lines, data_lines, constraint_set)
            - header_lines: list of comment/header lines
            - data_lines: list of tuples (line_text, oam_id, counter)
            - constraint_set: set of (oam_id, counter) tuples
    """
    header_lines = []
    data_lines = []
    constraint_set = set()

    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    for line in lines:
        stripped = line.strip()

        # Keep header/comment lines
        if not stripped or stripped.startswith('#'):
            header_lines.append(line)
            continue

        # Parse data line
        fields = [f.strip() for f in line.split(';')]

        if len(fields) >= 2:
            oam_id = fields[0].strip()
            counter = fields[1].strip()

            # Store line with its key
            data_lines.append((line, oam_id, counter))
            constraint_set.add((oam_id, counter))

    return header_lines, data_lines, constraint_set


def remove_duplicates(file1, file2, output_file=None):
    """
    Remove constraints from file1 that exist in file2.

    Args:
        file1: Path to file with potential duplicates (will be cleaned)
        file2: Path to reference file (duplicates source)
        output_file: Optional output file path (default: overwrite file1)
    """
    print(f"Reading reference file: {file2}")
    _, _, ref_constraints = parse_constraint_file(file2)
    print(f"  Found {len(ref_constraints)} unique constraints in reference file")

    print(f"\nReading file to clean: {file1}")
    with open(file1, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Process lines
    output_lines = []
    removed_count = 0
    data_count = 0

    for line in lines:
        stripped = line.strip()

        # Keep all comment/empty lines
        if not stripped or stripped.startswith('#'):
            output_lines.append(line)
            continue

        # Parse data line
        fields = [f.strip() for f in line.split(';')]

        if len(fields) >= 2:
            data_count += 1
            oam_id = fields[0].strip()
            counter = fields[1].strip()

            # Check if duplicate
            if (oam_id, counter) in ref_constraints:
                removed_count += 1
                print(f"  Removing duplicate: {oam_id} ; {counter}")
            else:
                output_lines.append(line)
        else:
            # Keep malformed lines
            output_lines.append(line)

    # Determine output file
    if output_file is None:
        output_file = file1

    # Write result
    print(f"\nWriting cleaned file: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(output_lines)

    print(f"\n✓ Done!")
    print(f"  - Original data lines: {data_count}")
    print(f"  - Removed duplicates: {removed_count}")
    print(f"  - Remaining data lines: {data_count - removed_count}")

    return data_count - removed_count


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    file1 = sys.argv[1]
    file2 = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else None

    # Validate files exist
    if not Path(file1).exists():
        print(f"ERROR: File not found: {file1}")
        sys.exit(1)

    if not Path(file2).exists():
        print(f"ERROR: File not found: {file2}")
        sys.exit(1)

    remove_duplicates(file1, file2, output_file)


if __name__ == "__main__":
    main()
