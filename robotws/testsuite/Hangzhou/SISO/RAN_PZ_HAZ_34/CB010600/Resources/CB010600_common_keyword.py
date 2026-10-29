# -*- coding: utf-8 -*
from robot.libraries.BuiltIn import BuiltIn
import logging
from typing import List


def match_rmod_sn_number(ru_info_list, ru_object_info_list):
    ru_info_dict1 = {}
    ru_info_dict2 = {}
    match_ru_dict = {}
    for ru_info1 in ru_info_list:
        ru_id1 = ru_info1['id']['configuration'].split('/')[-1]
        ru_sn1 = ru_info1['serialNumber']
        ru_info_dict1[ru_sn1] = ru_id1
    for ru_info2 in ru_object_info_list:
        ru_id2 = ru_info2['distName']
        ru_sn2 = ru_info2['parameters']['serialNumber']
        ru_info_dict2[ru_sn2] = ru_id2
    for key in ru_info_dict1.keys():
        match_ru_dict[ru_info_dict1[key]] = ru_info_dict2[key].split('/')[-1]
    print(match_ru_dict)
    return match_ru_dict


def Get_RU_DL_And_UL_info(endpoint_capacity_info):
    endpoint_capacity_idct = {}
    for info in endpoint_capacity_info:
        info_tmp_dict = {}
        distName = [i for i in info['distName'].split('/') if i.startswith('RMOD_L')][0]
        PerSlot = info['parameters']['maxUplaneSectionHeadersPerSlot']
        PerSymbol = info['parameters']['maxUplaneSectionHeadersPerSymbol']
        groupName = info['parameters']['groupName']
        if PerSlot == 78 and PerSymbol == 26:
            info_tmp_dict['RX'] = groupName
        elif PerSlot == 252 and PerSymbol == 18:
            info_tmp_dict['TX'] = groupName
        else:
            logging.info(
                "endpoint_capacity_info:{} check failed!".format(info))
            return {}
        if distName not in endpoint_capacity_idct.keys():
            endpoint_capacity_idct[distName] = {}
        endpoint_capacity_idct[distName].update(info_tmp_dict)
    print(endpoint_capacity_idct)
    return endpoint_capacity_idct


def Get_All_Low_Level_Endpoint_info(Low_Level_Endpoint_info, parameter):
    Low_Level_Endpoint_dict = {}
    all_ru_Endpoint_dict = {}
    for info in Low_Level_Endpoint_info:
        distName = info['distName']
        capacitySharingGroups = info['parameters']['capacitySharingGroups']
        userPlane = info['parameters'][parameter]
        if len(capacitySharingGroups) != 0:
            Low_Level_Endpoint_dict[distName] = [capacitySharingGroups, userPlane]
    print(Low_Level_Endpoint_dict)
    for key in Low_Level_Endpoint_dict.keys():
        tmp = {}
        new_element_list = [i for i in key.split('/') if
                            (i.startswith('RMOD') or i.startswith('RU_L') or
                             i.startswith('TX_') or i.startswith('RX_'))]
        new_element_list[-1] = new_element_list[-1].split('_')[0]
        new_key = '/'.join(new_element_list)
        tmp[key] = Low_Level_Endpoint_dict[key]
        if new_key not in all_ru_Endpoint_dict.keys():
            all_ru_Endpoint_dict[new_key] = {}
        all_ru_Endpoint_dict[new_key].update(tmp)
    for i in all_ru_Endpoint_dict:
        print(all_ru_Endpoint_dict[i])
    print(all_ru_Endpoint_dict)
    return all_ru_Endpoint_dict


def Check_RMOD_Endpoint_info(all_ru_Endpoint_dict, Rmod_list, endpoint_capacity_idct, trans, exp_value):
    for rmod in Rmod_list:
        for ru_info in all_ru_Endpoint_dict.keys():
            if rmod in ru_info and trans in ru_info:
                print(rmod)
                for keys in all_ru_Endpoint_dict[ru_info].keys():
                    if all_ru_Endpoint_dict[ru_info][keys][-1] is not exp_value:
                        logging.info("LOW_LEVEL_ENDPOINT-{} check failed!".format(keys))
                        logging.info(
                            "The LOW_LEVEL_ENDPOINT value is {}".format(all_ru_Endpoint_dict[ru_info][keys]))
                        return False
                    if endpoint_capacity_idct[rmod][trans] not in all_ru_Endpoint_dict[ru_info][keys][0]:
                        logging.info("LOW_LEVEL_ENDPOINT-{} check failed!".format(keys))
                        logging.info(
                            "The LOW_LEVEL_ENDPOINT value is {}".format(all_ru_Endpoint_dict[ru_info][keys]))
                        return False
    return True


def Cover_Romd_To_Rmod_L(match_ru_dict, rmod_list):
    rmod_L_list = []
    for rmod in rmod_list:
        rmod_L_list.append(match_ru_dict[rmod])
    print(rmod_L_list)
    return rmod_L_list


def Check_Parameter_In_Swconfig(data_list, para):
    for data in data_list:
        if para in data:
            print(data)
            if data.startswith('#'):
                return True
            else:
                return False
    return True


