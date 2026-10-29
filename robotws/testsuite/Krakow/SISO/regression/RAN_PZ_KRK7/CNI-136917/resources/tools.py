import datetime
import time
import re
from taf.hw.optical_switch.devices.leoni import Leoni_mol_5x_2x6
from robot.api import logger
from taf.transport.ssh import ssh
from taf.transport.ssh.connection import SSHConnection
from taf.sbts.oam.coam.admin.interface import admin
from typing import NoReturn
from taf.rfrl.bts.devices.exceptions import AlarmIsNotActive, AlarmIsActive


ssh_smod = ssh()


def link_brake() -> NoReturn:
    optical_switch = Leoni_mol_5x_2x6('10.255.40.43')
    out1 = optical_switch.get_optical_switch_channels()
    print(out1)
    optical_switch.set_optical_switch_channels({3: 2})
    out2 = optical_switch.get_optical_switch_channels()
    print(out2)
    time.sleep(0.1)
    optical_switch.set_optical_switch_channels({3: 1})
    out3 = optical_switch.get_optical_switch_channels()
    print(out3)


def link_brake_while() -> NoReturn:
    start_time = datetime.datetime.now()
    end_time = start_time + datetime.timedelta(minutes=5)

    while datetime.datetime.now() < end_time:
        print('Break!: time: {}'.format(datetime.datetime.now()))
        link_brake()
        time.sleep(30)


def connect_to_bts_via_ssh(conn_alias: str) -> SSHConnection:
    try:
        bts_conn = ssh_smod.connect_to(hostname="192.168.255.129",
                                       username="toor4nsn",
                                       password="oZPS0POrRieRtu",
                                       alias=conn_alias)
    except Exception as err:
        logger.console(err)
        raise err
    logger.console(f"TUTAJ {type(bts_conn)}")
    return bts_conn


def get_file_data_content_from_remote(file_path) -> str:
    conn_alias = "get_data_conn"
    try:
        connect_to_bts_via_ssh(conn_alias)
        cat_cmd = f"cat {file_path}"
        file_content = ssh_smod.execute(cat_cmd, conn_alias)
    except Exception as err:
        logger.console(f"File uploading exception: {err}")
        raise err
    finally:
        ssh_smod.disconnect(conn_alias)
    return file_content


def get_addr_from_frips_file(serial_no) -> str:
    frips_path = "/rom/config/FRIps.txt"
    frips_content = get_file_data_content_from_remote(frips_path)
    ru_pattern = f"MRBTS-.*?;{serial_no.upper()}"
    ip_pattern = r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    ru_addr = re.findall(ip_pattern, re.findall(ru_pattern, frips_content)[0])
    return ru_addr[0]


def check_text_contain_substr(text: str, substr: str) -> NoReturn:
    if substr not in text:
        raise ValueError("Substring not found")


def trigger_fids_2929_and_2930(container: str, ru_sn: str, ru_user: str, ru_pass: str) -> NoReturn:
    read_buff_size = 65536
    ru_addr = get_addr_from_frips_file(ru_sn)
    ru_conn = None
    try:
        ru_conn_alias = "ru_conn"
        ru_conn = connect_to_bts_via_ssh(ru_conn_alias)
        channel = ru_conn.invoke_shell()
        time.sleep(2)

        attach_container_cmd = f"lxc-attach {container}"
        channel.send(''.join((attach_container_cmd, '\n')))
        time.sleep(2)

        send_file_cmd = f"ssh {ru_user}@{ru_addr}"
        channel.send(''.join((send_file_cmd, '\n')))
        time.sleep(2)
        recv_output = channel.recv(read_buff_size)
        logger.console(f"\n\nSSH RESPONSE: {recv_output}")
        if "(yes/no/[fingerprint])?" in str(recv_output):
            channel.send(''.join(("yes", '\n')))
            time.sleep(2)
            recv_output = channel.recv(read_buff_size)
            logger.console(f"\n\nSSH RESPONSE: {recv_output}")
            channel.send(''.join((ru_pass, '\n')))
            time.sleep(2)
            recv_output = channel.recv(read_buff_size)
            logger.console(f"\n\nSSH RESPONSE: {recv_output}")
            check_text_contain_substr(str(recv_output), "serviceuser@stratix10-azqp")
        elif "password:" in str(recv_output):
            channel.send(''.join((ru_pass, '\n')))
            time.sleep(2)
            recv_output = channel.recv(read_buff_size)
            logger.console(f"\n\nSSH RESPONSE: {recv_output}")
            check_text_contain_substr(str(recv_output), "serviceuser@stratix10-azqp")
        channel.send(''.join(("frmonShellClient", '\n')))
        time.sleep(2)
        recv_output = channel.recv(read_buff_size)
        logger.console(f"\n\nSSH RESPONSE: {recv_output}")
        check_text_contain_substr(str(recv_output), "frmonShellClient starting on ip:localhost port:2000")

        channel.send(''.join(("/ action create SfpInfo /SI" + '\r')))
        time.sleep(2)
        recv_output = channel.recv(read_buff_size)
        logger.console(f"\n\nSSH RESPONSE:: {recv_output}")
        check_text_contain_substr(str(recv_output), "done ok")

        channel.send(''.join(("/SI action sfp_override_gpio 1 SIGNAL_LOSS true" + '\r')))
        time.sleep(2)
        recv_output = channel.recv(read_buff_size)
        logger.console(f"\n\nSSH RESPONSE:: {recv_output}")
        check_text_contain_substr(str(recv_output), "done ok")
    except Exception as err:
        logger.console(f"Faults 2929 and 2930 triggerring error: {err}")
        raise err
    finally:
        ssh_smod.disconnect(ru_conn)


