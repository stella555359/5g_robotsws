# -*- coding: utf-8 -*
"""
Author: Ding Binmei
Contacts: binmei.ding@nokia-sbell.com
Description: Please do not modify without the permission from author
             PM counter related operations on COAM.
             Including: 1. calculate time to wait for log trigger or log file generated
                        2. collect log files based on log generate time
                        3. Log download and decompress
                        4. Log analysis ...

"""
import sys
if sys.version_info.major == 3:
    import subprocess as commands
else:
    import commands
import logging
import os
import datetime
import re
import pprint
from robot.libraries.XML import XML
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from taf.config.testline.info.testline_info import TestlineInfo

tl = BuiltIn().get_variable_value("${tl}")
testline_info = TestlineInfo()
is_cloud = testline_info.has_cloudBts(tl)


class PMCounter(object):
    PM_COUNTER_FOLDER_BASE_ASIK = "/tmp"

    def __init__(self):
        self.ssh = ssh()
        self.xml = XML()

    def get_timestamp_from_gnb(self, asik_alias="ASIK Master"):
        """
        Author: Ding Binmei
        Description: Get timestamp from GNB
        :param asik_alias:
        :return: timestamp with datetime format
        """
        cmd_get_timestamp = 'date "+%Y-%m-%d %H:%M:%S"'
        cur_timestamp_str = self.ssh.execute(
            command=cmd_get_timestamp,
            connection=asik_alias).strip()
        logging.debug(
            "Execute command: {}, output: {}".format(
                cmd_get_timestamp,
                cur_timestamp_str))
        cur_timestamp = datetime.datetime.strptime(
            cur_timestamp_str, '%Y-%m-%d %H:%M:%S')
        return cur_timestamp

    def get_timestamp_from_gnb_cloud(
            self,
            gnb_index=0,
            vdu_index=0,
            bts_type='cu',
            conn_alias="OCP Master"):
        """
        Author: Dandan Fang
        Description: Get timestamp from GNB
        :param conn_alias:use to create connection with du or du ocp master
        :param bts_type: value should be as  cu or du
        :return: timestamp with datetime format
        """
        if bts_type == 'du':
            node_prefix = tl.gnbs[gnb_index].dus[vdu_index].cloud_deployment.cloud_hosting.master_node
            namespace = tl.gnbs[gnb_index].dus[vdu_index].cloud_deployment.cloud_hosting.namespace
        elif bts_type == 'cu':
            node_prefix = tl.gnbs[gnb_index].cloud_deployment.cloud_hosting.master_node
            namespace = tl.gnbs[gnb_index].cloud_deployment.cloud_hosting.namespace
        else:
            raise Exception(
                "bts_type is {} is error, please input cu or du".format(bts_type))

        connection = self.ssh.connect_to(
            hostname=node_prefix.ssh_connection_details.addr,
            username=node_prefix.ssh_connection_details.username,
            password=node_prefix.ssh_connection_details.password,
            port=node_prefix.ssh_connection_details.port,
            alias=conn_alias)
        pod_name = "po-oampm-0"
        container_name = "ctr-oampm"
        cmd_login = 'kubectl exec -it {pod} -c {container} -n {ns} -- '.format(
            pod=pod_name, container=container_name, ns=namespace)
        cmd_get_timestamp = cmd_login + 'date "+%Y-%m-%d %H:%M:%S"'
        for i in range(3):
            cur_timestamp_str = self.ssh.execute(
                command=cmd_get_timestamp, connection=conn_alias).strip()
            logging.debug(
                "Execute command: {}, output: {}".format(
                    cmd_get_timestamp,
                    cur_timestamp_str))
            match_result = re.search(
                r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})',
                cur_timestamp_str)
            if match_result:
                time = match_result.group()
                cur_timestamp = datetime.datetime.strptime(
                    time, '%Y-%m-%d %H:%M:%S')
                break
            if i == 2:
                raise Exception(
                    "bts_type is {}  cur_timestamp get error".format(bts_type))

        self.ssh.disconnect(connection)
        return cur_timestamp

    def get_timezone_from_gnb_cloud(
            self,
            gnb_index=0,
            vdu_index=0,
            bts_type='cu',
            conn_alias="OCP Master"):
        """
        Author: Dandan Fang
        Description: Get timestamp from Cloud GNB
        :param conn_alias:use to create connection with du or du ocp master
        :param bts_type: value should be as  cu or du
        :return: timezone string
        """
        if bts_type == 'du':
            node_prefix = tl.gnbs[gnb_index].dus[vdu_index].cloud_deployment.cloud_hosting.master_node
            namespace = tl.gnbs[gnb_index].dus[vdu_index].cloud_deployment.cloud_hosting.namespace
            conn_alias = "gnb" + str(gnb_index) + "_vdu" + \
                str(vdu_index) + "ocp_master_timezone_get"
        elif bts_type == 'cu':
            node_prefix = tl.gnbs[gnb_index].cloud_deployment.cloud_hosting.master_node
            namespace = tl.gnbs[gnb_index].cloud_deployment.cloud_hosting.namespace
            conn_alias = "gnb" + str(gnb_index) + \
                "_vcu" + "ocp_master_timezone_get"
        else:
            raise Exception(
                "bts_type is {} is error, please input cu or du".format(bts_type))

        connection = self.ssh.connect_to(
            hostname=node_prefix.ssh_connection_details.addr,
            username=node_prefix.ssh_connection_details.username,
            password=node_prefix.ssh_connection_details.password,
            port=node_prefix.ssh_connection_details.port,
            alias=conn_alias)
        pod_name = "po-oampm-0"
        container_name = "ctr-oampm"
        cmd_login = 'kubectl exec -it {pod} -c {container} -n {ns} -- '.format(
            pod=pod_name, container=container_name, ns=namespace)
        cmd_get_timezone = cmd_login + 'date "+%:z"'
        for i in range(3):
            timezone_str = self.ssh.execute(
                command=cmd_get_timezone,
                connection=conn_alias).strip()
            logging.debug(
                "Execute command: {}, output: {}".format(
                    cmd_get_timezone, timezone_str))
            match_result = re.search(r'(\+\d{2}:\d{2})', timezone_str)
            if match_result:
                time_zone = match_result.group()
                break
            if i == 2:
                raise Exception(
                    "bts_type is {}  timezone_str get error".format(bts_type))

        self.ssh.disconnect(connection)
        return time_zone

    def calculate_waiting_time_for_log_capturing_or_log_generation(
            self,
            reporting_interval,
            gnb_index=0,
            vdu_index=0,
            bts_type='cu',
            asik_alias="ASIK Master"):
        """
        Author: Ding Binmei
        Description:
        1. Get wait time for log capturing or log generation based on current datetime
           and reporting_interval (In minute unit)
        2. Get the log generator time. It can be used for log filtering
           For cloud, it means the start time.

        :param reporting_interval: Should be in minute unit
        :param asik_alias:
        :return: Example output: { wait_time=3, log_generator_timestamp=2019-08-06 07:45 }
        """
        reporting_interval = int(reporting_interval)
        if is_cloud:
            cur_timestamp = self.get_timestamp_from_gnb_cloud(
                gnb_index=gnb_index,
                vdu_index=vdu_index,
                bts_type=bts_type,
                conn_alias=asik_alias)
        else:
            cur_timestamp = self.get_timestamp_from_gnb(asik_alias=asik_alias)
        logging.info("cur_timestamp is {}".format(cur_timestamp))
        cur_min = cur_timestamp.minute
        cur_sec = cur_timestamp.second
        logging.info("cur_timestamp secons is {}".format(cur_sec))
        wait_time = (reporting_interval - (cur_min % reporting_interval))
        wait_time_sec = (reporting_interval - (cur_min %
                         reporting_interval)) * 60 - cur_sec
        timestamp_after_wait = (
            cur_timestamp +
            datetime.timedelta(
                minutes=wait_time)).strftime("%Y-%m-%d %H:%M")
        dict_time_info = {
            "wait_time": wait_time,
            "wait_time_sec": wait_time_sec,
            "log_generator_timestamp": timestamp_after_wait}
        return dict_time_info

    def get_pm_counter_files_by_create_time(
            self,
            timestamp,
            asik_alias="ASIK Master",
            pm_counter_file_folder=PM_COUNTER_FOLDER_BASE_ASIK,
            file_indicator="PM.BTS*.xml.gz"):
        """
        Author: Ding Binmei
        Description: Get all PM counter files which are generated after the input timestamp
        :param timestamp: Format can be: 2019-08-05 10:00
        :param asik_alias: Connection to ASIK
        :param pm_counter_file_folder: Log folder on ASIK where PM counter files are stored
        :param file_indicator: Expression to match the file name
        :return: List: PM counter log file path:
                 Example output: ['/tmp/PM.BTS-243.20190805.042500.ANY.xml.gz',
                                  '/tmp/PM.BTS-243.20190805.042000.ANY.xml.gz']
        """
        pm_counter_file_paths = []
        cmd_get_pm_counter_file_paths = "find {} -name '{}' -newermt '{}'".format(
            pm_counter_file_folder, file_indicator, timestamp)
        output_pm_counter_file_paths = self.ssh.execute(
            command=cmd_get_pm_counter_file_paths, connection=asik_alias).strip()
        logging.debug(
            "Execute command: {}, output: {}".format(
                cmd_get_pm_counter_file_paths,
                output_pm_counter_file_paths))
        if len(output_pm_counter_file_paths) == 0:
            logging.debug(
                "No pm counter file generated after timestamp: {} under {}".format(
                    timestamp, pm_counter_file_folder))
        else:
            pm_counter_file_paths = output_pm_counter_file_paths.splitlines()
        return pm_counter_file_paths

    def _get_pm_counter_file_name_list(self, pm_counter_file_paths):
        """
        Author: Ding Binmei
        Description: Get file names based on file path
        :param pm_counter_file_paths:
        :return:
        """
        list_file_names = []
        for file_path in pm_counter_file_paths:
            file_name = file_path.split("/")[-1]
            list_file_names.append(file_name)
        return list_file_names

    def _get_decompress_file_path(self, file_name, local_file_folder):
        """
        Author: Ding Binmei
        Description: Decompress PM counter file from gz to xml format
        :param file_name:
        :param local_file_folder:
        :return:
        """
        if file_name.endswith(".gz"):
            file_name_xml = file_name.replace(".gz", "")
            file_path_xml = os.path.join(local_file_folder, file_name_xml)
            logging.debug(
                "PM counter is in gz format, will decompress firstly")
            cmd_decompress_file = "cd {}; gzip -d {}".format(
                local_file_folder, file_name)
            output_decompress_file = commands.getoutput(
                cmd=cmd_decompress_file)
            logging.debug(
                "Decompress with command: {}, output message is: {}".format(
                    cmd_decompress_file,
                    output_decompress_file))
            cmd_is_file_decompressed = "ls {}".format(file_path_xml)
            output_decompress_file_path = commands.getoutput(
                cmd=cmd_is_file_decompressed).strip()
            if output_decompress_file_path == file_path_xml:
                return file_path_xml
            else:
                raise Exception(
                    "Fail to decompress file {} under {} on test pc".format(
                        file_name, local_file_folder))
        elif file_name.endswith(".xml"):
            logging.info("Already in xml format, no need to decompress")
            file_path_xml = os.path.join(local_file_folder, file_name)
            return file_path_xml
        else:
            raise Exception("Unsupported file format.")

    def download_pm_counter_files_to_test_pc(
            self,
            remote_file_path,
            local_file_folder,
            asik_alias="ASIK Master"):
        """
        Author: Ding Binmei
        Description: Download PM counter files from ASIK to local test pc. If downloaded files are in gz format,
        will decompress the file to xml format firstly
        :param remote_file_path: a list of file paths
                  Example input: ['/tmp/PM.BTS-243.20190805.042500.ANY.xml.gz',
                                  '/tmp/PM.BTS-243.20190805.042000.ANY.xml.gz']
        :param local_file_folder: Better to locate to case log folder: /XX/XX
        :param asik_alias:
        :return:
        """
        if len(remote_file_path) != 0:
            list_file_path_xml = []
            self.ssh.download_file(
                remote_path=remote_file_path,
                local_path=local_file_folder,
                connection=asik_alias)
            list_file_names = self._get_pm_counter_file_name_list(
                pm_counter_file_paths=remote_file_path)
            for file_name in list_file_names:
                file_path_xml = self._get_decompress_file_path(
                    file_name=file_name, local_file_folder=local_file_folder)
                list_file_path_xml.append(file_path_xml)
            return list_file_path_xml
        else:
            raise Exception(
                "No PM counter files found from remote server ASIK")

    def get_counters_from_file(self, file_path, list_measurement_ids):
        """
        Author: Ding Binmei
        Description: Get detail counters info from PM counter file.
            Support to get multiple measurement counter values
        :param file_path: PM counter file path in test pc. Should be in xml format
        :param list_measurement_ids: ['M55110C00009', 'M55110C000092]
        :return: dict: sum: refers to the total counter values for one specific measurement id
                       detail_values: A list. It refers to all the detail counter values,
                                      if one file has multiple counters for one measure id
                     Example output:
                       {'M55110C000092': {'sum': -1, 'detail_values': []},
                        'M55110C00009': {'sum': 0, 'detail_values': ['0']}}
        """
        xml_path = self.xml.parse_xml(source=file_path)
        dict_counters = {}
        for measurement_id in list_measurement_ids:
            dict_counter_info = {}
            counter_xpath = ".//" + measurement_id
            list_counter_values = self.xml.get_elements_texts(
                source=xml_path, xpath=counter_xpath)
            counter_sum = 0
            if len(list_counter_values) == 0:
                counter_sum = -1
                logging.debug(
                    "No measurement count found for {} in file {}".format(
                        measurement_id, file_path))
            else:
                for counter_value in list_counter_values:
                    counter_sum = counter_sum + int(counter_value)
            dict_counter_info['detail_values'] = list_counter_values
            dict_counter_info['sum'] = counter_sum
            dict_counters[measurement_id] = dict_counter_info
        return dict_counters

    def get_total_counter_from_multiple_files(
            self, list_file_path, list_measurement_ids):
        """
        Author: Ding Binmei
        Description: Get total counter values from multiple files
        :param list_file_path: PM counter file path in test pc. Should be in xml format
            Example input: ['/XXX/TC_Verify_PM_Counter/PM.BTS-243.20190806.073000.ANY.xml']
        :param list_measurement_ids: ['M55110C00009', 'M55110C000092]
        :return: dict: Example output:
                        {'M55110C000092': 0, 'M55110C00009': 2}
        """
        dict_counters_sum = {}
        logging.info("Initialize for counters.")
        for measurement_id in list_measurement_ids:
            dict_counters_sum[measurement_id] = 0
        for file_path in list_file_path:
            dict_counters_detail = self.get_counters_from_file(
                file_path=file_path, list_measurement_ids=list_measurement_ids)
            for measurement_id in list_measurement_ids:
                cur_counter = dict_counters_detail[measurement_id]['sum']
                logging.debug(
                    "measurement_id:{}, counter:{}, file: {}".format(
                        measurement_id, cur_counter, file_path))
                if cur_counter != -1:
                    dict_counters_sum[measurement_id] = cur_counter + \
                        dict_counters_sum[measurement_id]
                else:
                    logging.debug(
                        "Ignore the measurement calculation for {} in file {}, "
                        "as no measurement info found".format(
                            measurement_id, file_path))
                    dict_counters_sum[measurement_id] = 0 + \
                        dict_counters_sum[measurement_id]
        return dict_counters_sum

    def get_counters_from_file_based_on_level_identifier(
            self, file_path, list_ids, list_measurement_ids, level_identifier):
        """
        Author: Wang Yixiang.
        ... 2025-3-18 Ding Binmei: Refactor keyword to support not only cell but also other levels
        Description: Get detail counters info from PM counter file.
            Support to get multiple measurement counter values
        :param file_path: PM counter file path in test pc. Should be in xml format
        :param list_ids: Can be cell ids/ rmod ids: ['1', '2', '3', '4']
        :param list_measurement_ids: ['M55324C00000', 'M55324C00101']
        :param level_identifier: Identifier for the level (e.g., 'NRCELL' or 'RMOD').
        :return: dict:
                     Example output:
                       {'1': {'M55324C00000': '0', 'M55324C00101': '0'},
                        '2': {'M55324C00000': '0', 'M55324C00101': '0'},
                        '3': {'M55324C00000': '0', 'M55324C00101': '0'},
                        '4': {'M55324C00000': '0', 'M55324C00101': '0'}}
        """
        xml_path = self.xml.parse_xml(source=file_path)
        counters_dict = {}
        for id in list_ids:
            id = str(id)
            for measurement_id in list_measurement_ids:
                counters_dict = self._get_counters_from_file_parse_xml(
                    xml_path, id, measurement_id, level_identifier=level_identifier, **counters_dict)

        pprint.pprint(counters_dict)
        return counters_dict

    def get_counters_under_ssb_from_file(
            self,
            file_path,
            list_cell_ids,
            list_ssb_ids,
            list_measurement_ids):
        """
        Author: Liu Zheng
        Description: Get detail counters info from PM counter file.
        :param file_path: PM counter file path in test pc. Should be in xml format
        :param list_cell_ids: Can be cell ids/ rmod ids: ['1', '2', '3', '4']
        :param list_ssb_ids: Can be SSBPM ids: ['0','1', '2', '3', '4', '5']
        :param list_measurement_ids: ['M55202C00006', 'M55202C00007', 'M55202C00008']
        :return: dict:
                     Example output:
                       {'0': {'0',{'M55202C00006': '-117', 'M55202C00007': '2458711533'},
                              '1',{'M55202C00006': '0', 'M55202C00007': '0'}},
                        '1': {'0',{'M55202C00006': '0', 'M55202C00007': '0'},
                              '1',{'M55202C00006': '0', 'M55202C00007': '0'}}}
        """
        xml_path = self.xml.parse_xml(source=file_path)
        counters_dict = {}
        for cell_id in list_cell_ids:
            cell_id = str(cell_id)
            for ssb_id in list_ssb_ids:
                ssb_id = str(ssb_id)
                for measurement_id in list_measurement_ids:
                    counters_dict = self._get_counters_from_file_parse_xml_cell_and_subcell(
                        xml_path,
                        cell_id=cell_id,
                        subcell_id=ssb_id,
                        measurement_id=measurement_id,
                        **counters_dict)
        pprint.pprint(counters_dict)
        return counters_dict

    def get_cell_counters_from_file(
            self,
            file_path,
            list_cell,
            list_measurement_ids):
        """
        Author: Wang Yixiang
        Description: Get detail counters info from PM counter file.
            Support to get multiple measurement counter values
        :param file_path: PM counter file path in test pc. Should be in xml format
        :param list_cell: ['1', '2', '3', '4']
        :param list_measurement_ids: ['M55324C00000', 'M55324C00101']
        :return: dict:
                     Example output:
                       {'1': {'M55324C00000': '0', 'M55324C00101': '0'},
                        '2': {'M55324C00000': '0', 'M55324C00101': '0'},
                        '3': {'M55324C00000': '0', 'M55324C00101': '0'},
                        '4': {'M55324C00000': '0', 'M55324C00101': '0'}}
        """
        cell_counters_dict = self.get_counters_from_file_based_on_level_identifier(
            file_path=file_path,
            list_ids=list_cell,
            list_measurement_ids=list_measurement_ids,
            level_identifier="NRCELL")
        return cell_counters_dict

    def get_cell_SSB_counters_from_file(
            self,
            file_path,
            list_cell_ids,
            list_ssb_ids,
            list_measurement_ids):
        """
        Author: Liu Zheng
        Description: Get detail counters info from PM counter file.
            Support to get multiple measurement counter values
        :param file_path: PM counter file path in test pc. Should be in xml format
        :param list_cell: ['1', '2', '3', '4']
        :param list_ssb: ['0', '1', '2']
        :param list_measurement_ids: ['M55202C00006', 'M55202C00007', 'M55202C00008']
        :return: dict:
                     Example output:
                       {'0': {'0',{'M55202C00006': '-117', 'M55202C00007': '2458711533'},
                              '1',{'M55202C00006': '0', 'M55202C00007': '0'}},
                        '1': {'0',{'M55202C00006': '0', 'M55202C00007': '0'},
                              '1',{'M55202C00006': '0', 'M55202C00007': '0'}}}
        """
        ssb_counters_dict = self.get_counters_under_ssb_from_file(
            file_path=file_path,
            list_cell_ids=list_cell_ids,
            list_ssb_ids=list_ssb_ids,
            list_measurement_ids=list_measurement_ids)
        return ssb_counters_dict

    def _get_counters_from_file_parse_xml(
            self,
            xml_path,
            id,
            measurement_id,
            level_identifier,
            **counters_dict):
        """
        Parse counter xml to get counters based on the specified level (e.g., cell or RMOD).
        :param xml_path: Path to the XML file.
        :param id: Identifier (e.g., cell_id or rmod_id).
        :param measurement_id: Measurement ID to look for.
        :param level_identifier: Identifier for the level (e.g., 'NRCELL' or 'RMOD').
        :param counters_dict: Dictionary to store the counters.
        :return: Updated counters_dict.
        """
        raw_counter_value = None
        measurement_id_dict = {}
        pmsetup_xpath = ".//PMSetup"
        pmsetup_elements = self.xml.get_elements(
            source=xml_path, xpath=pmsetup_xpath)
        for pmsetup_element in pmsetup_elements:
            for pmmo_result_element in pmsetup_element:
                level_found_flag = False
                mo_elements = self.xml.get_child_elements(
                    source=pmmo_result_element, xpath='.')
                for mo_element in mo_elements:
                    if mo_element.tag == 'MO':
                        raw_info = self.xml.get_element_text(
                            source=mo_element, xpath='.//DN')
                        if re.search(
                                '{}-{}$'.format(level_identifier, id), raw_info):
                            level_found_flag = True
                    elif 'NE-WBTS' in mo_element.tag and level_found_flag is True:
                        try:
                            raw_counter_value = self.xml.get_element_text(
                                source=mo_element, xpath='.//{}'.format(measurement_id))
                            logging.debug(
                                "measurement_id:{} found, counter:{}".format(
                                    measurement_id, raw_counter_value))
                        except Exception as e:
                            logging.debug(
                                "measurement_id:{} not found. Exception: {}".format(
                                    measurement_id, e))
                if level_found_flag is True:
                    if counters_dict.get(id) is None:
                        measurement_id_dict[measurement_id] = raw_counter_value
                    else:
                        measurement_id_dict = counters_dict[id]
                        measurement_id_dict[measurement_id] = raw_counter_value
                    counters_dict[id] = measurement_id_dict
        return counters_dict

    def _get_counters_from_file_parse_xml_cell_and_subcell(
            self, xml_path, cell_id, subcell_id, measurement_id, **counters_dict):
        """
        Parse counter xml to get counters based on the specified level (e.g., cell or RMOD).
        :param xml_path: Path to the XML file.
        :param cell_id: Identifier (e.g., cell_id).
        :param subcell_id: Identifier (e.g., subcell_id).
        :param measurement_id: Measurement ID to look for.
        :param level_identifier: Identifier for the level (e.g., 'NRCELL').
        :param level_identifier_subcell: Identifier for the level (e.g., 'SSBPM').
        :param counters_dict: Dictionary to store the counters.
        :return: Updated counters_dict.
        """
        raw_counter_value = None
        measurement_id_dict = {}
        counters_dict[cell_id] = counters_dict.get(cell_id, {})
        counters_dict[cell_id][subcell_id] = counters_dict[cell_id].get(
            subcell_id, {})
        pmsetup_xpath = ".//PMSetup"
        pmsetup_elements = self.xml.get_elements(
            source=xml_path, xpath=pmsetup_xpath)
        for pmsetup_element in pmsetup_elements:
            for pmmo_result_element in pmsetup_element:
                level_found_flag = False
                level_found_flag_cell = False
                level_found_flag_ssb = False
                mo_elements = self.xml.get_child_elements(
                    source=pmmo_result_element, xpath='.')
                for mo_element in mo_elements:
                    if mo_element.tag == 'MO':
                        raw_info = self.xml.get_element_text(
                            source=mo_element, xpath='.//DN')
                        if re.search(
                                '{}-{}$'.format('NRCELL', cell_id), raw_info):
                            level_found_flag_cell = True
                        if re.search(
                                '{}-{}$'.format('SSBPM', subcell_id), raw_info):
                            level_found_flag_ssb = True
                        if level_found_flag_cell and level_found_flag_ssb:
                            level_found_flag = True
                    elif 'NE-WBTS' in mo_element.tag and level_found_flag is True:
                        try:
                            raw_counter_value = self.xml.get_element_text(
                                source=mo_element, xpath='.//{}'.format(measurement_id))
                            logging.debug(
                                "measurement_id:{} found, counter:{}".format(
                                    measurement_id, raw_counter_value))
                        except Exception as e:
                            logging.debug(
                                "measurement_id:{} not found. Exception: {}".format(
                                    measurement_id, e))
                if level_found_flag is True:
                    if counters_dict.get(cell_id) is None:
                        measurement_id_dict[measurement_id] = raw_counter_value
                    else:
                        measurement_id_dict = counters_dict[cell_id][subcell_id]

                        measurement_id_dict[measurement_id] = raw_counter_value
                    counters_dict[cell_id][subcell_id] = measurement_id_dict
        return counters_dict

    def get_total_cell_counter_from_multiple_files(
            self, list_file_path, list_cell, list_measurement_ids):
        """
        Author: Dandan Fang
        Description: Get total counter values from multiple files for cell
        :param list_file_path: list_file_path: PM counter file path in test pc. Should be in xml format
            Example input: ['/XXX/TC_Verify_PM_Counter/PM.BTS-243.20190806.073000.ANY.xml']
        :param list_cell: ['1', '2', '3', '4']
        :param list_measurement_ids: ['M55316C09000', 'M55316C09001]
        :return: dict: Example output:
                        '1': {'M55324C00000': '0', 'M55324C00101': '0'}
                        '2': {'M55324C00000': '1', 'M55324C00101': '1'}
        """
        dict_counters_sum = {}
        for cell_id in list_cell:
            cell_id = str(cell_id)
            logging.info("Initialize meas counters for each cell.")
            dict_counters_meas_info = {}
            for measurement_id in list_measurement_ids:
                dict_counters_meas_info[measurement_id] = 0

            raw_dict_counters = None
            for file_path in list_file_path:
                # result feedback: # {'1': {'M55324C00000': '0', 'M55324C00101': '0'},
                #                    '2': {'M55324C00000': '0', 'M55324C00101': '0'}
                raw_dict_counters = self.get_cell_counters_from_file(
                    file_path=file_path,
                    list_cell=list_cell,
                    list_measurement_ids=list_measurement_ids)
                for measurement_id in list_measurement_ids:
                    if raw_dict_counters[cell_id][measurement_id] is None:
                        cur_cell_meas_id_counter = -1
                    else:
                        cur_cell_meas_id_counter = int(
                            raw_dict_counters[cell_id][measurement_id])

                    logging.debug("measurement_id:{}, cell_id:{}, counter:{}, file: {}". format(
                        measurement_id, cell_id, cur_cell_meas_id_counter, file_path))
                    if cur_cell_meas_id_counter != -1:
                        dict_counters_meas_info[measurement_id] = cur_cell_meas_id_counter\
                            + dict_counters_meas_info[measurement_id]
                    else:
                        logging.debug(
                            "Ignore the measurement calculation for {} in file {}, "
                            "as no measurement info found".format(
                                measurement_id, file_path))
                        dict_counters_meas_info[measurement_id] = 0 + \
                            dict_counters_meas_info[measurement_id]
            dict_counters_sum[cell_id] = dict_counters_meas_info
        return dict_counters_sum
