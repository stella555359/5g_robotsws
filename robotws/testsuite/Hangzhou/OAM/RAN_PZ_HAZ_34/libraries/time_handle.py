import os
import re
import datetime
import random
import datetime
import string


def sort_time(time_value):
    time = list(time_value)
    time.sort(reverse=True)
    print(time)
    return time


def time_check(date0, date1, delta=300):
    second0 = t2s(date0)
    second1 = t2s(date1)
    second = second0 - second1

    if second == delta:
        return "success"


def t2s(t):
    date, time = t.strip().split(" ")
    h, m, s = time.strip().split(":")
    return int(h) * 3600 + int(m) * 60 + int(s)
