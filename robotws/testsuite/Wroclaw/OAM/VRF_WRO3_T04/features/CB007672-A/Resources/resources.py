from datetime import datetime

import taf.config.scf as scf
from taf.sbts.oam.coam.admin import admin


def get_measurements(dictionary):
    if type(list(dictionary.values())[0]) is not dict:
        return dictionary
    return get_measurements(list(dictionary.values())[0])


def get_counter(counter_path, counter_name, lmp_host, webem_password):
    api = admin()
    connection = api.connect_to(bts_host=lmp_host, password=webem_password)
    path_to_counter = counter_path + counter_name
    counter = api.get_counters_info(path_to_counter, connection=connection)
    api.teardown(connection=connection)
    return counter


def get_dropped_packets_counter_value(counter_path, counter_name, lmp_host, webem_password):
    counter = get_counter(counter_path, counter_name, lmp_host, webem_password)
    counter_values = get_measurements(counter)
    print(counter_values)
    unix_time = max([int(x) for x in counter_values.keys()])
    unix_time1 = max([int(x) for x in counter_values.values()])
    return unix_time1


def get_dropped_packets_counter_time(counter_path, counter_name, lmp_host, webem_password):
    counter = get_counter(counter_path, counter_name, lmp_host, webem_password)
    counter_values = get_measurements(counter)
    unix_time = max([int(x) for x in counter_values.keys()])
    return datetime.utcfromtimestamp(unix_time + 7200).strftime('%H:%M')


def activate_pm_counters_reporting(dist_name, path_to_scf, reporting_interval, na_instance):
    current_scf = scf.scf()
    current_scf.load_scf(path_to_scf)
    attributes = dict(current_scf.scf_operations._get_node(dist_name)._tree.attrib)
    return na_instance.activate_pm_reporting(class_name=attributes['class'], dist_name=dist_name,
                                             version_name=attributes['version'],
                                             reporting_interval=reporting_interval)


def get_counter_value_via_netact(counter_number, path_to_file='PM_Report.xml'):
    with open(path_to_file, 'r') as file:
        file_data = file.readlines()[0]
        counter_start = file_data.index("<{counter_number}>".format(counter_number=counter_number)) + len(
            "<{counter_number}>".format(counter_number=counter_number))
        counter_finish = file_data.index("</{counter_number}>".format(counter_number=counter_number))
        return file_data[counter_start:counter_finish]


def get_netact_report_time(path_to_file='PM_Report.xml'):
    with open(path_to_file, 'r') as file:
        file_data = file.readlines()[0]
        time_string_start_index = file_data.index("<PMSetup startTime=") + len('<PMSetup startTime="')
        time_string_finish_index = time_string_start_index
        while file_data[time_string_finish_index] != '"':
            time_string_finish_index += 1
        return file_data[time_string_start_index:time_string_finish_index]


def compare_netact_and_webem_raport_time(webem_ratort_time, netact_report_time):
    webem_ratort_time_modified = webem_ratort_time[webem_ratort_time.index(":"):] + ":00"
    return webem_ratort_time_modified in netact_report_time


def get_list_of_params_for_ipapp_object():
    params_list = [
        {"parameterName": "ipAppId", "operation": "update", "value": 1}
    ]
    return params_list


def get_list_of_params_for_twampreflect_object(m_plane_path):
    params_list = [
        {"parameterName": "refWaitTimeout", "operation": "update", "value": 900},
        {"parameterName": "twampReflectId", "operation": "update", "value": 1},
        {"parameterName": "twampReflectorEnabled", "operation": "update", "value": "true"},
        {"parameterName": "twampReflectorLocalIpAddressDN", "operation": "update", "value": m_plane_path},
        {"parameterName": "twampReflectorUdpEchoEnabled", "operation": "update", "value": "true"}
    ]
    return params_list


def get_list_of_params_for_top_object(s_plane_dn):
    params_list = [
        {"parameterName": "sPlaneDscp", "operation": "update", "value": 46},
        {"parameterName": "sPlaneIpAddressDN", "operation": "update", "value": s_plane_dn},
        {"parameterName": "topDomainNumber", "operation": "update", "value": 0}
    ]
    return params_list


def get_list_of_params_for_topp_object(master_ip_addr):
    params_list = [
        {"parameterName": "acceptedClockClass",
         "operation": "update",
         "value": ["6", "7"]},
        {"parameterName": "topMasterList",
         "value": [{"masterIpAddr": master_ip_addr,
                    "maximumNetworkTimingError": "100",
                    "phaseErrorComp": "0",
                    "topMasterId": "1"},
                   ],
         "operation": "update",
         },
        {"parameterName": "syncMessageRate",
         "operation": "update",
         "value": "RATE_64"},
        {"parameterName": "topStandardProfile",
         "operation": "update",
         "value": "Telecom2008"},
        {"parameterName": "tuningProfile",
         "operation": "update",
         "value": "Normal"},
    ]
    return params_list


def get_top_object_parameters(master_ip_addr):
    params_list = [
        {"parameterName": "topMasterList",
         "operation": "update",
         "value": [{"masterIpAddr": master_ip_addr,
                    "maximumNetworkTimingError": "100",
                    "phaseErrorComp": "0",
                    "topMasterId": "1"}]}
    ]
    return params_list


def get_s_plane_ip_address_dn_parameter(s_plane_DN):
    params_list = [
        {"parameterName": "sPlaneIpAddressDN",
         "operation": "update",
         "value": s_plane_DN}
    ]
    return params_list


def get_ipv6_route(ipv6_address):
    ipv6_route = ipv6_address[:-1]+str(int(ipv6_address[-1:])+1)
    return ipv6_route
