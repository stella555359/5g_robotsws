from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import os
from ipaddress import IPv6Address, ip_address
import json
from lxml import etree
import yaml
import re
from IPy import IP
import traceback
import socket
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.String import String
import datetime
from dateutil import parser
import time
import csv
import openpyxl
import copy
import sys
import random
from io import BytesIO
from zipfile import ZipFile
import gzip
import logging
import uuid
from taf.hw.fhgw.cli import cli
from pprint import pprint
import os.path
import linecache
# from time_convert import time_str_to_utc_timestamp
import ipaddress

log_format = "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=logging.DEBUG, format=log_format)

try:
    from cStringIO import StringIO
except ImportError:
    try:
        from StringIO import StringIO
    except ImportError:
        from io import StringIO

issh_cli = cli()

__all__ = [
    "check_ipv6_address",
    "fetch_sw_version_from_cm_artifacts",
    "generate_log_path",
    "get_a_file",
    "get_a_directory",
    "ignore_known_alarms",
    "check_alarm",
    "get_network_address",
    "get_multi_distName_by_xpath_filter",
    "yaml_file_to_dictionary",
    "dictionary_to_yaml_file",
    "list_file_with_extension",
    "list_file",
    "replace_string_with_regexp",
    "fetch_string_with_regexp",
    "update_dictionary",
    "update_dictionary_with_appending",
    "overwrite_dictionary",
    "get_intersection_for_dictionaries",
    "increase_ip",
    "String_Should_Be_An_Ip_Address_V4_or_V6",
    "generate_webui_password",
    "set_dictionary_with_multiple_level_keys",
    "get_online_parameter_value",
    "get_dl_tput_from_l2_log",
    "get_ul_tput_from_l2_log",
    "generate_integrate_config_file",
    "get_environ_value",
    "set_environ_value",
    "get_time_interval_1",
    "get_time_interval_2",
    "get_time_interval_3",
    "get_time_interval_4",
    "get_time_interval_of_two_msgs",
    "write_to_csv_file",
    "get_time_interval_in_2_files",
    "get_timestamp_from_log",
    "timestamp_convert",
    "get_time_diff_with_timezoneoffset",
    "get_nidd_counters",
    "write_counters_to_excel",
    "generate_alarm_post_request_command",
    "parse_pm_result_xml_file",
    "get_measurement_report_stop_time",
    "measurement_file_name_gen",
    "get_parameter_sum_from_dcap_log",
    "get_parameter_from_dcap_log",
    "count_string_in_list",
    "check_ip_type",
    "get_info_from_file_with_re",
    "is_iptables_exist",
    "parse_snapshot_file_list",
    "get_specific_snapshot_parent_zip_files_name_list",
    "get_specific_snapshot_log_file_object",
    "get_latest_pm_counter_value_from_snapshot",
    "un_gz",
    "un_zip",
    "get_pm_result_mapping_content",
    "get_unique_id",
    "fast_connect_to_k8s_master",
    "fast_disconnect",
    "fast_disconnect_all",
    "fast_execute",
    "get_vdu_namespace_from_testline",
    "get_k8s_admin_ssh_connection_info",
    "get_k8s_tenant_ssh_connection_info",
    "get_app_server_info",
    "get_vcu_k8s_admin_ssh_connection_info",
    "get_cu_namespace_from_testline",
    "fast_connect_to_cu_k8s_master_with_admin",
    "fast_execute_cu",
    "get_fhgw_extra_config_yaml_from_testLine",
    "get_fhgw_extra_config_dictionary_from_testLine",
    "get_fhgw_major_version",
    "strip_prompt",
    "set_to_multiple_dictionary",
    "get_rf_infos_by_rf_model",
    "get_rf_info_list_by_rf_type",
    "encode_base64",
    "get_rf_sn_from_dhcp_log",
    "get_nrcellid_list_from_l2_log",
    "remove_value_info",
    "get_info_from_multiple_dictionary",
    "convert_list",
    "reverse_list_value",
    "parse_snapshot_doc_index",
    "check_desc_file_exists_in_snapshot_doc",
    "get_value_from_plan_tree_info",
    "get_mac_from_string",
    "get_mac_ip_list_from_csv_txt",
    "set_ip_to_rf_info_list",
    # "get_pid_relationship",
    "get_container_id_from_info",
    "get_core_dump_info",
    "generate_plan_when_add_mo",
    "compare_cu_teardown_alarm_info_with_setup",
    "compare_vdu_teardown_alarm_info_with_setup",
    "set_ip_and_mac_to_info_of_TDD",
    "set_ip_and_mac_to_info_of_FDD",
    "get_cell_global_l2rt_mapping_dict",
    "ping_status_should_be_as_expected",
    "get_max_timestamp_of_container_start_time",
    "covert_time_str_to_timestamp",
    "get_pod_start_time",
    "check_RU_log_in_snapshot",
    "compare_2_ip_address_is_same",
    "filter_operation_history",
    "read_snapshot_file_structure",
    "search_fatal_error_in_log",
    "fetch_mo_content",
    "generate_delta_parameters_for_one_mo_for_changing_value",
    "generate_delta_parameters_for_multiple_mo",
    "is_numeric",
    "is_list",
    "parse_name_convention_from_json_cnf_release_values",
    "_find_paths_in_json_file_by_value",
    "find_container_image_path",
    "get_network_interface_name_and_vf_id"
]


def get_parameter_from_dcap_log(log_path, msg_type, parameter):
    """Generate case log path(will not create the log folder).
     *AUTHOR* wei.7.chen@nokia-sbell.com
     """
    with open(log_path, 'r') as f:
        msg_type_flag = False
        for i in f:
            if msg_type in i:
                msg_type_flag = True
                continue
            if msg_type_flag:
                if parameter in i:
                    res = i
                    for j in [parameter, ',', ':']:
                        # res = res.replace(parameter, "")
                        res = res.replace(j, "")
                    return res.strip()
                    # return res
                    # if ':' in i:
                    #
                    # else:
                    #     res = i.strip().split()[-1].strip()
                    #     res = res.replace(",", "")
                    #     return res
    return None


def generate_log_path(BuiltIn_obj):
    """Generate case log path(will not create the log folder).
     *AUTHOR* fen.huang@nokia-sbell.com
     """
    output_dir = BuiltIn_obj.get_variable_value("${RESULT_DIR}")
    print("output_dir:{}".format(output_dir))

    test_name = BuiltIn_obj.get_variable_value("${TEST_NAME}")
    timestamp = BuiltIn_obj.get_variable_value("${START_TIME}")

    if test_name:
        log_path_without_suite_name = os.path.join("TESTCASE__" + str(test_name), timestamp)
    else:
        log_path_without_suite_name = os.path.join(timestamp)

    log_path_without_suite_name = log_path_without_suite_name.replace(" ", "_").replace(":", "_").replace("-", "_")
    log_path = os.path.join(output_dir, log_path_without_suite_name)
    return log_path


def get_a_file(*path):
    """get a file name with absolute path

    *AUTHOR* fen.huang@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -13.07.2020,chris.l.cao@nokia-sbell.com,
                   Raise exception if failed to generate a file name.
    | Input Parameters  | Man. | Description |
    | path            | Yes  |   list type, e.g, ["folder1", "fold2", "filename.txt"] |


    *RETURN VALUE*
    string

    Example:
    | ${file_name}  | get_a_file | folder1 | folder2 | filename.txt |
    """
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        log_path = generate_log_path(builtin_obj)
        file_abs_path = os.path.join(log_path, os.path.sep.join(path))
        builtin_obj.log(file_abs_path, "INFO")
        file_dir, file_name = os.path.split(file_abs_path)
        if not os.path.exists(file_dir):
            os.makedirs(file_dir)
        if not os.path.exists(file_abs_path):
            os.system("touch %s" % file_abs_path)
        rtn = file_abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_file(): fail!!")
    return rtn


def get_a_directory(*path):
    """
    crete a directory and return absolute path

    *AUTHOR* fen.huang@nokia-sbell.com

    *History Change*
    | date | who | what and how |
    | 13.07.2020 | chris.l.cao@nokia-sbell.com | Raise exception if failed to generate a folder name. |

    *Argument Description*
    | Input Parameters | Man. | Description |
    | path | Yes | list type, e.g, ["folder1", "fold2"] |

    *RETURN VALUE*
    string, a directory absolute path.

    *Example*:
    | ${folder_name}  | get_a_directory | folder1 | folder2 |
    """
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        builtin_obj.log("Start get a directory", "INFO")
        log_path = generate_log_path(builtin_obj)
        builtin_obj.log("general log path" + log_path, "INFO")
        abs_path = os.path.join(log_path, os.path.sep.join(path))
        builtin_obj.log(abs_path, "INFO")
        if not os.path.exists(abs_path):
            os.makedirs(abs_path)
        rtn = abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_directory(): fail!!")
    return rtn


def ignore_known_alarms(alarm_info, ignored_alarm_list=None):
    """This keyword is used to ignore some known alarms.

    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | alarm_info | Yes |  the alarm list |
    | ignore_alarm_list | Yes |  configured in init.py  file |

    *RETURN VALUE*
    alarm list

    Example
        | ignore_known_alarms |  ${alarm_list_before}  |
        | ignore_known_alarms  |  ${alarm_list_before}  |  ${IGNORED_ALARM_FAULT_NAME_LIST}|
    """
    for ignored_alarm in ignored_alarm_list:
        for alarm in alarm_info:
            if alarm["fault_name"] == ignored_alarm or str(alarm["fault_id"]) == str(ignored_alarm) \
                    or str(alarm["alarm_id"]) == str(ignored_alarm):
                alarm_info.remove(alarm)
    return alarm_info


def check_alarm(alarm_info, fault_id=None, fault_name=None, alarm_id=None, alarm_name=None, severity=None,
                additional_info=None):
    """This keyword is used to check alarm.

    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | alarm_info | Yes |  the alarm list |
    | fault_id   | Yes |  fault id |
    | fault_name   | Yes |  fault name |
    | alarm_id   | Yes |  alarm id |
    | alarm_name   | Yes |  alarm name |

    *RETURN VALUE*
    Boolean, return True if alarm exists

    Example
        | check_alarm |  ${alarm_list}  |  fault_id=7300  |  alarm_id=7107   |
    """
    if fault_id:
        fault_id = str(fault_id)
    if fault_name:
        fault_name = str(fault_name)
    if alarm_id:
        alarm_id = str(alarm_id)
    if alarm_name:
        alarm_name = str(alarm_name)
    if severity:
        severity = str(severity)
    if additional_info:
        additional_info = str(additional_info).strip()
    flag = False
    for alarm in alarm_info:
        if fault_id:
            if str(alarm["fault_id"]) != fault_id:
                flag = False
                continue
            else:
                flag = True
        if fault_name:
            if str(alarm["fault_name"]) != fault_name:
                flag = False
                continue
            else:
                flag = True
        if alarm_id:
            if str(alarm["alarm_id"]) != alarm_id:
                flag = False
                continue
            else:
                flag = True
        if alarm_name:
            if str(alarm["alarm_name"]) != alarm_name:
                flag = False
                continue
            else:
                flag = True
        if severity:
            if str(alarm["severity"]) != severity:
                flag = False
                continue
            else:
                flag = True
        if additional_info:
            if str(alarm["additional_info"]).strip() != additional_info:
                flag = False
                continue
            else:
                flag = True
        if flag:
            break
    if flag:
        logger.info("Alarm is found!")
    else:
        logger.info("Alarm is not found!")
    return flag


def get_network_address(ip_address, prefix_length):
    """This keyword is used to get the network address via ip address and prefix length

    *AUTHOR* lingting.sun@nokia-sbell.com
    | ip_address | Yes |  the ip address |
    | prefix_length | Yes |  the prefix length |

    *RETURN VALUE*
    network_address

    Example
        | get_network_address |  '2a00:8a00:8000:137:0:2a:0:2' |  96  |
        | get_network_address |  '192.168.255.129' |  24 |
    """
    ip = ip_address + '/' + prefix_length
    iface = ipaddress.ip_interface(ip)
    network_address = iface.network.network_address.compressed
    return network_address


def get_parameter_value_from_scf(scf_content_json_list, para_name, dist_name, class_name=None):
    if isinstance(scf_content_json_list, list):
        for json_dict in scf_content_json_list:
            print('json_dict is % s' % json_dict)
            if isinstance(json_dict, dict):
                if not class_name:
                    if json_dict['dist_name'] == dist_name:
                        return json.loads(json_dict['payload'])[para_name]
                else:
                    if json_dict[dist_name] == dist_name and json_dict[class_name] == class_name:
                        return json.loads(json_dict['payload'])[para_name]


def get_multi_distName_by_xpath_filter(scf_content, xpath, raml_version="raml21.xsd"):
    """to get the distName of managedObject according to parameter filtering and distName filtering.

    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   history change: <date>,<who>,<what and how>
    ...   25.9.2021, chris.l.cao@nokia-sbell.com, add support to raml20.xsd to support scf exported from Netact
    ...
    | Input Parameters | Man. | Description |
    | scf_content      | Yes  | SCF content |
    | xpath            | Yes | xpath expression |
    |          |    | if any duplicate may happen, using multiple parameters filtering plus distName filtering |
    |          |    | in Xpath expression |
    | raml_version  | no | raml_version, default value is raml21.xsd used by VDU webem |

    *RETURN VALUE*
    list of distName, e.g, ['MRBTS-3006/TNLSVC-1/TNL-5/IPNO-1/IPRT-1','MRBTS-3006/TNLSVC-1/TNL-5/IPNO-1/IPRT-1']

    Example
    | ${scf_content} | OperatingSystem.Get File | /home/ute/scf.xml |
    | ${xpath}       | set variable |
    | ... | .//ns:managedObject[descendant::ns:*[local-name()='p' or local-name()='list']/@name="btsName"] |
    | ${distName}    | get_multi_distName_by_xpath_filter | scf_content=${scf_content} | xpath=${xpath} |
    """
    rtn = []
    utf8_scf_content = scf_content.encode("utf-8")
    utf8_parser = etree.XMLParser(ns_clean=True, recover=True, encoding="utf-8")
    scf_root = etree.fromstring(utf8_scf_content, parser=utf8_parser)

    print(xpath)

    # para_mo_list = scf_root.xpath(xpath, namespaces={"ns": "raml21.xsd"})
    # para_mo_list = scf_root.xpath(xpath, namespaces={"ns": "raml20.xsd"})
    namespace = {}
    namespace["ns"] = raml_version
    para_mo_list = scf_root.xpath(xpath, namespaces=namespace)
    mo_list_len = len(para_mo_list)
    if mo_list_len == 0:
        print("No distName found")
    else:
        for item in para_mo_list:
            rtn.append(item.get("distName"))
    return rtn


def yaml_file_to_dictionary(file_path):
    """Get dictionary according yaml format file.

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters | Man. | Description |
    | file_path       | Yes  | file_path of yaml file |

    *RETURN VALUE*
    Dictionary of content

    Example
    | ${dictionary_content} | yaml_file_to_dictionary | /home/ute/a.yaml |
    """
    with open(file_path) as stream:
        NoDatesSafeLoader = yaml.SafeLoader
        NoDatesSafeLoader.yaml_implicit_resolvers = {
            k: [r for r in v if r[0] != 'tag:yaml.org,2002:timestamp']
            for k, v in NoDatesSafeLoader.yaml_implicit_resolvers.items()
        }
        data_loaded = yaml.load(stream, Loader=NoDatesSafeLoader)
    return data_loaded


