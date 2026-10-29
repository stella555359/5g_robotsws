import re


def get_time_detail(time_string):
    time_list = time_string.split("\n")
    big_time = 0
    fault = ""
    for time in time_list:
        target_time = None
        target_time = re.sub("\\D", "", time.split(" ")[1])
        target_time = target_time[0:12]
        if int(target_time) >= int(big_time):
            big_time = target_time
            fault = time.split(" ")[2:]
    return big_time, fault


def searchFile(filename, searchName):
    f1 = open(filename, "r", encoding="utf-8")
    x = {}
    y = []
    for ll, lines in enumerate(f1):
        lines = lines.rstrip("\n")
        if ":" in lines:
            if ll == 0:
                value = lines
            else:
                x[value] = y
                value = lines
                y = []
        else:
            y.append(lines)
    x[value] = y
    for i, j in x.items():
        for k in j:
            if searchName in k:
                return i
    return "not find"
