import re


def check_calibration_attempts(msg):
    pattern = r"Calibration attempts: (\d+)"
    result = re.findall(pattern=pattern, string=msg)
    return result


def check_successful_calibrations(msg):
    pattern = r"Calibration attempts: (\d+)"
    result = re.findall(pattern=pattern, string=msg)
    return result