def dictionary_to_yaml_file(dict_values, file_path):
    """Get dictionary according yaml format file.

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters | Man. | Description |
    | dict_values      | Yes  | dict_values to be dumped|
    | file_path       | Yes  | file_path of yaml file |

    *RETURN VALUE*
    None

    Example
    | ${dictionary_content} | yaml_file_to_dictionary | /home/ute/a.yaml |
    """
    with open(file_path, 'w') as f:
        yaml.safe_dump(dict_values, f, encoding='utf-8', allow_unicode=True)


def list_file_with_extension(path, extension=".zip", pattern=None):
    """List file under given path with desired extension.

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters | Man. | Description |
    | path       | Yes  | path to be scanned |
    | extension  | no  | file extension, it can be .zip, .txt, .log etc,  default is .zip |

    *RETURN VALUE*
    File list with desired extension,  eg.
    [['a.zip', 'b.zip'], ['/temp/a.zip', '/temp/abc/b.zip']]

    Example
    | ${basenames} | ${paths} | list_file_with_extension | /temp | extension=.zip |
    | ${basenames} | ${paths} | list_file_with_extension | /temp | extension=.zip | pattern=rcplog |
    | ${basenames} | ${paths} | list_file_with_extension | /temp | extension=${None} | pattern=rcplog |
    """
    rtn_filename = []
    rtn_full_filename = []
    if not os.path.isdir(path):
        print("Directory {} does not exist!")
        return [rtn_filename, rtn_full_filename]
    for root, dirs_list, files_list in os.walk(path):
        for file_name in files_list:
            file_name_path = os.path.join(root, file_name)
            if extension is not None:
                if os.path.splitext(file_name)[-1] == extension:
                    if pattern is None:
                        rtn_filename.append(file_name)
                        rtn_full_filename.append(file_name_path)
                    else:
                        strPattern = ".*{}.*".format(pattern)
                        m = re.match(strPattern, file_name)
                        if m:
                            rtn_filename.append(file_name)
                            rtn_full_filename.append(file_name_path)
            else:
                if pattern is None:
                    rtn_filename.append(file_name)
                    rtn_full_filename.append(file_name_path)
                else:
                    strPattern = ".*{}.*".format(pattern)
                    m = re.match(strPattern, file_name)
                    if m:
                        rtn_filename.append(file_name)
                        rtn_full_filename.append(file_name_path)
    return [rtn_filename, rtn_full_filename]


def list_file(path, retrieve_type="FILE"):
    """List file under given path

    *AUTHOR* chris.l.cao@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -15.07.2020,chris.l.cao@nokia-sbell.com, Change description for KW.

    | Input Parameters | Man. | Description |
    | path       | Yes  | path to be scanned |
    | retrieve_type | no  | what type of files will be retrieved, possible value is FILE/DIR/FILE_AND_DIR, |
    |               |     | default value is FILE |

    *RETURN VALUE*
    File list with desired extension,  eg.
    [['file_a', 'file_b'], ['/temp/file_a', '/temp/abc/file_b']]

    Example
    | ${file_list} | ${full_file_path_list}  | list_file | /temp |
    | ${file_list} | ${full_file_path_list}  | list_file | /temp | retrieve_type=FILE |
    """
    retrieve_type = retrieve_type.upper()
    rtn_filename = []
    rtn_full_filename = []
    if not os.path.isdir(path):
        print("Directory {} does not exist!")
        return rtn

    for root, dirs_list, files_list in os.walk(path):
        if retrieve_type == "FILE":
            for file_name in files_list:
                file_name_path = os.path.join(root, file_name)
                rtn_filename.append(file_name)
                rtn_full_filename.append(file_name_path)
        if retrieve_type == "DIR":
            for file_name in dirs_list:
                file_name_path = os.path.join(root, file_name)
                rtn_filename.append(file_name)
                rtn_full_filename.append(file_name_path)
        if retrieve_type == "FILE_AND_DIR":
            for file_name in files_list:
                file_name_path = os.path.join(root, file_name)
                rtn_filename.append(file_name)
                rtn_full_filename.append(file_name_path)
            for file_name in dirs_list:
                file_name_path = os.path.join(root, file_name)
                rtn_filename.append(file_name)
                rtn_full_filename.append(file_name_path)
    return [rtn_filename, rtn_full_filename]


def replace_string_with_regexp(content, g1_regexp, g2_regexp=".*?", g3_regexp=">", g2_new_value=""):
    """replace_string_with_regexp, content will be devided by three gropus (group1)(group2)(group3)
    every group's regexp is g1_regexp, g2_regexp, g3_regexp. The second group will be replaced by g2_new_value.

    *AUTHOR* chris.l.cao@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -15.07.2020,chris.l.cao@nokia-sbell.com, Change description for KW.

    | Input Parameters | Man. | Description |
    | content         | Yes  | content to be processed |
    | g1_regexp       | Yes  | group1's regexp |
    | g2_regexp       | no  | group2's regexp, default value is .*? |
    | g3_regexp       | no  | group3's regexp, default value is > |
    | g2_new_value    | no  | new value which will replace old content expressed by g2_regexp |

    *RETURN VALUE*
    String

    Example:
    | ${content} | set variable | <list name="f1Cplane"> <item><p name="ipV4AddressDN1">value</p></item></list> |
    | ${new_content} | replace_string_with_regexp | content=${content} |
    | ... | g1_regexp1=<list\\s+name=\\S+> | g2_regexp=.* | g3_regexp=</list> | g2_new_value=aaa |
    new_content will be <list name="f1Cplane">aaa</list>

    """
    p = re.compile("(^.*{})({})({})".format(g1_regexp, g2_regexp, g3_regexp), flags=re.S)
    rtn = re.sub(p, "\\1{}\\3".format(g2_new_value), content)
    return rtn


def fetch_string_with_regexp(content, g1_regexp, g2_regexp=".*?", g3_regexp=">"):
    """fetch_string_with_regexp, content will be devided by three gropus (group1)(group2)(group3)
    every group's regexp is g1_regexp, g2_regexp, g3_regexp.

    *AUTHOR* chris.l.cao@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -15.07.2020,chris.l.cao@nokia-sbell.com, Change description for KW.

    | Input Parameters | Man. | Description |
    | content       | Yes  | content to be searched |
    | g1_regexp       | Yes  | group1's regexp |
    | g2_regexp       | no  | group2's regexp, default value is .*? |
    | g3_regexp       | no  | group3's regexp, default value is > |

    *RETURN VALUE*
    tuple: (group1_string, group2_string, group3_string)

    Example:
    | ${content} | set variable | <list name="f1Cplane"> <item><p name="ipV4AddressDN1">value</p></item></list> |
    | ${o1} | ${o2} | ${o3} | fetch_string_with_regexp | content=${content} |
    |  ...  |  g1_regexp=<list\\s+name=\\S+> | g2_regexp=.* | g3_regexp=</list> |
    o1 will be:<list name="f1Cplane">
    o2 will be: <item><p name="ipV4AddressDN1">value</p></item>
    o3 will be:</list>

    """
    p = re.compile("(^.*{})({})({})".format(g1_regexp, g2_regexp, g3_regexp), flags=re.S)
    m = p.match(content)
    if m:
        return (m.group(1), m.group(2), m.group(3))
    else:
        return "", "", ""


def fetch_mo_content(scf_path, distName):
    """fetch MO content from SCF file

    *AUTHOR* chris.l.cao@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -24.11.2023,chris.l.cao@nokia-sbell.com, new KW.

    | Input Parameters | Man. | Description |
    | scf_path       | Yes  | scf path, e.g, /tmp/scf.xml |
    | distName       | Yes  | distName , e.g, MRBTS-108201/MNL-1 |

    *RETURN VALUE*
    whole MO content, e.g,
   <managedObject class="com.nokia.srbts.mnl:MNLENT" distName="MRBTS-108201/MNL-1/MNLENT-1" operation="create"
      version="MNLVDU24R1_2322_100">
     <p name="targetDNType">Container</p>
    </managedObject>

    Example:
    | ${content} | fetch_mo_content | scf_path=/tmp/scf.xml | distName=MRBTS-108201/MNL-1 |
    """
    rtn = ""
    try:
        with open(scf_path, 'r') as f:
            content = f.read()
            p = re.compile("""
                .*(<managedObject.*?distName="{}".*?</managedObject>?)
                """.format(distName), re.VERBOSE | re.MULTILINE | re.DOTALL)

            m = p.match(content)
            if m:
                rtn = m.group(1)
    except Exception as e:
        traceback.print_exc()
    return rtn


def increase_ip(ip, step=1):
    """This function is used to increase ip address, and return an IP address , supporting ipv4 and ipv6

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | ip            | Yes  |  ip address you want to increase eg, 10.107.63.206 |
    | step            | Yes  | increasement step, e.g, 1, -1, 2 , -2, default is 1 |

    *RETURN VALUE*
    ip

    Example:
     | ${ip} | increase_ip | 10.107.63.206 |     |
     | ${ip} | increase_ip | 10.107.63.206 |  1  |
     | ${ip} | increase_ip | 10.107.63.206 | -1  |
     | ${ip} | increase_ip | 10.107.63.206 | 10  |
     | ${ip} | increase_ip | 10.107.63.206 | -10 |
    """
    if len(ip) == 0:
        raise RuntimeError("To be increased ip should not be empty!!")

    nIp = IP(ip, make_net=True).int()
    step = int(step)
    nIp = nIp + step
    rtn = IP(nIp).strNormal()
    return rtn


def String_Should_Be_An_Ip_Address_V4_or_V6(ip):
    """This function is used to determine whether it's an ip v4 or ipv6 address

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | ip            | Yes  |  ip address string eg, 10.107.63.206, 1:2::3 |

    *RETURN VALUE*
    None

    Example:
     | String_Should_Be_An_Ip_Address_V4_or_V6 | 10.107.63.206 |     |
     | String_Should_Be_An_Ip_Address_V4_or_V6 | 1::1 |     |
     | String_Should_Be_An_Ip_Address_V4_or_V6 | 1:1:1:: |     |
    """
    if len(ip) == 0:
        raise RuntimeError("ip address should not be empty!!")

    IP(ip)


def generate_webui_password(length=10, excluded_string=""):
    """This function is used to generate webui password

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | length            | No  |  password length, default is 10 |
    | excluded_string   | No  |  excluded_string, default is empty |

    *RETURN VALUE*
    None

    Example:
     | ${tmp_password} | generate_webui_password | length=10 |        |
     | ${tmp_password} | generate_webui_password | length=10 | excluded_string="abcdef" |
    """
    length = int(length)
    char_list = "abcdefghijklmnopqrstuvwxyz"

    for i in excluded_string:
        char_list = char_list.replace(i, "")

    captilized_index = random.randint(0, 25)
    captilized_char = chr(65 + captilized_index)

    temp_string = ""
    j = 0
    while j <= length:
        char_list_len = len(char_list)
        random_num = random.randint(0, char_list_len-1)
        ch = char_list[random_num: random_num+1]
        temp_string += ch
        char_list = char_list.replace(ch, "")
        j += 1
    rtn = "{}{}123!".format(captilized_char, temp_string)
    print("generate_webui_password:{}".format(rtn))
    return rtn


def update_dictionary(src_dict, dst_dict):
    """use src_dict to overwrite dst_dict, but will not copy src_dict's key/value
    which is not existed in dst_dict.

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | src_dict            | Yes  |  src dictionary |
    | dst_dict            | Yes  |  dst dictionary |

    *RETURN VALUE*
    dict

    Example:
    | ${dict1}  | create dictionary | key1=dict1_value1 | key2=dict1_value2 | key4=dict1_value3 |
    | ${dict2}  | create dictionary | key1=dict2_value1 | key2=dict2_value2 | key3=dict2_vaalue3 |
    | ${dict}   |create dictionary |
    | update_dictionary |  src_dict=${dict1}   dst_dict=${dict2} |
    | should be true | "${dict2["key1"]}"=="dict1_value1" |
    | should be true | "${dict2["key2"]}"=="dict1_value2" |
    | should be true | "${dict2["key3"]}"=="dict2_vaalue3" |
    | should be true | "key4" not in ${dict2.keys()} |
    """
    if len(dst_dict) == 0:
        raise RuntimeError("dst_dict dictionary should not be empty!!")

    intersection_dict = {}
    get_intersection_for_dictionaries(src_dict, dst_dict, intersection_dict)
    rtn = overwrite_dictionary(intersection_dict, dst_dict)
    return rtn


def update_dictionary_with_appending(dict1, dict2):
    """Update dict2 with dict1, the member which does not exist in dict2 will be appended to dict2

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | dict1            | Yes  |   dictionary1 |
    | dict2            | Yes  |   dictionary2 |

    *RETURN VALUE*
    None

    Example:
    | ${dict1}  | create dictionary | key1=dict1_value1 | key2=dict1_value2 |
    | ${dict2}  | create dictionary | key2=dict2_value2 | key3=dict2_vaalue3 |
    | update_dictionary_with_append_mode |  src_dict=${dict1}   dst_dict=${dict2} |
    | should be true | "${dict2["key1"]}"=="dict1_value1" |
    | should be true | "${dict2["key2"]}"=="dict1_value2" |
    | should be true | "${dict2["key3"]}"=="dict2_vaalue3" |
    | should be true | "key4" not in ${dict2.keys()} |
    """
    for src_key in dict1:
        if src_key in dict2:
            tmp_dict2_value = dict2.get(src_key, None)
            if isinstance(tmp_dict2_value, dict):
                update_dictionary_with_appending(dict1[src_key], dict2[src_key])
            else:
                dict2[src_key] = copy.deepcopy(dict1[src_key])
        else:
            dict2[src_key] = copy.deepcopy(dict1[src_key])

    return


def overwrite_dictionary(src_dict, dst_dict):
    """use src_dict to overwrite dst_dict

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | src_dict            | Yes  |  src dictionary |
    | dst_dict            | Yes  |  dst dictionary |

    *RETURN VALUE*
    dict

    Example:
    | ${dict1}  | create dictionary | key1=dict1_value1 |   key2=dict1_value2 |
    | ${dict2}  | create dictionary | key1=dict2_value1 |   key2=dict2_value2 | key3=dict2_vaalue3 |
    | ${dict}   | create dictionary |
    | overwrite_dictionary |  src_dict=${dict1} |  dst_dict=${dict2} |
    | should be true | "${dict2["key1"]}"=="dict1_value1" |
    | should be true | "${dict2["key2"]}"=="dict1_value2" |
    | should be true | "${dict2["key3"]}"=="dict2_vaalue3" |
    """
    for key in src_dict:
        if isinstance(dst_dict[key], dict):
            overwrite_dictionary(src_dict[key], dst_dict[key])
        else:
            dst_dict[key] = src_dict[key]


def get_intersection_for_dictionaries(dict1, dict2, intersection_dict):
    """get intersection for dictionary1 and dictionary2, but the value is from dict1

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | dict1            | Yes  |   dictionary1 |
    | dict2            | Yes  |   dictionary2 |

    *RETURN VALUE*
    dict

    Example:
    | ${dict1}  | create dictionary | key1=dict1_value1 |   key2=dict1_value2 |
    | ${dict2}  | create dictionary | key11=dict2_value1 |   key2=dict2_value2 |  key3=dict2_vaalue3 |
    | ${intersection_dict}   | create dictionary |
    | get_intersection_for_dictionaries | dict1=${dict1} | dict2=${dict2} | intersection_dict=${intersection_dict} |
    | should be true | "${dict["key2"]}"=="dict1_value2" |
    """
    if not isinstance(dict1, dict) or not isinstance(dict2, dict):
        return dict1
    for src_key in dict1:
        if src_key in dict2:
            intersection_dict[src_key] = {}
            intersection_dict[src_key] = get_intersection_for_dictionaries(
                dict1[src_key], dict2[src_key], intersection_dict[src_key])
    return intersection_dict


