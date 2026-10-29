import datetime


def get_current_time():
    current_time = str(datetime.datetime.now()).split(".")[0]
    current_time = datetime.datetime.strptime(current_time, '%Y-%m-%d %H:%M:%S')
    return current_time


# change 20221014124258.633+0800 into 2022-10-14 12:42:58
def time_convert(time_original):
    time_str = str(time_original)
    year = time_str[0:4]
    month = time_str[4:6]
    day = time_str[6:8]
    hour = time_str[8:10]
    minute = time_str[10:12]
    second = time_str[12:14]
    time_str_new = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second
    time_str_new = datetime.datetime.strptime(time_str_new, '%Y-%m-%d %H:%M:%S')
    return time_str_new


def calculate_delta_minutes(time1, time2):
    delta = str(time2 - time1)
    days = 0
    if ',' in delta:
        delta_copy = delta
        delta = delta.split(",")[1].strip()
        days = int(delta_copy.split(",")[0].strip().split(" ")[0])
    hours = int(delta.split(":")[0])
    minutes = int(delta.split(":")[1])
    minutes_delta = days*24*60+hours * 60 + minutes
    return minutes_delta
