from datetime import datetime
from datetime import timedelta
import logging


def get_current_time():
    current_time = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
    return current_time


def get_time_difference(start_time, end_time):
    duration = datetime.strptime(end_time, '%Y-%m-%dT%H:%M:%SZ') - datetime.strptime(start_time, '%Y-%m-%dT%H:%M:%SZ')
    print(f"Test suite duration: {duration}")
    return duration


def check_suite_duration(start_time, end_time, hours):
    duration = get_time_difference(start_time, end_time)
    hours = int(hours)
    if duration > timedelta(hours=hours):
        logging.warning("Test suite duration is longer than " + str(hours) + "h")
        return True
    else:
        return False