def set_dictionary_with_multiple_level_keys(value, dict_name, keys):
    """Set new value for dictionary member, support many depth(multiple level key),
    like key1->key2->key3->...

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | value            | Yes  |  new value to be set |
    | dict_name        | Yes  |  dictionary name |
    | keys             | Yes  |  keys list name, type is list, please see example |

    *RETURN VALUE*
    None

    Example:
    | ${dict1_subdict1} | Create Dictionary | subkey1=subke1_dict1_value |
    | ${dict1} | Create Dictionary | key1=dict1_value1 | key2=dict1_value2 |
    | ... |  keyaaa=${dict1_subdict1} |

    | ${key_list} | Create List | keyaaa | subkey1 |
    | Set_Dictionary_With_Multiple_Level_Keys | value=aaaa |  dict_name=${dict1} | keys=${key_list} |
    | Should Be True | "${dict1["keyaaa"]["subkey1"]}"=="aaaa" |
    """

    key_len = len(keys)
    for i, key in enumerate(keys):
        if key not in dict_name:
            raise RuntimeError("key:{} not exists!".format(key))
        if i == key_len-1:
            dict_name[key] = value
        else:
            dict_name = dict_name.get(key)


def is_numeric(value):
    """
    [Documentation]  return True if it's numeric, otherwise return False
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.22  chris.l.cao@nokia-sbell.com, initialization
    """
    try:
        float(value)
        return True
    except ValueError:
        return False


def is_list(value):
    """
    [Documentation]  return True if it's list, otherwise return False
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.22  chris.l.cao@nokia-sbell.com, initialization
    """
    try:
        ret = isinstance(value, list)
        return ret
    except ValueError:
        return False


def get_online_parameter_value(paras_info, dn, para_struct_path, return_list=False):
    """This keyword is used to get parameter value from current plan.

    *AUTHOR* fen.huang@nokia-sbell.com
     Change History
     2023.12.22 chris.l.cao@nokia-sbell.com, When return_list is True, it returns list instead of list member value
                                             We can use this way to know the list length

    | Input Parameters | Man. | Description |
    |  paras_info | Yes |  all parameter info returned by taf kw search_parameters_of_current_plan  |
    |  dn   | Yes |  fault id |
    |  para_struct_path   | Yes |  parameter path, like a2ThresholdRedirectSsbRsrp/0/a2MeasRedirectSsbRsrp  |


    *RETURN VALUE*
    parameter value, if it's simple or complex parameter, returns string type
    if it's a simple list type parameter, it will return a list.

    Example
    |  get_online_parameter_value  |  MRBTS-5248     |   btsName  |
    |  get_online_parameter_value  |  MRBTS-52/NRBTS-1/NRCELL-1| a2ThresholdRedirectSsbRsrp/0/a2MeasRedirectSsbRsrp |
    """
    para_struct_list = para_struct_path.split('/')
    items = paras_info["items"]
    for item in items:
        if item["distname"] == dn and item['parameter_name'] == para_struct_list[0]:
            para_info = item["parameter"]
            para_type = item["parameter"]["parameter_type"]
            if para_type == "simple":
                return _get_simple_parameter_value(para_info)
            elif para_type == "complex":
                return _get_complex_parameter_value(para_info, para_struct_list, return_list=return_list)
            elif para_type == "simpleList":
                return _get_simple_list_parameter_value(para_info)
            else:
                logger.error(
                    "Parameter type is not simple or complex or simpleList")


def _get_simple_parameter_value(para_info):
    # if item_info["parameter"]["simple_parameter"]["name"] == para_name:
    simple_value = para_info["simple_parameter"]
    if 'value' in simple_value.keys():
        return simple_value["value"]


def _get_complex_parameter_value(para_info, para_struct_list, return_list=False):
    if return_list:
        return para_info['complex_parameter']['value']
    complex_para_value = para_info['complex_parameter']['value'][int(para_struct_list[1])]

    for struct_para in complex_para_value.structure_parameters:
        if struct_para.parameter_type == 'simple' \
                and struct_para.simple_parameter.name == para_struct_list[-1] \
                and hasattr(struct_para.simple_parameter, 'value'):
            return struct_para.simple_parameter.value
        if struct_para.parameter_type == 'simpleList' \
                and struct_para.simple_list_parameter.name == para_struct_list[-1] \
                and hasattr(struct_para.simple_list_parameter, 'value'):
            return struct_para.simple_list_parameter.value


def _get_simple_list_parameter_value(para_info):
    # if item_info["parameter"]["simple_list_parameter"]["name"] == para_name:
    simple_list_value = para_info["simple_list_parameter"]
    if 'value' in simple_list_value.keys():
        return simple_list_value["value"]


def get_dl_tput_from_l2_log(log_path, cell_id=None):
    """This keyword is used to get dl t-put from l2rt log
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |
    |  cell_id  | No  |  global cell id, default is None |

    *RETURN VALUE*
    dl t-put

    Example
    |  get_dl_tput_from_l2_log     |  ${log_dir}l2rt.log    |
    """
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        if cell_id is not None:
            for line in lines:
                if "DataPdu" in line and cell_id in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'\|DataPdu:\s*\d+\|', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("dl tb_size is {}".format(tb_list))
        if cell_id is None:
            for line in lines:
                if "DataPdu" in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'\|DataPdu:\s*\d+\|', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("dl tb_size is {}".format(tb_list))
        if tb_list:
            dl_tput = float(sum(tb_list))/len(tb_list)*8/1024/1024
        else:
            dl_tput = 0
    return dl_tput


def get_ul_tput_from_l2_log(log_path, cell_id=None):
    """This keyword is used to get ul t-put from l2rt log
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |
    |  cell_id  | No  |  global cell id, default is None |

    *RETURN VALUE*
    ul t-put

    Example
    |  get_ul_tput_from_l2_log     |  ${log_dir}l2rt.log    |
    """
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        if cell_id is not None:
            for line in lines:
                if "UlCounterUpdate" in line and cell_id in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'/UL:\s*\d+\s*Bytes received', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("ul tb_size is {}".format(tb_list))
        if cell_id is None:
            for line in lines:
                if "UlCounterUpdate" in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'/UL:\s*\d+\s*Bytes received', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("ul tb_size is {}".format(tb_list))
        if tb_list:
            ul_tput = float(sum(tb_list))/len(tb_list)*8/1024/1024
        else:
            ul_tput = 0
    return ul_tput


def generate_integrate_config_file(file_path, ne_type, ne_id, host, port, neo_endpoints_ip,
                                   username="wsuser", password="A0zY~rP#8Mx@"):
    """This keyword is used to generate cu/vdu/fhgw config file for integrating to nom.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  file_path | Yes |  Where to store config file  |
    |  ne_type | Yes |  NE type, can be cu, vdu or fhgw  |
    |  ne_id | Yes |  Instance ID of NE  |
    |  host | Yes |  IP address of NE  |
    |  port | Yes |  Port of NE  |
    |  neo_endpoints_ip | Yes |  IP address of neo endpoints  |
    |  username | No |  Username for ne access  |
    |  password | No |  Password for ne access  |

    *RETURN VALUE*
     None

    Example
    |  generate_integrate_config_file     |  /tmp/cu0.json    |
    """
    ne_type = ne_type.upper()
    if ne_type == "CU":
        ne_type = "VCU"
    if ne_type == "DU":
        ne_type = "VDU"
    if ne_type == "VCU" or ne_type == "VDU":
        generated_template_content = '''
          {{
              "neType": "MRBTS",
              "neId": "{ne_id}",
              "neVersion": "{ne_type}20",
              "host": "{host}",
              "port": "{port}",
              "timezone": "Europe/Helsinki",
              "username": "{username}",
              "password": "{password}",
              "smLaunchUrl": "https://{host}",
              "neoNotificationEndpoint": "http://{neo_endpoints_ip}/NE3S/1.0",
              "neoDownloadServiceEndpoint": "http://{neo_endpoints_ip}/files",
              "agentId": "HQZ-{ne_type}{ne_id}",
              "integratedId": "HQZ-{ne_type}/MRBTS-{ne_id}"
          }}
         '''
        generated_template_content = generated_template_content.strip().\
            format(ne_type=ne_type, ne_id=ne_id, host=host, port=port,
                   username=username, password=password, neo_endpoints_ip=neo_endpoints_ip)
    else:
        generated_template_content = '''
                 {{
                     "neType": "MRBTS",
                     "neId": "{ne_id}",
                     "neVersion": "FHGW20",
                     "host": "{host}",
                     "port": "{port}",
                     "timezone": "Europe/Helsinki",
                     "username": "{username}",
                     "password": "{password}",
                     "neoNotificationEndpoint": "http://{neo_endpoints_ip}/NE3S/1.0",
                     "neoDownloadServiceEndpoint": "http://{neo_endpoints_ip}/files",
                     "systemId": "FHGW-{ne_id}",
                     "agentId": "HQZ-FHGW{ne_id}",
                     "integratedId": "HQZ-FHGW/FHGW-{ne_id}"
                 }}
                '''
        generated_template_content = generated_template_content.strip().\
            format(ne_id=ne_id, host=host, port=port,
                   username=username, password=password, neo_endpoints_ip=neo_endpoints_ip)
    os_obj = OperatingSystem()
    os_obj.create_file(file_path, generated_template_content)


def get_environ_value(environ_variable_name):
    """get_environ_value
    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | environ_variable_name    | Yes  |  environ_variable_name |


    *RETURN VALUE*
    None

    Example:
    | ${value} | get_environ_value | HTTP_PROXY |
    """
    environ = os.environ
    if environ_variable_name in environ:
        return environ[environ_variable_name]
    return ""


def set_environ_value(environ_variable_name, value):
    """get_environ_value
    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | environ_variable_name    | Yes  |  environ_variable_name |
    | value                    | Yes  |  value |

    *RETURN VALUE*
    None

    Example:
    | set_environ_value | HTTP_PROXY | http://1.1.1.1:8080 |
    """
    environ = os.environ
    environ[environ_variable_name] = value


def write_to_csv_file(*args):
    """This keyword is used to write info to csv file.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | args         | Yes | first param is csv full path, the other params use key=value format |

    *RETURN VALUE*

    Example
    | write_to_csv_file | /tmp/123.csv | header1=${para1} | header2=${param2} |
    | write_to_csv_file | /tmp/123.csv | header1=${para1} | header2=${param2} | header3=${param3} | header4=${param4}|
    """
    csv_name = args[0]
    header = list()
    row = dict()
    for element in args[1:]:
        item = element.split('=')
        header.append(item[0].strip())
        row[item[0].strip()] = item[1].strip()
    if sys.version_info[0] < 3:
        _write_to_csv_file_PY2(csv_name, header, row)
    else:
        _write_to_csv_file_PY3(csv_name, header, row)


def _write_to_csv_file_PY2(csv_name, header, row):
    try:
        with open(csv_name, 'rb') as csv_read:
            csv_read.seek(0)
            header_exist = csv.Sniffer().has_header(csv_read.read(1024))
            if header_exist:
                with open(csv_name, 'ab') as csvfile:
                    writer = csv.DictWriter(csvfile, fieldnames=header)
                    writer.writerow(row)
    except IOError:
        with open(csv_name, 'wb') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=header)
            writer.writeheader()
            writer.writerow(row)


def _write_to_csv_file_PY3(csv_name, header, row):
    try:
        with open(csv_name, 'r') as csv_read:
            csv_read.seek(0)
            header_exist = csv.Sniffer().has_header(csv_read.read(1024))
            if header_exist:
                with open(csv_name, 'a', newline='') as csvfile:
                    writer = csv.DictWriter(csvfile, fieldnames=header)
                    writer.writerow(row)
    except IOError:
        with open(csv_name, 'w', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=header)
            writer.writeheader()
            writer.writerow(row)


def get_time_interval_1(time_1, time_2):
    """
    This keyword is used to get time delta, return result is time_2 subtracts time_1 in seconds.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  time_1 | Yes |  timestamp string, should be in format 2018-01-03T09:10:02.465931Z |
    |  time_2 | Yes |  timestamp string, should be in format 2018-01-03T09:10:02.465931Z |

    *RETURN VALUE*
    Time in seconds

    Example
    | ${time_delta}= | get_time_interval_1  |  2018-01-03T09:10:02.465931   |  2018-01-03T09:10:02.465931   |

    """
    if "." not in time_1:
        time_1 = time_1+".0"
    if "." not in time_2:
        time_2 = time_2+".0"
    print(time_1)
    print(time_2)
    a = datetime.datetime.strptime(time_1, "%Y-%m-%dT%H:%M:%S.%f")
    b = datetime.datetime.strptime(time_2, "%Y-%m-%dT%H:%M:%S.%f")
    return round(datetime.timedelta.total_seconds(b-a), 3)


def get_time_interval_2(time_1, time_2):
    """
    This keyword is used to get time delta, return result is time_2 subtracts time_1 in seconds.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  time_1 | Yes |  timestamp string, should be in format 20201230.1620  |
    |  time_2 | Yes | timestamp string, should be in format 20201230.1720  |

    *RETURN VALUE*
    Time in seconds

    Example
    | ${time_delta}= | get_time_interval_2  |  20201230.1620    |  20201230.1720   |

    """
    try:
        a = datetime.datetime.strptime(time_1, "%Y%m%d.%M%S")
        b = datetime.datetime.strptime(time_2, "%Y%m%d.%M%S")
    except Exception:
        a = datetime.datetime.strptime(time_1, "%b %d %H:%M:%S")
        b = datetime.datetime.strptime(time_2, "%b %d %H:%M:%S")
    return datetime.timedelta.total_seconds(b-a)


def get_time_interval_3(time_1, time_2):
    """
    This keyword is used to get time delta, return result is time_2 subtracts time_1 in seconds.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  time_1 | Yes | timestamp string, should be in format Jan 03 17:10:06 |
    |  time_2 | Yes | timestamp string, should be in format 2018-01-03T09:10:02.465931Z |

    *RETURN VALUE*
    Time in seconds

    Example
    | ${time_delta}= | get_time_interval_3  |  Jan 03 17:10:06    |  2018-01-03T09:10:02.465931Z   |

    """
    current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    current_year = current_time.split("-")[0]
    time_1 = current_year+" "+time_1
    a = datetime.datetime.strptime(time_1, "%Y %b %d %H:%M:%S")
    b = datetime.datetime.strptime(time_2, "%Y-%m-%dT%H:%M:%S.%fZ")
    return datetime.timedelta.total_seconds(b-a)


def get_time_interval_4(time_1, time_2):
    """
    This keyword is used to get time delta, return result is time_2 subtracts time_1 in seconds.
    *AUTHOR* zongke.lv@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  time_1 | Yes |  timestamp string, should be in format 2018-01-03 09:10:02 |
    |  time_2 | Yes |  timestamp string, should be in format 2018-01-03T09:10:02.465931Z |

    *RETURN VALUE*
    Time in seconds

    Example
    | ${time_delta}= | get_time_interval_1  |  2018-01-03 09:10:02   |  2018-01-03T09:10:02.465931   |

    """
    if "." not in time_1:
        time_1 = time_1+".0"
    if "." not in time_2:
        time_2 = time_2+".0"
    print(time_1)
    print(time_2)
    a = datetime.datetime.strptime(time_1, "%Y-%m-%d %H:%M:%S.%f")
    b = datetime.datetime.strptime(time_2, "%Y-%m-%dT%H:%M:%S.%f")
    return round(datetime.timedelta.total_seconds(b-a), 3)


