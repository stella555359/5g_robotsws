from datetime import datetime


def get_day_time():
    dayofWeek = datetime.now().isoweekday()
    day = "day"
    if dayofWeek == 1:
        day = "Mon"
    elif dayofWeek == 2:
        day = "Tue"
    elif dayofWeek == 3:
        day = "Wed"
    elif dayofWeek == 4:
        day = "Thu"
    elif dayofWeek == 5:
        day = "Fri"
    elif dayofWeek == 6:
        day = "Sat"
    else:
        day = "Sun"
    return day


modify_lbps_params = [
    {'dist_name': 'MRBTS-1138/NRBTS-1138/NRPGRP-1', 'filter_param': 'Load-based power saving duration',
     'p_name': 'lbpsDuration', 'value': 120},
    {'dist_name': 'MRBTS-1138/NRBTS-1138/NRPGRP-1', 'filter_param': 'Load-based power saving day of week',
     'p_name': 'lbpsDayOfWeek', 'value': get_day_time()}
]

rate_for_stream = {
    '21A': 'peak',
    '21B': 'peak',
    '20B': 'peak',
    'master': '0.8',
    'SBTS22R1': 'peak',
    'SBTS21B': 'peak'
}
