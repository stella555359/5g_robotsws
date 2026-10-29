import json
from robot.api import logger
from typing import List, Dict, Any
from dataclasses import dataclass, field


# --- Standalone Helper Functions ---
def _check_substring_exists(data, target_substring):
    """Iteratively checks if any key or string value contains the target substring (case-insensitive)."""
    target_lower = target_substring.lower()
    stack = [data]
    while stack:
        current = stack.pop()
        if isinstance(current, dict):
            for key, value in current.items():
                if target_lower in key.lower():
                    return True
                stack.append(value)
        elif isinstance(current, list):
            for item in current:
                stack.append(item)
        elif isinstance(current, str):
            if target_lower in current.lower():
                return True
            if current.strip().startswith(("{", "[")):
                try:
                    stack.append(json.loads(current))
                except json.JSONDecodeError:
                    pass
    return False


def _find_values_for_key_substring(data, key_substring):
    """A robust iterative search for values where the key contains a substring."""
    results = []
    key_lower = key_substring.lower()
    stack = [data]
    while stack:
        current = stack.pop()
        if isinstance(current, dict):
            for key, value in current.items():
                if key_lower in key.lower():
                    results.append(value)
                stack.append(value)
        elif isinstance(current, list):
            for item in current:
                stack.append(item)
        elif isinstance(current, str):
            if current.strip().startswith(("{", "[")):
                try:
                    stack.append(json.loads(current))
                except json.JSONDecodeError:
                    pass
    return results


def _compare_values_local(expected, actual):
    """A simple comparison logic that handles empty lists as a wildcard."""
    if not expected:
        return True

    if not isinstance(expected, list):
        expected = [expected]
    if not isinstance(actual, list):
        actual = [actual]

    expected_str = {str(e) for e in expected}
    actual_str = {str(a) for a in actual}
    return expected_str.issubset(actual_str)


# --- Main Keywords ---


class AwaitedMessageNotFoundError(Exception):
    pass


@dataclass
class AwaitedMessage:
    name: str
    fields: Dict[str, List[Any]] = field(default_factory=dict)


def expect_flow(file_path: str, display_filter: str, item: str):
    """Standalone function to find the last occurrence of an item in a log file."""
    last_found_item = None
    try:
        with open(file_path, "r") as f:
            for line in f:
                try:
                    data_to_search = json.loads(line)
                    all_occurrences = _find_values_for_key_substring(
                        data_to_search, item
                    )

                    if all_occurrences:
                        current_item_content = all_occurrences[-1]
                        if item == "cellReselectionPriorities":
                            result = {}
                            priorities = current_item_content
                            for list_name in [
                                "freqPriorityListEUTRA",
                                "freqPriorityListNR",
                            ]:
                                for item_from_list in priorities.get(list_name, []):
                                    freq = item_from_list.get("carrierFreq")
                                    priority = item_from_list.get(
                                        "cellReselectionPriority"
                                    )
                                    if freq is not None and priority is not None:
                                        sub = item_from_list.get(
                                            "cellReselectionSubPriority"
                                        )
                                        if sub:
                                            sub_clean = sub.replace("oDot", "")
                                            result[str(freq)] = (
                                                f"{priority}.{sub_clean}"
                                            )
                                        else:
                                            result[str(freq)] = str(priority)
                            last_found_item = result
                        else:
                            last_found_item = current_item_content
                except (json.JSONDecodeError, KeyError):
                    continue
    except FileNotFoundError:
        raise AwaitedMessageNotFoundError(f"Log file not found: {file_path}")

    if last_found_item is not None:
        logger.warn(f"Found message '{item}' in the log file: {file_path}")
        return last_found_item

    raise IndexError(f"No '{item}' found in the log file: {file_path}")


