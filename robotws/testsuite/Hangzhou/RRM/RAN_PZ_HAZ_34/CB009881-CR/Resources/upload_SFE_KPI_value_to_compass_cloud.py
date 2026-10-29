# coding = utf-8


"""
:copyright: Nokia Networks
:author: Shi Ming
:contact: ming.shi@nokia-sbell.com
:maintainer: Ming Shi
:contact: Ming Shi
"""

import requests
import openpyxl
import time
import taf.transport.ssh as ssh
from multiprocessing import Pool
from multiprocessing import cpu_count
from variables import SA_HO_SCE1, SA_HO_SCE2, SA_HO_SCE3, SA_HO_SCE4, SA_HO_SCE5, SA_HO_SCE6, SA_HO_SCE7, \
    SA_HO_SCE8, NSA_HO_SCE1, NSA_HO_SCE2, NSA_HO_SCE3, NSA_HO_SCE4, NSA_HO_SCE5, NSA_HO_SCE6, NSA_HO_SCE7, NSA_HO_SCE8


def get_value_from_dict_counter(counter_value):
    max_counter_value = counter_value.get(max(counter_value.keys()))
    if max(counter_value.keys()) in counter_value:
        del counter_value[max(counter_value.keys())]
    second_max_counter_value = counter_value.get(max(counter_value.keys()))
    return max_counter_value, second_max_counter_value


def get_available_ue_sn(control_pc_ip, username, password):
    try:
        sshconn = ssh.ssh()
        sshconn.connect_to(hostname=control_pc_ip, username=username, password=password, alias='get_ue_sn', timeout=60)
    except Exception as e:
        print("\tError %s\n" % e)
    else:
        # sshconn.send_command(command="adb devices |awk '{print $2}'", timeout=30, connection='get_ue_sn')
        # read_output = sshconn.read_output(connection='get_ue_sn')
        # result = read_output
        result = sshconn.execute(command="adb devices |awk '{print $2}'", connection='get_ue_sn', timeout=30)
        available_ue_num = int(result.count('device'))
        # sshconn.send_command(
        #     command="adb devices  |tail -n -" + str(available_ue_num + 1) + "|awk '{print $1}'",
        #     timeout=60,
        #     connection='get_ue_sn')
        # sn_output = sshconn.read_output(connection='get_ue_sn')
        # result = sn_output
        result = sshconn.execute(
            command="adb devices  |tail -n -" + str(available_ue_num + 1) + "|awk '{print $1}'",
            connection='get_ue_sn',
            timeout=30)
        list_result = result.split('\n')
        available_ue_SN = []
        for i in list_result:
            if len(i) > 0:
                available_ue_SN.append(i.strip().strip('\x1b').strip('[6n'))
        if available_ue_SN.count('') > 0:
            available_ue_SN.remove('')
    finally:
        try:
            sshconn.disconnect(connection='get_ue_sn')
        except UnboundLocalError:
            print('close failed')
    return available_ue_SN, available_ue_num


def get_all_ue_info(file_path, file_sheet, check_name):
    data = openpyxl.load_workbook(file_path)
    table = data[file_sheet]
    nrows_num = table.max_row
    ncols_num = table.max_column
    for row in table.iter_rows():
        for cell in row:
            if cell.value is not None:
                info = str(cell.value).find(check_name)
                if info == 0:
                    check_name_col = cell.column
    all_ue_info = []
    for i in range(2, nrows_num + 1):
        if table.cell(row=i, column=check_name_col).value is not None:
            all_ue_info.append(table.cell(row=i, column=check_name_col).value)
    return all_ue_info, len(all_ue_info)


def get_lost_ues(actual_ue_info, excel_ue_info):
    differ_ue_list = list(set(excel_ue_info).difference(set(actual_ue_info)))
    print(differ_ue_list)
    return differ_ue_list


def get_value_on_excel(filepath, filesheet, counter_prop):
    '''
    get values of counters on filepath
    :param counter_prop: : dict which contain the counter prop like:
            GNB2/BTS/CELLS/NRCELL-301/MCC-310_MNC-260/NRANS/M55145C00352
    :param filepath: the Excel exist path.
    :param filesheet: the sheet name which add the counter data
    :return sum(sum_value): summary value of counter_prop
    '''

    data = openpyxl.load_workbook(filepath)
    table = data[filesheet]
    nrows_num = table.max_row
    ncols_num = table.max_column
    counter_names_value = []
    for i in range(1, ncols_num + 1):
        counter_names_value.append(table.cell(row=1, column=i).value)
    for row in table.iter_rows():
        for cell in row:
            if cell.value is not None:
                info = str(cell.value).find(counter_prop)
                if info == 0:
                    counter_col = cell.column
    sum_value = []
    for i in range(2, nrows_num + 1):
        sum_value.append(table.cell(row=i, column=counter_col).value)
    # print(sum(sum_value))
    return sum(sum_value)


def remove_no_use_value(filepath, filesheet, start_time, end_time, counter_name, format_string="%Y-%m-%d %H:%M:%S"):
    '''
    set redundant value to 0
    :param counter_name: : dict which contain the counter name like:
            GNB2/BTS/CELLS/NRCELL-301/MCC-310_MNC-260/NRANS/M55145C00352
    :param filepath: the Excel exist path.
    :param filesheet: the sheet name which add the counter data
    :param start_time: the start time of 1 case
    :param end_time: the end time of 1 case
    :param format_string: the format of time
    '''

    start_time_array = time.strptime(start_time, format_string)
    start_time_stamp = int(time.mktime(start_time_array))
    end_time_array = time.strptime(end_time, format_string)
    end_time_stamp = int(time.mktime(end_time_array))
    data = openpyxl.load_workbook(filepath)
    table = data[filesheet]
    nrows_num = table.max_row
    time_values = []
    for i in range(2, nrows_num):
        time_values.append(table.cell(row=i + 1, column=1).value)
    not_satisfied_place = []
    for time_value in time_values:
        if (int(time_value) < int(start_time_stamp)) or (int(time_value) > int(end_time_stamp)):
            not_satisfied_place.append(search_place_of_value(filepath, filesheet, time_value)[0])
    counter_name_place = []
    for name in counter_name:
        counter_name_place.append(search_place_of_value(filepath, filesheet, name)[1])
    for row_place in not_satisfied_place:
        for col_place in counter_name_place:
            table.cell(row=row_place, column=col_place, value=0)
    data.save(filepath)


def search_place_of_value(filepath, filesheet, search_key):
    '''
    serach the place of value in excel file
    :param filepath: the Excel exist path.
    :param filesheet: the sheet name which add the counter data
    :param search_key: key which want to search

    '''

    data = openpyxl.load_workbook(filepath)
    table = data[filesheet]
    serach_key_row = 1
    serach_key_col = 1
    serach_key_value = 1
    for row in table.iter_rows():
        for cell in row:
            if cell.value is not None:
                info = str(cell.value).find(str(search_key))
                if info == 0:
                    serach_key_row = cell.row
                    serach_key_col = cell.column
                    serach_key_value = cell.value
    print(serach_key_row, serach_key_col, serach_key_value)
    return serach_key_row, serach_key_col, serach_key_value


