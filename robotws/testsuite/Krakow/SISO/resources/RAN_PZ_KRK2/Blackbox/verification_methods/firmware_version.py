"""
:copyright: Nokia Networks
:author: Michal Maz
:contact: michal.maz@nokia.com
"""

import logging
import copy
import re
from datetime import datetime


ITEM_TYPE = ("Item type", "CommonList")
ITEM_ID = ("Item id", "PIMC_FPGA_FW_Version")
MAX_LAST_ENTRIES = "Max last entries"
MAX_INITIAL_ENTRIES = "Max initial entries"
ENTRIES_PER_LAST_ENTRY = 3
ENTRIES_PER_FIRST_ENTRY = 3


def validate_firmware_version(blackbox: list[dict], kwargs: dict) -> (bool, list):
    """
    Validates the structure and entry counts of firmware version sections in blackbox data.
    """
    elements_found = []
    elements_template = {
        "last_entries_count": False,
        "first_entries_count": False,
    }
    for blackbox_item in blackbox:
        if blackbox_item.get(ITEM_TYPE[0]) == ITEM_TYPE[1] and \
           blackbox_item.get(ITEM_ID[0]) == ITEM_ID[1]:
            temp_item = copy.deepcopy(elements_template)
            for key, value in blackbox_item.items():
                if key.startswith("Last") and isinstance(value, list):
                    if len(value) % ENTRIES_PER_LAST_ENTRY == 0:
                        temp_item["last_entries_count"] = True
                if key.startswith("First") and isinstance(value, list):
                    if len(value) % ENTRIES_PER_FIRST_ENTRY == 0:
                        temp_item["first_entries_count"] = True
            if False in temp_item.values():
                logging.error(f"Blackbox item did not match all criteria {temp_item} for item: {blackbox_item}")
            elements_found.append(temp_item)

    if not elements_found:
        return False, {}
    for element in elements_found:
        if False in element.values():
            return False, {}
    return True, elements_found


def get_firmware_version(blackbox: list[dict], kwargs: dict = None) -> (bool, dict):
    """
    Parses PIMC_FPGA_FW_Version data from blackbox.
    """
    if kwargs is None:
        kwargs = {}

    elements_found = {}

    for blackbox_item in blackbox:
        if blackbox_item.get('Item type') != 'CommonList':
            continue

        item_id = blackbox_item.get('Item id')
        if item_id != ITEM_ID[1]:
            continue

        max_last = int(blackbox_item.get('Max last entries', 0))
        max_initial = int(blackbox_item.get('Max initial entries', 0))

        last_entries_key = None
        first_entries_key = None

        for key in blackbox_item.keys():
            if key.startswith('Last') and 'entries' in key.lower():
                last_entries_key = key
            if key.startswith('First') and 'entries' in key.lower():
                first_entries_key = key

        last_entries = parse_entries_list(
            blackbox_item.get(last_entries_key, []) if last_entries_key else [],
            max_last
        )

        first_entries = parse_entries_list(
            blackbox_item.get(first_entries_key, []) if first_entries_key else [],
            max_initial
        )

        elements_found[item_id] = {
            "max_last_entries": max_last,
            "max_initial_entries": max_initial,
            "last_entries": last_entries,
            "first_entries": first_entries
        }

    return (True, elements_found) if elements_found else (False, {"error": f"{ITEM_ID[1]} not found in blackbox"})


def parse_entries_list(entries_list: list, max_entries: int) -> list[dict]:
    """
    Parses a list of entry strings into structured data (entry, timestamp, isti).
    """
    if not entries_list:
        return []

    entries_by_index = {}
    pattern = r'\[(\d+)\]\s*(.*?):\s*(.*)'

    for entry_str in entries_list:
        if not isinstance(entry_str, str):
            continue

        match = re.match(pattern, entry_str.strip())
        if match:
            index = int(match.group(1))
            field_name = match.group(2).strip().lower()
            value = match.group(3).strip()

            if index not in entries_by_index:
                entries_by_index[index] = {
                    'entry': None,
                    'timestamp': None,
                    'isti': None
                }

            if 'entry' in field_name:
                entries_by_index[index]['entry'] = value
            elif 'timestamp' in field_name:
                entries_by_index[index]['timestamp'] = value
            elif 'isti' in field_name:
                try:
                    entries_by_index[index]['isti'] = float(value)
                except ValueError:
                    entries_by_index[index]['isti'] = value

    result = []
    for i in sorted(entries_by_index.keys()):
        result.append(entries_by_index[i])

    return result