def get_time_interval_5(time_1, time_2):
    """
    This keyword is used to get time delta, return result is time_2 subtracts time_1 in seconds.
    *AUTHOR* zongke.lv@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  time_1 | Yes |  timestamp string, should be in format Jan 03 17:10:06  |
    |  time_2 | Yes |  timestamp string, should be in format 2018-01-03T09:10:02.465931 |

    *RETURN VALUE*
    Time in seconds

    Example
    | ${time_delta}= | get_time_interval_1  | Jan 03 17:10:06    |  2018-01-03T09:10:02.465931Z  |

    """
    current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    current_year = current_time.split("-")[0]
    time_1 = current_year+" "+time_1
    a = datetime.datetime.strptime(time_1, "%Y %b %d %H:%M:%S")
    b = datetime.datetime.strptime(time_2, "%Y-%m-%dT%H:%M:%S.%f")
    return datetime.timedelta.total_seconds(b-a)


def get_time_interval_in_2_files(file_1, msg_pattern_1, index_1, expected_msg_num_1,
                                 file_2, msg_pattern_2, index_2, expected_msg_num_2):
    """
    This keyword is used to get time interval of 2 specified messages.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  file_1  | Yes |  Path of the first log file  |
    |  file_2  | Yes |  Path of the second log file  |

    *RETURN VALUE*
    Timestamp string of the last line

    Example
    | ${time_delta}= | get_time_interval_in_2_files   |  /home/ute/log_1.txt  |   /home/ute/log_2.txt  |

    """
    time_1 = get_timestamp_from_log(file_1, msg_pattern_1, index_1, expected_msg_num_1)
    logger.info(time_1)
    time_2 = get_timestamp_from_log(file_2, msg_pattern_2, index_2, expected_msg_num_2)
    logger.info(time_2)
    if time_1 and time_2 and "T" not in time_1 and "-" in time_1 and "T" in time_2:
        return get_time_interval_4(time_1, time_2)
    elif time_1 and time_2 and "-" not in time_1 and "-" in time_2 and "Z" not in time_2:
        return get_time_interval_5(time_1, time_2)
    elif time_1 and time_2 and "-" in time_1 and "-" not in time_2:
        return get_time_interval_3(time_2, time_1)
    elif time_1 and time_2 and "-" not in time_1 and "-" in time_2:
        return get_time_interval_3(time_1, time_2)
    elif time_1 and time_2 and "-" not in time_1 and "-" not in time_2:
        return get_time_interval_2(time_1, time_2)
    elif time_1 and time_2 and "-" in time_1 and "-" in time_2:
        return get_time_interval_1(time_1, time_2)
    else:
        return None


def get_timestamp_from_log(file_path, msg_pattern, index, expected_msg_num=False):
    """
    This keyword is used to get timestamp value in the last line of the file.
    *AUTHOR* fen.huang@nokia-sbell.com
    *Change History*
    | date | who | what or how |
    | 2022-4-18 | r3li | add new a time format to match. |
    | 2022-8-2 | r3li | add new a time format to match. |
    *Arguments Description*
    | Input Parameters | Man. | Description |
    | file_path  | Yes | Path of the log file  |
    | msg_pattern | Yes | match line info |
    | index | Yes | What line index be matched |
    | expected_msg_num | No | msg number in file |
    *RETURN VALUE*
    Timestamp string of the expected line by index
    *Example*
    | ${time_delta}= | get_last_timestamp_from_log   |  /tmp/log.txt  |  message  |
    """
    st = String()
    os_obj = OperatingSystem()
    file_content = os_obj.get_file(file_path, encoding='LATIN1')
    matches = st.get_lines_matching_regexp(file_content, msg_pattern, True)
    num_of_msg = st.get_line_count(matches)
    matched_line = st.get_line(matches, index)
    print(matched_line)
    if expected_msg_num and num_of_msg != int(expected_msg_num):
        raise ValueError("{} messages matched, but expected matched {}!".format(str(num_of_msg),
                                                                                str(expected_msg_num)))
    logger.info(matched_line)
    if matched_line:
        matches = st.get_regexp_matches(matched_line, "(\\d+-\\d+-\\d+T\\d+:\\d+:\\d+.\\d+)[+Z]", 1)
        if matches:
            return matches[0].strip("Z")
        else:
            pattern_list = ["(\\d+-\\d+-\\d+T\\d+:\\d+:\\d+)",
                            "(\\d+-\\d+-\\d+ \\d+:\\d+:\\d+)",
                            "((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sept|Oct|Nov|Dec) \\d+ \\d+:\\d+:\\d+)"]
            for pattern in pattern_list:
                matches = st.get_regexp_matches(matched_line, pattern, 1)
                if matches:
                    return matches[0]
        return None


def timestamp_convert(time_string):
    plus_hours_time = datetime.datetime.strptime(time_string, "%Y-%m-%dT%H:%M:%S.%f")
    plus_hours_time = (plus_hours_time + datetime.timedelta(hours=8)).strftime("%Y-%m-%dT%H:%M:%S.%f")
    return plus_hours_time


def get_time_diff_with_timezoneoffset(date1, offset1='+0000', date2=None, offset2='+0000'):
    """
    This keyword is used to get timestamp difference with timezone offset, and return a sec.
    *AUTHOR* shan-eric.wu@nokia-sbell.com
    *Change History*
    | date | who | what or how |
    | 2023-7-27 | shwu | add timezone offset scenario |
    *Arguments Description*
    | Input Parameters | Man. | Description |
    | date1  | Yes | datetime 1  |
    | offset1 | No | timezone offset of datetime1 |
    | date2 | Yes | datetime 2 |
    | offset2 | No | timezone offset of datetime2 |
    *RETURN VALUE*
    Timestamp string of seconds
    *Example*
    | get_time_diff_with_timezoneoffset |"2023-07-25T02:03:17" |"+0000"|"2023-07-25 09:50:28"|"+0800"
    """
    date2 = date2.replace("T", " ")
    date1 = date1.replace("T", " ")

    # Define the date format
    date_format = "%Y-%m-%d %H:%M:%S"

    # Parse the dates into datetime objects
    date1_obj = datetime.datetime.strptime(date1, date_format)
    date2_obj = datetime.datetime.strptime(date2, date_format)

    # Calculate the time zone offsets in seconds
    offset1_secs = int(offset1[:3]) * 3600 + int(offset1[3:]) * 60
    offset2_secs = int(offset2[:3]) * 3600 + int(offset2[3:]) * 60

    # Convert the datetime objects to UTC
    date1_utc = date1_obj - datetime.timedelta(seconds=offset1_secs)
    date2_utc = date2_obj - datetime.timedelta(seconds=offset2_secs)

    # Calculate the difference
    diff = date1_utc - date2_utc

    # Print the difference
    return diff.total_seconds()


def get_nidd_counters(file_dir):
    """Get all counter id list from nidd definition excel file(input by user).
      *AUTHOR* fen.huang@nokia-sbell.com
    """
    os_obj = OperatingSystem()
    file_list = os_obj.list_directory(file_dir)
    counter_id_list = []
    measurement_id_list = []
    for file_name in file_list:
        file_location = file_dir+"/"+file_name
        workbook = openpyxl.load_workbook(file_location, read_only=True)
        worksheet = workbook.get_sheet_by_name("counters")
        for row in worksheet.iter_rows():
            for cell in row:
                counter_id_list.append(cell.value)
                measurement_id = cell.value[0:6]
                measurement_id_list.append(measurement_id)
    return list(set(measurement_id_list)), list(set(counter_id_list))


def write_counters_to_excel(file_path, counter_value_list):
    """ Write counters id to excel file in one column.
      *AUTHOR* fen.huang@nokia-sbell.com
    """
    wb = openpyxl.Workbook()
    sheet = wb.active
    i = 0
    for value in counter_value_list:
        i = i+1
        c1 = sheet.cell(row=i, column=1)
        c1.value = value
    wb.save(file_path)


def generate_alarm_post_request_command(faultid, state, source, severity="1",
                                        sourcetype="1",
                                        extrainfo="57360",
                                        recoveryoverride="1"):
    """This keyword is used to generate alarm post request command
    *AUTHOR* yun.1.wang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  faultId | Yes | faultId want to post  |
    |  state | Yes |  1 or 0 ;1-rasie, 0-clear  |
    |  source | Yes |  distname  |
    |  severity | No |  default 1  |
    |  sourceType | No |  default 1  |
    |  extraInfo | No |  default "57360"  |
    |  recoveryOverride | No |  default 1 |

    *RETURN VALUE*
     None

    Example
    |  generate_alarm_post_request_command     |  "9000"   "1"   "MRBTS-5471/NRBTS-5471/NRCELL-1" |
    """
    source = source.replace("/", r"\/")
    var_list = ["curl", "--request POST", "--url http://oam-faultmanagement:9004/api/fm/v1/faults",
                "--header 'content-type: application/json'", "--data "]
    a = ' '
    command_template_content_0 = a.join(var_list)

    contents = [("faultId", faultid),
                ("state", state),
                ("severity", severity),
                ("source", '"'+source+'"'),
                ("sourceType", sourcetype),
                ("extraInfo", '"'+extrainfo+'"'),
                ("recoveryOverride", recoveryoverride), ]

    command_template_content_1 = '{'
    for i in range(0, len(contents)):
        content = contents[i]
        command_template_content_1 = command_template_content_1 + '"' + content[0] + '"' + ':' + content[1]
        if i != len(contents) - 1:
            command_template_content_1 += ','
    command_template_content_1 += '}'
    command_template_content_1 = command_template_content_1.replace('\"', '\\"')
    command_template_content = command_template_content_0+'"'+command_template_content_1+'"'
    return command_template_content


def _get_mo_diff_deep_from_pm_report_xml(file_name):
    dn_list = []
    root = etree.parse(file_name).getroot()
    for pmmo in root.iter('PMMOResult'):
        mo = pmmo.find('MO')
        dn_list.append(mo.find('DN').text.strip())
    if len(dn_list) < 2:
        return -1
    dn_1 = dn_list[0].split('/')
    dn_2 = dn_list[1].split('/')
    for a, b in zip(dn_1, dn_2):
        if a != b:
            return dn_1.index(a)


def parse_pm_result_xml_file(file_name):
    """This keyword is used to parse the pm report xml file.
    *AUTHOR* calla.wang@nokia-sbell.com
    *Modified by calla* <2022-01-07> get dn difference because some measurements dn have the same last element.
    *Modified bu r3li* <2022-01-21> support the situation of xml file only has one "PMMOResult" node
    | Input Parameters | Man. | Description |
    |  file_name | Yes | the report xml file absolute path  |

    *RETURN VALUE*
    the dict of all the counters value, like {'NRCELL-1': {'M55300C00000': '0',
                                                           'M55300C00001': '0',
                                                           'M55300C00002': '0'},
                                              'NRCELL-2': {'M55300C00000': '0',
                                                           'M55300C00001': '0',
                                                           'M55300C00002': '0'}
                                              }

    Example
    | parse_pm_result_xml_file | /home/ute/TESTCASE__PM/2021_01_13_11_37_54/pm_related/x:9.xml |
    """
    counter_values_all_mo = {}

    dn_diff_deep = _get_mo_diff_deep_from_pm_report_xml(file_name)
    root = etree.parse(file_name).getroot()
    for pmmo in root.iter('PMMOResult'):
        counter_values_one_mo = {}
        mo = pmmo.find('MO')
        if dn_diff_deep < 0:
            dn = mo.find('DN').text.strip().split('/')[-1]
        else:
            dn = '/'.join(mo.find('DN').text.strip().split('/')[dn_diff_deep:])
        pmtarget = pmmo.find('PMTarget')
        for counter in pmtarget:
            counter_values_one_mo[counter.tag] = counter.text.strip()
        counter_values_all_mo[dn] = counter_values_one_mo
    return counter_values_all_mo


def get_time_interval_of_two_msgs(file_path, pattern_1, index_1, pattern_2, index_2):
    """
    This keyword is used to get time interval for 2 messages.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  file_path  | Yes |  Log path |
    |  pattern_1 | Yes |  Regex pattern for message 1 to match in file |
    |  index_1 | Yes |  0 means get the first matched message, -1 means get the last matched massage |
    |  pattern_2 | Yes | Regex pattern for message 2 to match in file |
    |  index_2 | Yes | 0 means get the first matched message, -1 means get the last matched massage |

    *RETURN VALUE*
    Message 2 time subtracts message 1, return time is in seconds

    Example
    | ${interval} = | get_time_interval_of_two_msgs | /tmp/1.log | \\[mcu.rap02\\] | 0 | /localCell/\\d+s* | 0 |

    """
    time_1 = get_timestamp_from_log(file_path, pattern_1, index_1)
    logger.info(time_1)
    time_2 = get_timestamp_from_log(file_path, pattern_2, index_2)
    logger.info(time_2)
    if time_1 and time_2 and "-" in time_1 and "-" in time_2:
        return get_time_interval_1(time_1, time_2)
    elif time_1 and time_2 and "-" in time_1 and "-" not in time_2:
        return get_time_interval_3(time_2, time_1)
    elif time_1 and time_2 and "-" not in time_1 and "-" in time_2:
        return get_time_interval_3(time_1, time_2)
    elif time_1 and time_2 and "-" not in time_1 and "-" not in time_2:
        return get_time_interval_2(time_1, time_2)
    else:
        return None


def get_measurement_report_stop_time(start, interval):
    """
        this keyword is used to get the interval stop time base on start
        time, the minutes part shall as '0', '5' suffix. for example, if start time is
        2009-06-06T13:30:33.3428342+08:00, and interval is 5, the result is
        2009-06-06T13:35:33.3428342+08:00.

        *AUTHOR*: calla.wang@nokia-sbell.com

        | Parameters | Man. | Description                                                     |
        | start      | Yes  | Specify the start time in 2009-06-06T13:35:00.000+08:00 format. |
        | interval   | Yes  | Specify the interval time in minutes.                           |

        *RETRUN VALUE*
        | Return Value | The tidied time base on start time and interval |

        *EXAMPLE*
        | get_measurement_report_stop_time | ${start} | ${interval} |
        """

    if len(start) != 29:
        return

    # Get the components of the start time
    year = start[0:4]
    month = start[5:7]
    day = start[8:10]
    hour = start[11:13]
    min = start[14:16]
    sec = start[17:19]
    other = start[19:]

    # Caculate the time.
    d = datetime.datetime(int(year),
                          int(month),
                          int(day),
                          int(hour),
                          int(min),
                          int(sec))
    d1 = d + datetime.timedelta(minutes=int(interval))

    # Generate the time in specific format.
    ret = "{:0>4d}-{:0>2d}-{:0>2d}T{:0>2d}:{:0>2d}:{:0>2d}{}".format(d1.year, d1.month,
                                                                     d1.day, d1.hour,
                                                                     d1.minute, d1.second,
                                                                     other)

    return ret.strip()


def _time_format_change(s_time):
    """
    this keyword is used to format time change.
    #COMMAND:

    *AUTHOR*: calla.wang@nokia-sbell.com

    | Parameters | Man. | Description                                                     |
    | time       | yes  | old time                                                        |

    *RETRUN VALUE*
    | Return Value | new format time                                                      |

    *EXAMPLE*
    | _time_format_change |
    """
    if s_time is None:
        return None
    li = s_time.split(":")
    s_li = li[0].split("-")
    YYYY = s_li[0]
    MM = s_li[1]
    s_s_li = s_li[2].split("T")
    DD = s_s_li[0]
    hh = s_s_li[1]
    mm = li[1]
    zone = li[2][6:]+li[3]
    ret_time = YYYY+MM+DD+"."+hh+mm+zone
    return ret_time