def get_counter_names(counter_prop):
    initial_counters = []
    counter_title = []
    for initial_counter in counter_prop:
        initial_counters.append(initial_counter)
    for counter in initial_counters:
        counter_title.append('GNB{}/{}/{}'.format(counter['gnb_id'], counter['dic_path'], counter['counter_id']))

    return counter_title


def sum_counters_value_to_dict(filepath, filesheet):
    '''
    sum values of per counter
    :rtype: object
    :param filepath: the Excel exist path.
    :param filesheet:the sheet name which add the counter data
    :return dict_sum_counter_name_and_value: get dictionary of sum counter's name and corresponding value
    '''
    data = openpyxl.load_workbook(filepath)
    table = data[filesheet]

    ncols_num = table.max_column
    counter_names_value = []
    for i in range(1, ncols_num + 1):
        counter_names_value.append(table.cell(row=1, column=i).value)
    list_counters_name = list(set(counter_names_value[1:]))

    list_sum_counters_value = []
    for counter in list_counters_name:
        counter_values_valiable = get_value_on_excel(filepath, filesheet, counter)
        list_sum_counters_value.append(counter_values_valiable)

    dict_sum_counter_name_and_value = dict(zip(list_counters_name, list_sum_counters_value))
    print(dict_sum_counter_name_and_value)

    return dict_sum_counter_name_and_value


