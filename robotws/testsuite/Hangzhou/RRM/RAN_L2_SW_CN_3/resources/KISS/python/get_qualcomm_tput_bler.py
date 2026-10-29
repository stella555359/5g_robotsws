# -*- coding: UTF-8 -*-

import re


def get_dl_cell_tput(log, cell_id):
    return get_tput_and_bler(log, 'DL.*cc: %s.*avgPHY.*?(\\d+)' % cell_id)


def get_ul_cell_tput(log, cell_id):
    return get_tput_and_bler(log, 'UL.*cc: %s.*avgPHY.*?(\\d+)' % cell_id)


def get_dl_cell_bler(log, cell_id):
    return get_tput_and_bler(log, 'DL.*cc: %s.*BLER.*?(\\d+)' % cell_id)


def get_ul_cell_bler(log, cell_id):
    return get_tput_and_bler(log, 'UL.*cc: %s.*BLER.*?(\\d+)' % cell_id)


def get_tput_and_bler(log, reg):
    all_result = []
    with open(log, 'r', encoding='utf-8', errors='ignore')as f:
        content = f.read()
        result = re.findall(reg, content, re.IGNORECASE)
        print(result)
        for i in result:
            all_result.append(int(i))
        if all_result:
            ret = sum(all_result) // len(all_result)
        else:
            ret = 0
        print(ret)
        return ret
