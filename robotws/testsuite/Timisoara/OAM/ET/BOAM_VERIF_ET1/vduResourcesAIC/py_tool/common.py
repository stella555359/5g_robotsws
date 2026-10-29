from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import os
import ipaddress
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
import time
import csv
import openpyxl
import copy
import sys


try:
    from cStringIO import StringIO
except ImportError:
    try:
        from StringIO import StringIO
    except ImportError:
        from io import StringIO

__all__ = [
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
    "compare_ip",
    "String_Should_Be_An_Ip_Address_V4_or_V6",
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
    "get_time_interval_of_two_msgs",
    "write_to_csv_file",
    "get_time_interval_in_2_files",
    "get_timestamp_from_log",
    "timestamp_convert",
    "get_power_when_ue_lost_from_l2rtlog",
    "get_nidd_counters",
    "write_counters_to_excel",
    "generate_alarm_post_request_command",
    "parse_pm_result_xml_file",
    "get_measurement_report_stop_time",
    "measurement_file_name_gen",
    "get_parameter_sum_from_dcap_log",
    "get_parameter_from_dcap_log",
    "count_string_in_list"
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
    output_dir = BuiltIn_obj.get_variable_value("${OUTPUT_DIR}")
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
    """get a directory name with absolute path

    *AUTHOR* fen.huang@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -13.07.2020,chris.l.cao@nokia-sbell.com,
                   Raise exception if failed to generate a folder name.
    | Input Parameters  | Man. | Description |
    | path            | Yes  |   list type, e.g, ["folder1", "fold2"] |


    *RETURN VALUE*
    string

    Example:
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


def check_alarm(alarm_info, fault_id=None, fault_name=None, alarm_id=None, alarm_name=None):
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
    flag = False
    for alarm in alarm_info:
        faultId = str(alarm["fault_id"])
        faultName = str(alarm["fault_name"])
        alarmId = str(alarm["alarm_id"])
        alarmName = str(alarm["alarm_name"])
        if not fault_id and not fault_name and not alarm_id and not alarm_name:
            logger.warn("No alarmId or faultName or fauldId are needed to check, check alarm skipped!")
            break
        elif fault_id and not fault_name and not alarm_id and not alarm_name:
            if faultId == fault_id:
                flag = True
                break
        elif not fault_id and fault_name and not alarm_id and not alarm_name:
            if faultName == fault_name:
                flag = True
                break
        elif not fault_id and not fault_name and alarm_id and not alarm_name:
            if alarmId == alarm_id:
                flag = True
                break
        elif not fault_id and not fault_name and not alarm_id and alarm_name:
            if alarmName == alarm_name:
                flag = True
                break
        elif fault_id and fault_name and not alarm_id and not alarm_name:
            if faultId == fault_id and faultName == fault_name:
                flag = True
                break
        elif not fault_id and fault_name and alarm_id and not alarm_name:
            if faultName == fault_name and alarmId == alarm_id:
                flag = True
                break
        elif not fault_id and not fault_name and alarm_id and alarm_name:
            if alarmId == alarm_id and alarmName == alarm_name:
                flag = True
                break
        elif fault_id and not fault_name and alarm_id and not alarm_name:
            if faultId == fault_id and alarmId == alarm_id:
                flag = True
                break
        elif fault_id and not fault_name and alarm_id and alarm_name:
            if faultId == fault_id and alarmName == alarm_name:
                flag = True
                break
        elif not fault_id and fault_name and not alarm_id and alarm_name:
            if faultName == fault_name and alarmName == alarm_name:
                flag = True
                break
        elif fault_id and fault_name and alarm_id and not alarm_name:
            if faultId == fault_id and faultName == fault_name and alarmId == alarm_id:
                flag = True
                break
        elif not fault_id and fault_name and alarm_id and alarm_name:
            if faultName == fault_name and alarmId == alarm_id and alarmName == alarm_name:
                flag = True
                break
        elif fault_id and fault_name and not alarm_id and alarm_name:
            if faultId == fault_id and faultName == fault_name and alarmName == alarm_name:
                flag = True
                break
        elif fault_id and not fault_name and alarm_id and alarm_name:
            if faultId == fault_id and alarmId == alarm_id and alarmName == alarm_name:
                flag = True
                break
        elif fault_id and fault_name and alarm_id and alarm_name:
            if faultId == fault_id and faultName == fault_name and alarmId == alarm_id and alarmName == alarm_name:
                flag = True
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


def list_file_with_extension(path, extension=".zip"):
    """List file under given path with desired extension.

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters | Man. | Description |
    | path       | Yes  | path to be scanned |
    | extension  | no  | file extension, it can be .zip, .txt, .log etc,  default is .zip |

    *RETURN VALUE*
    File list with desired extension,  eg.
    [['a.zip', 'b.zip'], ['/temp/a.zip', '/temp/abc/b.zip']]

    Example
    | ${file_list} | ${full_file_path_list}  | list_file_with_extension | /temp | extension=.zip |
    """
    rtn_filename = []
    rtn_full_filename = []
    if not os.path.isdir(path):
        print("Directory {} does not exist!")
        return rtn

    for root, dirs_list, files_list in os.walk(path):
        for file_name in files_list:
            if os.path.splitext(file_name)[-1] == extension:
                file_name_path = os.path.join(root, file_name)
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


def compare_ip(ip1, ip2, operator="eq"):
    """This function is used to compare ip address, and return true or false supporting ipv4 and ipv6

    *AUTHOR* chris.l.cao@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | ip1            | Yes  |  ip address you want to increase eg, 10.107.63.206 |
    | ip2            | Yes  |  ip address you want to increase eg, 10.107.63.206 |
    | operator       | Yes  | operator, eq:==, ge:>=, gt:>, le:<=, lt:<, ne:!=, default is eq |

    *RETURN VALUE*
    ${True} or ${False}

    Example:
       Return ${True}
     | ${result} | compare_ip | ip1=10.107.63.206 | ip2=10.107.63.206  | operator=eq |
        Return ${True}
     | ${result} | compare_ip | ip1=10.107.63.206 | ip2=10.107.63.205  | operator=ge |
        Return ${True}
     | ${result} | compare_ip | ip1=10.107.63.206 | ip2=10.107.63.206  | operator=le |
        Return ${False}
     | ${result} | compare_ip | ip1=10.107.63.206 | ip2=10.107.63.206  | operator=ne |
        Return ${True}
     | ${result} | compare_ip | ip1=10.107.63.208 | ip2=10.107.63.206  | operator=gt |

    """
    if len(ip1) == 0:
        raise RuntimeError("ip1 should not be empty!!")
    if len(ip2) == 0:
        raise RuntimeError("ip2 should not be empty!!")

    nIp1 = IP(ip1, make_net=True).int()
    nIp2 = IP(ip2, make_net=True).int()
    if operator == "eq":
        return nIp1 == nIp2
    elif operator == "ge":
        return nIp1 >= nIp2
    elif operator == "gt":
        return nIp1 > nIp2
    elif operator == "le":
        return nIp1 <= nIp2
    elif operator == "lt":
        return nIp1 < nIp2
    elif operator == "ne":
        return nIp1 != nIp2

    raise RuntimeError("Unknow operator:{}".format(operator))


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


def get_online_parameter_value(paras_info, dn, para_struct_path):
    """This keyword is used to get parameter value from current plan.

    *AUTHOR* fen.huang@nokia-sbell.com
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
                return _get_complex_parameter_value(para_info, para_struct_list)
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


def _get_complex_parameter_value(para_info, para_struct_list):
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
    a = datetime.datetime.strptime(time_1, "%Y%m%d.%M%S")
    b = datetime.datetime.strptime(time_2, "%Y%m%d.%M%S")
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


def get_timestamp_from_log(file_path, msg_pattern, index, expected_msg_num=False):
    """
    This keyword is used to get timestamp value in the last line of the file.
    *AUTHOR* fen.huang@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  file_path  | Yes |  Path of the log file  |

    *RETURN VALUE*/
    Timestamp string of the expected line by index

    Example
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
    if matched_line:
        logger.info(matched_line)
        matches = st.get_regexp_matches(matched_line, "(\\d+-\\d+-\\d+T\\d+:\\d+:\\d+.\\d+)[+Z]", 1)
        if matches:
            return matches[0].strip("Z")
        else:
            matches = st.get_regexp_matches(matched_line, "(\\d+-\\d+-\\d+T\\d+:\\d+:\\d+)", 1)
            if matches:
                return matches[0]
            else:
                return None


def timestamp_convert(time_string):
    plus_hours_time = datetime.datetime.strptime(time_string, "%Y-%m-%dT%H:%M:%S.%f")
    plus_hours_time = (plus_hours_time + datetime.timedelta(hours=8)).strftime("%Y-%m-%dT%H:%M:%S.%f")
    return plus_hours_time


def get_power_when_ue_lost_from_l2rtlog(l2rt_log_path):
    """from l2rt log to calculate how long the call dropped this only can be used after call started.
    *AUTHOR* shan-eric.wu@nokia-sbell.com

    | Input Parameters  | Man. | Description |
    | environ_variable_name    | Yes  |  environ_variable_name |

    *RETURN VALUE*
    type float, duration of 5g upload traffic transfer total_seconds

    Example:
    | ${timer_difference} | get_power_when_ue_lost_from_l2rtlog | l2rt_log_path |
    """
    # open log file, and find tput and corresponding duratio
    with open(l2rt_log_path, 'r') as f:
        lines = f.read()
        match_list = re.findall(
            r'\d+-\d\d-\d\dT(\d+:\d+:\d\d).+UL: (\d+) Bytes received.+nrCellIdentity (\d+)', lines)

        NoTputTimeIndex = 0
        TrafficStartTime = "00:00:00"
        NoTupTimestr = "00:00:00"
        cell1 = []
        cell2 = []
        cell3 = []
        CellTputList = []
        Cell1TputFlag = True
        Cell2TputFlag = True
        OnlyFlag = False
        # find each cell tput and save into cell1 cell2 list
        for length in range(len(match_list)):
            if match_list[0][2] == match_list[1][2]:
                OnlyFlag = True
                break
            if match_list[0][2] == match_list[length][2]:
                cell1.append(match_list[length])
            if match_list[1][2] == match_list[length][2]:
                cell2.append(match_list[length])

        if OnlyFlag is True:
            CellTputList = match_list
        else:
            for length in range(len(cell1)):
                if cell1[length][1] == '0':
                    NoTputTimeIndex = NoTputTimeIndex + 1
                if NoTputTimeIndex > 30 and length < 0.6 * len(cell1):
                    Cell1TputFlag = False

            NoTputTimeIndex = 0
            for length in range(len(cell2)):
                if cell2[length][1] == '0':
                    NoTputTimeIndex = NoTputTimeIndex + 1
                if NoTputTimeIndex > 30 and (length < 0.6 * len(cell2)):
                    Cell2TputFlag = False
            if Cell1TputFlag is False and Cell2TputFlag is False:
                return "no tput detected"
            if Cell1TputFlag is False and Cell2TputFlag is True:
                CellTputList = cell2
            if Cell2TputFlag is False and Cell1TputFlag is True:
                CellTputList = cell1
            if Cell2TputFlag is True and Cell1TputFlag is True:
                return ("2 cells have tput or have no tput detected")

        NoTputTimeIndex = 0
        # find the time traffic start if the tput smaller than 1000, consider call is not ok.
        for length in range(len(CellTputList)):
            if int(CellTputList[length][1]) == 0:
                # ignore first 20 trace sometime call start need few seconds
                if length > 20:
                    NoTputTimeIndex = NoTputTimeIndex + 1
                # only if 5(NoTputTimeIndex) consecutive seconds no tput, consider call drop,
                if NoTputTimeIndex > 4:
                    print("no tput for 5 sec, and first sec is ", CellTputList[length - 5][0])
                    NoTupTimestr = CellTputList[length - 5][0]
                    break
            else:
                continue
        # only if the tput bigger than 1000, use it as traffic start time
        for length in range(len(CellTputList)):
            if int(CellTputList[length][1]) > 1000:
                TrafficStartTime = CellTputList[length][0]
                break

        NoTupTimeobj = datetime.datetime.strptime(NoTupTimestr, '%H:%M:%S')
        TrafficStartTimeobj = datetime.datetime.strptime(TrafficStartTime, '%H:%M:%S')
        # return how long this call drop per l2rt log
        if TrafficStartTime == "00:00:00":
            return "no tput detected"
        else:
            return (NoTupTimeobj - TrafficStartTimeobj).total_seconds()


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


def parse_pm_result_xml_file(file_name):
    """This keyword is used to parse the pm report xml file.
    *AUTHOR* calla.wang@nokia-sbell.com
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
    # tree = etree.parse(file_name)
    root = etree.parse(file_name).getroot()
    for pmmo in root.iter('PMMOResult'):
        counter_values_one_mo = {}
        mo = pmmo.find('MO')
        dn = mo.find('DN').text.strip().split('/')[-1]
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

    if len(start) is not 29:
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
