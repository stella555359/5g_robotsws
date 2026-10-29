import time
from datetime import datetime


tput_define = {
    1: {
        'dl_exp': 280,
        'dl_tp': '300M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step1_cell1 = {
    1: {
        'dl_exp': 40,
        'dl_tp': '40M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step1_cell3 = {
    3: {
        'dl_exp': 470,
        'dl_tp': '470M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step2_cell1 = {
    1: {
        'dl_exp': 150,
        'dl_tp': '150M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step2_cell3 = {
    3: {
        'dl_exp': 970,
        'dl_tp': '970M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step3_cell1 = {
    1: {
        'dl_exp': 150,
        'dl_tp': '150M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step3_cell3 = {
    3: {
        'dl_exp': 1,
        'dl_tp': '1M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step4_cell1 = {
    1: {
        'dl_exp': 150,
        'dl_tp': '150M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_step4_cell3 = {
    3: {
        'dl_exp': 970,
        'dl_tp': '970M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


tput_define_all_cells = {
    1: {
        'dl_exp': 260,
        'dl_tp': '300M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 0
    },
    3: {
        'dl_exp': 260,
        'dl_tp': '300M',
        'ul_exp': 10,
        'ul_tp': '100M',
        'ue_index': 1
    },
}


def get_lbps_current_time():
    year = time.localtime().tm_year
    month = time.localtime().tm_mon
    day = time.localtime().tm_mday
    date = datetime.date(datetime(year=year, month=month, day=day))
    weekday = 'Mon'
    # isoweekday(): 1-7 表示周一到周日
    day = date.isoweekday()
    if day == 1:
        weekday = 'Mon'
    elif day == 2:
        weekday = 'Tue'
    elif day == 3:
        weekday = 'Wed'
    elif day == 4:
        weekday = 'Thu'
    elif day == 5:
        weekday = 'Fri'
    elif day == 6:
        weekday = 'Sat'
    else:
        weekday = 'Sun'
    hour = time.strftime('%H', time.localtime())
    minute = time.strftime('%M', time.localtime())
    return weekday, hour, minute


def get_item_times_in_list(item_list, item):
    times_list = []
    for i in item_list:
        if i == item:
            times_list.append(i)
    item_times = len(times_list)
    return item_times