def calculate_percentage_for_each_scenario(filepath, filesheet, KPI_ID):
    '''
    calculate percentage for per kpi
    :param KPI_ID: : list which contain kpiid like:
            'NR_5175b', 'NR_5176b', 'NR_5177b', 'NR_5206a', 'NR_5202a', 'NR_5204a',
    :param filepath: the Excel exist path.
    :param filesheet:the sheet name which add the counter data
    '''
    Intra_F_TDD_TDD_intra_gnb_intra_DU_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE1]
    Intra_F_TDD_TDD_intra_gnb_inter_DU_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE2]
    Intra_F_TDD_TDD_inter_gnb_inter_DU_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE3]
    Inter_F_TDD_TDD_inter_gnb_HO_via_Xn = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE4]
    Inter_F_TDD_TDD_intra_gnb_inter_DU_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE5]
    Inter_F_TDD_TDD_intra_gnb_intra_DU_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE6]
    Inter_F_TDD_TDD_HO_via_NG = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE7]
    Inter_RAT_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE8]
    Intra_F_T_T_intra_DU_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE1]
    Intra_F_T_T_intra_gnb_inter_DU_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE2]
    Inter_F_T_T_intra_gnb_inter_DU_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE3]
    Inter_F_T_T_inter_gnb_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE4]
    Inter_F_T_T_intra_DU_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE5]
    Intra_F_T_T_inter_gnb_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE6]
    Inter_MeNB_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE7]
    Intra_MeNB_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE8]
    dict_sum = sum_counters_value_to_dict(filepath, filesheet)
    list_percentage_value = []
    total_ho_attempts = []
    total_ho_success = []
    if KPI_ID == 'NR_5175b':
        MC301 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[0]) + \
                dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[4])
        MC302 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[1]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[5])
        MC303 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[2]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[6])
        MC304 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[3]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[7])
        print(int(MC301), int(MC303), int(MC304))
        total_ho_attempts = [int(MC301) + int(MC303) + int(MC304)]
        total_ho_success = [int(MC302)]
        try:
            intra_gnb_intra_du_prepare_succ = round(float(MC301) / (float(MC301) + float(MC303) + float(MC304)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [intra_gnb_intra_du_prepare_succ]
    elif KPI_ID == 'NR_5176b':
        MC301 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[0]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[4])
        MC302 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[1]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[5])
        MC303 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[2]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[6])
        MC304 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[3]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[7])
        print(int(MC301), int(MC302))
        total_ho_attempts = [int(MC301) + int(MC303) + int(MC304)]
        total_ho_success = [int(MC302)]
        try:
            intra_gnb_intra_du_execution_success_ratio = round((float(MC302) / float(MC301)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [intra_gnb_intra_du_execution_success_ratio]
    elif KPI_ID == 'NR_5177b':
        MC301 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[0]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[4])
        MC302 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[1]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[5])
        MC303 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[2]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[6])
        MC304 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[3]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_intra_DU_HO[7])
        print(int(MC301), int(MC302), int(MC303), int(MC304))
        total_ho_attempts = [int(MC301) + int(MC303) + int(MC304)]
        total_ho_success = [int(MC302)]
        try:
            intra_gnb_intra_ho_succ_ratio = round((float(MC302) / (float(MC301) + float(MC303) + float(MC304))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [intra_gnb_intra_ho_succ_ratio]
    elif KPI_ID == 'NR_5376a':
        MC3501 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[0]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[4])
        MC3502 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[1]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[5])
        MC3503 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[2]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[6])
        MC3504 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[3]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[7])
        print(int(MC3501), int(MC3502), int(MC3503))
        total_ho_attempts = [int(MC3501) + int(MC3502) + int(MC3503)]
        total_ho_success = [int(MC3504)]
        try:
            intra_gnb_inter_du_prepare_succ = round(float(MC3503) / (float(MC3501) + float(MC3502) + float(MC3503)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [intra_gnb_inter_du_prepare_succ]
    elif KPI_ID == 'NR_5377a':
        MC3501 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[0]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[4])
        MC3502 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[1]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[5])
        MC3503 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[2]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[6])
        MC3504 = dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[3]) + \
            dict_sum.get(Intra_F_TDD_TDD_intra_gnb_inter_DU_HO[7])
        print(int(MC3501), int(MC3502), int(MC3503))
        total_ho_attempts = [int(MC3501) + int(MC3502) + int(MC3503)]
        total_ho_success = [int(MC3504)]
        try:
            intra_gnb_inter_du_execution_success_ratio = round((float(MC3504) / float(MC3503)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [intra_gnb_inter_du_execution_success_ratio]
    elif KPI_ID == 'NR_5204a':
        tmp_NR_5204a_0 = dict_sum.get(Intra_F_TDD_TDD_inter_gnb_inter_DU_HO[0])
        tmp_NR_5204a_1 = dict_sum.get(Intra_F_TDD_TDD_inter_gnb_inter_DU_HO[1])
        tmp_NR_5204a_2 = dict_sum.get(Intra_F_TDD_TDD_inter_gnb_inter_DU_HO[2])
        tmp_NR_5204a_3 = dict_sum.get(Intra_F_TDD_TDD_inter_gnb_inter_DU_HO[3])
        total_ho_attempts = [int(tmp_NR_5204a_0), int(tmp_NR_5204a_2)]
        total_ho_success = [int(tmp_NR_5204a_1), int(tmp_NR_5204a_3)]
        try:
            tmp1 = float(tmp_NR_5204a_1) / float(tmp_NR_5204a_0)
            tmp2 = float(tmp_NR_5204a_3) / float(tmp_NR_5204a_2)
            print(int(tmp1), int(tmp2))
            Intra_freq_inter_gNB1_ho_exec_suc = round(tmp1, 4)
            Intra_freq_inter_gNB2_ho_exec_suc = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [Intra_freq_inter_gNB1_ho_exec_suc, Intra_freq_inter_gNB2_ho_exec_suc]
    elif KPI_ID == 'NR_5206a':
        tmp_5206a_0 = dict_sum.get(Inter_F_TDD_TDD_inter_gnb_HO_via_Xn[0])
        tmp_5206a_1 = dict_sum.get(Inter_F_TDD_TDD_inter_gnb_HO_via_Xn[1])
        tmp_5206a_2 = dict_sum.get(Inter_F_TDD_TDD_inter_gnb_HO_via_Xn[2])
        tmp_5206a_3 = dict_sum.get(Inter_F_TDD_TDD_inter_gnb_HO_via_Xn[3])
        total_ho_attempts = [int(tmp_5206a_0), int(tmp_5206a_2)]
        total_ho_success = [int(tmp_5206a_1), int(tmp_5206a_3)]
        try:
            tmp1 = float(tmp_5206a_1) / float(tmp_5206a_0)
            tmp2 = float(tmp_5206a_3) / float(tmp_5206a_2)
            print(int(tmp1), int(tmp2))
            inter_freq_inter_gNB1_xn_ho_exec_succ = round(tmp1, 4)
            inter_freq_inter_gNB2_xn_ho_exec_succ = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_inter_gNB1_xn_ho_exec_succ, inter_freq_inter_gNB2_xn_ho_exec_succ]
    elif KPI_ID == 'NR_5380a':
        MC3505 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[0]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[4])
        MC3506 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[1]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[5])
        MC3507 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[2]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[6])
        MC3508 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[3]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[7])
        print(int(MC3505), int(MC3506), int(MC3507))
        total_ho_attempts = [int(MC3505) + int(MC3506) + int(MC3507)]
        total_ho_success = [int(MC3508)]
        try:
            inter_freq_intra_gnb_inter_du_prepare_succ = round(float(MC3507) / (float(MC3505)
                                                                                + float(MC3506) + float(MC3507)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_intra_gnb_inter_du_prepare_succ]
    elif KPI_ID == 'NR_5381a':
        MC3505 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[0]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[4])
        MC3506 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[1]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[5])
        MC3507 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[2]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[6])
        MC3508 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[3]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_inter_DU_HO[7])
        print(int(MC3505), int(MC3506), int(MC3507))
        total_ho_attempts = [int(MC3505) + int(MC3506) + int(MC3507)]
        total_ho_success = [int(MC3508)]
        try:
            inter_freq_intra_gnb_inter_du_execution_success_ratio = round((float(MC3508) / float(MC3507)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_intra_gnb_inter_du_execution_success_ratio]
    elif KPI_ID == 'NR_5202a':
        MC321 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_intra_DU_HO[0]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_intra_DU_HO[2])
        MC322 = dict_sum.get(Inter_F_TDD_TDD_intra_gnb_intra_DU_HO[1]) + \
            dict_sum.get(Inter_F_TDD_TDD_intra_gnb_intra_DU_HO[3])
        print(int(MC321), int(MC322))
        print("MC321:{}".format(int(MC321)))
        print("MC322:{}".format(int(MC322)))
        total_ho_attempts = [int(MC321)]
        total_ho_success = [int(MC322)]
        try:
            inter_frequency_intra_DU_handover_execution_success_ratio = round(float(MC322) / float(MC321), 4)
            print("KPI:{}".format(inter_frequency_intra_DU_handover_execution_success_ratio))
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_frequency_intra_DU_handover_execution_success_ratio]
    elif KPI_ID == 'NR_5410a':
        list_NR_5410a = []
        for i in range(len(Inter_F_TDD_TDD_HO_via_NG)):
            list_NR_5410a.append(dict_sum.get(Inter_F_TDD_TDD_HO_via_NG[i]))
        total_ho_attempts = [int(list_NR_5410a[0]), int(list_NR_5410a[3])]
        total_ho_success = [int(list_NR_5410a[1]), int(list_NR_5410a[4])]
        try:
            tmp1 = float(list_NR_5410a[1]) / float(list_NR_5410a[0])
            tmp2 = float(list_NR_5410a[4]) / float(list_NR_5410a[3])
            print(float(tmp1), float(tmp2))
            inter_freq_inter_gNB1_ho_NG_prep_succ = round(tmp1, 4)
            inter_freq_inter_gNB2_ho_NG_prep_succ = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_inter_gNB1_ho_NG_prep_succ, inter_freq_inter_gNB2_ho_NG_prep_succ]
    elif KPI_ID == 'NR_5412a':
        list_NR_5412a = []
        for i in range(len(Inter_F_TDD_TDD_HO_via_NG)):
            list_NR_5412a.append(dict_sum.get(Inter_F_TDD_TDD_HO_via_NG[i]))
        total_ho_attempts = [int(list_NR_5412a[1]), int(list_NR_5412a[4])]
        total_ho_success = [int(list_NR_5412a[2]), int(list_NR_5412a[5])]
        try:
            tmp1 = float(list_NR_5412a[2]) / float(list_NR_5412a[1])
            tmp2 = float(list_NR_5412a[5]) / float(list_NR_5412a[4])
            print(int(tmp1), int(tmp2))
            inter_freq_inter_gNB1_ho_NG_exec_succ = round(tmp1, 4)
            inter_freq_inter_gNB2_ho_NG_exec_succ = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_inter_gNB1_ho_NG_exec_succ, inter_freq_inter_gNB2_ho_NG_exec_succ]
    elif KPI_ID == 'NR_5413a':
        list_NR_5413a = []
        for i in range(len(Inter_F_TDD_TDD_HO_via_NG)):
            list_NR_5413a.append(dict_sum.get(Inter_F_TDD_TDD_HO_via_NG[i]))
        total_ho_attempts = [int(list_NR_5413a[0]), int(list_NR_5413a[3])]
        total_ho_success = [int(list_NR_5413a[2]), int(list_NR_5413a[5])]
        try:
            tmp1 = float(list_NR_5413a[2]) / float(list_NR_5413a[0])
            tmp2 = float(list_NR_5413a[5]) / float(list_NR_5413a[3])
            print(int(tmp1), int(tmp2))
            inter_freq_inter_gNB1_ho_NG_total_succ = round(tmp1, 4)
            inter_freq_inter_gNB2_ho_NG_total_succ = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_inter_gNB1_ho_NG_total_succ, inter_freq_inter_gNB2_ho_NG_total_succ]
    elif KPI_ID == 'NR_5195a':
        list_NR_5195a = []
        for i in range(len(Inter_RAT_HO)):
            list_NR_5195a.append(dict_sum.get(Inter_RAT_HO[i]))
        total_ho_attempts = [int(list_NR_5195a[0])]
        total_ho_success = [int(list_NR_5195a[1])]
        try:
            inter_rat_ho_prep_success_ratio = round((float(list_NR_5195a[1]) / float(list_NR_5195a[0])), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_rat_ho_prep_success_ratio]
    elif KPI_ID == 'NR_5197a':
        list_NR_5197a = []
        for i in range(len(Inter_RAT_HO)):
            list_NR_5197a.append(dict_sum.get(Inter_RAT_HO[i]))
        total_ho_attempts = [int(list_NR_5197a[1])]
        total_ho_success = [int(list_NR_5197a[2])]
        try:
            inter_rat_ho_exec_success_ratio = round((float(list_NR_5197a[2]) / float(list_NR_5197a[1])), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_rat_ho_exec_success_ratio]
    elif KPI_ID == 'NR_5198a':
        list_NR_5198a = []
        for i in range(len(Inter_RAT_HO)):
            list_NR_5198a.append(dict_sum.get(Inter_RAT_HO[i]))
        total_ho_attempts = [int(list_NR_5198a[0])]
        total_ho_success = [int(list_NR_5198a[2])]
        try:
            inter_rat_ho_total_success_ratio = round((float(list_NR_5198a[2]) / float(list_NR_5198a[0])), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_rat_ho_total_success_ratio]
    elif KPI_ID == 'NR_5671a':
        list_NR_5671a = []
        for i in range(len(Inter_RAT_HO)):
            list_NR_5671a.append(dict_sum.get(Inter_RAT_HO[i]))
        total_ho_attempts = [int(list_NR_5671a[3])]
        total_ho_success = [int(list_NR_5671a[4])]
        try:
            inter_rat_ho_prep_success_ratio = round((float(list_NR_5671a[4]) / float(list_NR_5671a[3])), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_rat_ho_prep_success_ratio]
    elif KPI_ID == 'NR_5672a':
        list_NR_5672a = []
        for i in range(len(Inter_RAT_HO)):
            list_NR_5672a.append(dict_sum.get(Inter_RAT_HO[i]))
        total_ho_attempts = [int(list_NR_5672a[4])]
        total_ho_success = [int(list_NR_5672a[5])]
        try:
            inter_rat_ho_exec_success_ratio = round((float(list_NR_5672a[5]) / float(list_NR_5672a[4])), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_rat_ho_exec_success_ratio]
    elif KPI_ID == 'NR_5047b':
        MC1001 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[0]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[8])
        MC1002 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[1]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[9])
        MC1003 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[2]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[10])
        MC1004 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[3]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[11])
        MC1005 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[4]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[12])
        MC1006 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[5]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[13])
        MC1007 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[6]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[14])
        MC1008 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[7]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[15])
        print(int(MC1001), int(MC1002), int(MC1003), int(MC1004), int(MC1005), int(MC1006), int(MC1007), int(MC1008))
        total_ho_attempts = [int(MC1001) + int(MC1002) + int(MC1007) + int(MC1008) + int(MC1005)]
        total_ho_success = [int(MC1001) + int(MC1002)]
        try:
            nsa_preparation_success_ratio = round(((float(MC1001) + float(MC1002)) / (
                    float(MC1001) + float(MC1002) + float(MC1007) + float(MC1008) + float(MC1005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_preparation_success_ratio]
    elif KPI_ID == 'NR_5048b':
        MC1001 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[0]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[8])
        MC1002 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[1]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[9])
        MC1003 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[2]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[10])
        MC1004 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[3]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[11])
        MC1005 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[4]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[12])
        MC1006 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[5]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[13])
        MC1007 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[6]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[14])
        MC1008 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[7]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[15])
        print(int(MC1001), int(MC1002), int(MC1003), int(MC1004), int(MC1005), int(MC1006), int(MC1007), int(MC1008))
        total_ho_attempts = [int(MC1001) + int(MC1002)]
        total_ho_success = [int(MC1001) + int(MC1002) - int(MC1006) - int(MC1003) - int(MC1004)]
        try:
            nsa_execution_success_ratio = round(((float(MC1001) + float(MC1002) - float(MC1006) - float(
                MC1003) - float(MC1004)) / (float(MC1001) + float(MC1002))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_execution_success_ratio]
    elif KPI_ID == 'NR_5049b':
        MC1001 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[0]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[8])
        MC1002 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[1]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[9])
        MC1003 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[2]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[10])
        MC1004 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[3]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[11])
        MC1005 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[4]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[12])
        MC1006 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[5]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[13])
        MC1007 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[6]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[14])
        MC1008 = dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[7]) + dict_sum.get(Intra_F_T_T_intra_DU_HO_NSA[15])
        print(int(MC1001), int(MC1002), int(MC1003), int(MC1004), int(MC1005), int(MC1006), int(MC1007), int(MC1008))
        total_ho_attempts = [int(MC1001) + int(MC1002) + int(MC1007) + int(MC1008) + int(MC1005)]
        total_ho_success = [int(MC1001) + int(MC1002) - int(MC1006) - int(MC1003) - int(MC1004)]
        try:
            nsa_total_succ_ratio = round(((float(MC1001) + float(MC1002) - float(MC1006) - float(MC1003) - float(
                MC1004)) / (float(MC1001) + float(MC1002) + float(MC1007) + float(MC1008) + float(MC1005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_total_succ_ratio]
    elif KPI_ID == 'NR_5038b':
        MC0001 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[0]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[6])
        MC0501 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[1]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[7])
        MC0002 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[2]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[8])
        MC0003 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[3]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[9])
        MC0004 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[4]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[10])
        MC0007 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[5]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[11])

        print(int(MC0001), int(MC0501), int(MC0002), int(MC0003), int(MC0004), int(MC0007))
        total_ho_attempts = [int(MC0001) + int(MC0501)]
        total_ho_success = [int(MC0001) + int(MC0501) - int(MC0002) - int(MC0003)]
        try:
            nsa_exec_succ_ratio = round(((float(MC0001) + float(MC0501) - float(MC0002) - float(MC0003)) / (float(
                MC0001) + float(MC0501))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_exec_succ_ratio]
    elif KPI_ID == 'NR_5041b':
        MC0001 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[0]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[6])
        MC0501 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[1]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[7])
        MC0002 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[2]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[8])
        MC0003 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[3]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[9])
        MC0004 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[4]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[10])
        MC0007 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[5]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[11])

        print(int(MC0001), int(MC0501), int(MC0002), int(MC0003), int(MC0004), int(MC0007))
        total_ho_attempts = [int(MC0001) + int(MC0501) + int(MC0004)]
        total_ho_success = [int(MC0001) + int(MC0501)]
        try:
            nsa_prep_succ_ratio = round(((float(MC0001) + float(MC0501)) / (float(
                MC0001) + float(MC0501) + int(MC0004))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_prep_succ_ratio]
    elif KPI_ID == 'NR_5042b':
        MC0001 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[0]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[6])
        MC0501 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[1]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[7])
        MC0002 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[2]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[8])
        MC0003 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[3]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[9])
        MC0004 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[4]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[10])
        MC0007 = dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[5]) + \
            dict_sum.get(Intra_F_T_T_intra_gnb_inter_DU_HO_NSA[11])

        print(int(MC0001), int(MC0501), int(MC0002), int(MC0003), int(MC0004), int(MC0007))
        total_ho_attempts = [int(MC0001) + int(MC0501) + int(MC0004)]
        total_ho_success = [int(MC0001) + int(MC0501) - int(MC0002) - int(MC0003)]
        try:
            nsa_total_succ_ratio = round(((float(MC0001) + float(MC0501) - float(MC0002) - float(MC0003)) / (float(
                MC0001) + float(MC0501) + int(MC0004))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_total_succ_ratio]
    elif KPI_ID == 'NR_5189b':
        MC0013 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[0]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[8])
        MC0014 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[1]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[9])
        MC0015 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[2]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[10])
        MC0016 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[3]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[11])
        MC0017 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[4]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[12])
        MC0018 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[5]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[13])
        MC0019 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[6]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[14])
        MC0020 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[7]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[15])

        print(int(MC0013), int(MC0014), int(MC0015), int(MC0016), int(MC0017), int(MC0018), int(MC0019), int(MC0020))
        total_ho_attempts = [int(MC0013) + int(MC0014) + int(MC0017) + int(MC0019) + int(MC0020)]
        total_ho_success = [int(MC0013) + int(MC0014)]
        try:
            nsa_prep_succ_ratio = round(((float(MC0013) + float(MC0014)) / (float(MC0013) + float(MC0014) + float(
                MC0017) + float(MC0019) + float(MC0020))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_prep_succ_ratio]
    elif KPI_ID == 'NR_5190b':
        MC0013 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[0]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[8])
        MC0014 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[1]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[9])
        MC0015 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[2]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[10])
        MC0016 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[3]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[11])
        MC0017 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[4]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[12])
        MC0018 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[5]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[13])
        MC0019 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[6]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[14])
        MC0020 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[7]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[15])

        print(int(MC0013), int(MC0014), int(MC0015), int(MC0016), int(MC0017), int(MC0018), int(MC0019), int(MC0020))
        total_ho_attempts = [int(MC0013) + int(MC0014)]
        total_ho_success = [int(MC0013) + int(MC0014) - int(MC0015) - int(MC0016) - int(MC0018)]
        try:
            nsa_exec_succ_ratio = round(((float(MC0013) + float(MC0014) - float(MC0015) - float(
                MC0016) - int(MC0018)) / (float(MC0013) + float(MC0014))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_exec_succ_ratio]
    elif KPI_ID == 'NR_5191b':
        MC0013 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[0]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[8])
        MC0014 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[1]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[9])
        MC0015 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[2]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[10])
        MC0016 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[3]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[11])
        MC0017 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[4]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[12])
        MC0018 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[5]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[13])
        MC0019 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[6]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[14])
        MC0020 = dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[7]) + \
            dict_sum.get(Inter_F_T_T_intra_gnb_inter_DU_HO_NSA[15])

        print(int(MC0013), int(MC0014), int(MC0015), int(MC0016), int(MC0017), int(MC0018), int(MC0019), int(MC0020))
        total_ho_attempts = [int(MC0013) + int(MC0014) + int(MC0017) + int(MC0019) + int(MC0020)]
        total_ho_success = [int(MC0013) + int(MC0014) - int(MC0015) - int(MC0016) - int(MC0018)]
        try:
            nsa_total_succ_ratio = round(((float(MC0013) + float(MC0014) - float(MC0015) - float(MC0016) - float(
                MC0018)) / (float(MC0013) + float(MC0014) + float(MC0017) + float(MC0019) + float(MC0020))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_total_succ_ratio]
    elif KPI_ID == 'NR_5034a':
        list_NR_5034a = []
        for i in range(len(Inter_F_T_T_inter_gnb_HO_NSA)):
            list_NR_5034a.append(dict_sum.get(Inter_F_T_T_inter_gnb_HO_NSA[i]))
        total_ho_attempts = [int(list_NR_5034a[0]), int(list_NR_5034a[5])]
        total_ho_success = [int(list_NR_5034a[1]), int(list_NR_5034a[6])]
        try:
            tmp1 = float(list_NR_5034a[1]) / float(list_NR_5034a[0])
            tmp2 = float(list_NR_5034a[6]) / float(list_NR_5034a[5])
            print(float(tmp1), float(tmp2))
            nsa_gNB1_inter_gNB_ho_succ_ratio = round(tmp1, 4)
            nsa_gNB2_inter_gNB_ho_succ_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_gNB1_inter_gNB_ho_succ_ratio, nsa_gNB2_inter_gNB_ho_succ_ratio]
    elif KPI_ID == 'NR_5730a':
        list_NR_5730a = []
        for i in range(len(Inter_F_T_T_inter_gnb_HO_NSA)):
            list_NR_5730a.append(dict_sum.get(Inter_F_T_T_inter_gnb_HO_NSA[i]))
        total_ho_attempts = [int(list_NR_5730a[2]), int(list_NR_5730a[7])]
        total_ho_success = [int(list_NR_5730a[3]), int(list_NR_5730a[8])]
        try:
            tmp1 = float(list_NR_5730a[3]) / float(list_NR_5730a[2])
            tmp2 = float(list_NR_5730a[8]) / float(list_NR_5730a[7])
            print(float(tmp1), float(tmp2))
            nsa_gNB1_if_inter_gNB_ho_succ_ratio = round(tmp1, 4)
            nsa_gNB2_if_inter_gNB_ho_succ_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_gNB1_if_inter_gNB_ho_succ_ratio, nsa_gNB2_if_inter_gNB_ho_succ_ratio]
    elif KPI_ID == 'NR_5731a':
        list_NR_5731a = []
        for i in range(len(Inter_F_T_T_inter_gnb_HO_NSA)):
            list_NR_5731a.append(dict_sum.get(Inter_F_T_T_inter_gnb_HO_NSA[i]))
        total_ho_attempts = [int(list_NR_5731a[2]), int(list_NR_5731a[7])]
        total_ho_success = [int(list_NR_5731a[4]), int(list_NR_5731a[9])]
        try:
            tmp1 = float(list_NR_5731a[4]) / float(list_NR_5731a[2])
            tmp2 = float(list_NR_5731a[9]) / float(list_NR_5731a[7])
            print(float(tmp1), float(tmp2))
            nsa_gNB1_if_inter_gNB_ho_tot_succ_ratio = round(tmp1, 4)
            nsa_gNB2_if_inter_gNB_ho_tot_succ_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_gNB1_if_inter_gNB_ho_tot_succ_ratio, nsa_gNB2_if_inter_gNB_ho_tot_succ_ratio]
    elif KPI_ID == 'NR_5185b':
        MC0001 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[0]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[8])
        MC0002 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[1]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[9])
        MC0003 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[2]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[10])
        MC0004 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[3]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[11])
        MC0005 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[4]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[12])
        MC0006 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[5]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[13])
        MC0007 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[6]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[14])
        MC0008 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[7]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[15])
        print(int(MC0001), int(MC0002), int(MC0003), int(MC0004), int(MC0005), int(MC0006), int(MC0007), int(MC0008))
        total_ho_attempts = [int(MC0001) + int(MC0002) + int(MC0007) + int(MC0008) + int(MC0005)]
        total_ho_success = [int(MC0001) + int(MC0002)]
        try:
            nsa_preparation_success_ratio = round(((float(MC0001) + float(MC0002)) / (
                    float(MC0001) + float(MC0002) + float(MC0007) + float(MC0008) + float(MC0005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_preparation_success_ratio]
    elif KPI_ID == 'NR_5186b':
        MC0001 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[0]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[8])
        MC0002 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[1]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[9])
        MC0003 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[2]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[10])
        MC0004 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[3]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[11])
        MC0005 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[4]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[12])
        MC0006 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[5]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[13])
        MC0007 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[6]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[14])
        MC0008 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[7]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[15])
        print(int(MC0001), int(MC0002), int(MC0003), int(MC0004), int(MC0005), int(MC0006), int(MC0007), int(MC0008))
        total_ho_attempts = [int(MC0001) + int(MC0002)]
        total_ho_success = [int(MC0001) + int(MC0002) - int(MC0006) - int(MC0003) - int(MC0004)]
        try:
            nsa_execution_success_ratio = round(((float(MC0001) + float(MC0002) - float(MC0006) - float(
                MC0003) - float(MC0004)) / (float(MC0001) + float(MC0002))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_execution_success_ratio]
    elif KPI_ID == 'NR_5187b':
        MC0001 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[0]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[8])
        MC0002 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[1]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[9])
        MC0003 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[2]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[10])
        MC0004 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[3]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[11])
        MC0005 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[4]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[12])
        MC0006 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[5]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[13])
        MC0007 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[6]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[14])
        MC0008 = dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[7]) + dict_sum.get(Inter_F_T_T_intra_DU_HO_NSA[15])
        print(int(MC0001), int(MC0002), int(MC0003), int(MC0004), int(MC0005), int(MC0006), int(MC0007), int(MC0008))
        total_ho_attempts = [int(MC0001) + int(MC0002) + int(MC0007) + int(MC0008) + int(MC0005)]
        total_ho_success = [int(MC0001) + int(MC0002) - int(MC0006) - int(MC0003) - int(MC0004)]
        try:
            nsa_total_succ_ratio = round(((float(MC0001) + float(MC0002) - float(MC0006) - float(MC0003) - float(
                MC0004)) / (float(MC0001) + float(MC0002) + float(MC0007) + float(MC0008) + float(MC0005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_total_succ_ratio]
    elif KPI_ID == 'NR_5071a':
        list_NR_5071a = []
        for i in range(len(Intra_F_T_T_inter_gnb_HO_NSA)):
            list_NR_5071a.append(dict_sum.get(Intra_F_T_T_inter_gnb_HO_NSA[i]))
        total_ho_attempts = [int(list_NR_5071a[2]), int(list_NR_5071a[10])]
        total_ho_success = [int(list_NR_5071a[3]), int(list_NR_5071a[11])]
        try:
            tmp1 = float(list_NR_5071a[3]) / float(list_NR_5071a[2])
            tmp2 = float(list_NR_5071a[11]) / float(list_NR_5071a[10])
            print(float(tmp1), float(tmp2))
            nsa_gNB1_inter_gNB_ho_succ_ratio = round(tmp1, 4)
            nsa_gNB2_inter_gNB_ho_succ_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_gNB1_inter_gNB_ho_succ_ratio, nsa_gNB2_inter_gNB_ho_succ_ratio]
    elif KPI_ID == 'NR_5074a':
        list_NR_5074a = []
        for i in range(len(Intra_F_T_T_inter_gnb_HO_NSA)):
            list_NR_5074a.append(dict_sum.get(Intra_F_T_T_inter_gnb_HO_NSA[i]))
        total_ho_attempts = [int(list_NR_5074a[2]), int(list_NR_5074a[10])]
        total_ho_success = [int(list_NR_5074a[4]), int(list_NR_5074a[12])]
        try:
            tmp1 = float(list_NR_5074a[4]) / float(list_NR_5074a[2])
            tmp2 = float(list_NR_5074a[12]) / float(list_NR_5074a[10])
            print(float(tmp1), float(tmp2))
            nsa_gNB1_inter_gNB_ho_total_succ_ratio = round(tmp1, 4)
            nsa_gNB2_inter_gNB_ho_total_succ_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_gNB1_inter_gNB_ho_total_succ_ratio, nsa_gNB2_inter_gNB_ho_total_succ_ratio]
    elif KPI_ID == 'NR_5732a':
        list_NR_5732a = []
        for i in range(len(Intra_F_T_T_inter_gnb_HO_NSA)):
            list_NR_5732a.append(dict_sum.get(Intra_F_T_T_inter_gnb_HO_NSA[i]))
        total_ho_attempts1 = int(list_NR_5732a[0]) - int(list_NR_5732a[6])
        total_ho_attempts2 = int(list_NR_5732a[8]) - int(list_NR_5732a[14])
        total_ho_attempts = [total_ho_attempts1, total_ho_attempts2]
        total_ho_success = [int(list_NR_5732a[5]), int(list_NR_5732a[13])]
        try:
            tmp1 = float(total_ho_success[0]) / float(total_ho_attempts[0])
            tmp2 = float(total_ho_success[1]) / float(total_ho_attempts[1])
            print(float(tmp1), float(tmp2))
            nsa_gNB1_intraF_interG_total_succ_ratio = round(tmp1, 4)
            nsa_gNB2_intraF_interG_total_succ_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_gNB1_intraF_interG_total_succ_ratio, nsa_gNB2_intraF_interG_total_succ_ratio]
    elif KPI_ID == 'NR_5750a':
        list_NR_5750a = []
        for i in range(len(Intra_F_T_T_inter_gnb_HO_NSA)):
            list_NR_5750a.append(dict_sum.get(Intra_F_T_T_inter_gnb_HO_NSA[i]))
        total_ho_attempts1 = int(list_NR_5750a[0]) - int(list_NR_5750a[6])
        total_ho_attempts2 = int(list_NR_5750a[8]) - int(list_NR_5750a[14])
        total_ho_success1 = int(list_NR_5750a[1]) - int(list_NR_5750a[7])
        total_ho_success2 = int(list_NR_5750a[9]) - int(list_NR_5750a[15])
        total_ho_attempts = [total_ho_attempts1, total_ho_attempts2]
        total_ho_success = [total_ho_success1, total_ho_success2]
        try:
            tmp1 = float(total_ho_success[0]) / float(total_ho_attempts[0])
            tmp2 = float(total_ho_success[1]) / float(total_ho_attempts[1])
            print(float(tmp1), float(tmp2))
            nsa_gNB1_intraF_intergNB_succ_ratio = round(tmp1, 4)
            nsa_gNB2_intraF_intergNB_succ_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_gNB1_intraF_intergNB_succ_ratio, nsa_gNB2_intraF_intergNB_succ_ratio]
    elif KPI_ID == 'NR_574':
        MC03501 = dict_sum.get(Inter_MeNB_HO_NSA[0])
        MC03502 = dict_sum.get(Inter_MeNB_HO_NSA[1])
        MC03503 = dict_sum.get(Inter_MeNB_HO_NSA[2])
        MC00501 = dict_sum.get(Inter_MeNB_HO_NSA[3])
        MC00502 = dict_sum.get(Inter_MeNB_HO_NSA[4])
        MC00503 = dict_sum.get(Inter_MeNB_HO_NSA[5])
        MC00504 = dict_sum.get(Inter_MeNB_HO_NSA[6])
        MC00505 = dict_sum.get(Inter_MeNB_HO_NSA[7])
        print(int(MC00503), int(MC00504))
        total_ho_attempts = [int(MC00503)]
        total_ho_success = [int(MC00504)]
        try:
            Inter_MeNB_HO_succ_ratio = round((float(MC00504)) / (float(MC00503)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [Inter_MeNB_HO_succ_ratio]
    elif KPI_ID == 'NR_575':
        MC00001 = dict_sum.get(Intra_MeNB_HO_NSA[0])
        MC00002 = dict_sum.get(Intra_MeNB_HO_NSA[1])
        MC00003 = dict_sum.get(Intra_MeNB_HO_NSA[2])
        MC00004 = dict_sum.get(Intra_MeNB_HO_NSA[3])
        MC00005 = dict_sum.get(Intra_MeNB_HO_NSA[4])
        print(int(MC00003), int(MC00004))
        total_ho_attempts = [int(MC00003)]
        total_ho_success = [int(MC00004)]
        try:
            Intra_MeNB_HO_succ_ratio = round((float(MC00004)) / (float(MC00003)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [Intra_MeNB_HO_succ_ratio]

    return list_percentage_value, total_ho_attempts, total_ho_success


def get_time_for_per_scenario(time_list, childern_list_len):
    '''
        get time values of each scenario
        :param time_list: list of per scenario
        :param childern_list_len: split time_list to many lists, num childern_list_len of per list
        '''
    get_time = [i.encode('utf-8') for i in time_list]
    n = childern_list_len
    result = [get_time[i:i + n] for i in range(0, len(get_time), n)]
    return result


def upload_execute_data(filepath, filesheet, KPI_ID, tl_id, time_list, childern_list_len, ue_number=1):
    '''
    upload result to compass
    :param filepath: the Excel exist path.
    :param filesheet:the sheet name which add the counter data
    :param KPI_ID: : list which contain kpiid like:
            'NR_5175b', 'NR_5176b', 'NR_5177b', 'NR_5206a_FT', 'NR_5202a_FT', 'NR_5204a', 'NR_5206a_TT', 'NR_5202a_TT'
    :param tl_id: instance id of gnb
    :param time_list: list of per scenario
    :param childern_list_len: split time_list to many lists, num childern_list_len of per list
    '''
    list_percentage_value = calculate_percentage_for_each_scenario(filepath, filesheet, KPI_ID)
    print("list_percentage_value:{}".format(list_percentage_value))
    time_per_secnario = get_time_for_per_scenario(time_list, childern_list_len)
    print("time_per_secnario:{}".format(time_per_secnario))
    # url_upload_execute_data = 'http://compass.eecloud.dynamic.nsn-net.net/kpi/api/case_execute_data/'
    url_upload_execute_data = 'http://compass-5g.eecloud.dynamic.nsn-net.net:8000/kpi/api/case_execute_data/'
    test_line = '7_5_UTE5G401T' + str(tl_id)[0:3]
    if KPI_ID == 'NR_5175b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5175b 5G SA intra-freq intra-gNB intra-DU handover preparation success ratio',
             'case_name': '[1]CB009881_C_SCE1_SA_Cloud_intrafre_intragnb_intraDU_HO_704',
             'start': time_per_secnario[6][0],
             'end': time_per_secnario[6][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[6],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5176b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5176b 5G SA intra-freq intra-gNB intra-DU handover execution success ratio',
             'case_name': '[1]CB009881_C_SCE1_SA_Cloud_intrafre_intragnb_intraDU_HO_704',
             'start': time_per_secnario[6][0],
             'end': time_per_secnario[6][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[6],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5177b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5177b 5G SA intra-freq intra-gNB intra-DU handover total success ratio',
             'case_name': '[1]CB009881_C_SCE1_SA_Cloud_intrafre_intragnb_intraDU_HO_704',
             'start': time_per_secnario[6][0],
             'end': time_per_secnario[6][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[6],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5376a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5376b 5G SA intra-freq intra-gNB inter-DU handover execution success ratio',
             'case_name': '[1]CB009881_C_SCE2_SA_Cloud_intrafre_intragnb_interDU_HO_704',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[0],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5377a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5377b 5G SA intra-freq intra-gNB inter-DU handover execution success ratio',
             'case_name': '[1]CB009881_C_SCE2_SA_Cloud_intrafre_intragnb_interDU_HO_704',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[0],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5204a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5204a 5G SA Xn based inter-gnb intra-frequency handover execution success ratio per PLMN',
             'case_name': '[1]CB009881_C_SCE3_SA_Cloud_intrafre_intergnb_HO_via_Xn_704',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[1],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5204a 5G SA Xn based inter-gnb intra-frequency handover execution success ratio per PLMN',
             'case_name': '[1]CB009881_C_SCE3_SA_Cloud_intrafre_intergnb_HO_via_Xn_704',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[1],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5206a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5206a 5G SA Xn based inter-gNB inter-frequency handover execution success ratio per PLMN',
             'case_name': '[1]CB009881_C_SCE4_SA_Cloud_interfre_intergnb_HO_via_Xn_706',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5206a 5G SA Xn based inter-gNB inter-frequency handover execution success ratio per PLMN',
             'case_name': '[1]CB009881_C_SCE4_SA_Cloud_interfre_intergnb_HO_via_Xn_706',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5380a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5380b 5G SA inter-freq intra-gNB inter-DU handover execution success ratio',
             'case_name': '[1]CB009881_C_SCE5_SA_Cloud_interfre_intragnb_interDU_HO_706',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[3],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5381a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5381b 5G SA inter-freq intra-gNB inter-DU handover execution success ratio per PLMN',
             'case_name': '[1]CB009881_C_SCE5_SA_Cloud_interfre_intragnb_interDU_HO_706',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[3],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5202a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5202a 5G SA inter-frequency intra-DU handover execution success ratio for per PLMN',
             'case_name': '[1]CB009881_C_SCE6_SA_Cloud_interfre_intragnb_intraDU_HO_706',
             'start': time_per_secnario[4][0],
             'end': time_per_secnario[4][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[4],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5410a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5410a 5G SA NG based handover preparation success ratio on the target cell',
             'case_name': '[1]CB009881_C_SCE7_SA_Cloud_interfre_intergnb_HO_via_NG_705',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5410a 5G SA NG based handover preparation success ratio on the target cell',
             'case_name': '[1]CB009881_C_SCE7_SA_Cloud_interfre_intergnb_HO_via_NG_705',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5412a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5412a 5G SA NG based handover execution success ratio on the target cell',
             'case_name': '[1]CB009881_C_SCE7_SA_Cloud_interfre_intergnb_HO_via_NG_705',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5412a 5G SA NG based handover execution success ratio on the target cell',
             'case_name': '[1]CB009881_C_SCE7_SA_Cloud_interfre_intergnb_HO_via_NG_705',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5413a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5413a 5G SA NG based handover total success ratio on the target cell',
             'case_name': '[1]CB009881_C_SCE7_SA_Cloud_interfre_intergnb_HO_via_NG_705',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5413a 5G SA NG based handover total success ratio on the target cell',
             'case_name': '[1]CB009881_C_SCE7_SA_Cloud_interfre_intergnb_HO_via_NG_705',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5195a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5195a 5G SA Inter-RAT handover preparation success ratio',
             'case_name': '[1]SFE_707_711_inter-rat_handover_between_5G_and_4G',
             'start': time_per_secnario[7][0],
             'end': time_per_secnario[7][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[7],
             'success_rate': list_percentage_value[0][0]},
        ]
    elif KPI_ID == 'NR_5197a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5197a 5G SA Inter-RAT handover execution success ratio',
             'case_name': '[1]SFE_707_711_inter-rat_handover_between_5G_and_4G',
             'start': time_per_secnario[7][0],
             'end': time_per_secnario[7][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[7],
             'success_rate': list_percentage_value[0][0]},
        ]
    elif KPI_ID == 'NR_5198a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5198a 5G SA Inter-RAT handover total success ratio',
             'case_name': '[1]SFE_707_711_inter-rat_handover_between_5G_and_4G',
             'start': time_per_secnario[7][0],
             'end': time_per_secnario[7][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[7],
             'success_rate': list_percentage_value[0][0]},
        ]
    elif KPI_ID == 'NR_5671a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5671a Incoming HO preparation success ratio for 5G SA Inter-RAT',
             'case_name': '[1]SFE_707_711_inter-rat_handover_between_5G_and_4G',
             'start': time_per_secnario[7][0],
             'end': time_per_secnario[7][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[7],
             'success_rate': list_percentage_value[0][0]},
        ]
    elif KPI_ID == 'NR_5672a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5672a HO execution success ratio for 5G SA Inter-RAT',
             'case_name': '[1]SFE_707_711_inter-rat_handover_between_5G_and_4G',
             'start': time_per_secnario[7][0],
             'end': time_per_secnario[7][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[7],
             'success_rate': list_percentage_value[0][0]},
        ]
    elif KPI_ID == 'NR_5047b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5047b 5G NSA Intra frequency intra DU PSCell change preparation success ratio',
             'case_name': '[1]CB009444_W_01_NSA_Handover_latency_Intra-Gnb_Intra-DU_HO_without SRB3_1_beam',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5048b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5048b 5G NSA Intra frequency intra DU PSCell change execution success ratio',
             'case_name': '[1]CB009444_W_01_NSA_Handover_latency_Intra-Gnb_Intra-DU_HO_without SRB3_1_beam',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5049b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5049b 5G NSA Intra frequency intra DU PSCell change total success ratio',
             'case_name': '[1]CB009444_W_01_NSA_Handover_latency_Intra-Gnb_Intra-DU_HO_without SRB3_1_beam',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[5],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5038b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5038b 5G NSA Intra gNB intra frequency PSCell change execution success ratio',
             'case_name': '[1]CB009444_W_05_NSA_Handover_latency_Intra-Gnb_Inter-DU_HO_without_SRB3_1_beam',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[0],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5041b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5041b 5G NSA Intra gNB intra frequency PSCell change preparation success ratio',
             'case_name': '[1]CB009444_W_05_NSA_Handover_latency_Intra-Gnb_Inter-DU_HO_without_SRB3_1_beam',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[0],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5042b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5042b 5G NSA Intra gNB intra frequency PSCell change total success ratio',
             'case_name': '[1]CB009444_W_05_NSA_Handover_latency_Intra-Gnb_Inter-DU_HO_without_SRB3_1_beam',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[0],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5189b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5189b 5G NSA Inter-frequency inter-DU handover preparation success ratio',
             'case_name': '[1]CB009444_W_06_NSA_Handover_latency_Intra-Gnb_Inter-DU_HO_without_SRB3_6_beam',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[1],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5190b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5190b 5G NSA Inter-frequency inter-DU handover execution success ratio',
             'case_name': '[1]CB009444_W_06_NSA_Handover_latency_Intra-Gnb_Inter-DU_HO_without_SRB3_6_beam',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[1],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5191b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5191b 5G NSA Inter-frequency inter-DU handover total success rati',
             'case_name': '[1]CB009444_W_06_NSA_Handover_latency_Intra-Gnb_Inter-DU_HO_without_SRB3_6_beam',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[1],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5034a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5034a 5G NSA Inter gNB handover success ratio for NSA',
             'case_name': '[1]CB009444_W_10_NSA_Handover_latency_Inter-Gnb_without_SRB3_6_beam',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[4],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5034a 5G NSA Inter gNB handover success ratio for NSA',
             'case_name': '[1]CB009444_W_10_NSA_Handover_latency_Inter-Gnb_without_SRB3_6_beam',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[4],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5730a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5730a 5G NSA Inter-gNB Inter-Frequency PSCell Change Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_10_NSA_Handover_latency_Inter-Gnb_without_SRB3_6_beam',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[4],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5730a 5G NSA Inter-gNB Inter-Frequency PSCell Change Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_10_NSA_Handover_latency_Inter-Gnb_without_SRB3_6_beam',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[4],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5731a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5731a 5G NSA Inter-gNB Inter-Frequency PSCell Change Total Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_10_NSA_Handover_latency_Inter-Gnb_without_SRB3_6_beam',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[4],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5731a 5G NSA Inter-gNB Inter-Frequency PSCell Change Total Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_10_NSA_Handover_latency_Inter-Gnb_without_SRB3_6_beam',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[4],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5185b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5185b 5G Inter-frequency intra-DU handover preparation success ratio for NSA',
             'case_name': '[1]CB009444_W_02_NSA_Handover_latency_Intra-Gnb_Intra-DU_HO_without SRB3_6_beam',
             'start': time_per_secnario[4][0],
             'end': time_per_secnario[4][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[3],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5186b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5186b 5G Inter-frequency intra-DU handover execution success ratio for NSA',
             'case_name': '[1]CB009444_W_02_NSA_Handover_latency_Intra-Gnb_Intra-DU_HO_without SRB3_6_beam',
             'start': time_per_secnario[4][0],
             'end': time_per_secnario[4][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[3],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5187b':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5187b 5G NSA Inter-frequency intra-DU handover total success ratio for NSA',
             'case_name': '[1]CB009444_W_02_NSA_Handover_latency_Intra-Gnb_Intra-DU_HO_without SRB3_6_beam',
             'start': time_per_secnario[4][0],
             'end': time_per_secnario[4][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[3],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5071a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5731a 5G NSA Inter gNB PSCell change preparation success ratio on target gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5731a 5G 5G NSA Inter gNB PSCell change preparation success ratio on target gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5074a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5734a 5G NSA Inter gNB PSCell change total success ratio on target gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5734a 5G NSA Inter gNB PSCell change total success ratio on target gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5732a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5732a 5G NSA Inter-gNB Intra-Frequency PSCell Change Total Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5732a 5G NSA Inter-gNB Intra-Frequency PSCell Change Total Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5750a':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'NR_5750a 5G NSA Inter-gNB Intra-Frequency PSCell Change Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_vDU3',
             'kpi': 'NR_5750a 5G NSA Inter-gNB Intra-Frequency PSCell Change Success Ratio on source gNB',
             'case_name': '[1]CB009444_W_09_NSA_Handover_latency_Inter-Gnb_without_SRB3_1_beam',
             'start': time_per_secnario[5][0],
             'end': time_per_secnario[5][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number[2],
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_574':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'Inter-MeNB HO without PSCell Change Success Ratio',
             'case_name': '[1]CB009444_N_20_5GC000574_inter_MeNB_HO_without_Pscell_change',
             'start': time_per_secnario[6][0],
             'end': time_per_secnario[6][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[6],
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_575':
        dict_data = [
            {'test_line': test_line + '_vDU1',
             'kpi': 'Intra-MeNB HO without PSCell Change Success Ratio',
             'case_name': '[1]CB009444_N_07_5GC000575_Counter_pegged_on_SgNbModification_during_intraMeNbHO',
             'start': time_per_secnario[7][0],
             'end': time_per_secnario[7][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number[7],
             'success_rate': list_percentage_value[0][0]}
        ]

    # headers = {'cookie': 'sessionid={}'.format('5vwr2ouphkr1zdpeij1dta0xjst8qw4f')}
    headers = {'cookie': 'sessionid={}'.format('abwvzh5qkstk8czlu2l2oyrinakd88o1')}
    response = requests.post(url=url_upload_execute_data, json=dict_data, headers=headers)
    print(response.status_code)
    print(response.content)
