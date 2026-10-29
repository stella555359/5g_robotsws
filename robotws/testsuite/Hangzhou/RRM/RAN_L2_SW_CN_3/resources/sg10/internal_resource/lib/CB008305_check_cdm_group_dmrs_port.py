# -*- coding: UTF-8 -*-

import csv
from pdcch_dci_decode import Decode_PDCCH_Dciinfo


def get_dmrs_port(int_num):
    """
    :param int_num: DMRS antport Decimal, type:int
    :return DMRS antport list
    """
    str_1 = []
    bin_str = bin(int_num).replace('0b', '')
    if len(bin_str) == 13:
        bin_str = '000' + bin_str
    elif len(bin_str) == 14:
        bin_str = '00' + bin_str
    elif len(bin_str) == 15:
        bin_str = '0' + bin_str

    for index, every_char in enumerate(bin_str):
        if every_char == '1':
            str_1.append(index)
    return str_1


def get_cmd_group_and_dmrs_port_from_table(antenna_port_value):
    """
    :param antport_value: antport value,type: int, the first column in table 7.3.1.2.2-1
    :Return CDM Group and DMRS port list accord to Table 7.3.1.2.2-1
    """
    if antenna_port_value == 0:
        return [1, [0]]
    elif antenna_port_value == 1:
        return [1, [1]]
    elif antenna_port_value == 2:
        return [1, [0, 1]]
    elif antenna_port_value == 3:
        return [2, [0]]
    elif antenna_port_value == 4:
        return [2, [1]]
    elif antenna_port_value == 5:
        return [2, [2]]
    elif antenna_port_value == 6:
        return [2, [3]]
    elif antenna_port_value == 7:
        return [2, [0, 1]]
    elif antenna_port_value == 8:
        return [2, [2, 3]]
    elif antenna_port_value == 9:
        return [2, [0, 1, 2]]
    elif antenna_port_value == 10:
        return [2, [0, 1, 2, 3]]
    elif antenna_port_value == 11:
        return [2, [0, 1, 2]]
    elif antenna_port_value == 12 | antenna_port_value == 13 | antenna_port_value == 14 | antenna_port_value == 15:
        return ['Reserved', ['Reserved']]
    else:
        raise Exception('Input value error')


def check_cdm_group_and_dmrs_port_by_antenna_port_value(csv_filename, ue_nums=10):
    """
    :param csv_filename:ttitrace csv file (include absolute path)
    :param ue_nums: ue num
    """
    print("start Decode_PDCCH_Dciinfo")
    Decode_PDCCH_Dciinfo(csv_filename)
    file_len = len(csv_filename) - len('.csv')
    decode_file = csv_filename[:file_len] + '_dci_decode.csv'
    # decode_file = csv_filename
    print("start check cdm group and dmrs port")
    with open(decode_file, 'r') as csvfile:
        header = []
        reader = csv.DictReader(csvfile)
        list_reader = list(reader)
        for fieldnames in reader.fieldnames:
            header.append(fieldnames)
        total_err = 0
        total_pass = 0
        if 'PdcchDciData.rnti' and 'PdcchDciData.antennaPort' in header:
            for index, i_line in enumerate(list_reader):
                antenna_port = i_line["PdcchDciData.antennaPort"]
                rnti = i_line["PdcchDciData.rnti"]
                if rnti == '':
                    continue
                curr_sfn = i_line['sfn']
                curr_slot = i_line['slot']
                curr_index = list_reader.index(i_line)
                find_rnti = 0
                for j_line in list_reader[index + 1:curr_index + ue_nums * 2 + 1]:
                    if (j_line['rnti'] == rnti and j_line['sfn'] == curr_sfn and j_line['slot'] == curr_slot):
                        find_rnti = 1
                        ant_port = j_line['dlFdSchedData.antPort']
                        cmd_group = j_line['dlFdSchedData.numCdmGroupNoData']
                        if ant_port == '':
                            continue
                        # print("ant_port:", ant_port)
                        ant_port_str = get_dmrs_port(int(float(ant_port)))
                        port_list = list()
                        port_list.append(int(float(cmd_group)))
                        port_list.append(ant_port_str)
                        port_list_get = get_cmd_group_and_dmrs_port_from_table(int(float(antenna_port)))
                        if port_list_get == port_list:
                            # print("antenna_port :", antenna_port, "ok sfn:", curr_sfn, "slot:", curr_slot)
                            total_pass += 1
                        else:
                            print("error antenna_port:", antenna_port, "sfn:", curr_sfn, "slot:", curr_slot,
                                  "port_list:", port_list, "port_list_get:", port_list_get)
                            total_err += 1
                        break

                if find_rnti == 0:
                    print("can not find rnti:", rnti)
        else:
            raise Exception('Fail')
            print("Ttitrace has no PdcchDciData field!")
    if total_err:
        print("Fail times:", total_err)
        raise Exception('Fail')
    else:
        print("Pass times:", total_pass)


# if __name__ == "__main__":
# #     str1 = get_dmrs_port(12288)
# #     #     # str1 = get_dmrs_port(32768)
# #     print(str1)
#     file_name = "C:/N-20S1PF2R85NG-Data/changyli/Desktop/ttitrace/230505/1/tti_2_256/tti_dl.csv"
#     check_cdm_group_and_dmrs_port_by_antenna_port_value(file_name, 10)
