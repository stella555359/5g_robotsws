# -*- coding: utf-8 -*-
"""
Author: Ding Binmei
Contacts: binmei.ding@nokia-sbell.com
Description: Verify tput from GNB log

"""
import logging
import re
from taf.transport.ssh import ssh

ssh = ssh()


def convert_tput_format(tput_value):
    """
    Author: Ding Binmei
    Description: Convert tput value captured from journal log to mbits/sec unit
    :param tput_value:
    :return:
    """
    tput_with_mbit_format = round(float(tput_value) / 1000 / 1000, 3)
    return tput_with_mbit_format


def get_tput_info_from_cobham_log_for_all_ues_on_all_cells(tput_log_file_path):
    """
    Author: Ding Binmei
    Description: Get tput info from Physical layer for all ues in all cells
    :param tput_log_file_path:
    :return: Dict
        Note: ul_bler_sch only exists for cells with ul tput, others will not exists
    {ue_id:{physical_cell_id:{dl_bler_sch:XX, tput_dl_sch:XX, tput_ul_sch:XX, ul_bler_sch:XX}}}
    Example output:
    {'1': # refers to ue id
    {
    '58': {'dl_bler_sch': 3.91593e-05, 'tput_dl_sch': 273.532, 'tput_ul_sch': 0.0},
    '51': {'dl_bler_sch': 2.2553e-07, 'ul_bler_sch': 0.2603377696, 'tput_dl_sch': 1396.273, 'tput_ul_sch': 0.121}
    }
    '0':
    {
    '58': {'dl_bler_sch': 3.91593e-05, 'tput_dl_sch': 273.532, 'tput_ul_sch': 0.0},
    '51': {'dl_bler_sch': 2.2553e-07, 'ul_bler_sch': 0.2603377696, 'tput_dl_sch': 1396.273, 'tput_ul_sch': 0.121}
    }}
    """

    dict_all_ue_all_cell_tput_info = {}
    dict_tput_info = {}
    try:
        with open(tput_log_file_path) as f:
            key_ue_id = ""
            key_cell_id = ""
            dl_sch_position = 0
            dl_sch_found = False
            ul_sch_position = 0
            ul_sch_found = False
            for line in f.readlines():
                logging.debug(line)
                if dl_sch_found:
                    dl_sch_position = dl_sch_position + 1
                if ul_sch_found:
                    ul_sch_position = ul_sch_position + 1
                if line.find("UE ID:") != -1:
                    logging.info("line:{}, key_ue_id:{}, key_cell_id:{}".format(line, key_ue_id, key_cell_id))
                    dict_tput_info = {}
                    key_ue_id = line.split("UE ID: ")[-1].strip().split(" ")[0].strip()
                    key_cell_id = line.split("Cell ID:")[-1].strip().split(" ")[0].strip()
                    dict_all_ue_all_cell_tput_info.setdefault(key_ue_id, {})[key_cell_id] = dict_tput_info
                elif re.search(pattern=r'DL-SCH \([S|P]CC\d*\)[^NO DATA]', string=line):
                    dl_sch_position = 0
                    dl_sch_found = True
                elif dl_sch_found and dl_sch_position == 2:
                    dl_tput_sch = line.split("Throughput:")[-1].strip().split(" ")[0].strip()
                    dl_tput_sch = convert_tput_format(dl_tput_sch)
                    dict_tput_info["tput_dl_sch"] = dl_tput_sch
                elif dl_sch_found and dl_sch_position == 5:
                    dl_bler_sch = re.split(pattern=r"\s+", string=line)[2]
                    dict_tput_info["dl_bler_sch"] = float(dl_bler_sch)
                    dl_sch_found = False
                # Collect UL data
                elif re.search(pattern=r'UL-SCH \([S|P]CC\d*\)[^NO DATA]', string=line):
                    ul_sch_position = 0
                    ul_sch_found = True
                elif ul_sch_found and ul_sch_position == 1:
                    ul_tput_sch = line.split("Throughput:")[-1].strip().split(" ")[0].strip()
                    ul_tput_sch = convert_tput_format(ul_tput_sch)
                    dict_tput_info["tput_ul_sch"] = ul_tput_sch
                elif ul_sch_found and ul_sch_position == 4:
                    try:
                        ul_bler_sch = re.split(pattern=r"\s+", string=line)[5]
                        dict_tput_info["ul_bler_sch"] = float(ul_bler_sch)
                    except IndexError:
                        logging.info("No UL bler found for UE:{} on cell:{}".format(key_ue_id, key_cell_id))
                    finally:
                        ul_sch_found = False
                else:
                    continue
    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
    return dict_all_ue_all_cell_tput_info


def get_physical_cells_with_tput_exist(tput_log_file_path, ue_id):
    """
    Author: Ding Binmei
    Description: list all phycical cell ids with tput exist for both ul and dl
    :param tput_log_file_path:
    :param ue_id: ue index value, start from 0
    :return: dict
             Example output: {'ul': ['51', '52'], 'dl': ['58', '55', '54', '57', '56', '51', '53', '52']}
    """
    ue_id = str(ue_id)
    tput_info_all_ues_all_cells = get_tput_info_from_cobham_log_for_all_ues_on_all_cells(
        tput_log_file_path=tput_log_file_path)
    logging.debug("tput_info_all_ues_all_cells:{}".format(tput_info_all_ues_all_cells))
    ue_ids = tput_info_all_ues_all_cells.keys()
    if ue_id not in ue_ids:
        raise Exception("No ue id {} found from log file".format(ue_id))
    else:
        tput_info_for_specific_ue = tput_info_all_ues_all_cells[ue_id]
        list_physical_cell_id = tput_info_for_specific_ue.keys()
        list_cells_with_ul_tput = []
        list_cells_with_dl_tput = []
        dict_cells_with_tput_exist = {}
        for phy_cell_id in list_physical_cell_id:
            ul_tput = tput_info_for_specific_ue[phy_cell_id]['tput_ul_sch']
            dl_tput = tput_info_for_specific_ue[phy_cell_id]['tput_dl_sch']
            print("phy_cell_id:{}, ul_tput: {}, dl_tput:{}".format(phy_cell_id, ul_tput, dl_tput))
            if ul_tput > 0:
                list_cells_with_ul_tput.append(phy_cell_id)
            if dl_tput > 0:
                list_cells_with_dl_tput.append(phy_cell_id)
        dict_cells_with_tput_exist['ul'] = list_cells_with_ul_tput
        dict_cells_with_tput_exist['dl'] = list_cells_with_dl_tput
        logging.debug("cells with tput exist: {}".format(dict_cells_with_tput_exist))
        return dict_cells_with_tput_exist
