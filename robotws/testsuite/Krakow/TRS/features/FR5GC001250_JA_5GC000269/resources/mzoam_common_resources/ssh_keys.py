"""
author: Filip Hein
contact: filip.hein@nokia.com
"""

import os
import paramiko
import re
from cryptography.hazmat.backends import default_backend as crypto_default_backend
from cryptography.hazmat.primitives import serialization as crypto_serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from robot.api import logger
from robot.libraries import DateTime
from taf.transport.ssh import interface
from time import sleep

ssh = interface.ssh()
local_path = os.path.dirname(__file__)


def wait_for_response(seconds):
    """
    In order to successfully interact with FSCLISH - internal secure CLI for serviceuser, we have to
    ensure that CU proceeded request it got and responded correctly.
    We can not use bash commands, use its perks and we can't expect bash's behaviours whatsoever.
    If CU fails to do answer before the next command is sent, the test will break.
    Therefore, the sleep function used for waiting is understandable and even somehow justified.
    Moreover, sometimes tests have to create an interactive shell, where those sleeps are also very important and can
    not be omitted.
    """
    sleep(seconds)


def check_if_connect_via_ssh_not_possible(ip_address, username, password):
    error_msg = ''
    try:
        ssh.connect_to(ip_address, username, password)
    except Exception as e:
        error_msg = e
    assert error_msg != '', "Connection with credentials {}:{} was possible!".format(username, password)


def check_if_connect_via_ssh_possible(ip_address, username, pwd):
    error_msg = ''
    try:
        ssh.connect_to(ip_address, username, pwd)
    except Exception as e:
        error_msg = e
    assert error_msg == '', "Connection with credentials {}:{} was not possible!".format(username, pwd)


def check_if_system_control_possible(answer):
    assert 'Permission denied' not in answer, "Permission denied for operation fdisk -l"


def check_if_relog_happened(answer):
    assert 'root@' in answer, "Relog did not happen!"


def check_if_access_is_non_root_on(*args):
    list_of_failures = []
    for connection in args:
        connection.send_command("show user-management user")
        wait_for_response(1)
        answer = connection.read_output()
        uid = int(re.findall(r'Primary group.*: serviceuser\((.*)\)', answer)[0])
        if uid == 0:
            list_of_failures.append("UID equals 0.")
    assert list_of_failures == [], list_of_failures


def change_user_to_toor4nsn_and_execute_command(connection, username, password, command):
    channel = connection.invoke_shell()
    sleep(1)
    channel.send('set user username {} \n'.format(username))
    wait_for_response(2)
    channel.send("{}\n".format(password))
    wait_for_response(3)
    channel.send('{}\n'.format(command))
    wait_for_response(3)
    out = channel.recv(9999)
    return out


def gather_logs(connection, commands):
    logs = []
    date_now = ssh.execute('date +"%Y-%m-%dT%H:%M:%S%:z"', connection=connection)
    logs.append(date_now)
    for command in commands:
        answer = ssh.execute(command, connection=connection)
        logs.append(answer)
    return logs


def check_timestamps_in_all_logs(logs):
    assert '' not in logs, "One or more logs were not found in log file."
    check_delta_time(logs[1:], logs[0])


def calc_time_diff(datetime, log_datetime):
    return DateTime.subtract_date_from_date(datetime, log_datetime)


def check_delta_time(logs, time_now, max_delta=180):
    failures = []
    time_now = time_now.split("+")[0]
    failures.append("Did not get any logs!") if len(logs) == 0 else None
    for log in logs:
        event_time = eval(log)['eventTime'].split("+")[0]
        event_delta = calc_time_diff(time_now, event_time)
        if event_delta > max_delta:
            failures.append("Event occured {} seconds ago, max is {}".format(event_delta, max_delta))
    assert failures == [] and len(logs) > 0, failures


def check_if_connection_succeeds(ip, login, password, proxy):
    try:
        ssh.connect_to(ip, login, password, proxy=proxy)
    except Exception as e:
        assert not e, "Connection was not possible but it should be."


def check_if_permission_is_non_root_on_du(answer):
    answer = answer.rstrip()
    assert int(answer) != 0, "UID equals 0."


