import time
from datetime import datetime


def get_now_lbps_week_and_time():
    weekday = datetime.now().strftime("%a")
    hour = time.strftime('%H', time.localtime())
    minute = time.strftime('%M', time.localtime())
    return weekday, hour, minute