def disable_fids_2929_and_2930(container: str, ru_sn: str, ru_user: str, ru_pass: str) -> NoReturn:
    read_buff_size = 65536
    ru_addr = get_addr_from_frips_file(ru_sn)
    ru_conn = None
    try:
        ru_conn_alias = "ru_conn"
        ru_conn = connect_to_bts_via_ssh(ru_conn_alias)
        channel = ru_conn.invoke_shell()
        time.sleep(2)

        attach_container_cmd = f"lxc-attach {container}"
        channel.send(''.join((attach_container_cmd, '\n')))
        time.sleep(2)

        send_file_cmd = f"ssh {ru_user}@{ru_addr}"
        channel.send(''.join((send_file_cmd, '\n')))
        time.sleep(2)
        recv_output = channel.recv(read_buff_size)
        logger.console(f"\n\nSSH RESPONSE: {recv_output}")
        if "(yes/no/[fingerprint])?" in str(recv_output):
            channel.send(''.join(("yes", '\n')))
            time.sleep(2)
            recv_output = channel.recv(read_buff_size)
            logger.console(f"\n\nSSH RESPONSE: {recv_output}")
            channel.send(''.join((ru_pass, '\n')))
            time.sleep(2)
            recv_output = channel.recv(read_buff_size)
            logger.console(f"\n\nSSH RESPONSE: {recv_output}")
            check_text_contain_substr(str(recv_output), "serviceuser@stratix10-azqp")
        elif "password:" in str(recv_output):
            channel.send(''.join((ru_pass, '\n')))
            time.sleep(2)
            recv_output = channel.recv(read_buff_size)
            logger.console(f"\n\nSSH RESPONSE: {recv_output}")
            check_text_contain_substr(str(recv_output), "serviceuser@stratix10-azqp")

        channel.send(''.join(("frmonShellClient", '\n')))
        time.sleep(2)
        recv_output = channel.recv(read_buff_size)
        logger.console(f"\n\nSSH RESPONSE: {recv_output}")
        check_text_contain_substr(str(recv_output), "frmonShellClient starting on ip:localhost port:2000")

        channel.send(''.join(("/SI action cancel_sfp_override_gpio 1" + '\r')))
        time.sleep(2)
        recv_output = channel.recv(read_buff_size)
        logger.console(f"\n\nSSH RESPONSE:: {recv_output}")
        check_text_contain_substr(str(recv_output), "done ok")
    except Exception as err:
        logger.console(f"Faults 2929 and 2930 disabling error: {err}")
        raise err
    finally:
        ssh_smod.disconnect(ru_conn)


def get_list_of_raw_alarms_history_file() -> list:
    gnb_admin = admin()
    admin_conn = gnb_admin.connect_to()
    try:
        alarm_hist = gnb_admin.get_raw_alarm_history_file(connection=admin_conn)
    except Exception as err:
        logger.console(f"Admin conn error: {err}")
        raise err
    finally:
        gnb_admin.teardown_admin(connection=admin_conn)
    alarms_list = alarm_hist.split('\n')
    return alarms_list


def verify_alarm_is_active_in_raw_alarms_history_file(fault_id: str) -> bool:
    alarms_list = get_list_of_raw_alarms_history_file()
    for alarm in range(len(alarms_list)):
        if "Inactive faults" in alarms_list[alarm]:
            break
        elif fault_id in alarms_list[alarm]:
            return True
    raise AlarmIsNotActive


def verify_alarm_is_not_active_raw_alarms_history_file(fault_id: str) -> bool:
    alarms_list = get_list_of_raw_alarms_history_file()
    reversed_list = alarms_list[::-1]
    for alarm in range(len(reversed_list)):
        if "Inactive faults" in reversed_list[alarm]:
            break
        elif fault_id in reversed_list[alarm]:
            return True
    raise AlarmIsActive
