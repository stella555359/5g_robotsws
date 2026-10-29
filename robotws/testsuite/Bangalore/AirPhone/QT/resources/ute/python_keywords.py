import os
import sys
import logging
import xml.etree.ElementTree as ElementTree
from decimal import Decimal
import re


def parse_sw_to_stream(sw_d):
    """
    Script takes parameter sw_version from coam.admin in format: '5G20B_GNB_0000_000800_000612'
    and parses it to stream number: '0.800'
    If it is a knife it looks like: '5G20B_GNB_0000_000800_000612_0ijup_' (Exceptions below are for knife builds)
    """
    try:
        build = '.'.join([str(int(s)) for s in sw_d.split('_')[2:4]])
    except ValueError:
        try:
            build = '.'.join([str(int(s)) for s in sw_d.split('_')[1:3]])
        except ValueError:
            build = '.'.join([str(int(s)) for s in sw_d.split('_')[3:5]])

    return build


def get_nidd_version_from_scf_file(scf_location, managed_object=1):
    """
    :param scf_location: absolute path to SCF file, i.e: "/home/ute/scf.xml"
    :return: (str) NIDD version checked from provided SCF file.
    """
    tree = ElementTree.parse(scf_location)
    try:
        nidd = tree.getroot().find(
            "./{raml}cmData/{raml}managedObject[{object}]".format(
                raml="{raml21.xsd}", object=managed_object)).attrib["version"]
        nidd = nidd.strip() if len(nidd) > 3 else "error"
    except Exception:
        nidd = "error"
    print(nidd)  # do not delete this print, it's necessary!

    return nidd


def add_content_to_file(file_name, content):
    with open(file_name, 'a+') as fh:
        fh.writelines(content)
    return


def cal_data_rate(bytes_rec_int, coll_time_int):
    """
    Method to calculate data rate for Multi UEs.
    """
    data_rate = float(Decimal(bytes_rec_int*8)/Decimal(coll_time_int*1000000))
    print(data_rate)
    return data_rate


def calculate_number_of_traffic_ids(rate):
    """
    Calculate number of traffic IDs and last traffic rate (max 160 Mbps per ID).
    Used for splitting high throughput traffic across multiple traffic IDs.

    :param rate: Target rate in Mbps (int or float).
    :return: Tuple of (num_trf_final, last_trf_rate_final).
             num_trf_final: Number of traffic IDs needed.
             last_trf_rate_final: Rate in Mbps for the last traffic ID (160 if rate divides evenly).
    """
    rate = int(rate)
    if rate > 160:
        num_trf_ids = rate / 160
        last_trf_rate = rate % 160
    else:
        num_trf_ids = 1
        last_trf_rate = rate

    if last_trf_rate > 0:
        num_trf = num_trf_ids + 1
    else:
        num_trf = num_trf_ids

    if last_trf_rate == rate:
        num_trf_final = 1
    else:
        num_trf_final = int(num_trf)

    if last_trf_rate == 0:
        last_trf_rate_final = 160
    else:
        last_trf_rate_final = last_trf_rate

    return num_trf_final, last_trf_rate_final


def find_tput_stats_from_egate_console_file(ul_dl_pattern, egate_console_file, mode):
    matching_pattern = str(ul_dl_pattern)
    matched_list = []
    mode = str(mode)
    offset = 9 if mode.upper() == "CA" else 4

    def is_separator(text):
        text = text.strip()
        return (
            not text or
            all(ch in "-=+ " for ch in text) and len(text) >= 5
        )

    with open(egate_console_file, 'r') as f:
        lines = f.readlines()
        for index, line in enumerate(lines):
            if matching_pattern in line:
                try:
                    if mode.upper() == "CA":
                        search_index = index + 1
                        while search_index < len(lines):
                            cur_line = lines[search_index].strip()
                            if cur_line.startswith("UE-") and (("Throughput" in cur_line) or ("ue_stats" in cur_line)):
                                break

                            if "total" in cur_line.lower():
                                val_index = search_index + 1
                                while val_index < len(lines) and is_separator(lines[val_index]):
                                    val_index += 1
                                if val_index < len(lines) and lines[val_index].strip():
                                    matched_list.append(lines[val_index])
                                else:
                                    print("Expected tput line under 'Total' not found. Please check manually!")
                                break
                            search_index += 1
                    else:
                        matched_list.append(lines[index + offset])
                except IndexError:
                    print("Expected tput line is not found in the file. Please check manually!")
                    pass

    return matched_list[-1].strip() if matched_list else ""


def calculate_sum_of_ca_traffic(egate_console):
    Cell_Index = ['CellIndex-8', 'CellIndex-9']
    sum_values = 0
    matched_lines = []
    for line in egate_console.split('\n'):
        for value in Cell_Index:
            if value in line:
                matched_lines.append(line.strip())
    first_two_matching_lines = matched_lines[:2]
    for line in first_two_matching_lines:
        words = line.split()
        if len(words) >= 2:
            second_to_last_value = float(words[-2])
            print("Second to last value:", second_to_last_value)
            sum_values += second_to_last_value
    return sum_values


def get_cell_blocking_state(cell_info, cell_dist_name):
    return next(
        (d["status"]["blockingState"] for d in cell_info
         if d.get("id", {}).get("configuration") == cell_dist_name),
        None,
    )


def get_last_data_rate_by_cell(file_path, cell_id, direction):
    """
    Extracts UL or DL Current Data Rate for the given cell ID from the last cell_stats_nr table.
    """
    direction = direction.upper()
    if direction not in ['UL', 'DL']:
        raise ValueError("Direction must be 'UL' or 'DL'")

    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    tables = []
    current_table = []
    parsing = False

    for line in lines:
        if re.search(
            r'Cell Id\s+UL Max Data Rate\s+UL Current Data Rate\s+'
            r'DL Max Data Rate\s+DL Current Data Rate',
            line
        ):
            parsing = True
            current_table = []
            continue
        if parsing and re.search(r'={10,}', line):
            parsing = False
            if current_table:
                tables.append(current_table)
            continue
        if parsing and re.match(r'^\d+', line.strip()):
            current_table.append(line.strip())

    if not tables:
        return None

    # Process the last table
    last_table = tables[-1]
    for row in last_table:
        parts = re.split(r'\s{2,}', row)
        parts = re.split(r'\s{2,}', row)
        if len(parts) >= 5 and int(parts[0]) == cell_id:
            ul_rate = float(parts[2].replace(' kbps', '').replace(' bps', ''))
            dl_rate = float(parts[4].replace(' kbps', '').replace(' bps', ''))
            return ul_rate if direction == 'UL' else dl_rate

    return None


def extract_ue_ids_from_egate(file_path, pattern, start_line, end_line):
    """
    Extracts UE IDs from a log file based on a single pattern, scoped between start and end markers.
    """
    ue_ids = set()
    in_scope = False

    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            if start_line in line:
                in_scope = True
                continue
            if end_line in line:
                in_scope = False
                continue
            if in_scope and pattern in line:
                matches = re.findall(r'\bUE(\d+)\b|\bUe:(\d+)\b', line)
                for match in matches:
                    ue_id = int(match[0] or match[1])
                    ue_ids.add(ue_id)

    return sorted(ue_ids)
