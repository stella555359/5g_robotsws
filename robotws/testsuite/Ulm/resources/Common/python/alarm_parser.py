"""
Module for parsing BTS raw alarm history files.

This module provides functions to extract and filter fault IDs from
alarm history files containing both active and inactive faults.

Robot Framework Library Scope: SUITE
"""

import re
import argparse
import json
from typing import Set, Optional, List, Dict, Tuple
from datetime import datetime
from collections import Counter

try:
    from robot.api.deco import keyword
    ROBOT_AVAILABLE = True
except ImportError:
    ROBOT_AVAILABLE = False
    # Dummy decorator when robot is not available

    def keyword(name=None):
        def decorator(func):
            return func
        return decorator


__all__ = ['no_alarm_should_be_present']


def _extract_fault_id(fault_id_str: str) -> Optional[int]:
    """Extract fault ID from string like '(7523)'."""
    match = re.search(r'\((\d+)\)', fault_id_str)
    return int(match.group(1)) if match else None


def _safe_int_conversion(value: str) -> int:
    """Safely convert string to integer, return 0 if not a digit."""
    return int(value) if value.isdigit() else 0


def _parse_fault_line(parts_clean: List[str], current_section: str) -> Optional[Dict]:
    """Parse a single fault line into a dictionary."""
    if len(parts_clean) < 9:
        return None

    fault_id = _extract_fault_id(parts_clean[1])

    return {
        'timestamp': parts_clean[0],
        'fault_id': fault_id,
        'fault_name': parts_clean[2] if len(parts_clean) > 2 else "",
        'fault_source': parts_clean[3] if len(parts_clean) > 3 else "",
        'node_id': parts_clean[4] if len(parts_clean) > 4 else "N/A",
        'last_10s': _safe_int_conversion(parts_clean[5]) if len(parts_clean) > 5 else 0,
        'last_min': _safe_int_conversion(parts_clean[6]) if len(parts_clean) > 6 else 0,
        'last_hour': _safe_int_conversion(parts_clean[7]) if len(parts_clean) > 7 else 0,
        'last_day': _safe_int_conversion(parts_clean[8]) if len(parts_clean) > 8 else 0,
        'all_count': _safe_int_conversion(parts_clean[9]) if len(parts_clean) > 9 else 0,
        'status': current_section
    }


def _is_section_header(line: str) -> Optional[str]:
    """Check if line is a section header and return section name."""
    if 'Active faults' in line:
        return 'active'
    if 'Inactive faults' in line:
        return 'inactive'
    return None


def _should_skip_line(stripped_line: str) -> bool:
    """Check if line should be skipped during parsing."""
    if not stripped_line:
        return True
    if stripped_line.startswith('='):
        return True
    if stripped_line.startswith('TimeStamp'):
        return True
    return False


def _process_fault_line(line: str, current_section: str,
                        active_faults: List[Dict], inactive_faults: List[Dict]) -> None:
    """Process a single fault data line and append to appropriate list."""
    if not current_section or '\t' not in line:
        return

    parts_clean = [p.strip() for p in line.split('\t')]
    fault_dict = _parse_fault_line(parts_clean, current_section)

    if fault_dict and current_section == 'active':
        active_faults.append(fault_dict)
    elif fault_dict and current_section == 'inactive':
        inactive_faults.append(fault_dict)


def _read_alarm_file(filename: str) -> Tuple[List[Dict], List[Dict]]:
    """Read and parse alarm file line by line."""
    active_faults = []
    inactive_faults = []
    current_section = None

    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            section = _is_section_header(line)
            if section:
                current_section = section
                continue

            if _should_skip_line(line.strip()):
                continue

            _process_fault_line(line, current_section, active_faults, inactive_faults)

    return active_faults, inactive_faults


def parse_alarm_table(filename: str) -> Tuple[List[Dict], List[Dict]]:
    """
    Parse the alarm history file and return structured data for active and inactive faults.

    Args:
        filename: Path to the raw alarm history file

    Returns:
        Tuple of (active_faults, inactive_faults) where each is a list of dictionaries

    Example:
        >>> active, inactive = parse_alarm_table('alarm_history.txt')
        >>> import pandas as pd
        >>> df_active = pd.DataFrame(active)
    """
    try:
        return _read_alarm_file(filename)
    except FileNotFoundError:
        raise FileNotFoundError(f"Alarm history file not found: {filename}")
    except Exception as e:
        raise Exception(f"Error parsing alarm history file: {str(e)}")


def _extract_fault_ids_from_list(faults: List[Dict]) -> Set[int]:
    """Extract unique fault IDs from a list of fault dictionaries."""
    return {fault['fault_id'] for fault in faults if fault['fault_id'] is not None}


