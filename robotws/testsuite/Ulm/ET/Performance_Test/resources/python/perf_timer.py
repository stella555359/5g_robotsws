from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime

rbi = BuiltIn()


def start():
    return datetime.now()


def stop(msg='', start_time=datetime.now(), console=True):
    timer_stop_time = datetime.now()
    difference = timer_stop_time - start_time
    min, sec = divmod(difference.days * (24 * 60 * 60) +
                      difference.seconds, 60)
    if min <= 0:
        rbi.log(f"    {msg} {sec} second/s\n", console=console)
    else:
        rbi.log(f"    {msg} {min}:{sec:0>2}\n", console=console)
    return sec + (min*60)
