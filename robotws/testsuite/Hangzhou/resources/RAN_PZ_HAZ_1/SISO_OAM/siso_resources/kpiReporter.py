# -*- coding: utf-8 -*-

"""
:author:  Lisa Ding
:contact: Ding, Lisa (NSB - CN/Hangzhou) <lisa.ding@nokia-sbell.com>

"""
import re
import os
import zipfile
import datetime as dt


def time_now():
    time_formated = dt.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    time_and_date = dt.datetime.utcnow()
    return time_formated, time_and_date


def get_first_cell_downtime(item):
    items = item.split("\n")
    first_cell = items[0]
    return first_cell


def get_last_cell_downtime(item):
    all_cells = item.count("CellDriver")
    items = item.split("\n")
    print(items[all_cells - 1])
    return items[all_cells - 1]


def get_last_cell(item):
    all_cells = item.count("CellDriver")
    items = item.split("\n")
    print(items[all_cells - 1])
    return items[all_cells - 1]


def get_first_cell(item):
    # if cell_m == 1:
    #    return item
    # else:
    #    all_cells = item.count("CellDriver")
    items = item.split("\n")
    print(items[0])
    return items[0]


def get_delta_time_in_seconds(start_frame, stop_frame):
    start_frame = start_frame.split('\n')[0]
    start = re.search("<(.*?)>", start_frame).group(1).split("T")[1][:14]
    stop = re.search("<(.*?)>", stop_frame).group(1).split("T")[1][:14]
    start_formated = dt.datetime.strptime(start, '%H:%M:%S.%f')
    stop_formated = dt.datetime.strptime(stop, '%H:%M:%S.%f')
    diff = (stop_formated - start_formated).total_seconds()
    print("Time Difference: ".format(diff))
    if diff > 0:
        return diff
    else:
        return 0


def set_delta_time_to_seconds(kpi_results, kpi_dictionary):
    for _kpi_name in kpi_results:
        deltas = [record['delta'].total_seconds() for record in kpi_results[_kpi_name]]
        if _kpi_name in kpi_dictionary:
            kpi_dictionary[_kpi_name].append(deltas)
        else:
            kpi_dictionary[_kpi_name] = deltas


def get_latest_disconnected_ims_file(btsid, file_path):
    lists = os.listdir(file_path)
    lists.sort(key=lambda fn: os.path.getmtime(file_path + '/' + fn))
    lists.reverse()
    for fl in lists:
        if '_%s_disconnect' % btsid in fl and '.ims2' in fl:
            return os.path.join(file_path, fl)


def get_bts_snapshot_file(btsid, file_path):
    lists = os.listdir(file_path)
    for fl in lists:
        if '_%s_' % btsid in fl and 'Snapshot' in fl and '.zip' in fl:
            return os.path.join(file_path, fl)


def unzipfile(zip_path, unzip_path):
    with zipfile.ZipFile(zip_path, "r") as zf:
        if not os.path.exists(unzip_path):
            os.mkdir(unzip_path)
        zf.extractall(unzip_path)
