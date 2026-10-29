from datetime import datetime, timedelta


def convert_to_utc(input_time_str):
    """
    :param input_time_str: Time string in UTC current, e.g., '2025-05-15 4:00:09.041620' or '2025-05-15 14:15:00'.
    :return: Time string in UTC-15min.
    """
    # Define possible formats
    formats = ["%Y-%m-%d %H:%M:%S.%f", "%Y-%m-%d %H:%M:%S"]

    # Parse the input time string
    for fmt in formats:
        try:
            utc_current_time = datetime.strptime(input_time_str, fmt)
            break
        except ValueError:
            continue
    else:
        raise ValueError(
            "Invalid time format. Supported formats: 'YYYY-MM-DD HH:MM:SS' or 'YYYY-MM-DD HH:MM:SS.ssssss'")

    # minus 15min
    utc_time = utc_current_time - timedelta(minutes=15)

    # Return the new time as a string
    return utc_time.strftime("%Y-%m-%d %H:%M")


def get_comparator_report_id(data):
    """
    Extracts the ID from the comparator_reports field in the given data.

    :param data: List of dictionaries containing the report data.
    :return: The ID of the comparator report, or None if not found.
    """
    if not data or not isinstance(data, list):
        return None

    for item in data:
        if 'comparator_reports' in item and isinstance(item['comparator_reports'], list):
            for report in item['comparator_reports']:
                if 'id' in report:
                    return report['id']
    return None
