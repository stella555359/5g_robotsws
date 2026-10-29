import re
from datetime import datetime
from robot.api.deco import keyword


@keyword
def get_last_upue_online_timestamp(log_path, upue_count=22):
    """
    Scans a log file line by line and returns the timestamp when the last required UPUE
    (User Plane Unit Element) transitioned to "ON LINE" for the first time.

    Arguments:
    - log_path (str): Path to the log file to be parsed
    - upue_count (int): Number of expected UPUEs (e.g., 22 for UPUE 0 to 21)

    Returns:
    - str: Timestamp in format "YYYY-MM-DD HH:MM:SS.sss" when the last UPUE came online
    """
    upue_set = set(range(upue_count))
    found = {}
    last_timestamp = None

    pattern = rf"<(\d{{4}}-\d{{2}}-\d{{2}}T\d{{2}}:\d{{2}}:\d{{2}}\.\d+Z)>.*?po-upue-(\d+)\s+to\s+ON\s+LINE"

    with open(log_path, 'r') as file:
        for line in file:
            match = re.search(pattern, line)
            if match:
                timestamp_str, upue_id = match.groups()
                upue_id = int(upue_id)

                if upue_id in upue_set and upue_id not in found:
                    found[upue_id] = timestamp_str

                    if len(found) == upue_count:
                        last_timestamp = timestamp_str
                        break

    if len(found) != upue_count:
        missing = upue_set - found.keys()
        raise Exception(f"? Not all UPUEs are ONLINE. Missing: {', '.join(map(str, missing))}")

    dt = datetime.strptime(last_timestamp, "%Y-%m-%dT%H:%M:%S.%fZ")
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]  # Return with milliseconds