def measurement_file_name_gen(start, stop, file_suffix, f_type='A'):
    """
    this keyword is used to generate the measurement result file name, the measurement result name
    includes the file name type, period start time, period end time, NE name etc.
    Arguement @period_begin shall in format as YYYY-MM-DDThh:mm:ss.000+(/-)mm:ss,
    e.g. 2021-06-01T11:25:00.000+08:00
    The Details please refer to PM9 UG Result file naming section.
    #COMMAND:

    *AUTHOR*: calla.wang@nokia-sbell.com

    | Parameters | Man. | Description                                                     |
    | start      | Yes  | Point out which period the statistic result file belongs to.        |
    | stop       | Yes  | Point out the Granularity Period End Time, format like period_begin |
    | file_suffix | Yes | report file suffix |
    | f_type     | Yes  | Point out the file type: A, B, C or D                               |

    *RETRUN VALUE*
    | Return Value | Measurement Report File Name |

    """

    fmt_start = _time_format_change(start)
    fmt_stop = _time_format_change(stop)

    """The format is:
    <Type><Startdate>.<Starttime>-[<Enddate>].<Endtime>_[<UniqueId][:<RC>]
    """
    file_name = "{}{}-{}_{}".format(f_type.strip(), fmt_start.strip(), fmt_stop.strip(),
                                    file_suffix.strip())
    return file_name.strip()


def get_parameter_sum_from_dcap_log(log_path, data_type, parameter, crnti=None):
    sum = 0
    crnti_flag = False
    data_type_flag = False
    parameter_flag = False
    with open(log_path, 'r') as f:
        for i in f:
            if crnti_flag and data_type_flag and parameter_flag:
                crnti_flag = False
                data_type_flag = False
                parameter_flag = False
            if not crnti_flag:
                if not crnti or (crnti and str(crnti) in i):
                    crnti_flag = True
                    continue
            else:
                if not data_type_flag:
                    if data_type in i:
                        data_type_flag = True
                        continue
                else:
                    if parameter in i:
                        parameter_flag = True
                        res = i.strip()
                        res2 = res.strip(',').split()
                        if len(res2) == 2:
                            sum = sum + int(res2[-1])
    return sum


def count_string_in_list(list_info, string_info):
    flag = 0
    for info in list_info:
        if info.find(string_info) >= 0:
            flag += 1
    return flag


def check_ip_type(ip):
    matches = re.match("((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}", ip)
    if matches is not None:
        return "ipv4"
    else:
        return "ipv6"


def get_info_from_file_with_re(file_path, re_pattern, is_the_last=False):
    with open(file_path, 'r') as fp:
        info = fp.read()
    if not is_the_last:
        match_info = re.search(re_pattern, info)
        return match_info.group()
    else:
        match_info = re.findall(re_pattern, info)
        return match_info[-1]


def is_iptables_exist(content):
    if "anywhere" in content:
        return True
    else:
        return False


def parse_snapshot_file_list(snapshot_dir):
    """
    Parse the snapshot_file_list.txt to get the parent zip file and the sub-files in it.

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param str snapshot_dir: snapshot directory in UTE, like /home/ute/snapshot
    :return: dict of file content, like
    {'MRBTS-10776_metadata.txt': [],
     'MRBTS-10776_E044_part_1.zip:': ['MRBTS-10776_E042_runtime_cpidInfo.log',
                                      'MRBTS-10776_E046_runtime_cpidInfo.log',
                                      'MRBTS-10776_E048_runtime_cpidInfo.log',
                                      'MRBTS-10776_E047_runtime_cpidInfo.log',
                                      'MRBTS-10776_E020_runtime_cpidInfo.log',
                                      'MRBTS-10776_E045_runtime_cpidInfo.log'
                                      ]
    }
    """
    if not os.path.isdir(snapshot_dir):
        raise Exception('snapshot file list not exist!')
    cont = {}
    flag = False
    value_list = []
    snapshot_list_file = os.path.join(snapshot_dir, 'snapshot_file_list.txt')
    with open(snapshot_list_file, 'r') as f:
        for line in f.readlines():
            if not len(line.strip()):
                continue
            if line.startswith('\t') or line.startswith(' '):
                value_list.append(line.strip())
            else:
                if flag:
                    cont[key] = value_list
                key = line.strip().strip(':')
                flag = True
                value_list = []
        if flag:
            cont[key] = value_list
    return cont


def get_specific_snapshot_parent_zip_files_name_list(filename_part, snapshot_dir):
    """
    Get the parent zip file name in which the specific snapshot log is contained.

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param str filename_part: specific snapshot log part name, like 'pm9_rad_counters'
    :param snapshot_dir: snapshot directory in UTE, like '/home/ute/snapshot'
    :return list: zip file name list, like ['MRBTS-10776_E044_part_3.zip', 'MRBTS-10776_E044_part_12.zip']
    """
    specific_zip_list = []
    snapshot_list_cont = parse_snapshot_file_list(snapshot_dir)
    for parent_file, snapshot_files in snapshot_list_cont.items():
        if snapshot_files:
            for file_name in snapshot_files:
                if file_name.find(filename_part) > -1:
                    specific_zip_list.append(parent_file)
                    break
    if not specific_zip_list:
        raise Exception('cannot find the expected snapshot file!')
    return specific_zip_list


def get_specific_snapshot_log_file_object(parent_zip_files, filename_part, snapshot_dir):
    """
    This keyword will get the specific snapshot log file object.

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param list parent_zip_files: the zip file name list that contain the specific snapshot log,
                                  like ['MRBTS-10776_E044_part_3.zip', 'MRBTS-10776_E044_part_12.zip']
    :param str filename_part: specific snapshot log part name, like 'pm9_rad_counters'
    :param str snapshot_dir: snapshot directory in UTE, like '/home/ute/snapshot'
    :return list: list of snapshot file-like object that contains the expected log type,
                  like [<_io.BytesIO object at 0x7ffbb57cb590>, <_io.BytesIO object at 0x7ffbb57cb456>]
    """
    wanted_snapshot_logs_object = []

    # zip_list = get_specific_snapshot_parent_zip_files_name_list(filename_part, snapshot_dir)
    for zip_file in parent_zip_files:
        with ZipFile(os.path.join(snapshot_dir, zip_file)) as snapshot_zipfile:
            for name in snapshot_zipfile.namelist():
                if filename_part in name:
                    file = BytesIO(snapshot_zipfile.read(name))
                    wanted_snapshot_logs_object.append(file)
    return wanted_snapshot_logs_object


def get_latest_pm_counter_value_from_snapshot(snapshot_dir, filename_part, measurement_id):
    """
    This keyword will get all of the latest counters value in one measurement from snapshot.
    By now, the pm counters snapshot is compressed as zip file, so only decompress zip file in this keywords.
    There is a limitation that only supporting one pm zip file to decompress and get counters value because normally,
    only one pm report satisfied the filter condition.

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param str snapshot_dir: snapshot file directory, like /home/ute/snapshot
    :param str filename_part: the part name of one snapshot file, like 'pm9_counters'
    :param str measurement_id: measurement id that counters belong to, like '55603'
    :return: dict of the counters value
    """
    parent_zip_files = get_specific_snapshot_parent_zip_files_name_list(filename_part, snapshot_dir)
    expected_snapshot_obj_list = get_specific_snapshot_log_file_object(parent_zip_files, filename_part, snapshot_dir)
    pm_parent_zip_file = parent_zip_files[0]
    pm_snapshot_file_obj = expected_snapshot_obj_list[0]
    decompress_dir = os.path.join(snapshot_dir, pm_parent_zip_file.strip('.zip'))
    if os.path.isdir(decompress_dir):
        pass
    else:
        os.mkdir(decompress_dir)
    logging.info("The specific snapshot is decompressed to {}".format(decompress_dir))
    un_zip(src_file=pm_snapshot_file_obj, dst_dir=decompress_dir)
    result_mapping = get_pm_result_mapping_content(decompress_dir)
    latest_pm_report_file = result_mapping[measurement_id]['filenames'][0]
    pm_xml_report_file = un_gz(os.path.join(decompress_dir, latest_pm_report_file))
    pm_report_content = parse_pm_result_xml_file(pm_xml_report_file)
    return pm_report_content


def un_gz(input_file_path):
    """
    Decompressing .gz file to the same directory as the gz file.
    The file name after decompressed is the source file name stripped '.gz'

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param str input_file_path: file path needs to be decompressed,
                                like '/home/ute/snapshot/MRBTS-10776_E044_part_20/A2022xx-2022xx_-:32.xml.gz'
    :return str: the file path after decompressed,
                 like /home/ute/snapshot/MRBTS-10776_E044_part_20/A20220104.0945+0000-20220104.1000+0000_-:32.xml
    """
    g_file = gzip.GzipFile(input_file_path, "rb+")
    # s = g_file.read()
    # g_file.close()
    output_file_path = input_file_path.replace(".gz", "")
    with open(output_file_path, "wb+") as output:
        output.write(g_file.read())
    g_file.close()
    return output_file_path


def un_zip(src_file, dst_dir, password=None):
    """
    Decompress zip file.

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param str or file-like object src_file: source file path or file-like object,
                                             like /home/ute/snapshot/MRBTS-10776_E044_part_20.zip
    :param str dst_dir: the destination directory.
    :param str password: unzip password, default is None.
    :return: None
    """
    with ZipFile(src_file) as pm_zip:
        pm_zip.extractall(path=dst_dir, pwd=password)


def get_pm_result_mapping_content(file_dir):
    """
    Get the content of resultMapping.json.

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param str file_dir: the directory that resultMapping.json located.
    :return dict: the dict of the resultMapping.json content.
    """
    with open(os.path.join(file_dir, 'resultMapping.json'), 'rb+') as f:
        result_mapping = json.load(f)
    return result_mapping


def get_unique_id(prefix="", suffix="", precise="HIGH"):
    """This function is used to get unique id, came from robot KW

    *AUTHOR* chris.l.cao@nokia-sbell.com,

    *History Change*:
    | date | who | what and how |
    | 2021-11-28 | chris.l.cao@nokia-sbell.com | convert robot KW to python KW |
    | 2022-3-31 | r3li | update documentation |

    *Parameter Description*
    | Input Parameters | Man. | Description |
    | prefix       | no | prefix, default is empty |
    | suffix       | no | suffix, default is empty |
    | precise      | no | precise, HIGH or LOW or FORMAT_DATETIME or HIGH_WITH_FORMAT_DATETIME_EPOCH, default is HIGH |

    precise clear: If precise is HIGH, will return a random string, which including string and number;
    If precise is LOW, will return a random string, which only including number;
    If precise is FORMAT_DATETIME, will return time string;
    If precise is HIGH_WITH_FORMAT_DATETIME_EPOCH, will return a string including random char and time sting.

    *RETURN VALUE*
    - unique_id

    Example:
    | ${tmp_id} | Get Unique ID |
    | ${tmp_id} | Get Unique ID | prefix=myprefix |
    | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    | ${tmp_id} | Get Unique ID | precise=HIGH |
    | ${tmp_id} | Get Unique ID | precise=LOW |
    | ${tmp_id} | Get Unique ID | precise=FORMAT_DATETIME |
   | ${tmp_id} | Get Unique ID | precise=HIGH_WITH_FORMAT_DATETIME_EPOCH |
    """
    precise = precise.upper()
    if precise == "HIGH":
        rtn = _get_Unique_id_high_precise(prefix, suffix)
    elif (precise == "LOW"):
        rtn = _get_Unique_id_low_precise(prefix, suffix)
    elif (precise == "FORMAT_DATETIME"):
        rtn = _get_Unique_id_datetime_precise(prefix, suffix)
    elif (precise == "HIGH_WITH_FORMAT_DATETIME_EPOCH"):
        rtn = _get_Unique_id_datetime_precise_epoch(prefix, suffix)
    else:
        raise RuntimeError("Unknown precise:{}!!".format(precise))
    return rtn


def _get_Unique_id_high_precise(prefix="", suffix=""):
    rtn = str(uuid.uuid4())
    rtn = rtn.replace('-', '')
    rtn = "{}{}{}".format(prefix, rtn, suffix)
    return rtn


def _get_Unique_id_low_precise(prefix="", suffix=""):
    rtn = str(time.time())
    rtn = rtn.replace('.', '')
    rtn = "{}{}{}".format(prefix, rtn, suffix)
    return rtn


def _get_Unique_id_datetime_precise(prefix="", suffix=""):
    unique_id_part1 = time.strftime("%Y%m%d_%H%M%S", time.localtime())

    unique_id_part2 = str(time.time())
    unique_id_part2 = unique_id_part2.split(".")[-1]

    unique_id = "{}_{}".format(unique_id_part1, unique_id_part2)
    rtn = "{}{}{}".format(prefix, unique_id, suffix)
    return rtn


def _get_Unique_id_datetime_precise_epoch(prefix="", suffix=""):
    unique_id_part1 = str(uuid.uuid4())
    unique_id_part1 = unique_id_part1.replace('-', '')

    unique_id_part2 = time.strftime("%Y%m%d_%H%M%S", time.localtime())

    unique_id = "{}_{}".format(unique_id_part1, unique_id_part2)

    rtn = "{}{}{}".format(prefix, unique_id, suffix)
    return rtn


def strip_prompt(content, remove_last_line=True, remove_first_line=True, return_list=False):
    """
    [Documentation]  Strip Prompt
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...   26.12.2023,lingting.sun@nokia-sbell.com, adaption for different CU OCP version
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | content          | yes | content |
    ...	   | remove_last_line | no | remove_last_line, default is True, type is bool |
    ...	   | remove_first_line | no | remove_first_line, default is True, type is bool |
    ...	   | return_list      | no | return_list, default is False, type is bool |
    ...
    ...    *RETURN VALUE*
    ...    string or list
    ...
    ...    Example
    ...    | ${my_content} | Strip Prompt | aaaaa\nbbbb\nccccc |
    ...
    """
    lines = [i.strip() for i in content.split('\n')]
    length = len(lines)
    if length >= 1 and remove_last_line:
        lines.pop(-1)

    if length > 2 and remove_first_line:
        lines.pop(0)

    if return_list is True:
        return lines
    return "\n".join(lines)