def list_fault_ids(filename: str, whitelist: Optional[Set[int]] = None) -> Set[int]:
    """
    Parse all faults (active and passive) and return fault IDs not in the whitelist.

    Args:
        filename: Path to the raw alarm history file
        whitelist: Set of fault IDs to exclude. If None, all fault IDs are returned.

    Returns:
        Set of fault IDs (as integers) that are not in the whitelist
    """
    whitelist = whitelist or set()
    active_faults, inactive_faults = parse_alarm_table(filename)
    all_faults = active_faults + inactive_faults
    fault_ids = _extract_fault_ids_from_list(all_faults)
    return fault_ids - whitelist


def get_all_fault_ids(filename: str) -> Set[int]:
    """Get all fault IDs from the alarm history file."""
    return list_fault_ids(filename, whitelist=set())


def get_active_fault_ids(filename: str) -> Set[int]:
    """Get fault IDs from the active faults section only."""
    active_faults, _ = parse_alarm_table(filename)
    return _extract_fault_ids_from_list(active_faults)


def get_inactive_fault_ids(filename: str) -> Set[int]:
    """Get fault IDs from the inactive faults section only."""
    _, inactive_faults = parse_alarm_table(filename)
    return _extract_fault_ids_from_list(inactive_faults)


def _create_argument_parser() -> argparse.ArgumentParser:
    """Create and configure the command-line argument parser."""
    parser = argparse.ArgumentParser(
        description='Parse BTS raw alarm history files and extract fault information.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Examples:
  python alarm_parser.py file.txt --list-ids
  python alarm_parser.py file.txt --list-ids --whitelist 7523 61649
  python alarm_parser.py file.txt --export-json output.json --active-only
  python alarm_parser.py file.txt --stats"""
    )

    parser.add_argument('filename', help='Path to the raw alarm history file')
    parser.add_argument('--list-ids', action='store_true',
                        help='List all fault IDs (or filtered by whitelist)')
    parser.add_argument('--whitelist', nargs='*', type=int, metavar='ID',
                        help='Fault IDs to exclude from the list')
    parser.add_argument('--active-only', action='store_true', help='Process only active faults')
    parser.add_argument('--inactive-only', action='store_true', help='Process only inactive faults')
    parser.add_argument('--export-json', metavar='FILE', help='Export fault data to JSON file')
    parser.add_argument('--stats', action='store_true', help='Show statistics about the faults')
    return parser


def _select_faults_to_process(active_faults: List[Dict], inactive_faults: List[Dict],
                              active_only: bool, inactive_only: bool) -> Tuple[List[Dict], str]:
    """Select which faults to process based on command-line flags."""
    if active_only:
        return active_faults, "Active"
    if inactive_only:
        return inactive_faults, "Inactive"
    return active_faults + inactive_faults, "All"


def _handle_list_ids_command(filename: str, whitelist_arg: Optional[List[int]]) -> None:
    """Handle the --list-ids command."""
    whitelist = set(whitelist_arg) if whitelist_arg else set()
    fault_ids = list_fault_ids(filename, whitelist)
    print(f"Fault IDs (excluding whitelist: {whitelist}):")
    print(sorted(fault_ids))
    print(f"\nTotal: {len(fault_ids)} unique fault IDs")


def _create_export_data(active_faults: List[Dict], inactive_faults: List[Dict],
                        inactive_only: bool, active_only: bool) -> Dict:
    """Create the data structure for JSON export."""
    return {
        'active_faults': active_faults if not inactive_only else [],
        'inactive_faults': inactive_faults if not active_only else [],
        'metadata': {
            'total_active': len(active_faults),
            'total_inactive': len(inactive_faults),
            'parsed_at': datetime.now().isoformat()
        }
    }


def _handle_export_json_command(filename: str, active_faults: List[Dict],
                                inactive_faults: List[Dict], section_name: str,
                                inactive_only: bool, active_only: bool) -> None:
    """Handle the --export-json command."""
    output_data = _create_export_data(active_faults, inactive_faults, inactive_only, active_only)
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2)
    print(f"Exported {section_name.lower()} faults to {filename}")


def _print_basic_stats(active_faults: List[Dict], inactive_faults: List[Dict],
                       active_only: bool, inactive_only: bool) -> None:
    """Print basic statistics about active and inactive faults."""
    if not inactive_only:
        active_ids = _extract_fault_ids_from_list(active_faults)
        print(f"Active faults: {len(active_faults)}")
        print(f"Unique active fault IDs: {len(active_ids)}")

    if not active_only:
        inactive_ids = _extract_fault_ids_from_list(inactive_faults)
        print(f"Inactive faults: {len(inactive_faults)}")
        print(f"Unique inactive fault IDs: {len(inactive_ids)}")


def _print_common_faults(faults_to_process: List[Dict]) -> None:
    """Print the most common fault IDs and their names."""
    all_ids = _extract_fault_ids_from_list(faults_to_process)
    print(f"\nTotal unique fault IDs: {len(all_ids)}")
    print(f"Most common fault IDs:")

    id_counts = Counter(f['fault_id'] for f in faults_to_process if f['fault_id'])
    for fault_id, count in id_counts.most_common(5):
        fault_name = next((f['fault_name'] for f in faults_to_process
                          if f['fault_id'] == fault_id), "Unknown")
        print(f"  ({fault_id}) {fault_name}: {count} occurrences")


def _handle_stats_command(section_name: str, active_faults: List[Dict],
                          inactive_faults: List[Dict], faults_to_process: List[Dict],
                          active_only: bool, inactive_only: bool) -> None:
    """Handle the --stats command."""
    print(f"\n{section_name} Faults Statistics:")
    print(f"{'='*60}")
    _print_basic_stats(active_faults, inactive_faults, active_only, inactive_only)

    if not active_only and not inactive_only:
        _print_common_faults(faults_to_process)


def _show_default_summary(filename: str, active_faults: List[Dict],
                          inactive_faults: List[Dict]) -> None:
    """Show brief summary when no action is specified."""
    print(f"Parsed {filename}")
    print(f"Active faults: {len(active_faults)}")
    print(f"Inactive faults: {len(inactive_faults)}")
    print(f"\nUse --help to see available options")


@keyword("No Alarm Should Be Present")
def no_alarm_should_be_present(filename: str, whitelist_ids=None):
    """
    Robot Framework keyword to verify no active alarms are present.

    This keyword fails if any active alarms are found that are not in the whitelist.

    Arguments:
        filename: Path to the raw alarm history file
        *whitelist_ids: Optional fault IDs to ignore (space-separated integers)

    Raises:
        AssertionError: If active alarms are present that are not whitelisted

    Examples:
        | No Alarm Should Be Present | alarm_history.txt |
        | No Alarm Should Be Present | alarm_history.txt | 7523 | 61649 | 4654 |
    """
    if whitelist_ids:
        whitelist = {x.strip() for x in whitelist_ids.split(",")}
    else:
        whitelist = set()
    active_ids = get_active_fault_ids(filename)
    non_whitelisted = active_ids - whitelist

    if not non_whitelisted:
        return f"No active alarms present (whitelist: {sorted(whitelist)})"

    # Build detailed error message
    active_faults, _ = parse_alarm_table(filename)
    problem_faults = [f for f in active_faults if f['fault_id'] in non_whitelisted]

    error_lines = [f"Found {len(non_whitelisted)} unexpected active alarm(s):"]
    error_lines.append("")

    for fault in problem_faults[:10]:
        error_lines.append(
            f"  - Fault ID {fault['fault_id']}: {fault['fault_name']}"
        )
        error_lines.append(f"    Source: {fault['fault_source']}")
        error_lines.append(f"    Time: {fault['timestamp']}")

    if len(problem_faults) > 10:
        error_lines.append(f"  ... and {len(problem_faults) - 10} more")

    error_lines.append("")
    error_lines.append(f"Fault IDs: {sorted(non_whitelisted)}")

    if whitelist:
        error_lines.append(f"Whitelisted IDs: {sorted(whitelist)}")

    raise AssertionError("\n".join(error_lines))


def main():
    """Command-line interface for the alarm parser."""
    parser = _create_argument_parser()
    args = parser.parse_args()

    try:
        active_faults, inactive_faults = parse_alarm_table(args.filename)
        faults_to_process, section_name = _select_faults_to_process(
            active_faults, inactive_faults, args.active_only, args.inactive_only
        )

        if args.list_ids:
            _handle_list_ids_command(args.filename, args.whitelist)

        if args.export_json:
            _handle_export_json_command(args.export_json, active_faults, inactive_faults,
                                        section_name, args.inactive_only, args.active_only)

        if args.stats:
            _handle_stats_command(section_name, active_faults, inactive_faults,
                                  faults_to_process, args.active_only, args.inactive_only)

        if not any([args.list_ids, args.export_json, args.stats]):
            _show_default_summary(args.filename, active_faults, inactive_faults)

        return 0
    except Exception as e:
        print(f"Error: {e}")
        return 1


if __name__ == '__main__':
    exit(main())