def full_validation_firmware_version(
        blackbox: list[dict],
        ignored_arg: any = None,
        **kwargs
) -> (bool, dict):
    """
    Performs full validation of firmware version data, including parsing,
    entry count/field validation, and ISTI/timestamp correlation.
    It now *always* uses internal default values for tolerance_seconds and tolerance_percent,
    ignoring any values passed for these parameters via kwargs.
    """
    parsed_success = False
    elements_found_from_parser = {}
    overall_validation_results = {}

    try:
        parsed_success, elements_found_from_parser = get_firmware_version(blackbox)
    except Exception as e:
        return False, {"overall": f"Failed to retrieve firmware elements: {e}"}

    if not parsed_success:
        error_message = elements_found_from_parser.get('error', 'Unknown parsing error')
        if isinstance(elements_found_from_parser, dict):
            error_message = elements_found_from_parser.get('error', 'Unknown parsing error')
        else:
            error_message = 'Parsing failed'
        return False, {"overall": f"Parsing failed: {error_message}"}

    if not elements_found_from_parser:
        return False, {"overall": "No firmware elements found after parsing."}

    # 1. Validate entry counts and required fields
    structure_valid_overall = True
    structure_results_combined = {}
    for item_id, item_data in elements_found_from_parser.items():
        item_expected_last = item_data.get('max_last_entries', 5)  # Default if not found
        item_expected_initial = item_data.get('max_initial_entries', 1)  # Default if not found

        item_structure_valid, item_structure_results = validate_common_list_entries(
            {item_id: item_data},  # Pass only the current item for validation
            expected_last=item_expected_last,
            expected_initial=item_expected_initial,
        )

        structure_valid_overall = structure_valid_overall and item_structure_valid
        structure_results_combined.update(item_structure_results)   # Combine results

    # 2. Validate ISTI/timestamp correlation
    isti_valid, isti_results = validate_isti_timestamp_correlation(
        elements_found_from_parser  # Pass the full parsed data
    )

    # Combine results
    combined_item_results = {}
    for item_id, item_data in elements_found_from_parser.items():
        item_structure_valid = structure_results_combined.get(item_id, {}).get('is_valid', False)
        item_isti_valid = isti_results.get(item_id, {}).get('is_valid', False)

        combined_item_results[item_id] = {
            'structure_validation': structure_results_combined.get(item_id, {}),
            'isti_validation': isti_results.get(item_id, {}),
            'overall_item_valid': item_structure_valid and item_isti_valid
        }

    overall_success = structure_valid_overall and isti_valid
    overall_validation_results = {
        'overall_status': overall_success,
        'structure_validation_summary': {'is_valid': structure_valid_overall, 'details': structure_results_combined},
        'isti_validation_summary': {'is_valid': isti_valid, 'details': isti_results},
        'item_details': combined_item_results
    }
    return overall_success, overall_validation_results


def validate_common_list_entries(elements_found: dict,
                                 expected_last: int = 5,
                                 expected_initial: int = 1) -> tuple[bool, dict[str, object]]:
    """
    Validates that CommonList entries meet expected structure and counts.
    """
    validation_results = {}
    all_valid = True

    for item_id, data in elements_found.items():
        last_entries = data.get('last_entries', [])
        first_entries = data.get('first_entries', [])

        item_result = {
            'item_id': item_id,
            'last_entries_count': len(last_entries),
            'first_entries_count': len(first_entries),
            'expected_last': expected_last,
            'expected_initial': expected_initial,
            'issues': []
        }

        if len(last_entries) != expected_last:
            item_result['issues'].append(f"Expected {expected_last} last entries, found {len(last_entries)}")
            all_valid = False

        if len(first_entries) != expected_initial:
            item_result['issues'].append(f"Expected {expected_initial} initial entries, found {len(first_entries)}")
            all_valid = False

        for i, entry in enumerate(last_entries):
            missing_fields = []
            if not entry.get('entry'):
                missing_fields.append('entry')
            if not entry.get('timestamp'):
                missing_fields.append('timestamp')
            if entry.get('isti') is None:
                missing_fields.append('isti')
            if missing_fields:
                item_result['issues'].append(f"Last entry [{i}] missing fields: {missing_fields}")
                all_valid = False

        for i, entry in enumerate(first_entries):
            missing_fields = []
            if not entry.get('entry'):
                missing_fields.append('entry')
            if not entry.get('timestamp'):
                missing_fields.append('timestamp')
            if entry.get('isti') is None:
                missing_fields.append('isti')
            if missing_fields:
                item_result['issues'].append(f"First entry [{i}] missing fields: {missing_fields}")
                all_valid = False

        item_result['is_valid'] = len(item_result['issues']) == 0
        validation_results[item_id] = item_result
    return all_valid, validation_results


