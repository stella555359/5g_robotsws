# -*- coding: utf-8 -*-
# @Time    : 2024/2/22 14:41
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_time.py
# @Software: PyCharm
import datetime
import time


def get_latest_quarter_time_for_utc(offset_time=15):

    latest_quarter_time = datetime.datetime.now() + datetime.timedelta(hours=-8, minutes=offset_time)
    latest_quarter_time = latest_quarter_time.replace(second=0, microsecond=0)

    latest_quarter_minute = latest_quarter_time.minute//15*15
    latest_quarter_time = latest_quarter_time.replace(minute=latest_quarter_minute)

    return latest_quarter_time


def wait_until_latest_quarter_time():
    latest_quarter_time = get_latest_quarter_time_for_utc()
    now = datetime.datetime.now() + datetime.timedelta(hours=-8, minutes=0)
    wait_time = int(latest_quarter_time.timestamp()) - int(now.timestamp())
    time.sleep(wait_time)
    return latest_quarter_time


if __name__ == "__main__":
    time = get_latest_quarter_time_for_utc()
    print(time)
