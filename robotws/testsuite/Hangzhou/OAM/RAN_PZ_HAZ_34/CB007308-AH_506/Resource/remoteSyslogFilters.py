import re
from datetime import datetime
from math import ceil

from robot.libraries.BuiltIn import BuiltIn


def extract_syslog_and_ip(line):
    matches = re.search(r"\S+\s+\d+\s+(\d+:\d+:\d+)\s(?P<ip>[a-zA-Z0-9.:]+)\s(?P<syslog_line>.*)", line)
    if not matches:
        BuiltIn().log(message="Missing ip and syslog in line: " + str(line))
        return None, None

    return matches.group("ip"), matches.group("syslog_line")


def split_syslog_line_into_columns(syslog_line):
    number_of_columns_before_message = 6
    columns = syslog_line.split(" ", number_of_columns_before_message)

    message = ""
    if len(columns) > 6:
        message = columns[6]

    try:
        result = {
            "timestamp": columns[3],
            "id": columns[1],
            "thread": columns[4],
            "mrbts_and_module": columns[0],
            "module": columns[2],
            "level_and_location": columns[5],
            "message": message
        }
    except Exception as error:
        BuiltIn().log(
            message="Failed to split line to columns for: {}\n"
                    "Error: {}".format(syslog_line, str(error)),
            level="ERROR"
        )
        raise error
    return result


def get_module_name_from_string(module_name_string):
    return module_name_string.split("_")[0]


def verify_last_id_with_current(current_id, last_id):
    current_id_int = int(current_id, 16)
    last_id_int = int(last_id, 16)
    return last_id_int < current_id_int or last_id_int == 255 and current_id_int > 0


def get_timestamp_from_str(current_timestamp_str):
    current_timestamp_str = current_timestamp_str.strip("<> \n\r\t")
    current_datetime = datetime.strptime(current_timestamp_str, '%Y-%m-%dT%H:%M:%S.%fZ')
    return (current_datetime - datetime(1970, 1, 1)).total_seconds()


def verify_last_timestamp_with_current(current_timestamp_str, last_timestamp_str):
    current_timestamp = get_timestamp_from_str(current_timestamp_str)
    last_timestamp = get_timestamp_from_str(last_timestamp_str)
    current_timestamp = ceil(current_timestamp)
    last_timestamp = ceil(last_timestamp)
    return last_timestamp <= current_timestamp or (last_timestamp - current_timestamp) <= 2


def check_chronology_of_syslog(syslogPath):
    fileStream = open(syslogPath, "r")
    last_timestamp_str = {}

    for line_id, line in enumerate(fileStream):
        ip, syslog_line = extract_syslog_and_ip(line)
        if ip is None:
            continue

        syslog_line_columns = split_syslog_line_into_columns(syslog_line)

        module = get_module_name_from_string(syslog_line_columns["module"])

        if "CCS" in module:
            continue

        current_timestamp_str = syslog_line_columns["timestamp"]
        if module in last_timestamp_str:
            verification_result = verify_last_timestamp_with_current(current_timestamp_str,
                                                                     last_timestamp_str[module][0])

            if not verification_result:
                BuiltIn().log(
                    "Syslog lines are not in chronology order,"
                    " error in line: {}".format(line_id),
                    level="ERROR"
                )
                return False

        last_timestamp_str[module] = current_timestamp_str, line_id

    fileStream.close()

    return True