def check_if_change_from_serviceuser_to_toor4nsn_du_loopback_is_not_possible(addr, login, pwd, proxy):
    error = ''
    try:
        ssh.connect_to(addr, login, pwd, proxy=proxy)
    except Exception as e:
        error += str(e)
    finally:
        assert error != '', "Connection was possible but it shouldn't."


def create_ssh_keypair_for(owner):
    keypaths = []
    key = rsa.generate_private_key(
        backend=crypto_default_backend(),
        public_exponent=65537,
        key_size=2048
    )
    private_key = key.private_bytes(
        crypto_serialization.Encoding.PEM,
        crypto_serialization.PrivateFormat.TraditionalOpenSSL,
        crypto_serialization.NoEncryption())
    public_key = key.public_key().public_bytes(
        crypto_serialization.Encoding.OpenSSH,
        crypto_serialization.PublicFormat.OpenSSH
    )
    with open(local_path + "/private_{}.key".format(owner), 'w') as priv:
        priv.write(private_key)
        keypaths.append(local_path + "/private_{}.key".format(owner))
    with open(local_path + "/public_{}.key".format(owner), 'w') as pub:
        pub.write(public_key)
        keypaths.append(local_path + "/public_{}.key".format(owner))
    return keypaths


def create_ssh_connection_using_paramiko(ip_address, username, password):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=ip_address, username=username, password=password)
    return ssh_client


def send_private_keys_to(cu_or_du, ip_address, username, password, *keypaths):
    ssh_client = create_ssh_connection_using_paramiko(ip_address, username, password)
    sftp = ssh_client.open_sftp()
    keypaths = keypaths[0]
    for keypath in keypaths:
        logger.console(keypath)
        if cu_or_du.lower() == 'du':
            sftp.put(keypath, "/user/{}/{}".format(username, keypath.split("/")[-1]))
        elif cu_or_du.lower() == 'cu':
            sftp.put(keypath, "/home/robot/{}".format(keypath.split("/")[-1]))
    sftp.close()


def create_key_description_and_value_dictionary_for(private_and_public_key):
    final_dict = {'Key description': '# ', 'Key value': None}
    with open(private_and_public_key[1]) as public_key:
        final_dict['Key value'] = public_key.read()
    final_dict['Key description'] += str('test')
    return final_dict


def connect_to_du_as_toor4nsn_and_execute_command(ip_address, username, password, command):
    ssh_client = create_ssh_connection_using_paramiko(ip_address, username, password)
    channel = ssh_client.invoke_shell()
    wait_for_response(1)
    channel.send('''sudo ssh -o ProxyCommand="ssh -W %h:%p serviceuser@192.168.2.60 -i private_serviceuser.key" '''
                 '''toor4nsn@localhost -i private_toor4nsn.key\n''')
    wait_for_response(3)
    channel.send('{}\n'.format(command))
    wait_for_response(1)
    answer = channel.recv(9999)
    channel.close()
    return answer


def connect_and_execute_command_using_interactive_shell(ip_address, username, password, command):
    ssh_client = create_ssh_connection_using_paramiko(ip_address, username, password)
    channel = ssh_client.invoke_shell()
    wait_for_response(1)
    channel.send('{}\n'.format(command))
    wait_for_response(3)
    answer = channel.recv(9999)
    channel.close()
    return answer


def get_mnlent_number(cu_or_du):
    if 'cu' == cu_or_du.lower():
        return 1
    elif 'du' == cu_or_du.lower():
        return 2
    raise ValueError("Given parameter was not CU nor DU.")


def get_new_parameter_list_value_based_on_username(username):
    if 'toor' in username.lower() or 'root' == username.lower():
        return 'Root user public keys'
    elif 'serviceuser' == username.lower():
        return 'Service user public keys'
    raise ValueError("Given username does not exist.")


def get_public_keys_abbreviation_based_on_username(username):
    if 'toor' in username.lower() or 'root' == username.lower():
        return 'rootUserPublicKeys'
    elif 'serviceuser' == username.lower():
        return 'serviceUserPublicKeys'
    raise ValueError("Given username does not exist.")