def Modify_Swconfig_Files(data_list, para, file_path):
    data_list_tmp = [data for data in data_list if data != '']
    new_list = [para if para.strip('#') in data else data for data in data_list_tmp]
    if para not in new_list:
        new_list.append(para)
    print(new_list)
    with open(file_path, 'w') as file:
        for data in new_list:
            file.write(data + '\n')
    file.close()


def Change_UL_And_DL_TP(ue_config, ul_tp, dl_tp):
    for ue_id in ue_config['MultiUECFG'].keys():
        if ue_id.isdigit():
            ue_config['MultiUECFG'][ue_id]['dl']['target_throughput'] = str(dl_tp) + 'MKbits/sec'
            ue_config['MultiUECFG'][ue_id]['ul']['target_throughput'] = str(ul_tp) + 'MKbits/sec'
    print(ue_config)
    return ue_config


def Check_Mulite_UE_TP_And_Bler(if_ul, if_dl, actual_value, expect_ul_bler, expect_dl_bler,
                                expect_ul_tp, expect_dl_tp):
    ue_id = 0
    ul_ue_count = 0
    dl_ue_count = 0
    for single_ue_actual_value in actual_value:
        ue_id = ue_id + 1
        dl_bler = single_ue_actual_value['DL_bler'][0]
        ul_bler = single_ue_actual_value['UL_bler'][0]
        dl_tp = single_ue_actual_value['DL_tp'][0]
        ul_tp = single_ue_actual_value['UL_tp'][0]
        if if_ul and ul_tp > 1:
            ul_ue_count = ul_ue_count + 1
            if ul_bler > expect_ul_bler:
                logging.info("UE-{} UL bler {} is more than expect value {}".format(ue_id, ul_bler, expect_ul_bler))
                return False
            if ul_tp < expect_ul_tp:
                logging.info("UE-{} UL TP {} is less than expect value {}".format(ue_id, ul_tp, expect_ul_tp))
                return False
        if if_dl and dl_tp > 1:
            dl_ue_count = dl_ue_count + 1
            if dl_bler > expect_dl_bler:
                logging.info("UE-{} DL bler {} is more than expect value {}".format(ue_id, dl_bler, expect_dl_bler))
                return False
            if dl_tp < expect_dl_tp:
                logging.info("UE-{} DL TP {} is less than expect value {}".format(ue_id, dl_tp, expect_dl_tp))
                return False
    if if_ul:
        print("ul ue count is {}", ul_ue_count)
        if ul_ue_count < 1:
            logging.info("All UE has no UL tp")
            return False
    if if_dl:
        print("dl ue count is {}", dl_ue_count)
        if dl_ue_count < 1:
            logging.info("All UE has no DL tp")
            return False
    return True


def Comparison_of_Front_and_Rear_Traffic(Front_ul_value, Front_dl_value, Rear_ul_value, Rear_dl_value, proportion):
    result_list = []
    upper_ul_value = Front_ul_value * (1 + proportion)
    lower_ul_value = Front_ul_value * (1 - proportion)
    upper_dl_value = Front_dl_value * (1 + proportion)
    lower_dl_value = Front_dl_value * (1 - proportion)
    if Rear_ul_value <= upper_ul_value and Rear_ul_value >= lower_ul_value:
        result_list.append('True')
    else:
        result_list.append('False')
    if Rear_dl_value <= upper_dl_value and Rear_dl_value >= lower_dl_value:
        result_list.append('True')
    else:
        result_list.append('False')
    logging.info("all check result is {}".format(result_list))
    for value in result_list:
        if value != 'True':
            return False
    return True


def Define_Cell_Status(cell_id, all_cell_list, unblock_status, block_status, flag):
    cells_status = {}
    if flag is True:
        for id in all_cell_list:
            cell_name = 'NRCELL-' + str(id)
            if id != cell_id:
                cells_status[cell_name] = block_status
            else:
                cells_status[cell_name] = unblock_status
    else:
        for id in all_cell_list:
            cell_name = 'NRCELL-' + str(id)
            cells_status[cell_name] = unblock_status
    all_cell_list.remove(cell_id)
    return all_cell_list, cells_status


def Total_TP_From_Spark_Log(spark_list, exp_ul, exp_dl):
    total_ul_tp = sum(spark_list[0])
    total_dl_tp = sum(spark_list[1])
    if total_ul_tp < exp_ul:
        logging.info("Total Ul Tp {} is less than expect Ul TP {}".format(total_ul_tp, exp_ul))
        return False, total_ul_tp, total_dl_tp
    if total_dl_tp < exp_dl:
        logging.info("Total Dl Tp {} is less than expect Dl TP {}".format(total_dl_tp, exp_dl))
        return False, total_ul_tp, total_dl_tp
    return True, total_ul_tp, total_dl_tp


def merge_to_one_dictionary(newlist: List[str]):
    new_dict = {}
    for d in newlist:
        print(d.keys())
        nrcell = list(d.keys())[0]
        new_dict.setdefault(nrcell, {})
        counter_name = list(d[nrcell].keys())[0]
        new_dict[nrcell].setdefault(counter_name, [])
        new_dict[nrcell][counter_name] = d[nrcell][counter_name]
    return new_dict