def expect_flow_uecap(
    file_path: str,
    awaited_messages: List[AwaitedMessage],
    display_filter: str = None,
    json_format: str = "ndjson",
) -> None:
    """
    Checks if the awaited messages are present in the flow.
    This standalone version reads the file line-by-line to be memory efficient.
    """
    awaited_messages_iterator = iter(awaited_messages)
    try:
        current_awaited_message = next(awaited_messages_iterator)
    except StopIteration:
        return

    try:
        with open(file_path, "r") as f:
            for line_num, line in enumerate(f, 1):
                if current_awaited_message is None:
                    return

                try:
                    data_to_search = json.loads(line)

                    # Also check for UeRadioCapabilityInformation as requested
                    message_name_found = _check_substring_exists(
                        data_to_search, current_awaited_message.name
                    ) or (
                        current_awaited_message.name == "ueCapabilityInformation"
                        and _check_substring_exists(
                            data_to_search, "UeRadioCapabilityInformation"
                        )
                    )

                    if message_name_found:
                        # DEBUGGING: Log the full JSON object being analyzed.
                        logger.debug(
                            f"DEBUG Line {line_num}: Found entry for '{current_awaited_message.name}'. "
                            f"Analyzing JSON: {json.dumps(data_to_search, indent=2)}"
                        )

                        all_fields_match = True
                        for (
                            field_name,
                            expected_values,
                        ) in current_awaited_message.fields.items():
                            packet_field_values = _find_values_for_key_substring(
                                data_to_search, field_name
                            )
                            if not _compare_values_local(
                                expected_values, packet_field_values
                            ):
                                logger.warn(
                                    f"Field '{field_name}' did not match. Expected: {expected_values}, "
                                    f"Got: {packet_field_values}."
                                )
                                all_fields_match = False
                                break

                        if all_fields_match:
                            logger.warn(
                                f"Awaited message: {current_awaited_message.name} found and all fields match."
                            )
                            try:
                                current_awaited_message = next(
                                    awaited_messages_iterator
                                )
                            except StopIteration:
                                logger.warn(f"All awaited messages found.")
                                current_awaited_message = None
                                return

                except json.JSONDecodeError:
                    continue
                except Exception as e:
                    logger.debug(f"Error processing line {line_num}: {repr(e)}")
                    continue
    except FileNotFoundError:
        raise AwaitedMessageNotFoundError(f"Log file not found: {file_path}")

    if current_awaited_message is not None:
        logger.warn(f"Some awaited messages not found.")
        raise AwaitedMessageNotFoundError(
            f"Awaited message: {current_awaited_message.name} not found with matching fields in the log file."
        )


# --- Legacy functions for compatibility ---


def verify_that_t320_timer_configured_in_rrc_release_message(file_path, expected_value):
    t320 = expect_flow(file_path, "rrc", item="t320")
    assert t320 == expected_value, "t320 value does not match!"
    logger.warn("Timer t320 found in RRC release message and has correct value.")


def verify_that_t320_timer_not_configured_in_rrc_release_message(file_path):
    try:
        t320 = expect_flow(file_path, "rrc", item="t320")
        if t320:
            raise Exception(
                f"t320 timer with value '{t320}' appears, but it should not."
            )
    except (KeyError, IndexError):
        logger.warn(
            "Timer t320 did not found in RRC release message and that is expected."
        )
        return True
    return None


def verify_rrc_release_message_freq_reselection_priority(
    release_freq_prio_list, expected_freq_priority_list
):
    [
        list_of_freq_with_not_expected_priority,
        list_of_freq_not_exist_in_expected_list,
        list_of_rrc_release_freq,
    ] = get_lists_of_freq(release_freq_prio_list, expected_freq_priority_list)

    list_of_freq_not_exist_in_release_message = list(
        set(str(k) for k in expected_freq_priority_list.keys())
        - set(list_of_rrc_release_freq)
    )

    error_list = []
    if len(list_of_freq_with_not_expected_priority) > 0:
        error_list.append(
            "Following frequencies priority do not match: "
            + str(list_of_freq_with_not_expected_priority)
        )
    if len(list_of_freq_not_exist_in_expected_list) > 0:
        error_list.append(
            "Following frequencies do not exist in expected list: "
            + str(list_of_freq_not_exist_in_expected_list)
        )
    if len(list_of_freq_not_exist_in_release_message) > 0:
        error_list.append(
            "Following frequencies do not exist in RRC release message: "
            + str(list_of_freq_not_exist_in_release_message)
        )
    if error_list:
        logger.warn(f"Some frequencies do not match to the expected.")
        raise Exception(error_list)
    else:
        logger.warn(f"All frequencies do match to the expected.")
        return True


def get_lists_of_freq(release_freq_prio_list, expected_freq_priority_list):
    list_of_freq_with_not_expected_priority = []
    list_of_freq_not_exist_in_expected_list = []
    list_of_rrc_release_freq = []

    expected_str_keys = {str(k): str(v) for k, v in expected_freq_priority_list.items()}

    for carrierFreq_str in release_freq_prio_list.keys():
        if carrierFreq_str not in expected_str_keys:
            list_of_freq_not_exist_in_expected_list.append(carrierFreq_str)
        else:
            list_of_rrc_release_freq.append(carrierFreq_str)
            priority = release_freq_prio_list.get(carrierFreq_str)
            if priority != expected_str_keys.get(carrierFreq_str):
                list_of_freq_with_not_expected_priority.append(carrierFreq_str)

    return [
        list_of_freq_with_not_expected_priority,
        list_of_freq_not_exist_in_expected_list,
        list_of_rrc_release_freq,
    ]


def convert_trunk_sw_version(sw_version):
    if "9999" in str(sw_version):
        if "00" not in str(sw_version).split("_")[0]:
            return str(sw_version)[:4] + "00" + str(sw_version)[8:]
    return sw_version
