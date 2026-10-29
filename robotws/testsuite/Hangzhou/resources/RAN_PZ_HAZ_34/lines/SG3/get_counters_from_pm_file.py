# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/6/15 23:45
import json
import os
import re
import time

from typing import List, Dict

import taf.transport.ssh as ssh
import yaml


def get_newest_pm_xml_file(ip, username, password, connection, local_path,
                           pm_xml_path="/ffs/run/uri/PERFMON_FILES/"):
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
        xml_pm_folder_name = str(int(time.time()))
        os.system(command=f"cd {local_path};mkdir {xml_pm_folder_name}")
        for xml_file in xml_file_names:
            connection_ssh.download_file(remote_path=f"{pm_xml_path}{xml_file}",
                                         local_path=f"{local_path}/{xml_pm_folder_name}/{xml_file}",
                                         connection=connection)
        newest_xml_gz_file = sorted(xml_file_names, reverse=True)[0]
        # xml file name, remove .gz suffix name
        newest_xml_file = newest_xml_gz_file[:-3]
        # Unzip pm file
        os.system(command=f"cd {local_path}/{xml_pm_folder_name};gzip -d {newest_xml_gz_file}")
    finally:
        connection_ssh.disconnect(connection=connection)
    return f"{local_path}/{xml_pm_folder_name}/{newest_xml_file}"


def get_period_of_time_pm_xml_files(ip, username, password, connection, local_path, num,
                                    pm_xml_path="/ffs/run/uri/PERFMON_FILES/"):
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
        xml_pm_folder_name = str(int(time.time()))
        os.system(command=f"cd {local_path};mkdir {xml_pm_folder_name}")
        for xml_file in xml_file_names:
            connection_ssh.download_file(remote_path=f"{pm_xml_path}{xml_file}",
                                         local_path=f"{local_path}/{xml_pm_folder_name}/{xml_file}",
                                         connection=connection)
        period_time_xml_gz_file_list = sorted(xml_file_names, reverse=True)[:int(num) + 1]
        xml_folder_file_list = []
        # xml file name, remove .gz suffix name
        for xml_gz_file in period_time_xml_gz_file_list:
            # Unzip pm file
            os.system(command=f"cd {local_path}/{xml_pm_folder_name};gzip -d {xml_gz_file}")
            xml_folder_file_list.append(f"{local_path}/{xml_pm_folder_name}/{xml_gz_file[:-3]}")
    finally:
        connection_ssh.disconnect(connection=connection)
    return xml_folder_file_list


def calculate_kpi_from_pm_file(pm_xml_file, kpi_file, para_index):
    with open(pm_xml_file, 'r') as pm_xml:
        # read PM.BTS-xx.xx.xx.ANY.xml
        xml_content = pm_xml.read()
    with open(kpi_file, 'r') as kpi:
        # read kpi
        kpi_content = kpi.read()
    counter_regular = re.compile(r'M55\w{9}')
    # Obtain a list of counter IDs that meet the regular conditions from the KPI txt file
    counter_id_list = counter_regular.findall(kpi_content)
    # Loop to replace the counter id in the kpi file with the corresponding specific value,
    # and then calculate the value of kpi
    for id in counter_id_list:
        value_regular = re.compile(r'<{}>(\d*)</{}>'.format(id, id))
        counter_value_list = value_regular.findall(xml_content)
        counter_value = counter_value_list[para_index - 1]
        kpi_content = kpi_content.replace(id, counter_value)
        print(kpi_content)
    kpi_value = eval(kpi_content)
    return kpi_value


def calculate_kpis_from_pm_file(pm_xml_file, kpi_file, para_index):
    with open(pm_xml_file, 'r') as pm_xml:
        # read PM.BTS-xx.xx.xx.ANY.xml
        xml_content = pm_xml.read()
    with open(kpi_file, 'r') as kpi:
        # read kpi per line
        kpi_content_list = kpi.readlines()
    kpi_value_list = []
    # Loop to calculate the KPIs for each row to obtain a list of elements with each KPI value
    for kpi_content in kpi_content_list:
        counter_regular = re.compile(r'M55\w{9}')
        # Obtain a list of counter IDs that meet the regular conditions from the KPI txt file
        counter_id_list = counter_regular.findall(kpi_content)
        # Loop to replace the counter id in the kpi file with the corresponding specific value,
        # and then calculate the value of kpi
        for id in counter_id_list:
            value_regular = re.compile(r'<{}>(\d*)</{}>'.format(id, id))
            counter_value_list = value_regular.findall(xml_content)
            counter_value = counter_value_list[para_index - 1]
            kpi_content = kpi_content.replace(id, counter_value)
        kpi_value = eval(kpi_content)
        kpi_value_list.append(kpi_value)
    return kpi_value_list


def calculate_dict_kpis_from_pm_file(pm_xml_file: str, kpi_file: str, para_index: int):
    with open(pm_xml_file, 'r') as pm_xml:
        # read PM.BTS-xx.xx.xx.ANY.xml
        xml_content = pm_xml.read()
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
            value_regular = re.compile(r'<{}>(\d*)</{}>'.format(id, id))
            counter_value_list = value_regular.findall(xml_content)
            counter_value = counter_value_list[para_index - 1]
            kpi_value = kpi_value.replace(id, counter_value)
        print(kpi_value)
        calculate_kpi_value = eval(kpi_value)
        kpi_detail_value_list.append(calculate_kpi_value)
    # Generate a dictionary of all kpi names and corresponding specific values
    dict_kpi_key_value = dict(zip(kpi_key_list, kpi_detail_value_list))
    return dict_kpi_key_value


def calculate_kpis_of_kpi_file_via_pm_file(pm_xml_file: str, kpi_file: str, para_index: int):
    file_type = kpi_file.split(".")[-1]
    with open(pm_xml_file, 'r') as pm_xml:
        # read PM.BTS-xx.xx.xx.ANY.xml
        xml_content = pm_xml.read()
    kpi_key_list = []
    kpi_values_list = []
    with open(kpi_file, 'r') as kpi:
        # read kpi per line
        if file_type == 'json':
            kpi_content = json.load(kpi)
            kpi_key_list = kpi_content.keys()
            kpi_values_list = kpi_content.values()
        elif file_type == 'yml':
            kpi_content = yaml.safe_load(kpi)
            kpi_key_list = kpi_content.keys()
            kpi_values_list = kpi_content.values()
        elif file_type == 'txt':
            kpi_content_list = kpi.readlines()
            # Separate KPI names and KPI values with colons
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
            value_regular = re.compile(r'<{}>(\d*)</{}>'.format(id, id))
            counter_value_list = value_regular.findall(xml_content)
            counter_value = counter_value_list[para_index - 1]
            kpi_value = kpi_value.replace(id, counter_value)
        print(kpi_value)
        calculate_kpi_value = eval(kpi_value)
        kpi_detail_value_list.append(calculate_kpi_value)
    # Generate a dictionary of all kpi names and corresponding specific values
    dict_kpi_key_value = dict(zip(kpi_key_list, kpi_detail_value_list))
    return dict_kpi_key_value


def get_mPci_value_from_adb_command_output(output):
    pattern = re.compile(pattern=r".*?mPci = (?P<mPci>.*?) mTac.*?")
    mPci_value = pattern.search(string=output).group("mPci")
    return mPci_value