def get_k8s_admin_ssh_connection_info(gnb_index=0, vdu_index=0):
    """
    Get K8s Admin SSH Connection Info
    *Author*: chris.l.cao@nokia-sbell.com

    *History Change*:
    | date | who | what and how |
    | 11.12.2021 |chris.l.cao@nokia-sbell.com | convert robot KW to python KW |

    *Argument Description*
    | Input Parameters | Man. | Description |
    | gnb_index | no | gnb_index, default is 0 |
    | vdu_index | no | vdu_index, default is 0 |

    *RETURN VALUE*
    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py,
           dictionary keys are addr, username, password and port.
    example: {'addr': '1.1.1.1', 'username': 'cloudadmin', 'password': 'system123', 'port': 22}

    *Example*
    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Admin SSH Connection Info |
    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Admin SSH Connection Info | vdu_index=1 |

    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}}".\
        format(gnb_index, vdu_index)
    addr = builtin_obj.get_variable_value(value)
    print(addr)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}}".\
        format(gnb_index, vdu_index)
    username = builtin_obj.get_variable_value(value)
    print(username)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}}".\
        format(gnb_index, vdu_index)
    password = builtin_obj.get_variable_value(value)
    print(password)

    port = "22"

    rtn = {
        "addr": addr,
        "username": username,
        "password": password,
        "port": port,
    }

    return rtn


def get_k8s_tenant_ssh_connection_info(gnb_index=0, vdu_index=0):
    """
    Get K8s Tenant SSH Connection Info
    *Author*: lingting.sun@nokia-sbell.com

    *History Change*:
    | date | who | what and how |
    | 06.05.2022 |lingting.sun@nokia-sbell.com | initial created |

    *Argument Description*
    | Input Parameters | Man. | Description |
    | gnb_index | no | gnb_index, default is 0 |
    | vdu_index | no | vdu_index, default is 0 |

    *RETURN VALUE*
    Dictionary of OE server K8s Master Tenant SSH Connection Info defined in __init__.py,
           dictionary keys are addr, username, password and port.
    example: {'addr': '1.1.1.1', 'username': 'cranuser1', 'password': 'system123', 'port': 22}

    *Example*
    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Tenant SSH Connection Info |
    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Tenant SSH Connection Info | vdu_index=1 |

    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}}".\
        format(gnb_index, vdu_index)
    addr = builtin_obj.get_variable_value(value)
    print(addr)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}}".\
        format(gnb_index, vdu_index)
    username = builtin_obj.get_variable_value(value)
    print(username)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}}".\
        format(gnb_index, vdu_index)
    password = builtin_obj.get_variable_value(value)
    print(password)

    port = "22"

    rtn = {
        "addr": addr,
        "username": username,
        "password": password,
        "port": port,
    }

    return rtn


def get_cu_namespace_from_testline(gnb_index=0):
    """
    [Documentation]    get cu namespace from testline
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...  history change:
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  27.11.2021,chris.l.cao@nokia-sbell.com, add support to VCU NCIR
    ...  28.1.2022,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...   *RETURN VALUE*
    ...   namespace for CNF, tenant name for VNF
    ...
    """
    gnb_index = int(gnb_index)

    builtin_obj = BuiltIn()
    cnf = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.namespace}}".format(gnb_index)
    vnf = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.username}}".\
        format(gnb_index)
    ns = builtin_obj.get_variable_value(cnf)
    if ns is None:
        print("It's VNF.")
        ns = builtin_obj.get_variable_value(vnf)
    return ns


def get_vcu_k8s_admin_ssh_connection_info(gnb_index=0):
    """
    [Documentation]  Get VCU K8s Admin SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py,
    ...                    dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cbis-admin', 'password': 'systeM!23', 'port': 22}
      ...
    ...    Example
    ...    | ${vcu_k8s_master_ssh_connection_info} | Get VCU K8s Admin SSH Connection Info |
    ...    | ${vcu_k8s_master_ssh_connection_info} | Get VCU K8s Admin SSH Connection Info | gnb_index=1 |
    ...
    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}}".\
        format(gnb_index)
    addr = builtin_obj.get_variable_value(value)
    print("vcu ssh addr:{}".format(addr))

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}}".\
        format(gnb_index)
    username = builtin_obj.get_variable_value(value)
    print("vcu ssh username:{}".format(username))

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}}".\
        format(gnb_index)
    password = builtin_obj.get_variable_value(value)
    print("vcu ssh password:{}".format(password))

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}}".\
        format(gnb_index)
    port = builtin_obj.get_variable_value(value)
    print("vcu ssh port:{}".format(port))

    rtn = {
        "addr": addr,
        "username": username,
        "password": password,
        "port": port,
    }

    return rtn


def fast_connect_to_cu_k8s_master_with_admin(gnb_index=0):
    """
    [Documentation]   fast_connect_to_cu_k8s_master_with_admin
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   28.1.2022,chris.l.cao@nokia-sbell.com, initialization version
    ...   18.7.2022,chris.l.cao@nokia-sbell.com, support cranuserXXX prompt
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${alias} | fast_connect_to_cu_k8s_master_with_admin |
    ...    | ${out} | fast_execute_cu  | command=kubectl get pod | alias=${alias} |
    ...    | ${out} | fast_execute_cu  | command=ls -l | alias=${alias} | namespace=${False} |
    ...    | fast_disconnect | alias=${alias} |
    """
    gnb_index = int(gnb_index)

    vcu_ssh_info = get_vcu_k8s_admin_ssh_connection_info(gnb_index=gnb_index)
    ip = vcu_ssh_info["addr"]
    username = vcu_ssh_info["username"]
    password = vcu_ssh_info["password"]

    print(ip)
    print(username)
    print(password)

    # prompt = "\\[core@\\S+\\s\\S+\\]\\$"
    prompt = "\\[core@\\S+\\s\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s\\S+\\]\\$"
    alias = get_unique_id()
    issh_cli.connect_to(
        ip=ip, username=username, password=password, prompt=prompt, width=200, timeout=150, alias=alias)
    return alias


def fast_execute_cu(
        command="ls -l", with_pipeline_command="", check_result=True, gnb_index=0,
        alias="default", remove_first_line=True, remove_last_line=True, use_namespace=True):
    """
    [Documentation]   fast_execute_cu
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   28.1.2022,chris.l.cao@nokia-sbell.com, initialization version

    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | command    |  no  | command, e.,g ls -l|
    ...    | with_pipeline_command | no | with_pipeline_command, e.g '|wc -l' |
    ...    | check_result | no  | check_result, if true will check linux execution result, if false will not check |
    ...    |   |    | default is True |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...    | remove_first_line  |  no  | remove_first_line, default is true |
    ...    | remove_last_line  |  no  | remove_last_line, default is true |
    ...    | use_namespace     |  no  | use namespace, default is true |
    ...
    ...    *RETURN VALUE*
    ...    Command execution result.
    ...
    ...    Example
    ...    | ${alias} | fast_connect_to_cu_k8s_master_with_admin |
    ...    | ${out} | fast_execute_cu  | command=kubectl get pod | alias=${alias} |
    ...    | ${out} | fast_execute_cu  |  command=ls -l | alias=${alias} | use_namespace=${False} |
    ...    | fast_disconnect | alias=${alias} |
    """
    ns = get_cu_namespace_from_testline(gnb_index=gnb_index)
    if use_namespace:
        new_command = "{} -n {} {}".format(command, ns, with_pipeline_command)
    else:
        new_command = "{}  {}".format(command, with_pipeline_command)
    out = issh_cli.execute(command=new_command, alias=alias, check_result=check_result)
    out = strip_prompt(out, remove_first_line=remove_first_line, remove_last_line=remove_last_line)

    return out


def get_app_server_info(ue_index=0):
    """
    [Documentation]      Get App Server Info
    ...  author:  chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index  |  no | ue_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    app server information, e.g, {'address': '10.108.229.222', 'user': 'ute', 'password': 'ute'}
    ...
    ...    Example
    ...    | ${app_server_info} | Get App Server Info |
    ...    | ${app_server_info} | Get App Server Info | ue_index=1 |
    """

    builtin_obj = BuiltIn()
    ue_index = int(ue_index)

    pattern = "${{tl.ues[{}]}}".format(ue_index)
    ue_info = builtin_obj.get_variable_value(pattern)

    rtn = {}
    if ue_info.__class__.__name__ == "TafUeAndroid":
        app_server = ue_info.data_transfer[0].app_server
        address = app_server.address
        user = app_server.user
        password = app_server.password
        rtn = {
            "address": address,
            "user": user,
            "password": password,
        }

    return rtn


def get_fhgw_extra_config_yaml_from_testLine(gnb_index=0, vdu_index=0, fhgw_index=0):
    """
    [Documentation]  Get FHGW Extra Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of FHGW extra configuration
    ...
    ...    Example
    ...    | ${yaml_file}     | Get FHGW Extra Config Yaml From TestLine |
    ...
    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)
    fhgw_index = int(fhgw_index)

    value = "${{tl.gnbs[{}].cloud_deployment.default_cfg_dir}}".format(gnb_index)
    default_cfg_dir = builtin_obj.get_variable_value(value)
    yaml_file_name = os.path.join(default_cfg_dir, "DEP_SCF_FILES", "CU_{}".format(gnb_index),
                                  "vDU_{}".format(vdu_index), "FHGW_{}".format(fhgw_index),
                                  "fhgw_extra_config.yaml")
    return yaml_file_name


def get_fhgw_extra_config_dictionary_from_testLine(gnb_index=0, vdu_index=0, fhgw_index=0):
    """
    [Documentation]   Get FHGW Extra Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of fhgw_extra_config_0 . If there is no this file, return {}
    ...
    ...    Example
    ...    | ${conf_dict}     | Get FHGW Extra Config Dictionary From TestLine |
    ...
    """
    yaml_file_name = get_fhgw_extra_config_yaml_from_testLine(gnb_index=gnb_index, vdu_index=vdu_index,
                                                              fhgw_index=fhgw_index)

    dictionary_content = yaml_file_to_dictionary(yaml_file_name)
    pprint(dictionary_content)

    return dictionary_content


def get_fhgw_major_version(gnb_index=0, vdu_index=0, fhgw_index=0):
    """
    [Documentation]   Get FHGW Major Version
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   FHGW Major Version, type is string, e.g, FHGW21A or FHGW21B or FHGW22R1
    ...
    ...    Example
    ...   | ${fhgw_major_version} | Get FHGW Major Version |
    ...
    """
    fhgw_extra_conf_dict = get_fhgw_extra_config_dictionary_from_testLine(
        gnb_index=gnb_index, vdu_index=vdu_index, fhgw_index=fhgw_index)
    fhgw_major_version = fhgw_extra_conf_dict["fhgw_release_branch"]
    print("FHGW major version:{}".format(fhgw_major_version))
    return fhgw_major_version


def fast_connect_to_k8s_master(gnb_index=0, vdu_index=0, alias="default"):
    """
     Connect To K8s Master Interactively In Python
     *AUTHOR* chris.l.cao@nokia-sbell.com
     *History Change*:
     | date | who | what and how |
     | 8.12.2021 | chris.l.cao@nokia-sbell.com | initialization version |
     *Argument Description*
     |  Input Parameters | Man. | Description |
     | gnb_index  |  no  | gnb index, default is 0 |
     | vdu_index  |  no  | VDU index, default is 0 |
     | alias      | no   | alias, default value is default |
     *RETURN VALUE*
     None.
     *Example*
    | fast_connect_to_k8s_master |
    | ${out} | fast_execute  | command=ls -l |
    | fast_disconnect |
    | ${alias} | Get Unique Id |
    | fast_connect_to_k8s_master  | alias=${alias} |
    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    | fast_disconnect | alias=${alias} |
    """
    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    vdu_http_info = get_k8s_tenant_ssh_connection_info(gnb_index=gnb_index, vdu_index=vdu_index)
    ip = vdu_http_info["addr"]
    username = vdu_http_info["username"]
    password = vdu_http_info["password"]

    print(ip)
    print(username)
    print(password)

    prompt = "\\[core@\\S+\\s\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$"
    issh_cli.connect_to(
        ip=ip, username=username, password=password, prompt=prompt, width=200, timeout=150, alias=alias)


def fast_disconnect(alias="default"):
    """
    [Documentation]   fast_disconnect
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   8.12.2021,chris.l.cao@nokia-sbell.com, initialization version

    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | fast_connect_to_k8s_master |
    ...    | ${out} | fast_execute  | command=ls -l |
    ...    | fast_disconnect |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | fast_connect_to_k8s_master  | alias=${alias} |
    ...    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    ...    | fast_disconnect | alias=${alias} |
    """
    issh_cli.disconnect(alias=alias)


def fast_disconnect_all():
    """
    [Documentation]   fast_disconnect_all
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   8.12.2021,chris.l.cao@nokia-sbell.com, initialization version

    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | fast_connect_to_k8s_master |
    ...    | ${out} | fast_execute  | command=ls -l |
    ...    | fast_disconnect_all |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | fast_connect_to_k8s_master  | alias=${alias} |
    ...    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    ...    | fast_disconnect_all | |
    """
    issh_cli.disconnect(alias=None)


def get_vdu_namespace_from_testline(gnb_index=0, vdu_index=0):
    """
    [Documentation]  get vdu namespace from testline in init.py file
    ...  return the value correct get from TL
    ...  author: jianlin.zhang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu index | Yes. | the vdu index config on TL |
    ...    *RETURN VALUE*
    ...    namespace
    ...
    ...   Example
    ...  | ${ns} |  Get VDU Namespace From TestLine |
    """
    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    builtin_obj = BuiltIn()
    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.namespace}}".\
        format(gnb_index, vdu_index)
    ns = builtin_obj.get_variable_value(value)
    return ns


def fast_execute(command="ls -l", with_pipeline_command="", check_result=True, gnb_index=0,
                 vdu_index=0, alias="default", remove_first_line=True, remove_last_line=True):
    """
    [Documentation]   fast_execute
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   8.12.2022,chris.l.cao@nokia-sbell.com, initialization version

    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | command    |  no  | command, e.,g ls -l|
    ...    | with_pipeline_command | no | with_pipeline_command, e.g '|wc -l' |
    ...    | check_result | no  | check_result, if true will check linux execution result, if false will not check |
    ...    |   |    | default is True |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...    | remove_first_line  |  no  | remove_first_line, default is true |
    ...    | remove_last_line  |  no  | remove_last_line, default is true |
    ...
    ...    *RETURN VALUE*
    ...    Command execution result.
    ...
    ...    Example
    ...    | fast_connect_to_k8s_master |
    ...    | ${out} | fast_execute  | command=ls -l |
    ...    | fast_disconnect |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | fast_connect_to_k8s_master  | alias=${alias} |
    ...    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    ...    | fast_disconnect | alias=${alias} |
    """
    ns = "cran1"
    new_command = "{} -n {} {}".format(command, ns, with_pipeline_command)
    out = issh_cli.execute(command=new_command, alias=alias, check_result=check_result)
    out = strip_prompt(out, remove_first_line=remove_first_line, remove_last_line=remove_last_line)

    return out


def set_to_multiple_dictionary(ori_dict, key_str, set_value, separator='.'):
    """
    - set to multiple dictionary
    Author: rui.3.li@nokia-sbell.com
    Args:
        - ori_dict: the dictionary of modified
        - key_str:  muiltiple key conbined a string, such as "parameters.vim_details.kubeconfig"
        - set_value: set value
    Example:
        | dict_info = {a:{b:{c:{d:e}}}} |
        | set_to_multiple_dictionary | dict_info | a.b.c.d | f | . |
        | print dict_info value is {a:{b:{c:{d:f}}}} |
    """
    key_list = key_str.split(separator)
    if len(key_list) <= 1:
        ori_dict[key_list[0]] = set_value
        return
    else:
        dict_info = ori_dict[key_list[0]]
        set_to_multiple_dictionary(dict_info, separator.join(key_list[1:]), set_value, separator)


def get_rf_infos_by_rf_model(rf_infos_list, rf_model):
    print(rf_infos_list)
    for rf_info in rf_infos_list:
        if rf_model in rf_info["model"]:
            return rf_info["type"],  rf_info["username"],  rf_info["password"],  rf_info["2nduser"], \
                   rf_info["atten"], rf_info["rf_local_ip"],  rf_info["prompt"],


def get_rf_info_list_by_rf_type(rf_infos_list, rf_type):
    rf_info_list_new = []
    for rf_info in rf_infos_list:
        if rf_info["type"] == rf_type:
            rf_info_list_new.append(rf_info)
    return rf_info_list_new


def encode_base64(ori_info):
    """
    - encode base64
    Author: rui.3.li@nokia-sbell.com
    Args:
        - ori_info: original info which need encode to base64
    Example:
        | encode_base64 | info |
    """
    import base64
    base64_info = base64.b64encode(ori_info.encode('utf-8'))
    return base64_info.decode()


