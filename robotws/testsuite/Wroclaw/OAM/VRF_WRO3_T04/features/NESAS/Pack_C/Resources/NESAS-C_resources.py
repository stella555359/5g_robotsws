import string
import taf.config.scf as scf
from robot.api import logger
from taf.transport.ssh import interface
from datetime import datetime
from taf.sbts.oam.coam.admin import admin

ssh = interface.ssh()


def check_permissions(permission):
    '''
    Checking if the permission is denied for the file
    :param permission: the file that permission should be checked
    :return:
    '''
    denied = "Permission denied"
    if denied in permission:
        return True
    else:
        return False


def extract_is_secured_values(data):
    '''
    Getting the information about if the connection is secured from the output
    :param data: the output from the KW
    :return:
    '''
    return [message['isSecured'] for message in data['requestMessage']]


def check_if_system_is_not_overloaded(cpu, memory):
    '''
    Checking the system is not overloaded.
    :param cpu: the value of the CPU from the BTS
    :param memory: the memory value of the BTS
    :return: True is not overloaded, false if overloaded
    '''
    cpu_to_split = cpu.replace(" ", "")
    cpu_tab = cpu_to_split.split(",")
    cpu_id = cpu_tab[3]
    cpu_id = cpu_id.replace("x\x1b[m\x0f\x1b[1m", "")
    cpu_id = cpu_id.replace("\x1b[m\x0fid", "")
    cpu_id = cpu_id.replace("\x1b[m\x0f\x1b[1m", "")
    cpu_id = float(cpu_id)
    memory_to_split = memory.replace(" ", "")
    memory_tab = memory_to_split.split(",")
    memory_free = memory_tab[1]
    memory_free = memory_free.replace("", "")
    memory_free = memory_free.replace("\x1b[m\x0f", "")
    memory_free = memory_free.replace("\\x1b[m\x0f\x1b[1m", "")
    memory_free = memory_free.replace("[1m", "")
    memory_free = memory_free.replace(" ", "")
    memory_free = memory_free.replace("\x1b", "")
    memory_free = memory_free.replace("free", "")
    memory_free = float(memory_free)
    if cpu_id > 25 and memory_free > 500:
        return True
    else:
        return False


def check_local_user_password_hashed_with_sha512(ip_address, username, password, local_username=None):
    '''
    Checking if the password is hashed with SHA512
    :param ip_address: IP address
    :param username: username to login
    :param password: password to login
    :param local_username: local username
    :return:
    '''
    check_files_list_raw = [
        "/etc/shadow",
        "/ffs/run/etc/p_shadow",
        "/etc/security/opasswd",
        "/ffs/run/etc/security/opasswd",
        "/etc/passwd"
    ]
    ssh = interface.ssh()
    connection = ssh.connect_to(ip_address, username, password)
    for file_path in check_files_list_raw:
        if ssh.file_exists(file_path, connection=connection):
            if local_username is not None:
                logger.info("Checking hashes in file: {0} for user: {1}".format(
                    file_path, local_username), also_console=True)
                hash_raw = ssh.execute(command="grep '$.*$' {0} | grep {1}".format(file_path, local_username))
            else:
                logger.info("Checking hashes in file: {}".format(file_path), also_console=True)
                hash_raw = ssh.execute(command="grep '$.*$' {0}".format(file_path))
            for hashed_pass in hash_raw.split("\r\n"):
                if hashed_pass and "$6$rounds=10000" not in hashed_pass:
                    raise Exception(
                        "File {0} contains hash different than $6$ sha512, {1}".format(file_path, hashed_pass))


def check_webem_user_password_hashed_with_sha512(ip_address, username, password, webem_username):
    """
    Checking if the password is hashed with sha512
    :param ip_address:  IP address
    :param username: username to login
    :param password: password to login
    :param webem_username: username to webem
    :return:
    """
    WEBEM_USERS_FILE = "/ffs/run/config/users.json"
    ssh = interface.ssh()
    connection = ssh.connect_to(ip_address, username, password)
    hash_entry = ssh.execute(
        command="cat {1} | grep -A 6 \"{0}\" | grep hashedPassword".format(
            webem_username, WEBEM_USERS_FILE))
    logger.console("cat {1} | grep -A 6 \"{0}\" | grep hashedPassword".format(
            webem_username, WEBEM_USERS_FILE))
    logger.console("Checking hash value: {0}".format(hash_entry))
    hash_raw = hash_entry.split(":")[1].strip(string.whitespace + string.punctuation)
    logger.info("Checking {0} password hash: {1}".format(webem_username, hash_raw), also_console=True)
    assert len(hash_raw) == 128, \
        "Hash length equals to {0} digits but should 128, sha512 not used!".format(len(hash_raw))


def check_ip_vlan(ip, username, password, check_ip, vlan):
    connection = ssh.connect_to(ip, username, password)
    output = ssh.execute(command='ip a | grep {}'.format(vlan), connection=connection)
    ssh.disconnect(connection=connection)
    return True if check_ip in output else False


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
