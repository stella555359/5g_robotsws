import os
import sys
import re
import csv
ul_flag = "UlCounterUpdate.cpp"
dl_flag = "SentDataMeasurementCounting.hpp"
ul_txt = "ul_tp.txt"
dl_txt = "dl_tp.txt"
ul_csv = "ul_tp.csv"
dl_csv = "dl_tp.csv"
ul_regex = r"(ASP-\d{1,3}[0-9a-zA-Z]).*?<(.*?)Z>.*?UL: (\d{1,10}) Bytes received.*?nrCellIdentity (\d{1,5})"
dl_regex = r"(ASP-\d{1,3}[0-9a-zA-Z]).*?<(.*?)Z>.*SentDataMeasurementCounting.hpp.*?nrCellId (\d{1,5}).*?(\d{1,20})"


def get_tp_from_syslog(syslog_file):
    path, file_name = os.path.split(syslog_file)
    global ul_txt
    global dl_txt
    global ul_csv
    global dl_csv
    ul_txt = os.path.join(path, ul_txt)
    dl_txt = os.path.join(path, dl_txt)
    ul_csv = os.path.join(path, ul_csv)
    dl_csv = os.path.join(path, dl_csv)
    tp_dict_statistics = {"dl": 0, "ul": 0}
    filter_tp_lines_from_syslog(syslog_file)
    tp_dict_statistics_dl = calculate_tp_statitics(dl_csv)
    tp_dict_statistics_ul = calculate_tp_statitics(ul_csv)
    tp_dict_statistics["dl"] = tp_dict_statistics_dl
    tp_dict_statistics["ul"] = tp_dict_statistics_ul
    return tp_dict_statistics


def calculate_tp_statitics(log_csv):
    cells_list = []
    tp_dict = {}
    tp_dict_statistics = {}
    # get cell list
    with open(log_csv) as fh:
        data = csv.DictReader(fh)
        for line in data:
            cells_list.append(line["cell"])
    unique_cell_list = set(cells_list)
    # print("cell id list:{}".format(list(unique_cell_list)))
    for cell in unique_cell_list:
        tp_dict[cell] = []
        tp_dict_statistics[cell] = {"min": 0, "max": 0, "ave": 0}
    # print(tp_dict)
    # get tp for each cell
    with open(log_csv) as fh:
        data = csv.DictReader(fh)
        for line in data:
            tp_dict[line["cell"]].append(float(line["tp"]))
    # print(tp_dict)
    # calculate tp min,max,ave statistics for each cell
    for cell in unique_cell_list:
        # print(min(tp_dict[cell]),max(tp_dict[cell]),sum(tp_dict[cell])/len(tp_dict[cell]))
        print("jump the first tp value to avoid the first scell tp much lower than others.")
        print(tp_dict[cell])
        tp_dict[cell].pop(0)
        print(tp_dict[cell])
        tp_dict_statistics[cell]["min"] = min(tp_dict[cell])
        tp_dict_statistics[cell]["max"] = max(tp_dict[cell])
        tp_dict_statistics[cell]["ave"] = sum(tp_dict[cell])/len(tp_dict[cell])
    # print(tp_dict_statistics)
    return tp_dict_statistics


def filter_tp_lines_from_syslog(syslog_file):
    ul_tp_lines = []
    dl_tp_lines = []
    with open(syslog_file) as fh:
        data = fh.readlines()
        for line in data:
            if re.search(ul_flag, line):
                ul_tp_lines.append(line)
            if re.search(dl_flag, line):
                dl_tp_lines.append(line)
        with open(ul_txt, "w") as fh_ul:
            fh_ul.writelines(ul_tp_lines)
        with open(dl_txt, "w") as fh_dl:
            fh_dl.writelines(dl_tp_lines)
    with open(ul_txt) as fh_ul:
        ul_content = fh_ul.read()
        ul_data = re.findall(ul_regex, ul_content, flags=0)
        # print(ul_data)
    with open(dl_txt) as fh_dl:
        dl_content = fh_dl.read()
        dl_data = re.findall(dl_regex, dl_content, flags=0)
        # print(dl_data)
    with open(ul_csv, "w") as fh_ul:
        fh_ul.write("timestamp,cell,CPU,tp,unit\n")
        for line in ul_data:
            line_to_csv = "{},{},{},{},Mbps\n".format(
                line[1], line[3], line[0], float(line[2])/1000/1000*8)
            fh_ul.write(line_to_csv)
    with open(dl_csv, "w") as fh_dl:
        fh_dl.write("timestamp,cell,CPU,tp,unit,TBS\n")
        for line in dl_data:
            line_to_csv = "{},{},{},{},Mbps,{}\n".format(
                line[1], line[2], line[0], float(line[3])/1000/1000*8, line[3])
            fh_dl.write(line_to_csv)


if __name__ == "__main__":
    path = os.path.curdir
    syslog = os.path.join(path, "target_syslog.txt")
    print("syslog={}".format(syslog))
    tp = get_tp_from_syslog(syslog)
    print(tp)
    print(tp["dl"]["16396"]["ave"])
