import time
from time_convert import time_str_to_utc_timestamp

__all__ = [
    "filter_operation_history"
]


def filter_operation_history(ope_history, start_timestamp, end_timestamp=None, ope_name_substring=None, target=None):
    """
    Filters operation history based on given criteria.

    :param ope_history: List of operation history items.
    :param start_timestamp: Start timestamp for filtering.
    :param end_timestamp: End timestamp for filtering (optional).
    :param ope_name_substring: Substring to match operation names (optional).
    :param target: Target to match in operation targets (optional).
    :return: List of filtered operation history items.
    """
    target_ope_list = []
    for item in ope_history:
        print("############item###################")
        print(item)
        if (
            ope_name_substring
            and ope_name_substring.lower() not in item['name'].lower()
        ):
            continue

        if target and target not in item['targets']:
            continue

        item_start_timestamp = time_str_to_utc_timestamp(
            time_str=item['start_time'],
            time_format='%Y-%m-%dT%H:%M:%S.%f%z',
        )
        convert_start_timestamp = time_str_to_utc_timestamp(
            time_str=start_timestamp,
            time_format='%Y-%m-%dT%H:%M:%S.%f%z',
        )
        if int(item_start_timestamp) < int(convert_start_timestamp):
            continue
        if end_timestamp and int(item_start_timestamp) > int(end_timestamp):
            continue
        target_ope_list.append(item)
    return target_ope_list
