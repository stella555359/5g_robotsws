"""
:modified: 03.11.2024
"""

from robot.api import logger
from datetime import datetime
from robot.api.deco import keyword

ROBOT_AUTO_KEYWORDS = False


@keyword('Uptime Radio Convert Time In Days To Seconds')
def uptime_radio_converter_time_in_days_to_seconds(time_str):
    """
    Converts a custom time string to seconds.

    Args:
        time_str (str): A string representing the time in the format 'number unit time_part',
                        where 'unit' can be 'day(s)', 'week(s)', or 'month(s)', and 'time_part' is in 'HH:MM:SS' format.

    Returns:
        int: The total time in seconds.

    Raises:
        ValueError: If the time format is incorrect.
    """
    parts = time_str.split(' ', 2)
    print(f"Number: {parts}")
    number = int(parts[0])
    unit = parts[1]
    time_part = parts[2]
    if unit == 'day' or unit == 'days':
        unit_in_seconds = number * 24 * 3600
    elif unit == 'week' or unit == 'weeks':
        unit_in_seconds = number * 7 * 24 * 3600
    elif unit == 'month' or unit == 'months':
        unit_in_seconds = number * 30 * 24 * 3600  # Przyjmując 30 dni w miesiącu
    else:
        raise ValueError("Wrong Time Format")
    hours, minutes, seconds = map(int, time_part.split(':'))
    time_in_seconds = hours * 3600 + minutes * 60 + seconds
    total_seconds = unit_in_seconds + time_in_seconds

    return total_seconds


@keyword('Uptime Radio Convert Time To Seconds')
def uptime_radio_converter_time_to_seconds(time_str):
    """
    Converts a time string to seconds.

    Args:
        time_str (str): A string representing the time in one of the following formats:
                        'HH:MM', 'xx min', or 'xx days'.

    Returns:
        int: The total time in seconds.

    Raises:
        ValueError: If the time format is incorrect.
    """
    if ':' in time_str:
        hours, minutes = map(int, time_str.split(':'))
        return hours * 3600 + minutes * 60
    elif 'min' in time_str:
        minutes = int(time_str.split()[0])
        return minutes * 60
    elif 'days' in time_str:
        days = int(time_str.split()[0])
        return days * 86400
    elif time_str.isdigit():
        return int(time_str) * 60
    else:
        raise ValueError("Wrong Time Format")
