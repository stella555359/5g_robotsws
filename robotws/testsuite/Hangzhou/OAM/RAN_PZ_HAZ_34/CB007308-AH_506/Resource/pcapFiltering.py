import re


def get_packets_from_string(logs):
    lines = logs.split("\n")
    result = []
    for line in lines:
        matches = re.match(r"(\s*)(\d+)\s+(\d+(\.\d+)?)(.*)$", line)
        if matches:
            result.append(line)

    return result
