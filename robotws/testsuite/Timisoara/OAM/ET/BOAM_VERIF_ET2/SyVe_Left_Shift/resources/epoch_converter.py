from datetime import datetime


def convert_to_epoch(date_to_convert):
    return datetime.strftime(datetime.strptime(date_to_convert, "%Y-%m-%d %H:%M:%S"), "%s")


def get_date_python():
    return datetime.date(datetime.today()).isoformat()+" "+datetime.time(datetime.today()).strftime("%H:%M:%S")
