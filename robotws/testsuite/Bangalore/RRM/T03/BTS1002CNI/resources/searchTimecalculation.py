import re
from datetime import datetime


def search_pattern_in_file(file_path, pattern):
    """
    Searches for the first occurrence of a given regex pattern in a file.

    :param file_path: Path to the file to be searched.
    :param pattern: Regex pattern to match.
    :return: The first matched string or "No match found".
    """
    try:
        with open(file_path, "r") as file:
            for line in file:
                match = re.search(pattern, line)
                if match:
                    return match.group(0)  # Return first matched pattern
        return "No match found"
    except FileNotFoundError:
        return f"Error: The file '{file_path}' does not exist."
    except Exception as e:
        return f"Error: {e}"


def calculate_time_difference(timestamp1, timestamp2):
    """Calculates the time difference in milliseconds between two timestamps."""
    try:
        time1 = datetime.strptime(timestamp1, "%H:%M:%S.%f")
        time2 = datetime.strptime(timestamp2, "%H:%M:%S.%f")
        print("time1", time1)
        print("time2", time2)
        time_diff = (time1 - time2).total_seconds() * 1e6  # Convert to milliseconds
        return int(time_diff / 1000)  # Ensure only integer value is returned
    except Exception as e:
        return f"Error: {e}"


def read_file(filepath):
    with open(filepath, "r", encoding="UTF-8") as file:
        return file.read()
