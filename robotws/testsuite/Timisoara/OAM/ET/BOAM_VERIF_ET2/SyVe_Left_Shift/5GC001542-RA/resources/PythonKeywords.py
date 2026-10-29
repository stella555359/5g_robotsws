import time
from robot.api import logger
import ValuesGenerator

from taf.transport.ssh.interface import ssh
import taf.config.scf as scf_interface
import taf.sbts.oam.coam.admin as admin_cli_interface


ssh_usr = ssh()
scf = scf_interface.scf()
admin_cli = admin_cli_interface.admin()


def load_scf_file():
    admin_cli.get_current_scf_file("/tmp", "current_scf.xml")
    scf.load_scf("/tmp/current_scf.xml")


def get_this_bts_name(mrbts_id):
    return scf.get_value_from_scf(dist_name="MRBTS-"+mrbts_id, p_name="btsName")


def set_trblcadm_object(mrbts_id):
    parameters_list = ValuesGenerator.get_TRBLCADM_object_parameters()
    assert len(parameters_list) == 5

    if scf.is_object_in_scf("MRBTS-"+mrbts_id+"/MNL-1/MNLENT-1/TRBLCADM-1"):
        admin_cli.perform_object_recommissioning(
            dist_name="MRBTS-"+mrbts_id+"/MNL-1/MNLENT-1/TRBLCADM-1",
            parameter=parameters_list,
            operation="update",
            skip_parameter_relation_errors=True)
    else:
        admin_cli.perform_object_recommissioning(
            dist_name="MRBTS-" + mrbts_id + "/MNL-1/MNLENT-1/TRBLCADM-1",
            parameter=parameters_list,
            operation="create",
            skip_parameter_relation_errors=True)


# def connect_to_lss_server_ipv6_via_enb():
#     ssh_usr.connect_to(
#         hostname="2a00:8a00:6000:607c::5611", username="root", password="uteadmin", proxy="eNB", alias="lssv6")

def connect_to_lss_server_ipv6_via_enb():
    ssh_usr.connect_to(
        hostname="2a00:8a00:6000:607c::5611", username="root", password="uteadmin", alias="lssv6")


def connect_to_lss_server_ipv4():
    ssh_usr.connect_to(hostname="10.5.60.107", username="coam", password="zO&n1W*ktp7", alias="lssv4")


def connect_to_du():
    ssh_usr.connect_to(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu", alias="eNB")


def connect_to_rmod():
    ssh_usr.connect_to(hostname="192.168.254.52", username="root", password="umniedziala", proxy="eNB", alias="rmod")


def disconnect_du():
    ssh_usr.disconnect(connection="eNB")


def disconnect_rmod():
    ssh_usr.disconnect(connection="rmod")


def connect_to_gnb():
    ssh_usr.connect_to(hostname="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu", alias="eNB")


def generate_fault_10():
    connect_to_gnb()
    connect_to_rmod()
    ssh_usr.send_command(command="rfsw-reboot", connection="rmod")
    disconnect_rmod()


def generate_fault_4078():
    ssh_usr.execute(
        command="echo '#!/bin/bash' > /tmp/temp_script.sh; echo 'while [ 1 ]; do echo 0 > /dev/ddal/fan/0/pwm; "
                "echo 0 > /dev/ddal/fan/1/pwm; done' >> /tmp/temp_script.sh; chmod 775 /tmp/temp_script.sh",
        connection="eNB")
    ssh_usr.send_command(command="/tmp/temp_script.sh", connection="eNB")


def disable_fault_4078():
    ssh_usr.execute(command="killall temp_script.sh; rm /tmp/temp_script.sh", connection="eNB")


def generate_fault_4080():
    ssh_usr.execute(
        command="echo '#!/bin/bash' > /tmp/temp_script.sh; echo 'while [ 1 ]; do echo 255 > /dev/ddal/fan/0/pwm; echo "
                "255 > /dev/ddal/fan/1/pwm; done' >> /tmp/temp_script.sh; chmod 775 /tmp/temp_script.sh",
        connection="eNB")
    ssh_usr.send_command(command="/tmp/temp_script.sh", connection="eNB")


def disable_fault_4080():
    ssh_usr.execute(command="killall temp_script.sh; rm /tmp/temp_script.sh", connection="eNB")


def get_folders_amount(path):
    import os
    return sum(os.path.isdir(i) for i in os.listdir(path))


def get_directory_grep_list(grep_pattern, _connection="lssv4"):
    grep_command = "ls -l /opt/coam | grep " + str(grep_pattern)
    result = ssh_usr.execute(command=grep_command, connection=_connection)
    result_list = result.split("\n")
    return result_list[:-1]


def delete_bts_snapshot_from_lss(btsName, _connection="lssv4"):
    command = 'find /opt/coam/ -iname \'*'+btsName+'*\' -exec rm -r "{}" \\;'
    ssh_usr.execute(command, connection=_connection)


def trigger_fault_4078(times):
    for i in range(times):
        generate_fault_4078()
        logger.console("Fault 4078 " + str(i))
        time.sleep(600)
        disable_fault_4078()
        time.sleep(120)


def trigger_fault_10(times):
    for i in range(times):
        logger.console("LOOP "+str(i))
        generate_fault_10()
        logger.console("Fault 10 " + str(i))
        time.sleep(200)
        logger.console("WAKE UP")


def is_faults_list_complete(faults, expected_size):
    expected_size = int(expected_size)

    possible_fault_numbers = [10, 16, 22, 23] + list(range(24, 40))
    expected_fault_numbers = possible_fault_numbers[:expected_size]

    expected_fault_numbers = [str(i) for i in expected_fault_numbers]

    missing_fault_numbers_list = []

    for fault_nr in expected_fault_numbers:
        if not (fault_nr in faults):
            missing_fault_numbers_list.append(fault_nr)

    if missing_fault_numbers_list:
        logger.console("MISSING FAULT TRIGGERS: {}".format(missing_fault_numbers_list))
        return False

    return True
