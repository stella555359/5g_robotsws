# -*- coding: UTF-8 -*-

import re


def get_dl_pcell_tput(log):
    return get_tput_and_bler(log, 'nr5g_mac.*DL.*0.*vgPHY.*?(\\d+)')


def get_ul_pcell_tput(log):
    return get_tput_and_bler(log, 'nr5g_mac.*UL.*0.*vgPHY.*?(\\d+)')


def get_dl_pcell_bler(log):
    return get_tput_and_bler(log, 'nr5g_mac.*DL.*0.*vgPHY.*BLER.*?(\\d+)')


def get_ul_pcell_bler(log):
    return get_tput_and_bler(log, 'nr5g_mac.*UL.*0.*vgPHY.*BLER.*?(\\d+)')


def get_dl_scell_tput(log):
    return get_tput_and_bler(log, 'nr5g_mac.*DL.*1.*vgPHY.*?(\\d+)')


def get_ul_scell_tput(log):
    return get_tput_and_bler(log, 'nr5g_mac.*UL.*1.*vgPHY.*?(\\d+)')


def get_dl_scell_bler(log):
    return get_tput_and_bler(log, 'nr5g_mac.*DL.*1.*vgPHY.*BLER.*?(\\d+)')


def get_ul_scell_bler(log):
    return get_tput_and_bler(log, 'nr5g_mac.UL.*1.*vgPHY.*BLER.*?(\\d+)')


def get_tput_and_bler(log, reg):
    all_result = []
    with open(log, 'r', encoding='utf-8', errors='ignore')as f:
        content = f.read()
        result = re.findall(reg, content, re.IGNORECASE)
        for i in result:
            all_result.append(int(i))
        if all_result:
            ret = sum(all_result) // len(all_result)
        else:
            ret = 0
        print(ret)
        return ret
