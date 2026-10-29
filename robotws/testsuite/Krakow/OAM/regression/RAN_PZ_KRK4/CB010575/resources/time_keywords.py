from datetime import datetime, timedelta


def prepare_window_time(hours_shift=0):
    _time = datetime.today()
    _time = _time + (datetime.min - _time) % timedelta(minutes=30)
    d = _time + timedelta(hours=hours_shift)
    return d.strftime('%H:%M')
