import re


def get_cur_dl_cell_tput(cell_stats_nr):
    pattern = re.compile(r'(\d*\.\d*)')
    print(pattern)
    cur_dl_tput = pattern.findall(cell_stats_nr)[-1]
    return float(cur_dl_tput)


def get_max_dl_cell_tput(cell_stats_nr):
    pattern = re.compile(r'(\d*\.\d*)')
    print(pattern)
    max_dl_tput = pattern.findall(cell_stats_nr)[-2]
    return float(max_dl_tput)


def get_cur_ul_cell_tput(cell_stats_nr):
    pattern = re.compile(r'(\d*\.\d*)')
    print(pattern)
    cur_ul_tput = pattern.findall(cell_stats_nr)[-3]
    return float(cur_ul_tput)


def get_max_ul_cell_tput(cell_stats_nr):
    pattern = re.compile(r'(\d*\.\d*)')
    print(pattern)
    max_ul_tput = pattern.findall(cell_stats_nr)[-4]
    return float(max_ul_tput)
