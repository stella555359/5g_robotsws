# *-coding=utf-8-*

# Name: liu jia
# Time: 2023/6/15 23:45
import os
import re
import time

import taf.transport.ssh as ssh
import csv
import datetime


def get_pm_xml_file_from_cloud(ip, username, password, connection, local_path, namespace, folder_name,
                               test_start: int, test_end: int, pm_xml_path="/var/home/cranuser239/results/"):
    try:
        # connect bts
        connection_ssh = ssh.ssh()
        connection_ssh.connect_to(hostname=ip, username=username, password=password, alias=connection)
    except Exception as e:
        print(f"connection failed: {e}")
    else:
        # copy pm files from po to vcu/vdu
        command_pre = f"kubectl cp -n {namespace} " \
                      f"po-oampm-0:/mnt/services/SS_OAM/PMSTAT/pm_result_files" \
                      f" ./results -c ctr-oampm"
        connection_ssh.execute(command=command_pre, connection=connection)
        # get all files ending in xml.gz
        command = "cd results/" + ";" + "ls -l | grep .xml.gz | awk '{print $9}'"
        xml_pm_files = connection_ssh.execute(command=command, connection=connection)
        xml_file_names = xml_pm_files.split('\r\n')[:-1]
        xml_fle_download = []
        for xml_file in xml_file_names:
            # A20230823.0820+0800-20230823.0825+0800_MRBTS-1234:3.xml.gz
            # A20240123.1510+0800-20240123.1515+0800_MRBTS-239_55313.xml.gz
            # A20240125.1255+0800-20240125.1300+0800_MRBTS-2392_55143.xml.gz
            xml_file_time = int(xml_file.split(".")[0][1:] + xml_file.split(".")[1][:4])
            print(f"time1:{test_start};time2:{xml_file_time};time3{test_end}")
            if test_start <= xml_file_time <= test_end:
                xml_fle_download.append(xml_file)
        # Obtain the latest pm file from the path and download it to ute
        # download all xml.gz files for backup
        xml_pm_folder_name = str(folder_name)
        xml_folder_file_list = []
        os.system(command=f"cd {local_path};mkdir {xml_pm_folder_name}")
        for xml_file in xml_fle_download:
            connection_ssh.download_file(remote_path=f"{pm_xml_path}{xml_file}",
                                         local_path=f"{local_path}/{xml_pm_folder_name}/{xml_file}",
                                         connection=connection)
            os.system(command=f"cd {local_path}/{xml_pm_folder_name};gzip -d {xml_file}")
            xml_folder_file_list.append(f"{local_path}/{xml_pm_folder_name}/{xml_file[:-3]}")
    finally:
        command_end = "cd results/" + ";" + "ls | xargs -n 10 rm -rf ls"
        connection_ssh.send_command(command=command_end, connection=connection)
        connection_ssh.disconnect(connection=connection)
    return xml_folder_file_list


def calculate_cloud_counter_from_pm_file(kpi_file, xml_folder_file_list):
    all_counter_list = []
    with open(kpi_file, "r") as file:
        counter_list_1 = file.read().split(',')
        counter_list = list(map(str.strip, counter_list_1))
    # for n in range(len(counter_list)):
    #     counter_list[n] = counter_list[n].strip()
    for counter in counter_list:
        counter = counter.strip()
        counter_list_x = []
        for xml_file in xml_folder_file_list:
            with open(xml_file, "r") as pm_xml:
                pm_content = pm_xml.read()
                value_regular = re.compile(r'<{}>(\d*)</{}>'.format(counter, counter))
                counter_value_list = value_regular.findall(pm_content)
            # if counter_value_list is not null then put it into counter_list_x
            if bool(counter_value_list):
                # change value type from str to int
                counter_value_list = [eval(i) for i in counter_value_list]
                counter_list_x.append(counter_value_list)
                print(f"counter_value_list:{counter_list_x}")
        all_counter_list.append(counter_list_x)
    print(f"all_counter_list:{all_counter_list}")
    counter_sum_list = []
    # Sum according to different cells of the counter
    # for i in range(len(all_counter_list[0][0])):
    #     counter_sum_list.append([sum(n) for n in zip(*all_counter_list[i])])
    # sum according to bts
    for i in range(len(all_counter_list)):
        counter_sum_list.append(sum(sum(all_counter_list[i], [])))
    # create a dic by counter name
    counter_dic_by_name = dict(zip(counter_list, counter_sum_list))
    return counter_dic_by_name