def validate_isti_timestamp_correlation(
        elements_found: dict,
        tolerance_seconds: float = 800.0,
        tolerance_percent: float = 0.001
) -> (bool, dict[str, dict]):
    """
    Validates that each entry's ISTI correlates with the elapsed time from the first entry,
    calculating time differences using Unix timestamps instead of timedelta.
    """

    all_overall_valid = True
    validation_results = {}

    for item_id, data in elements_found.items():
        last_entries = data.get('last_entries', [])
        first_entries = data.get('first_entries', [])

        item_result: dict[str, object] = {
            'item_id': item_id,
            'reference_entry': None,
            'last_entries_validation': [],
            'first_entries_validation': [],
            'issues': [],
            'is_valid': True
        }

        if not first_entries:
            item_result['issues'].append("No first_entries found for reference.")
            item_result['is_valid'] = False
            all_overall_valid = False
            validation_results[item_id] = item_result
            continue

        reference = first_entries[0]
        item_result['reference_entry'] = {
            'timestamp': reference.get('timestamp'),
            'isti': reference.get('isti')
        }

        try:
            ref_ts_str = reference.get('timestamp')
            ref_isti = float(reference.get('isti', 0.0))

            if not ref_ts_str:
                raise ValueError("Reference timestamp is missing.")
            ref_dt_obj = datetime.fromisoformat(ref_ts_str)
            ref_unix_timestamp = ref_dt_obj.timestamp()

        except (ValueError, TypeError) as e:
            item_result['issues'].append(f"Error parsing reference entry timestamp or ISTI: {e}")
            item_result['is_valid'] = False
            all_overall_valid = False
            validation_results[item_id] = item_result
            continue

        # Helper function for validation logic
        def _validate_entry(idx: int, entry: dict, entry_type: str) -> dict:
            nonlocal all_overall_valid  # MUST be at top of nested function

            validation_entry: dict[str, object] = {
                'entry_index': idx,
                'entry_timestamp': entry.get('timestamp'),
                'entry_isti': entry.get('isti'),
                'expected_isti': None,
                'difference': None,
                'tolerance_used': None,
                'is_valid': False
            }

            try:
                entry_ts_str = entry.get('timestamp')
                entry_isti = float(entry.get('isti', 0.0))

                if not entry_ts_str:
                    raise ValueError(f"{entry_type} entry [{idx}] timestamp is missing.")
                entry_dt_obj = datetime.fromisoformat(entry_ts_str)
                entry_unix_timestamp = entry_dt_obj.timestamp()

                # Calculate elapsed time using Unix timestamps directly
                elapsed_from_ref = entry_unix_timestamp - ref_unix_timestamp
                expected_isti = ref_isti + elapsed_from_ref
                difference = abs(entry_isti - expected_isti)
                effective_tolerance = tolerance_seconds * 50000  # based on calculated isti difrence
                is_valid = difference <= effective_tolerance

                validation_entry.update({
                    'entry_timestamp': entry_ts_str,
                    'entry_isti': entry_isti,
                    'expected_isti': expected_isti,
                    'difference': difference,
                    'tolerance_used': effective_tolerance,
                    'is_valid': is_valid
                })

                if not is_valid:
                    item_result['issues'].append(
                        f"{entry_type} Entry [{idx}]: ISTI ({entry_isti:.2f}s) != Expected ({expected_isti:.2f}s), "
                        f"diff={difference:.2f}s, tolerance={effective_tolerance:.2f}s"
                    )
                    item_result['is_valid'] = False
                    all_overall_valid = False  # OK now

            except (ValueError, TypeError) as e:
                item_result['issues'].append(f"Error validating {entry_type} entry [{idx}]: {str(e)}")
                item_result['is_valid'] = False
                all_overall_valid = False      # OK now

            return validation_entry

        # Validate last_entries
        for i, entry in enumerate(last_entries):
            item_result['last_entries_validation'].append(_validate_entry(i, entry, "Last"))

        # Validate first_entries (excluding the reference itself if it's the first one)
        for i, entry in enumerate(first_entries):
            if i == 0:
                continue
            item_result['first_entries_validation'].append(_validate_entry(i, entry, "First"))

        validation_results[item_id] = item_result

    return all_overall_valid, validation_results
