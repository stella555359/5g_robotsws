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
from variable_new import SA_HO_SCE1, SA_HO_SCE2, SA_HO_SCE3, SA_HO_SCE4, SA_HO_SCE5, SA_HO_SCE6, NSA_HO_SCE1, \
    NSA_HO_SCE2, NSA_HO_SCE3, NSA_HO_SCE4, NSA_HO_SCE5, NSA_HO_SCE6, NSA_HO_SCE7, NSA_HO_SCE8, \
    VONR_INTRA_F_INTRA_GNB_HO, VONR_INTER_F_INTER_GNB_HO


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
        sshconn.send_command(command="adb devices |awk '{print $2}'", connection='get_ue_sn')
        read_output = sshconn.read_output(connection='get_ue_sn')
        result = read_output
        available_ue_num = int(result.count('device\r\n'))
        sshconn.send_command(
            command="adb devices  |tail -n -" + str(available_ue_num + 1) + "|awk '{print $1}'",
            connection='get_ue_sn')
        sn_output = sshconn.read_output(connection='get_ue_sn')
        result = sn_output
        list_result = result.split('\n')
        available_ue_SN = []
        for i in list_result:
            if len(i) > 0:
                available_ue_SN.append(i.strip())
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
            'NR_5175b', 'NR_5176b', 'NR_5177b', 'NR_5206a_FT', 'NR_5202a_FT', 'NR_5204a', 'NR_5206a_TT', 'NR_5202a_TT'
    :param filepath: the Excel exist path.
    :param filesheet:the sheet name which add the counter data
    '''
    Intra_F_FDD_FDD_intra_gnb_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE1]
    Inter_F_FDD_TDD_inter_gnb_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE2]
    Inter_F_FDD_TDD_intra_gnb_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE3]
    intra_F_TDD_TDD_inter_gnb_HO = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE4]
    Inter_F_FDD_TDD_inter_gnb_HO_NG = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE5]
    Inter_RAT_HO = ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SA_HO_SCE6]
    Intra_F_intra_gnb_F_F_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE1]
    Inter_F_inter_gnb_F_T_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE2]
    Inter_F_intra_gnb_F_F_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE3]
    Intra_F_inter_gnb_T_T_HO_NSA = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE4]
    Inter_MeNB_HO_NSA = ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE7]
    Intra_MeNB_HO_NSA = ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in NSA_HO_SCE8]
    VONR_IAHO_intra_gnb = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in VONR_INTRA_F_INTRA_GNB_HO]
    EMC_IFHO_inter_gnb = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in VONR_INTER_F_INTER_GNB_HO]
    dict_sum = sum_counters_value_to_dict(filepath, filesheet)
    list_percentage_value = []
    total_ho_attempts = []
    total_ho_success = []
    if KPI_ID == 'NR_5175b':
        MC301 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[0]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[4]) + \
                dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[8]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[12])
        MC302 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[1]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[5]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[9]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[13])
        MC303 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[2]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[6]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[10]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[14])
        MC304 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[3]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[7]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[11]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[15])
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
        MC301 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[0]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[4]) + \
                dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[8]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[12])
        MC302 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[1]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[5]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[9]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[13])
        MC303 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[2]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[6]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[10]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[14])
        MC304 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[3]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[7]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[11]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[15])
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
        MC301 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[0]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[4]) + \
                dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[8]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[12])
        MC302 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[1]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[5]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[9]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[13])
        MC303 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[2]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[6]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[10]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[14])
        MC304 = dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[3]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[7]) + \
            dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[11]) + dict_sum.get(Intra_F_FDD_FDD_intra_gnb_HO[15])
        print(int(MC301), int(MC302), int(MC303), int(MC304))
        total_ho_attempts = [int(MC301) + int(MC303) + int(MC304)]
        total_ho_success = [int(MC302)]
        try:
            intra_g_intra_ho_succ_ratio = round((float(MC302) / (float(MC301) + float(MC303) + float(MC304))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [intra_g_intra_ho_succ_ratio]
    elif KPI_ID == 'NR_5206a_FT':
        tmp_5206a_FT_0 = dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[0]) + dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[4])
        tmp_5206a_FT_1 = dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[1]) + dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[5])
        tmp_5206a_FT_2 = dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[2]) + dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[6])
        tmp_5206a_FT_3 = dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[3]) + dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO[7])
        total_ho_attempts = [int(tmp_5206a_FT_0), int(tmp_5206a_FT_2)]
        total_ho_success = [int(tmp_5206a_FT_1), int(tmp_5206a_FT_3)]
        try:
            tmp1 = float(tmp_5206a_FT_1) / float(tmp_5206a_FT_0)
            tmp2 = float(tmp_5206a_FT_3) / float(tmp_5206a_FT_2)
            print(int(tmp1), int(tmp2))
            inter_freq_inter_gNB1_ho_exec_succ = round(tmp1, 4)
            inter_freq_inter_gNB2_ho_exec_succ = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_inter_gNB1_ho_exec_succ, inter_freq_inter_gNB2_ho_exec_succ]
    elif KPI_ID == 'NR_5202a_FT':
        MC322 = dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[1]) + dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[3]) + \
                dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[5]) + dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[7])
        MC321 = dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[0]) + dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[2]) + \
            dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[4]) + dict_sum.get(Inter_F_FDD_TDD_intra_gnb_HO[6])
        print(int(MC322), int(MC321))
        total_ho_attempts = [int(MC321)]
        total_ho_success = [int(MC322)]
        try:
            inter_frequency_intra_DU_handover_execution_success_ratio = round(float(MC322) / float(MC321), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_frequency_intra_DU_handover_execution_success_ratio]
    elif KPI_ID == 'NR_5204a':
        tmp_NR_5204a_0 = dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[0]) + dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[4])
        tmp_NR_5204a_1 = dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[1]) + dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[5])
        tmp_NR_5204a_2 = dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[2]) + dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[6])
        tmp_NR_5204a_3 = dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[3]) + dict_sum.get(intra_F_TDD_TDD_inter_gnb_HO[7])
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
    elif KPI_ID == 'NR_5412a':
        list_NR_5412a = []
        for i in range(len(Inter_F_FDD_TDD_inter_gnb_HO_NG)):
            list_NR_5412a.append(dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO_NG[i]))
        total_ho_attempts = [int(list_NR_5412a[1]), int(list_NR_5412a[8])]
        total_ho_success = [int(list_NR_5412a[5]), int(list_NR_5412a[12])]
        try:
            tmp = float(list_NR_5412a[12]) / float(list_NR_5412a[8])
            print(int(tmp))
            inter_freq_inter_gNB2_ho_NG_exec_succ = round(tmp, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_inter_gNB2_ho_NG_exec_succ]
    elif KPI_ID == 'NR_5413a':
        list_NR_5413a = []
        for i in range(len(Inter_F_FDD_TDD_inter_gnb_HO_NG)):
            list_NR_5413a.append(dict_sum.get(Inter_F_FDD_TDD_inter_gnb_HO_NG[i]))
        total_ho_attempts = [int(list_NR_5413a[0]), int(list_NR_5413a[7])]
        total_ho_success = [int(list_NR_5413a[5]), int(list_NR_5413a[12])]
        try:
            tmp = float(list_NR_5413a[12]) / float(list_NR_5413a[7])
            print(int(tmp))
            inter_freq_inter_gNB2_ho_NG_total_succ = round(tmp, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [inter_freq_inter_gNB2_ho_NG_total_succ]
    elif KPI_ID == 'NR_5047b':
        MC1001 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[0]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[8])
        MC1002 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[1]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[9])
        MC1003 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[2]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[10])
        MC1004 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[3]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[11])
        MC1005 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[4]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[12])
        MC1006 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[5]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[13])
        MC1007 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[6]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[14])
        MC1008 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[7]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[15])
        print(int(MC1001), int(MC1002), int(MC1003), int(MC1004), int(MC1005), int(MC1006), int(MC1007), int(MC1008))
        total_ho_attempts = [int(MC1001) + int(MC1002) + int(MC1007) + int(MC1008) + int(MC1005)]
        total_ho_success = [int(MC1001) + int(MC1002) - int(MC1006) - int(MC1003) - int(MC1004)]
        try:
            nsa_agad_preparation_success_ratio = round(((float(MC1001) + float(MC1002)) / (
                    float(MC1001) + float(MC1002) + float(MC1007) + float(MC1008) + float(MC1005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_agad_preparation_success_ratio]
    elif KPI_ID == 'NR_5048b':
        MC1001 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[0]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[8])
        MC1002 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[1]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[9])
        MC1003 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[2]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[10])
        MC1004 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[3]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[11])
        MC1005 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[4]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[12])
        MC1006 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[5]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[13])
        MC1007 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[6]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[14])
        MC1008 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[7]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[15])
        print(int(MC1001), int(MC1002), int(MC1003), int(MC1004), int(MC1005), int(MC1006), int(MC1007), int(MC1008))
        total_ho_attempts = [int(MC1001) + int(MC1002) + int(MC1007) + int(MC1008) + int(MC1005)]
        total_ho_success = [int(MC1001) + int(MC1002) - int(MC1006) - int(MC1003) - int(MC1004)]
        try:
            nsa_agad_execution_success_ratio = round(((float(MC1001) + float(MC1002) - float(MC1006) - float(
                MC1003) - float(MC1004)) / (float(MC1001) + float(MC1002))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_agad_execution_success_ratio]
    elif KPI_ID == 'NR_5049b':
        MC1001 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[0]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[8])
        MC1002 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[1]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[9])
        MC1003 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[2]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[10])
        MC1004 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[3]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[11])
        MC1005 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[4]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[12])
        MC1006 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[5]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[13])
        MC1007 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[6]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[14])
        MC1008 = dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[7]) + dict_sum.get(Intra_F_intra_gnb_F_F_HO_NSA[15])
        print(int(MC1001), int(MC1002), int(MC1003), int(MC1004), int(MC1005), int(MC1006), int(MC1007), int(MC1008))
        total_ho_attempts = [int(MC1001) + int(MC1002) + int(MC1007) + int(MC1008) + int(MC1005)]
        total_ho_success = [int(MC1001) + int(MC1002) - int(MC1006) - int(MC1003) - int(MC1004)]
        try:
            nsa_agad_change_succ = round(((float(MC1001) + float(MC1002) - float(MC1006) - float(MC1003) - float(
                MC1004)) / (float(MC1001) + float(MC1002) + float(MC1007) + float(MC1008) + float(MC1005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_agad_change_succ]
    elif KPI_ID == 'NR_5034a_FT':
        tmp_NR_5034a_0 = dict_sum.get(Inter_F_inter_gnb_F_T_HO_NSA[0])
        tmp_NR_5034a_1 = dict_sum.get(Inter_F_inter_gnb_F_T_HO_NSA[1])
        tmp_NR_5034a_2 = dict_sum.get(Inter_F_inter_gnb_F_T_HO_NSA[2])
        tmp_NR_5034a_3 = dict_sum.get(Inter_F_inter_gnb_F_T_HO_NSA[3])
        total_ho_attempts = [int(tmp_NR_5034a_0), int(tmp_NR_5034a_2)]
        total_ho_success = [int(tmp_NR_5034a_1), int(tmp_NR_5034a_3)]
        try:
            tmp1 = float(tmp_NR_5034a_1) / float(tmp_NR_5034a_0)
            tmp2 = float(tmp_NR_5034a_3) / float(tmp_NR_5034a_2)
            print(int(tmp1), int(tmp2))
            nsa_Intra_freq_inter_gNB1_ho_suc = round(tmp1, 4)
            nsa_Intra_freq_inter_gNB2_ho_suc = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_Intra_freq_inter_gNB1_ho_suc, nsa_Intra_freq_inter_gNB2_ho_suc]
    elif KPI_ID == 'NR_5185b_FF':
        MC0001 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[0]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[8])
        MC0002 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[1]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[9])
        MC0003 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[2]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[10])
        MC0004 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[3]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[11])
        MC0005 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[4]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[12])
        MC0006 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[5]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[13])
        MC0007 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[6]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[14])
        MC0008 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[7]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[15])
        print(int(MC0001), int(MC0002), int(MC0003), int(MC0004), int(MC0005), int(MC0006), int(MC0007), int(MC0008))
        total_ho_attempts = [int(MC0001) + int(MC0002) + int(MC0007) + int(MC0008) + int(MC0005)]
        total_ho_success = [int(MC0001) + int(MC0002) - int(MC0006) - int(MC0003) - int(MC0004)]
        try:
            nsa_rgad_preparation_success_ratio = round(((float(MC0001) + float(MC0002)) / (
                    float(MC0001) + float(MC0002) + float(MC0007) + float(MC0008) + float(MC0005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_rgad_preparation_success_ratio]
    elif KPI_ID == 'NR_5186b_FF':
        MC0001 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[0]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[8])
        MC0002 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[1]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[9])
        MC0003 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[2]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[10])
        MC0004 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[3]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[11])
        MC0005 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[4]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[12])
        MC0006 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[5]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[13])
        MC0007 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[6]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[14])
        MC0008 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[7]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[15])
        print(int(MC0001), int(MC0002), int(MC0003), int(MC0004), int(MC0005), int(MC0006), int(MC0007), int(MC0008))
        total_ho_attempts = [int(MC0001) + int(MC0002) + int(MC0007) + int(MC0008) + int(MC0005)]
        total_ho_success = [int(MC0001) + int(MC0002) - int(MC0006) - int(MC0003) - int(MC0004)]
        try:
            nsa_rgad_execution_success_ratio = round(((float(MC0001) + float(MC0002) - float(MC0006) - float(
                MC0003) - float(MC0004)) / (float(MC0001) + float(MC0002))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_rgad_execution_success_ratio]
    elif KPI_ID == 'NR_5187b_FF':
        MC0001 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[0]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[8])
        MC0002 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[1]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[9])
        MC0003 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[2]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[10])
        MC0004 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[3]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[11])
        MC0005 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[4]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[12])
        MC0006 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[5]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[13])
        MC0007 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[6]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[14])
        MC0008 = dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[7]) + dict_sum.get(Inter_F_intra_gnb_F_F_HO_NSA[15])
        print(int(MC0001), int(MC0002), int(MC0003), int(MC0004), int(MC0005), int(MC0006), int(MC0007), int(MC0008))
        total_ho_attempts = [int(MC0001) + int(MC0002) + int(MC0007) + int(MC0008) + int(MC0005)]
        total_ho_success = [int(MC0001) + int(MC0002) - int(MC0006) - int(MC0003) - int(MC0004)]
        try:
            nsa_agad_total_succ = round(((float(MC0001) + float(MC0002) - float(MC0006) - float(MC0003) - float(
                MC0004)) / (float(MC0001) + float(MC0002) + float(MC0007) + float(MC0008) + float(MC0005))), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_agad_total_succ]
    elif KPI_ID == 'NR_5071a':
        tmp_NR_5071a_0 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[0])
        tmp_NR_5071a_1 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[1])
        tmp_NR_5071a_2 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[2])
        tmp_NR_5071a_3 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[3])
        tmp_NR_5071a_4 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[4])
        tmp_NR_5071a_5 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[5])
        total_ho_attempts = [int(tmp_NR_5071a_0), int(tmp_NR_5071a_3)]
        total_ho_success = [int(tmp_NR_5071a_2), int(tmp_NR_5071a_5)]
        try:
            tmp1 = float(tmp_NR_5071a_1) / float(tmp_NR_5071a_0)
            tmp2 = float(tmp_NR_5071a_4) / float(tmp_NR_5071a_3)
            print(int(tmp1), int(tmp2))
            nsa_Intra_freq_inter_gNB1_ho_preparationsuc_ratio = round(tmp1, 4)
            nsa_Intra_freq_inter_gNB2_ho_preparationsuc_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_Intra_freq_inter_gNB1_ho_preparationsuc_ratio,
                                     nsa_Intra_freq_inter_gNB2_ho_preparationsuc_ratio]
    elif KPI_ID == 'NR_5074a':
        tmp_NR_5074a_0 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[0])
        tmp_NR_5074a_1 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[1])
        tmp_NR_5074a_2 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[2])
        tmp_NR_5074a_3 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[3])
        tmp_NR_5074a_4 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[4])
        tmp_NR_5074a_5 = dict_sum.get(Intra_F_inter_gnb_T_T_HO_NSA[5])
        total_ho_attempts = [int(tmp_NR_5074a_0), int(tmp_NR_5074a_3)]
        total_ho_success = [int(tmp_NR_5074a_2), int(tmp_NR_5074a_5)]
        try:
            tmp1 = float(tmp_NR_5074a_2) / float(tmp_NR_5074a_0)
            tmp2 = float(tmp_NR_5074a_5) / float(tmp_NR_5074a_3)
            print(int(tmp1), int(tmp2))
            nsa_Intra_freq_inter_gNB1_ho_totalsuc_ratio = round(tmp1, 4)
            nsa_Intra_freq_inter_gNB2_ho_totalsuc_ratio = round(tmp2, 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [nsa_Intra_freq_inter_gNB1_ho_totalsuc_ratio,
                                     nsa_Intra_freq_inter_gNB2_ho_totalsuc_ratio]
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
            Inter_MeNB_HO_succ = round((float(MC00504)) / (float(MC00503)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [Inter_MeNB_HO_succ]
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
            Intra_MeNB_HO_succ = round((float(MC00004)) / (float(MC00003)), 4)
        except ZeroDivisionError:
            print('please check the counter whether is 0')
        finally:
            list_percentage_value = [Intra_MeNB_HO_succ]

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
    time_per_secnario = get_time_for_per_scenario(time_list, childern_list_len)
    # url_upload_execute_data = 'http://compass.eecloud.dynamic.nsn-net.net/kpi/api/case_execute_data/'
    url_upload_execute_data = 'http://compass-5g.eecloud.dynamic.nsn-net.net:8000/kpi/api/case_execute_data/'
    test_line = '7_5_UTE5G402T' + str(tl_id)[0:3]
    if KPI_ID == 'NR_5175b':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5175b 5G SA intra-gNB intra-DU handover preparation success ratio',
             'case_name': '[1]CB007835_5G_A_001_SA_intragnb_intrafre_FDD_HO_FDD_704_stability',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5176b':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5176b 5G SA intra-gNB intra-DU handover execution success ratio',
             'case_name': '[1]CB007835_5G_A_001_SA_intragnb_intrafre_FDD_HO_FDD_704_stability',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5177b':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5177b 5G SA intra-gNB intra-DU handover total success ratio',
             'case_name': '[1]CB007835_5G_A_001_SA_intragnb_intrafre_FDD_HO_FDD_704_stability',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5206a_FT':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5206a 5G SA inter-frequency inter-gNB handover execution success ratio for SA per PLMN',
             'case_name': '[1]CB007835_5G_A_002_SA_intergnb_interfre_FDD_HO_TDD_706_stability',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_2',
             'kpi': 'NR_5206a 5G SA inter-frequency inter-gNB handover execution success ratio for SA per PLMN',
             'case_name': '[1]CB007835_5G_A_002_SA_intergnb_interfre_FDD_HO_TDD_706_stability',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5202a_FT':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5202a 5G SA inter-frequency intra-DU handover execution success ratio for per PLMN',
             'case_name': '[1]CB007835_5G_A_003_SA_intragnb_interfre_FDD_HO_TDD_706_stability',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5204a':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5204a 5G SA Intra-frequency inter-gNB handover execution success ratio for SA per PLMN',
             'case_name': '[1]CB007835_5G_A_004_SA_intergnb_intrafre_TDD_HO_TDD_704_stability',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_2',
             'kpi': 'NR_5204a 5G SA Intra-frequency inter-gNB handover execution success ratio for SA per PLMN',
             'case_name': '[1]CB007835_5G_A_004_SA_intergnb_intrafre_TDD_HO_TDD_704_stability',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5412a':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5412a 5G SA NG based handover execution success ratio on the target cell',
             'case_name': '[1]CB007835_5G_A_005_SA_intergnb_interfre_TDD_HO_TDD_706_stability',
             'start': time_per_secnario[4][0],
             'end': time_per_secnario[4][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5413a':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5413a 5G SA NG based handover total success ratio on the target cell',
             'case_name': '[1]CB007835_5G_A_005_SA_intergnb_interfre_TDD_HO_TDD_706_stability',
             'start': time_per_secnario[4][0],
             'end': time_per_secnario[4][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5047b':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5047b 5G NSA Intra frequency intra DU PSCell change preparation success ratio',
             'case_name': '[1]CB007835_5G_A_007_NSA_intragnb_intrafre_FDD_HO_FDD_1094_stability',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5048b':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5048b 5G NSA Intra frequency intra DU PSCell change execution success ratio',
             'case_name': '[1]CB007835_5G_A_007_NSA_intragnb_intrafre_FDD_HO_FDD_1094_stability',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5049b':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5049b 5G NSA Intra frequency intra DU PSCell change total success ratio',
             'case_name': '[1]CB007835_5G_A_007_NSA_intragnb_intrafre_FDD_HO_FDD_1094_stability',
             'start': time_per_secnario[0][0],
             'end': time_per_secnario[0][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5034a_FT':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5034a 5G NSA Inter gNB handover success ratio for NSA',
             'case_name': '[1]CB007835_5G_A_008_NSA_intergnb_interfre_FDD_HO_TDD_1095_stability',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_2',
             'kpi': 'NR_5034a 5G NSA Inter gNB handover success ratio for NSA',
             'case_name': '[1]CB007835_5G_A_008_NSA_intergnb_interfre_FDD_HO_TDD_1095_stability',
             'start': time_per_secnario[1][0],
             'end': time_per_secnario[1][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5185b_FF':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5185b 5G Inter-frequency intra-DU handover preparation success ratio for NSA',
             'case_name': '[1]CB007835_5G_A_009_NSA_intragnb_interfre_FDD_HO_TDD_1095_stability',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5186b_FF':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5186b 5G Inter-frequency intra-DU handover execution success ratio for NSA',
             'case_name': '[1]CB007835_5G_A_009_NSA_intragnb_interfre_FDD_HO_TDD_1095_stability',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5187b_FF':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5187b 5G NSA Inter-frequency intra-DU handover total success ratio for NSA',
             'case_name': '[1]CB007835_5G_A_009_NSA_intragnb_interfre_FDD_HO_TDD_1095_stability',
             'start': time_per_secnario[2][0],
             'end': time_per_secnario[2][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_5071a':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5071a 5G NSA Inter gNB PSCell change preparation success ratio on target gNB',
             'case_name': '[1]CB007835_5G_A_010_NSA_intergnb_intrafre_TDD_HO_TDD_573_stability',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_2',
             'kpi': 'NR_5071a 5G NSA Inter gNB PSCell change preparation success ratio on target gNB',
             'case_name': '[1]CB007835_5G_A_010_NSA_intergnb_intrafre_TDD_HO_TDD_573_stability',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_5074a':
        dict_data = [
            {'test_line': test_line + '_1',
             'kpi': 'NR_5074a 5G NSA Inter gNB PSCell change total success ratio on target gNB',
             'case_name': '[1]CB007835_5G_A_010_NSA_intergnb_intrafre_TDD_HO_TDD_573_stability',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]},

            {'test_line': test_line + '_2',
             'kpi': 'NR_5074a 5G NSA Inter gNB PSCell change total success ratio on target gNB',
             'case_name': '[1]CB007835_5G_A_010_NSA_intergnb_intrafre_TDD_HO_TDD_573_stability',
             'start': time_per_secnario[3][0],
             'end': time_per_secnario[3][1],
             'ho_attempt': list_percentage_value[1][1],
             'ho_success': list_percentage_value[2][1],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][1]}
        ]
    elif KPI_ID == 'NR_574':
        dict_data = [
            {'test_line': test_line + '_2',
             'kpi': 'Number of successful RRC Reconfiguration due to Inter-MeNB HO rate',
             'case_name': '[1]CB007835_5G_A_013_NSA_interenb_interfre_FDD_HO_FDD_574_stability',
             'start': time_per_secnario[6][0],
             'end': time_per_secnario[6][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]
    elif KPI_ID == 'NR_575':
        dict_data = [
            {'test_line': test_line + '_2',
             'kpi': 'Number of successful RRC Reconfiguration due to Intra-MeNB HO rate',
             'case_name': '[1]CB007835_5G_A_014_NSA_intraenb_interfre_FDD_HO_FDD_575_stability',
             'start': time_per_secnario[7][0],
             'end': time_per_secnario[7][1],
             'ho_attempt': list_percentage_value[1][0],
             'ho_success': list_percentage_value[2][0],
             'ue_number': ue_number,
             'success_rate': list_percentage_value[0][0]}
        ]

    headers = {'cookie': 'sessionid={}'.format('n67y70t5ju6h6r2lqkr1flsi9nbay9hf')}
    response = requests.post(url=url_upload_execute_data, json=dict_data, headers=headers)
    print(response.status_code)