def get_rf_sn_from_dhcp_log(sn_info):
    """This keyword is used to get sn
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  sn_info | Yes |  sn_info |

    *RETURN VALUE*
    nrcellid_list

    Example
    |  get_rf_sn_from_dhcp_log    |   30:34:34:35:37,300   |
    """
    result = re.match(r'(\d+:){4}\d+', sn_info)
    if result:
        sn_list = result.group().split(":")
    sn = ""
    for sn_number in sn_list:
        sn = sn + sn_number[-1]
    return sn


def get_nrcellid_list_from_l2_log(log_path):
    """This keyword is used to get nrcell list from l2rt log
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |

    *RETURN VALUE*
    nrcellid_list

    Example
    |  get_nrcellid_list_from_l2_log    |  ${log_dir}l2rt.log    |
    """
    with open(log_path, 'r') as f:
        content = f.read()
    nrcellid_list = re.findall(r'nrCellId\s+\d+', content)
    nrcellid_list = set(nrcellid_list)
    nrcellid_list_clean = []
    for nrcellid_info in nrcellid_list:
        nrcellid = re.findall(r'\d+', nrcellid_info)
        nrcellid_list_clean.append(nrcellid[0])
    return nrcellid_list_clean


def remove_value_info(value, index, split_info):
    """This keyword is used to remove value info
    *AUTHOR* hongyuan.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  value | Yes |  e.g: up-0; up-1; PLMN-PLMN/FHGW-11122/EQM-1/FMOD-1 |
    |  index | Yes |  remove value index |
    |  split_info | Yes |  value split info; e.g: -; / |

    *RETURN VALUE*
    New value after remove

    Example
    |  remove_value_info | value=PLMN-PLMN/FHGW-11122/EQM-1/FMOD-1 | index=-1 | split_info=/ |
    """
    value_list = value.split(split_info)
    value_list.remove(value_list[int(index)])
    value_new = split_info.join(value_list)
    return value_new


def get_info_from_multiple_dictionary(ori_dict, key_str, separator='.'):
    """
    - get info from multiple dictionary
    Author: rui.3.li@nokia-sbell.com
    Args:
        - ori_dict: the dictionary of modified
        - key_str:  muiltiple key conbined a string, such as "parameters.vim_details.kubeconfig"
        - separator: separator
    Example:
        | dict_info = {a:{b:{c:{d:e}}}} |
        | get_info_from_multiple_dictionary | dict_info | a.b.c.d | f | . |
        | print dict_info value is {a:{b:{c:{d:f}}}} |
    """
    key_list = key_str.split(separator)
    value = ori_dict.get(key_list[0])
    if len(key_list) == 1:
        return value
    else:
        key_list.pop(0)
        key_str = separator.join(key_list)
        return get_info_from_multiple_dictionary(value, key_str, separator)


def convert_list(ori_info):
    """
    - convert to list, None and empty string convert to [], string convert to [string], list not convert.
    *Author*: rui.3.li@nokia-sbell.com
    *Change History*
    | date | who | how and what |
    | 20222-4-12 | r3li | init create |
    *Arguments description*
    |  Input Parameters | Man. | Description |
    | ori_info | Yes | original info |
    *Example*
    | convert_to_list | [1, 2, 3] |
    | return | [1, 2, 3] |

    | convert_to_list | None |
    | return | [] |

    | convert_to_list | 1 |
    | return | [1] |
    *Return*
    - list
    """
    if isinstance(ori_info, list):
        return ori_info
    elif ori_info:
        return [ori_info]
    else:
        return []


def reverse_list_value(list_info):
    """reverse list value
    *AUTHOR* hongyuan.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  list_info | Yes | a list |

    *RETURN VALUE*
    reversed list(eg: [1,2,3]-->[3,2,1])

    Example
    |  reverse_list | reverse_list_value | list_info=[1,2,3] |
    """
    list_info.reverse()
    return list_info


def parse_snapshot_doc_index(file_path):
    """parse index.html for snapshot documentation
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  file_path | Yes | the path of index.html |

    *RETURN VALUE*
    the description dir file_name mapping list

    Example
    |  desc_dir_file_list | parse_snapshot_doc_index | /home/ute/SLT/Snapshot_doc/vDU/index.html |
    """
    if os.path.exists(file_path):
        desc_dir_file_list = []
        cache_data = linecache.getlines(file_path)
        for line in range(len(cache_data)):
            if "vCU,vDU" in cache_data[line]:
                if 'description_files' in cache_data[line+8]:
                    path = cache_data[line+8].strip()
                    path = re.sub("<td>|</td>", "", path)
                    file_name = cache_data[line+9].strip()
                    file_name = re.sub("<td>|</td>", "", file_name)
                    path_file_list = [path, file_name]
                    desc_dir_file_list.append(path_file_list)
                elif 'description_files' in cache_data[line+7]:
                    path = cache_data[line + 7].strip()
                    path = re.sub("<td>|</td>", "", path)
                    file_name = cache_data[line + 6].strip()
                    file_name = re.sub("<td>|</td>", "", file_name)
                    path_file_list = [path, file_name]
                    desc_dir_file_list.append(path_file_list)
        return desc_dir_file_list
    else:
        print('the path [{}] is not exist!'.format(file_path))


def check_desc_file_exists_in_snapshot_doc(root, dir, file_name):
    """check the file exists or not in sanpshot accoring to the index.html
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  root | Yes | the path of snapshot doc |
    |  dir  | Yes | the dir get from index.html |
    |  file_name  | Yes | the fiel_name get form index.html|


    *RETURN VALUE*
    True or False

    Example
    |  exsit_status| check_desc_file_exists_in_snapshot_doc | /home/ute/SLT/ |  description/../   |  xxx.txt      |
    """
    complete_dir = root + dir
    for root, dirs, files in os.walk(complete_dir):
        for file in files:
            if file == file_name:
                return True
    return False


def get_value_from_plan_tree_info(info_list, dist_name, key, parent_mo_uuid=''):
    """
    Get Value From Plan Tree Info
    *AUTHOR* rui.3.li@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | dist_name | Yes | Dist Name, like MRBTS-10790/TNLSVC-1/TNL-9 |
    | info_list | Yes | info list get from keyword get_tree_of_current_plan, get_tree_of_delta_plan |
    | key | Yes | what's key you want get from info, like mo_uuid |
    | parent_mo_uuid | No | parent mo uuid, default is EMPTY str |

    *RETURN VALUE*
    value

    Example
    | value | get_value_from_plan_tree_info | tree_info | MRBTS-10790/TNLSVC-1 | mo_uuid |
    """
    dist_name_list = dist_name.split('/')
    if len(dist_name_list) > 1:
        for info in info_list:
            if info['parent_mo_uuid'] is None:
                parent_mo_uuid_in_plan = ''
            else:
                parent_mo_uuid_in_plan = info['parent_mo_uuid']
            if info['name'] == dist_name_list[0] and parent_mo_uuid_in_plan == parent_mo_uuid:
                return get_value_from_plan_tree_info(info_list, '/'.join(dist_name_list[1:]), key, info['mo_uuid'])
        else:
            raise Exception('distName %s not exist, please check.' % dist_name_list[0])
    else:
        for info in info_list:
            if info['parent_mo_uuid'] is None:
                parent_mo_uuid_in_plan = ''
            else:
                parent_mo_uuid_in_plan = info['parent_mo_uuid']
            if info['name'] == dist_name_list[0] and parent_mo_uuid_in_plan == parent_mo_uuid:
                return info[key]
        else:
            raise Exception('distName %s not exist, please check.' % dist_name_list[0])


def get_mac_from_string(content, only_one=False):
    pattern = r'[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}'
    mac_list = re.findall(pattern, content)
    if only_one:
        return mac_list[0]
    return mac_list


def get_mac_ip_list_from_csv_txt(content):
    content = content.strip()
    print(content)
    lines_info = content.split('\n')
    name_info = lines_info[0]
    name_list = name_info.split(',')
    ip_index = -1
    mac_index = -1
    sn_index = -1
    time_index = -1
    for i in range(len(name_list)):
        if name_list[i] == 'address' and ip_index == -1:
            ip_index = i
            continue
        if name_list[i] == 'hwaddr' and mac_index == -1:
            mac_index = i
            continue
        if name_list[i] == 'client_id' and sn_index == -1:
            sn_index = i
            continue
        if name_list[i] == 'expire' and time_index == -1:
            time_index = i
            continue
    if ip_index == -1 or mac_index == -1 or sn_index == -1 or time_index == -1:
        raise Exception('need to adapt due to csv file changed.')
    results = []
    for info in lines_info:
        result = {}
        split_info = info.split(',')
        result['ip'] = split_info[ip_index]
        result['mac'] = split_info[mac_index]
        result['expire'] = split_info[time_index]
        if len(split_info[2]) > 32 and _check_repeat(result, results) == 1:
            result['sn'] = _parse_sn(split_info[sn_index])
            results.append(result)
    return results


def _check_repeat(result, results):
    for r in results:
        if r['mac'] == result['mac']:
            if int(result['expire']) > int(r['expire']):
                results.remove(r)
                return 1  # need append
            else:
                return 0
    return 1


def _parse_sn(sn_info):
    sn_nums = sn_info.split(':')
    sn = ''
    for i in range(len(sn_nums) - 1, len(sn_nums) - 6, -1):
        sn = sn_nums[i][-1] + sn
    return sn


def set_ip_to_rf_info_list(rf_info_list, mac_ip_sn_full_list):
    results = []
    for rf_info in rf_info_list:
        for mac_ip_sn in mac_ip_sn_full_list:
            if mac_ip_sn['sn'][-5:] == rf_info['sn']:
                for key in mac_ip_sn.keys():
                    rf_info[key] = mac_ip_sn[key]
                results.append(rf_info)
    return results


def get_pid_relationship(pid_list):
    result = {}
    for pid_info in pid_list[:-1]:
        tmps = pid_info.split(' ')
        result[tmps[1][8]] = tmps[0]
    return result


def get_container_id_from_info(file_path, container_name):
    with open(file_path) as fp:
        get_info = fp.read()
    info_list = get_info.split('}}}')
    for info in info_list:
        info = info + '}}}'
        if container_name in info:
            infos = info.split(',')
            for i in infos:
                if '"containerID":"cri-o:' in i:
                    return i.split('//')[-1][:13]
    raise Exception('find container id fail.')


def get_core_dump_info(info, start_time):
    """
    Get available coredump info: node, id from koredumpctl list
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | info | Yes | coredump infos via command koredumpctl list |
    | start_time | Yes | the case start time (UTC timestamp), get from ute |

    *RETURN VALUE*
    coredump info list

    Example
    | target_coredump_info_list | get_core_dump_info | - ID: core.PM.9999... |1664177149 |
    """
    available_coredump_info_list = []
    coredump_info_list = info.split("\n- ")
    for coredump_info in coredump_info_list:
        id = re.findall('ID\\:\\s*\\S+\\.zst|ID\\:\\s*\\S+\\.lz4', coredump_info)
        if id:
            id = id[0].strip('ID:').lstrip()
        node = re.findall('Node\\:\\s*\\S+', coredump_info)
        if node:
            node = node[0].strip('Node:').lstrip()
        timestamp = re.findall('Timestamp\\:\\s*\\S+', coredump_info)
        time_stamp = -1
        if timestamp:
            timestamp = timestamp[0].strip('Timestamp:').lstrip()
            if timestamp.endswith('Z'):
                timestamp = timestamp.rstrip('Z')
            time_stamp = time_str_to_utc_timestamp(time_str=timestamp, time_format="%Y-%m-%dT%H:%M:%SZ")
        if time_stamp >= start_time:
            temp_dict = {'ID': id, 'Node': node, 'details': coredump_info}
            available_coredump_info_list.append(temp_dict)
    return available_coredump_info_list


def generate_plan_when_add_mo(para_list, delta_plan_path, current_plan_path):
    from taf.config.scf import scf
    scf_obj = scf()

    for param in para_list:
        dist_name = param['dist_name']
        p_name = convert_list(param.get('p_name'))
        value = convert_list(param.get('value'))
        class_name = param.get('class')
        operation = param.get('operation')
        if len(p_name) != len(value):
            raise Exception('The number of p name and vaule not equal')
        scf_obj.load_scf(current_plan_path)
        version = _get_mo_version(dist_name, scf_obj)

        scf_obj.load_scf(delta_plan_path)
        print('1111111', class_name, dist_name, version, operation)
        if operation:
            scf_obj.add_object_to_scf(class_name, dist_name, version, operation)
        else:
            scf_obj.add_object_to_scf(class_name, dist_name, version)
        for i in range(len(p_name)):
            scf_obj.add_element_to_scf(dist_name, p_name[i], value[i])
        scf_obj.save_scf(delta_plan_path)


def _get_mo_version(dist_name, scf_obj):
    try:
        version = scf_obj.get_mo_attribute(dist_name, attribute='version')
    except Exception:
        dist_name = '/'.join(dist_name.split('/')[:-1])
        return _get_mo_version(dist_name, scf_obj)
    return version


def compare_two_dict(dict1, dict2, ignore_keys=None):
    ignore_keys = convert_list(ignore_keys)
    for key, value in enumerate(dict1):
        if value in ignore_keys:
            continue
        if dict1.get(value) != dict2.get(value):
            return False
    return True


def compare_cu_teardown_alarm_info_with_setup(teardown_alarms, setup_alarm, white_fault_id_list, white_alarm_id_list):
    add_alarms = []
    length = len(setup_alarm)
    ignore_keys = ['appear_time', 'last_updated_time', 'additional_info', 'uuid', 'probable_cause_name']
    logging.info('key appear_time, last_updated_time, additional_info, uuid, probable_cause_name not compared.')
    for i in range(length):
        alarm_length = len(teardown_alarms[i])

        for j in range(alarm_length):
            flag = 0
            teardown_alarm_info = teardown_alarms[i][j]
            fault_id = teardown_alarm_info['fault_id']
            alarm_id = teardown_alarm_info['alarm_id']
            for k in range(len(setup_alarm[i])):
                if compare_two_dict(teardown_alarm_info, setup_alarm[i][k], ignore_keys):
                    flag = 1
                    break
            if flag == 0 and fault_id not in white_fault_id_list and alarm_id not in white_alarm_id_list:
                add_alarms.append({i: teardown_alarm_info})
    return add_alarms


def compare_vdu_teardown_alarm_info_with_setup(teardown_alarms, setup_alarm, white_fault_id_list, white_alarm_id_list):
    add_alarms = []
    gnb_length = len(teardown_alarms)
    ignore_keys = ['appear_time', 'last_updated_time', 'additional_info', 'uuid', 'probable_cause_name']
    logging.info('key appear_time, last_updated_time, additional_info, uuid, probable_cause_name not compared.')
    for i in range(gnb_length):
        vdu_length = len(teardown_alarms[i])
        for j in range(vdu_length):
            alarms = teardown_alarms[i][j]
            for k in range(len(alarms)):
                flag = 0
                teardown_alarm_info = alarms[k]
                fault_id = teardown_alarm_info['fault_id']
                alarm_id = teardown_alarm_info['alarm_id']
                for o in setup_alarm[i][j]:
                    if compare_two_dict(teardown_alarm_info, o, ignore_keys):
                        flag = 1
                        break
                if flag == 0 and fault_id not in white_fault_id_list and alarm_id not in white_alarm_id_list:
                    add_alarms.append({'%s-%s' % (i, j): teardown_alarm_info})
    return add_alarms


