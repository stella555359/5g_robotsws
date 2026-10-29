from datetime import datetime, timedelta
import random


def get_proper_interval(webemtime, data, interval):
    """
    This function returns the time of counter that will gather the dropped packages.
    Arguments:
    The webemtime variable is the last counter that is visible on vDU/vCU.
    The data variable is execution time from TestPC (to have the specific time of sending the traffic)
    The interval variable is value from parameter describe the time interval that counters will be gathered.
    Output:
    Returns the time rounded to the next 5 minutes.
    For example:
    Arguments: webemtime = 12:20:00, data = 10:26:12, interval = 5min
    Return: 12:30:00
    Arguments: webemtime = 13:55:00, data = 11:59:12, interval = 5min
    Return: 14:00:00
    """
    interval = int(interval)
    data = datetime.strptime(data, "%H:%M:%S")
    data = data.replace(second=0)
    webemtime = datetime.strptime(webemtime, "%H:%M:%S")
    # To webemtime is added one interval because the counters are gathered with delay that is the interval time.
    webemtime = webemtime + timedelta(minutes=interval)
    # The difference value removes the difference between time zones in TestPC and vDU/vCU. If there's no difference
    # in time zone, 0 hours will be added.
    difference = webemtime.hour - data.hour
    delta_min = data.minute % interval
    waiting_time_for_interval = interval - delta_min
    return (data + timedelta(hours=difference, minutes=waiting_time_for_interval)).strftime("%H:%M:%S")


def get_random_int(length):
    random_number = random.randint(0, length)
    return random_number
