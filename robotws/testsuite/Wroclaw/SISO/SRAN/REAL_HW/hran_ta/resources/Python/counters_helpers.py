from robot.api import logger
import datetime


def find_key_in_nested_dictionary(nested_dict, target_key):
    """
    Recursively searches for a key in a nested dictionary and returns its value.

    Args:
        nested_dict (dict): The dictionary to search within.
        target_key (str): The key to search for.

    Returns:
        list: A list of values associated with the target key if found, otherwise an empty list.
    """
    found_values = []

    if isinstance(nested_dict, dict):
        for key, value in nested_dict.items():
            if key == target_key:
                found_values.append(value)
            if isinstance(value, dict):
                found_values.extend(find_key_in_nested_dictionary(value, target_key))
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, dict):
                        found_values.extend(find_key_in_nested_dictionary(item, target_key))

    return found_values


def check_dictionary_values_in_range(dictionary, min_value, max_value):
    """
    Checks if all values in the dictionary are within the specified range.

    Args:
        dictionary (dict): The dictionary with values to check.
        min_value (int): The minimum value of the range.
        max_value (int): The maximum value of the range.

    Returns:
        bool: True if all values are within the range, False otherwise.
    """
    all_in_range = True

    for key, value in dictionary.items():
        if not (int(min_value) <= int(value) <= int(max_value)):
            all_in_range = False
            logger.info(f"Value '{value}' of key '{key}' is not in the range of {min_value} to {max_value}")
    return all_in_range


def get_last_timestamp_from_counters_dictionary(counters_dict, time_format='epoch'):
    """
    Retrieves the last timestamp from a counters dictionary.

    Args:
        counters_dict (dict): The dictionary containing counters with timestamps as keys.
        time_format (str): The format of the returned timestamp. 'epoch' or 'human'. Defaults to 'epoch'.

    Returns:
        int or str: The last timestamp in the specified format. Returns an integer if 'epoch', or a string if 'human'.
    """
    for timestamp in sorted(counters_dict.keys(), reverse=True):
        if time_format == 'epoch':
            return timestamp
        elif time_format == 'human':
            return datetime.datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')


def validate_epoch_timestamp(timestamp):
    """
    Checks if the given timestamp is a valid epoch timestamp.

    Args:
        timestamp (str): The timestamp to check.

    Returns:
        bool: True if the timestamp is a valid epoch timestamp, False otherwise.
    """
    try:
        datetime.datetime.fromtimestamp(int(timestamp))
        return True
    except ValueError:
        return False


def check_if_all_elements_in_list_equal(lst):
    """
    Checks if all elements in the list are equal.

    Args:
        lst (list): The list to check.

    Returns:
        bool: True if all elements in the list are equal, False otherwise.
    """
    return all(x == lst[0] for x in lst)


def get_status_of_max_difference_between_counters(counter_values_list, max_difference):
    """
       Checks if the maximum difference between counter values in the list is within the specified percentage.

       Args:
           counter_values_list (list): The list of counter values to check.
           max_difference (str): The maximum allowed difference as a percentage (e.g., '10%').

       Returns:
           bool: True if the maximum difference is within the specified percentage, False otherwise.
       """
    fraction = float(max_difference.strip('%')) / 100
    result = (lambda counter_values_list: all(abs(a - b) / b <= fraction for i, a in enumerate(counter_values_list)
                                              for b in counter_values_list[i + 1:]))(counter_values_list)
    return result