def set_ip_and_mac_to_info_of_TDD(info, mac_ip_list):
    sn = info['sn']
    for mac_ip in mac_ip_list:
        if mac_ip.get('sn') == sn:
            info['ip'] = mac_ip['ip']
            info['mac'] = mac_ip['mac']
            return info
    raise Exception('tdd ip add fail.')


def set_ip_and_mac_to_info_of_FDD(info, fhgw_info):
    sn_number = info['sn']
    alias = get_unique_id()
    issh_cli.connect_to(ip=fhgw_info['addr'], port=22, username=fhgw_info["root_username"],
                        password=fhgw_info["root_password_plain"], alias=alias)
    for i in range(20):
        rup_ip_command = "sudo redis-cli -n `expr $j + %d` get ECPRI_UDCP_WRAPPER_IP" % (i + 18)
        rf_ip_command = "sudo redis-cli -n `expr $j + %d` get RRH_IP_ADDR" % (i + 18)
        sn_number_command = "sudo redis-cli -n `expr $j + %d` get serialNum" % (i + 18)
        rup_ip_out = issh_cli.execute(alias=alias, command=rup_ip_command)
        if 'nil' in rup_ip_out:
            break
        rf_ip_out = issh_cli.execute(alias=alias, command=rf_ip_command)
        sn_number_out = issh_cli.execute(alias=alias, command=sn_number_command)
        rf_ip = rf_ip_out.split('"')[1]
        rup_ip = rup_ip_out.split('"')[1]
        sn = sn_number_out.split('"')[1]
        if sn[-5:] == sn_number:
            info['rf_ip'] = rf_ip
            info['ip'] = rup_ip
            return info
    raise Exception('fdd ip add fail.')


def get_cell_global_l2rt_mapping_dict(cell_to_l2rt_mapping):
    new_dict = {}
    for pod in cell_to_l2rt_mapping:
        for global_cell_id in cell_to_l2rt_mapping[pod]:
            new_dict[global_cell_id] = pod
    logger.console(new_dict)
    return new_dict


def ping_status_should_be_as_expected(ip_address, is_pass=True):
    result = os.system('ping %s -c 1' % ip_address)
    if result == 0 and is_pass:
        logger.info('ping result as except:%s' % is_pass)
    elif result != 0 and not is_pass:
        logger.info('ping result as except:%s' % is_pass)
    else:
        raise Exception('excepted result is %s, but actual result is %s' % (is_pass, result))


def get_max_timestamp_of_container_start_time(pod_info):
    max_timestamp = -1
    _time = None
    for key in pod_info.keys():
        start_time = pod_info[key]['startedAt']
        time_stamp = int(datetime.datetime.strptime(start_time, '%Y-%m-%dT%H:%M:%SZ').timestamp())
        if time_stamp > max_timestamp:
            print('11111111111111111', start_time)
            _time = start_time
            max_timestamp = time_stamp
    return _time, max_timestamp


def covert_time_str_to_timestamp(time_str, time_format='%a, %d %b %Y %H:%M:%S %z'):
    dt = datetime.datetime.strptime(time_str, time_format)
    timestamp = int(dt.timestamp())
    return timestamp


def get_pod_start_time(all_pod_info):
    pod_info_dict = json.loads(all_pod_info)
    _start = _end = None
    for info in pod_info_dict['status']['conditions']:
        if info['type'] == 'Initialized':
            _start = info['lastTransitionTime']
            start_timestamp = int(datetime.datetime.strptime(info['lastTransitionTime'],
                                                             '%Y-%m-%dT%H:%M:%SZ').timestamp())
        if info['type'] == 'Ready':
            _end = info['lastTransitionTime']
            end_timestamp = int(datetime.datetime.strptime(info['lastTransitionTime'],
                                                           '%Y-%m-%dT%H:%M:%SZ').timestamp())
    if _start and _end:
        return [_start, start_timestamp], [_end, end_timestamp]


def check_RU_log_in_snapshot(all_sn, all_zip_path):
    for sn in all_sn:
        flag = 0
        for zip_path in all_zip_path:
            command = 'unzip -l %s | grep %s' % (zip_path, sn)
            result = os.popen(command).read()
            if result:
                logger.info('RU %s found log in path %s' % (sn, zip_path))
                flag = 1
                break
        if flag == 0:
            raise Exception('Log of RU %s not found' % sn)


def compare_2_ip_address_is_same(address_1, address_2):
    if check_ip_type(address_1) == 'ipv6':
        address_1 = ipaddress.IPv6Address(address_1)
    if check_ip_type(address_2) == 'ipv6':
        address_2 = ipaddress.IPv6Address(address_2)

    if address_1 == address_2:
        return True
    else:
        return False


def filter_operation_history(ope_history, start_timestamp, end_timestamp=None, ope_name_substring=None, target=None):
    target_ope_list = []
    for item in ope_history:
        if ope_name_substring and ope_name_substring.lower() not in item['name'].lower():
            continue

        if target and target not in item['targets']:
            continue

        item_start_timestamp = time_str_to_utc_timestamp(time_str=item['start_time'],
                                                         time_format='%Y-%m-%dT%H:%M:%S.%f%z')
        if int(item_start_timestamp) < int(start_timestamp):
            continue
        if end_timestamp and int(item_start_timestamp) > int(end_timestamp):
            continue

        target_ope_list.append(item)

    return target_ope_list


def generate_delta_parameters_for_multiple_mo(updated_para_value_dict, origin_para_value_dict):
    """
    [Documentation]   Generate Delta Parameters For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.8  chris.l.cao@nokia-sbell.com, when original parameter does not exist, it will be added.
    ...                                          when new value is ${None}, it will be removed.
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | updated_paras_dict     | yes | the names of parameters list |
    ...   | origin_para_value_dict | No | if it's ${EMPTY}, it means we are restoring the parameters value |
    ...
    ...   *RETURN VALUE*
    ...  dictionray of MO, which can be used by 'VDU Online Change Parameters By Delta Plan REST'
    """
    ret_list = []
    for mo, para_value_info in updated_para_value_dict.items():
        one_mo_to_be_updated = copy.deepcopy(para_value_info)
        one_mo_to_be_updated_list = generate_delta_parameters_for_one_mo_for_changing_value(
            mo=mo, mo_value=one_mo_to_be_updated, origin_para_value_dict=origin_para_value_dict
        )
        for i in one_mo_to_be_updated_list:
            ret_list.append(i)
    return ret_list


def generate_delta_parameters_for_one_mo_for_changing_value(mo, mo_value, origin_para_value_dict):
    """
    [Documentation]   _Generate Delta Parameters For One MO For Changing Value
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.11  chris.l.cao@nokia-sbell.com, support add, replace, remove operation
    ...  2023.12.25 ,chris.l.cao@nokia-sbell.com, support list like
    ...                                           <list name="acceptedClockClass"><p>6</p><p>7</p></list>
    ...
    ...   | Input Parameters      | Man. | Description |
    ...   | mo_dn                 | yes | distName where the parameter to be updated |
    ...   | mo_value              | yes | point to new value dictionary |
    ...   | origin_para_value_dict | yes | point to original value dictionary |
    """
    rtn_list_for_one_mo = []
    para_keys = mo_value.keys()
    for key, new_parameter_value in mo_value.items():
        # set mo_dn
        tmp_dict = {}
        tmp_dict["mo_dn"] = mo

        # set '<parameter_name>':'<parameter_value>'
        tmp_dict[key] = new_parameter_value

        # set operation
        original_mo_value = origin_para_value_dict.get(mo)
        original_parameter_value = original_mo_value.get(key)
        if (original_parameter_value is None) and new_parameter_value is not None:
            operation = "add"
        elif original_parameter_value is not None and new_parameter_value is not None:
            operation = "replace"
        elif original_parameter_value is not None and new_parameter_value is None:
            operation = "remove"
        else:
            operation = "remove"

        para_list = key.split("/")
        is_first_para_of_list = is_numeric(para_list[-1])

        # When remove it, we does not need "index" information for "/staticRoutes/<index>",
        # but we need it for "/acceptedClockClass/<index>"
        add_to_list = True
        if operation == "remove" and is_first_para_of_list is True:
            add_to_list = vdu_need_add_delete_info_to_list(para=key, para_keys=para_keys)
        if add_to_list is True:
            tmp_dict["operation"] = operation
            rtn_list_for_one_mo.append(tmp_dict)
    return rtn_list_for_one_mo


def vdu_need_add_delete_info_to_list(para, para_keys):
    filter = [i for i in para_keys if i.startswith(para)]
    rtn = True if len(filter) == 1 else False
    return rtn


def read_snapshot_file_structure(snapshot_file_list_file_name):
    """read_snapshot_file_structure
    *AUTHOR* chris.l.cao@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -8.9.2023,chris.l.cao@nokia-sbell.com,
                   return dictionary of "snapshot_file_list.txt"
        - 19.1.2024, calla.wang@nokia-sbell.com,
                     change because the file structure changed and simplify the logic.

    | Input Parameters  | Man. | Description |
    | snapshot_file_list_file_name | Yes  | string type, /tmp/snapshot_file_list.txt |


    *RETURN VALUE*
    dictionary,
 {
 'MRBTS-108201_E044_part_7.zip': ['MRBTS-108201_E022_startup.zip',
                                  'MRBTS-108201_E051_startup.zip'],
 'MRBTS-108201_E044_part_8.zip': ['MRBTS-108201_E048_runtime.zip',
                                  'MRBTS-108201_E021_runtime.zip',
                                  'MRBTS-108201_E049_runtime.zip',
                                  'MRBTS-108201_E400_runtime.zip',
                                  'MRBTS-108201_E020_runtime_sysinfo.zip',
                                  'MRBTS-108201_E045_runtime.zip',
                                  'MRBTS-108201_E501_IqSnapshotBuffer.xz',
                                  'MRBTS-108201_E100_LINUX_runtime.zip'],
 'MRBTS-108201_E044_part_9.zip': ['MRBTS-108201_E023_AaTestPortClientHistory.log.xz',
                                  'MRBTS-108201_E011_startup.zip',
                                  'MRBTS-108201_E047_runtime.zip',
                                  'MRBTS-108201_E042_runtime.zip',
                                  'MRBTS-108201_E200_L2TraceLo.dat.xz',
                                  'MRBTS-108201_E043_startup.zip'],
 'MRBTS-108201_metadata.txt': [],
 'RU_logs.zip': ['RU_1.zip'],
 'historyFile.txt': [],
  ...
  }
    Example:
    | ${snapshot_file_dictionary}  | read_snapshot_file_list | /tmp/snapshot_file_list.txt |
    """
    result = {}
    current_key = None
    with open(snapshot_file_list_file_name, "r") as f:

        for line in f.readlines():
            if not line.startswith(" ") and len(line) > 1:
                current_key = line.strip().strip(':')
                result[current_key] = []
            elif current_key and len(line) > 1:
                result[current_key].append(line.strip())

    return result


def fetch_sw_version_from_cm_artifacts(cm_artifacts):
    vdu_sw_version = ''
    vcu_sw_version = ''
    new_cm_artifacts = cm_artifacts.replace('false', 'False').replace('true', 'True')

    for item in eval(new_cm_artifacts):
        if item.get('type') != 'build':
            continue
        if not item.get('name').lower().startswith('vdu'):
            continue

        vdu_sw_version = item['name']
        related_sw_version = item['properties']['related_artifacts']['5G']
        for related_item in related_sw_version:
            if related_item.get('name') == 'vcu_cnf':
                vcu_sw_version = related_item['version']

    return vdu_sw_version, vcu_sw_version


def check_ipv6_address(ip):
    if isinstance(ip_address(ip), IPv6Address):
        return True
    else:
        return False


def search_fatal_error_in_log(log_path, start_time):
    """read_snapshot_file_structure
    *AUTHOR* rui.3.li@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -28.9.2023,chris.l.cao@nokia-sbell.com, add errors='ignore' while open log file

    | Input Parameters  | Man. | Description |
    | log_path   | Yes  | string type, /tmp/0928/syslog-err_20230928034739 |
    | start_time | Yes  | string type, '2023-09-28 11:46:55' |

    *RETURN VALUE*
    list of error message that its appearing timestamp is 'great than' start_time,

    Example:
    | ${result} | search_fatal_error_in_log | /tmp/0928/syslog-err_20230928034739 | 2023-09-28 11:46:55 |
    """
    start_time_timestamp = covert_time_str_to_timestamp(start_time, time_format='%Y-%m-%d %H:%M:%S')
    result = []
    with open(log_path, 'r+', errors='ignore') as fp:
        file_content = fp.readlines()
    pattern = 'ERR.+fatality'
    time_pattern_1 = r'\d+-\d+-\d+T\d+:\d+:\d+\.\d+Z'
    time_pattern_2 = r'\d+-\d+-\d+T\d+:\d+:\d+\.\d+\+\d+:\d+'
    for content in file_content:
        timestamp = 0
        if len(re.findall(pattern, content)) > 0:
            if len(re.findall(time_pattern_1, content)) > 0:
                timestamp = covert_time_str_to_timestamp(re.findall(time_pattern_1, content)[0],
                                                         time_format='%Y-%m-%dT%H:%M:%S.%fZ')
            if len(re.findall(time_pattern_2, content)) > 0:
                time_str = re.findall(time_pattern_2, content)[0]
                timestamp = covert_time_str_to_timestamp(
                    time_str.split('+')[0] + '+' + time_str.split('+')[1].replace(':', ''), '%Y-%m-%dT%H:%M:%S.%f%z')
        if timestamp > start_time_timestamp:
            result.append(content)
    return result


def parse_name_convention_from_json_cnf_release_values(cnf_release_values, namespace, name_type):
    assert name_type in ['pod_prefix', 'container_prefix'], 'name_type must be one of pod_prefix or container_prefix'
    cnf_release_values_dict = json.loads(cnf_release_values)
    name_prefix_list = cnf_release_values_dict['global']['name_convention'][name_type]
    name_prefix_tmp = '-'.join(name_prefix_list)
    name_prefix = name_prefix_tmp.replace('_NAMESPACE_', namespace)
    return name_prefix + '-'


def _find_paths_in_json_file_by_value(json_data, target_value, paths=None):
    if paths is None:
        paths = []
    if isinstance(json_data, dict):
        for k, v in json_data.items():
            new_path = list(paths)
            new_path.append(k)
            for result in _find_paths_in_json_file_by_value(v, target_value, paths=new_path):
                yield result
    elif isinstance(json_data, list):
        for i, v in enumerate(json_data):
            new_path = list(paths)
            new_path.append(i)
            for result in _find_paths_in_json_file_by_value(v, target_value, paths=new_path):
                yield result
    elif json_data == target_value:
        yield paths


def find_container_image_path(json_data, target_value):
    json_data = json.loads(json_data)
    paths = list(_find_paths_in_json_file_by_value(json_data, target_value))
    image_path = ''
    for path in paths:
        if 'spec' in path and 'name' in path:
            path[-1] = "image"
            for item in path:
                image_path = image_path + '/'+str(item)
    return image_path


def get_network_interface_name_and_vf_id(mac_addr, ip_link_result):
    interface_pattern = r'^(\d+):\s(\S+):'
    vf_pattern = r'\s*(vf \d+)\s+link/ether ' + re.escape(mac_addr)

    current_interface = None
    lines = ip_link_result.strip().split('\n')

    for line in lines:
        interface_match = re.match(interface_pattern, line)
        if interface_match:
            current_interface = interface_match.group(2)

        vf_match = re.search(vf_pattern, line)
        if vf_match and current_interface:
            return current_interface, vf_match.group(1)

    raise Exception('Cannot find the VF ID and network interface for MAC address %s' % mac_addr)
