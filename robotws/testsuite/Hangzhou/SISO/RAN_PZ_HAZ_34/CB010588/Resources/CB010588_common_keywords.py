# -*- coding: utf-8 -*
from robot.libraries.BuiltIn import BuiltIn
import logging


def Check_Cell_Id_Info(cells_info_list, expect_cell_info):
    cell_id_dict = {}
    for single_cell_info in cells_info_list:
        Cell_id = single_cell_info['id']['configuration']
        SubCellList = single_cell_info['subCellList']
        cell_id_dict[Cell_id.split('/')[-1]] = SubCellList
    print(cell_id_dict)
    if len(cell_id_dict.keys()) != len(expect_cell_info.keys()):
        return False
    for cell_id in cell_id_dict.keys():
        for subcell_info in cell_id_dict[cell_id]:
            if subcell_info not in expect_cell_info[cell_id]:
                return False
    return True


def Get_UE_Right_IP(cmd_info):
    ue_ip = '127.0.0.1'
    ue_ip_list = cmd_info.split('\n')
    for ip in ue_ip_list:
        if ip.startswith('172'):
            ue_ip = ip
    return ue_ip


def Get_UE_Right_IP_9487_f(cmd_info):
    ue_ip = '127.0.0.1'
    ue_ip_list = cmd_info.split('\r\n')
    for ip in ue_ip_list:
        if ip.startswith('172'):
            ue_ip = ip
    return ue_ip
