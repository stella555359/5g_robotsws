from datetime import datetime


def Convert_Date_obtained_from_OCP(date_string):
    date_obj = datetime.strptime(date_string, "%a %b %d %H:%M:%S %Z %Y")
    return date_obj.isoformat()


def compare_dates(date_string1, date_string2):
    date1 = datetime.strptime(date_string1, "%Y-%m-%dT%H:%M:%S")
    date2 = datetime.strptime(date_string2, "%Y-%m-%dT%H:%M:%S")
    return date1 > date2


def Convert_Date_obtained_from_coredump(date_string):
    date_obj = datetime.strptime(date_string, "%a %Y-%m-%d %H:%M:%S")
    return date_obj.isoformat()
