# *-coding=utf-8-*

# Name: liu jia
# Time: 2023/6/15 23:45
import os
import re
import time

import taf.transport.ssh as ssh
import csv
import datetime
from openpyxl import Workbook
from datetime import datetime
from pytz import timezone


def get_pm_file_from_classical_by_time(ip, username, password, connection, local_path, folder_name,
                                       test_start: int, test_end: int, pm_xml_path="/ffs/run/uri/PERFMON_FILES/"):
    try:
        # connect bts
        connection_ssh = ssh.ssh()
        connection_ssh.connect_to(hostname=ip, username=username, password=password, alias=connection)
    except Exception as e:
        print(f"connection failed: {e}")
    else:
        # get all files ending in xml.gz
        command = "cd " + pm_xml_path + ";" + "ls -l | grep .xml.gz | awk '{print $9}'"
        xml_pm_files = connection_ssh.execute(command=command, connection=connection)
        xml_file_names = xml_pm_files.split('\r\n')[:-1]
        # Obtain the latest pm file from the path and download it to ute
        # download all xml.gz files for backup
        # get all files ending in xml.gz
        xml_fle_download = []
        for xml_file in xml_file_names:
            # PM.BTS-11694.20231030.022000.ANY.xml.gz
            xml_file_time = int(str(xml_file.split(".")[2]) + str(xml_file.split(".")[3]))
            print(f"time1:{test_start};time2:{xml_file_time};time3{test_end}")
            if test_start + 500 <= xml_file_time <= test_end - 500:
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
        connection_ssh.disconnect(connection=connection)
    return xml_folder_file_list


def getsum_counter_by_pm_file(kpi_file, xml_folder_file_list, para_index):
    counter_sum_list = []
    with open(kpi_file, 'r') as kpi:
        # read kpi
        kpi_content = kpi.read()
    counter_regular = re.compile(r'M55\w{9}')
    # Obtain a list of counter IDs that meet the regular conditions from the KPI txt file
    counter_id_list = counter_regular.findall(kpi_content)
    # Loop to replace the counter id in the kpi file with the corresponding specific value,
    # and then calculate the value of kpi
    for one_counter in counter_id_list:
        value_regular = re.compile(r'<{}>(\d*)</{}>'.format(one_counter, one_counter))
        print(one_counter)
        one_counter_list = []
        for one_xml in xml_folder_file_list:
            with open(one_xml, 'r') as pm_xml:
                # read PM.BTS-xx.xx.xx.ANY.xml
                xml_content = pm_xml.read()
            one_counter_value = value_regular.findall(xml_content)
            # para_index means cellid, when counter is LNBTS then para_index=0
            if len(one_counter_value) == 1:
                one_counter_list.append(int(one_counter_value[0]))
            else:
                one_counter_list.append(int(one_counter_value[para_index-1]))
        one_counter_sum = sum(one_counter_list)
        counter_sum_list.append(one_counter_sum)
    all_counter_dict = dict(zip(counter_id_list, counter_sum_list))

    return all_counter_dict


def calculate_kpi_by_counter(counter_dic_by_name, kpi_file):
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
            kpi_value = kpi_value.replace(id, str(counter_dic_by_name[id]))
        # print(kpi_value)
        try:
            calculate_kpi_value = eval(kpi_value)
        except ZeroDivisionError as e:
            calculate_kpi_value = e
        kpi_detail_value_list.append(calculate_kpi_value)
    # Generate a dictionary of all kpi names and corresponding specific values
    print(kpi_key_list)
    dict_kpi_key_value = dict(zip(kpi_key_list, kpi_detail_value_list))
    return dict_kpi_key_value


def get_ip_add_num(response):
    ip_num = re.findall(r'IPv4.*?\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}\r\n', response)
    print(ip_num)
    print(len(ip_num))
    ip_list_new = set(ip_num)
    print(len(ip_list_new))
    return len(ip_list_new)