def calculate_cloud_cell_kpis_by_counter(counter_dic_by_name, kpi_file, para_index):
    with open(kpi_file, 'r') as kpi:
        # read kpi per line
        kpi_content_list = kpi.readlines()
    # Separate KPI names and KPI values with colons
    kpi_key_list = []
    kpi_values_list = []
    for kpi_content in kpi_content_list:
        kpi_key_list.append(kpi_content.split(":")[0].strip())
        kpi_values_list.append(kpi_content.split(":")[1].strip())
    kpi_detail_value_list = []  # All kpis correspond to specific values
    # Loop to calculate the KPIs for each row to obtain a list of elements with each KPI value
    for kpi_value in kpi_values_list:
        counter_regular = re.compile(r'M55\w{9}')
        # Obtain a list of counter IDs that meet the regular conditions from the KPI txt file
        counter_id_list = counter_regular.findall(kpi_value)
        # Loop to replace the counter id in the kpi file with the corresponding specific value,
        # and then calculate the value of kpi
        for id in counter_id_list:
            xml_content = counter_dic_by_name[id][para_index-1]
            kpi_value = kpi_value.replace(id, xml_content)
        # print(kpi_value)
        try:
            calculate_kpi_value = eval(kpi_value)
        except ZeroDivisionError as e:
            calculate_kpi_value = e
        kpi_detail_value_list.append(calculate_kpi_value)
    # Generate a dictionary of all kpi names and corresponding specific values
    dict_kpi_key_value = dict(zip(kpi_key_list.strip(), kpi_detail_value_list))
    return dict_kpi_key_value


def calculate_cloud_bts_counter_from_pm_file(kpi_file, xml_folder_file_list):
    counter_list_x = []
    all_counter_list = []
    with open(kpi_file, "r") as file:
        counter_list = file.read().split(',')
    for counter in counter_list:
        counter = counter.strip()
        for xml_file in xml_folder_file_list:
            with open(xml_file, "r") as pm_xml:
                pm_content = pm_xml.read()
                value_regular = re.compile(r'<{}>(\d*)</{}>'.format(counter, counter))
                counter_value_list = value_regular.findall(pm_content)
            # if counter_value_list is not null then put it into counter_list_x
            if bool(counter_value_list):
                # change value type from str to int
                counter_value_list = [eval(i) for i in counter_value_list]
                # print(f"counter_value_list:{counter_value_list}")
                counter_list_x.append(counter_value_list)
        all_counter_list.append(counter_list_x)
    # print(f"all_counter_list:{all_counter_list}")
    counter_sum_list = []
    # Sum according to different cells of the counter
    for i in range(len(all_counter_list)):
        counter_sum_list.append(sum(sum(all_counter_list[i], [])))
    # create a dic by counter name
    counter_dic_by_name = dict(zip(counter_list.strip(), counter_sum_list))
    return counter_dic_by_name


def calculate_cloud_bts_kpis_by_counter(counter_dic_by_name, kpi_file):
    with open(kpi_file, 'r') as kpi:
        # read kpi per line
        kpi_content_list = kpi.readlines()
    # Separate KPI names and KPI values with colons
    kpi_key_list = []
    kpi_values_list = []
    for kpi_content in kpi_content_list:
        print(kpi_content.split(":"))
        kpi_key_list.append(kpi_content.split(":")[0].strip())
        kpi_values_list.append(kpi_content.split(":")[1].strip())
    kpi_detail_value_list = []  # All kpis correspond to specific values
    # Loop to calculate the KPIs for each row to obtain a list of elements with each KPI value
    for kpi_value in kpi_values_list:
        counter_regular = re.compile(r'M55\w{9}')
        # Obtain a list of counter IDs that meet the regular conditions from the KPI txt file
        counter_id_list = counter_regular.findall(kpi_value)
        # print(counter_id_list)
        # Loop to replace the counter id in the kpi file with the corresponding specific value,
        # and then calculate the value of kpi
        for id in counter_id_list:
            xml_content = counter_dic_by_name[id]
            kpi_value = kpi_value.replace(id, str(xml_content))
            print(kpi_value)
        # print(kpi_value)
        try:
            calculate_kpi_value = eval(kpi_value)
        except ZeroDivisionError as e:
            calculate_kpi_value = e
        kpi_detail_value_list.append(calculate_kpi_value)
    # Generate a dictionary of all kpi names and corresponding specific values
    dict_kpi_key_value = dict(zip(kpi_key_list, kpi_detail_value_list))
    return dict_kpi_key_value


def write_value_into_csv(csv_file, dict_kpi_key_value, case_kpi_path):
    order_list = []
    sum_list = []
    # read list from csv file and change the type to list
    with open(csv_file, 'r') as kpi_sequence:
        kpi_seq_list = csv.reader(kpi_sequence)
        for i in kpi_seq_list:
            order_list.append(i[0])
    # delete the first item from order_list
    del order_list[0]
    print(order_list)
    # find the dict_kpi_key_value key from order_list and get the value into write_dic
    for item in order_list:
        write_dic = {'kpiname': item, 'value': 'value1'}
        if item in dict_kpi_key_value.keys():
            write_dic['value'] = dict_kpi_key_value[item]
        else:
            write_dic['value'] = 'None'
        sum_list.append(write_dic)
    head_name = ['kpiname', 'value']
    with open(case_kpi_path, 'a+') as kpi_write:
        write_value = csv.DictWriter(kpi_write, head_name)
        write_value.writeheader()
        write_value.writerows(sum_list)
    return sum_list


def combine_vcu_vdu_dic(vcu_dic, vdu_dic):
    final_dic = dict(vcu_dic, **vdu_dic)
    return final_dic
