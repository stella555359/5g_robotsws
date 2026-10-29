"""
Author: Ming Shi
Contact: ming.shi@nokia-sbell.com
"""
import functools
import os.path
import re
import time

import pexpect
import taf.transport.ssh as ssh
from taf.hw.rf_attenuator import rf_attenuator
from robot.libraries.BuiltIn import BuiltIn
import taf.sbts.oam.coam.admin as coam
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter import *
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB012544_FDD.Resources.start_paging_and_traffic_via_thread import *


tl = BuiltIn().get_variable_value("${tl}")
ute_username = tl.test_pc.default_ssh_connection_details.username
ute_ip = tl.test_pc.default_ssh_connection_details.addr
ute_password = tl.test_pc.default_ssh_connection_details.password
tool_path = ""
ip = ""
rm_flag = True
timeout_arg = 120
gnb_log_tool_arg = "-s"


class GnbLogs:
    def __init__(self):
        pass

    @classmethod
    def run_gnb_logs_tool(cls, gnb_logs_tool_path, gnb_ip, is_rm_old_log_file=True, timeout=120, tool_arg="-s"):
        def func_name(func):
            @functools.wraps(func)
            def exec_func(*args, **kwargs):
                with open("./run_log.txt", "wb") as f:
                    child = pexpect.spawn(command=f"ssh {ute_username}@{ute_ip}", logfile=f)
                    child.expect('password:')
                    child.sendline(ute_password)
                    child.expect("ute")
                    child.sendline(f"cd {gnb_logs_tool_path}")
                    child.expect("gnb_logs")
                    if is_rm_old_log_file is True:
                        child.sendline(f"rm -rf BTS-*")
                        child.expect("gnb_logs")
                    child.sendline(f"./gnb_logs {gnb_ip} {tool_arg}")
                    child.expect("uit", timeout=timeout)
                    result = func(*args, **kwargs)
                    child.sendline("\r")
                    # child.expect('intend to other BBMOD', timeout=timeout)
                    child.expect('Tool finished running.', timeout=timeout)
                    child.close()
                    return result

            def set_params(gnb_logs_tool_path_value, gnb_ip_value, is_rm_old_log_file_value,
                           timeout_value, tool_arg_value):
                nonlocal gnb_logs_tool_path
                nonlocal gnb_ip
                nonlocal is_rm_old_log_file
                nonlocal timeout
                nonlocal tool_arg
                gnb_logs_tool_path = gnb_logs_tool_path_value
                gnb_ip = gnb_ip_value
                is_rm_old_log_file = is_rm_old_log_file_value
                timeout = timeout_value
                tool_arg = tool_arg_value

            exec_func.set_params = set_params

            return exec_func

        return func_name

    # @property
    # def gnb_logs_tool_path(self):
    #     return self._gnb_logs_tool_path
    #
    # @gnb_logs_tool_path.setter
    # def gnb_logs_tool_path(self, value):
    #     self._gnb_logs_tool_path = value
    #
    # @property
    # def gnb_ip(self):
    #     return self._gnb_ip
    #
    # @gnb_ip.setter
    # def gnb_ip(self, value):
    #     self._gnb_ip = value

    # def conditionally_run_gnb_log_tool(self, condition):
    #     def condition_run(func):
    #         if condition:
    #             return self.run_gnb_logs_tool(func, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
    #         else:
    #             return func
    #
    #     return condition_run

    @staticmethod
    def get_l2_num_from_gnb_logs_tool_log(gnb_logs_tool_path, log_folder, nrCellIdentity, log_name="tool.log"):
        log_file_name = os.path.join(gnb_logs_tool_path, log_folder, log_name)
        with open(log_file_name, "r") as f:
            log_content = f.readlines()
            for line in log_content:
                if str(nrCellIdentity) in line:
                    # match more than 1 space
                    pattern = re.compile(pattern=r"\s+", flags=re.IGNORECASE)
                    # get l2 num 0x2730, and remove 0x
                    l2_num = pattern.split(line.strip())[4][2:]
                    return l2_num


@GnbLogs.run_gnb_logs_tool(tool_path, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
def make_voice_call(connection, ue_index=0, phone_number="6688", status=2):
    serial_number = tl.ues[ue_index].serial_number
    sshconn = ssh.ssh()
    sshconn.connect_to(hostname=tl.ues[ue_index].ssh_connection_details.addr,
                       username=tl.ues[ue_index].ssh_connection_details.username,
                       password=tl.ues[ue_index].ssh_connection_details.password,
                       alias=connection)
    time.sleep(5)
    sshconn.send_command(command=f'adb -s {serial_number} shell input keyevent 3',
                         connection=connection)
    time.sleep(2)
    sshconn.send_command(command=f'adb -s {serial_number} shell input swipe 500 2050 500 800',
                         connection=connection)
    time.sleep(2)
    sshconn.send_command(
        command=f'adb -s {serial_number} shell am start -a android.intent.action.CALL tel:+{phone_number}',
        connection=connection)
    time.sleep(20)
    sshconn.send_command(command=f'adb -s {serial_number} shell dumpsys telephony.registry |grep mCallState',
                         connection=connection)
    time.sleep(2)
    output = sshconn.read_output(connection=connection)
    time.sleep(1)
    sshconn.disconnect(connection=connection)
    if f"mCallState={status}" in output:
        return True
    else:
        return False


@GnbLogs.run_gnb_logs_tool(tool_path, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
def hang_up_voice_call(connection, ue_index=0, status=0):
    serial_number = tl.ues[ue_index].serial_number
    sshconn = ssh.ssh()
    sshconn.connect_to(hostname=tl.ues[ue_index].ssh_connection_details.addr,
                       username=tl.ues[ue_index].ssh_connection_details.username,
                       password=tl.ues[ue_index].ssh_connection_details.password,
                       alias=connection)
    time.sleep(5)
    sshconn.send_command(command=f'adb -s {serial_number} shell input keyevent 6',
                         connection=connection)
    time.sleep(20)
    sshconn.send_command(command=f'adb -s {serial_number} shell dumpsys telephony.registry |grep mCallState',
                         connection=connection)
    time.sleep(2)
    output = sshconn.read_output(connection=connection)
    time.sleep(1)
    sshconn.disconnect(connection=connection)
    if f"mCallState={status}" in output:
        return True
    else:
        return False


def run_make_voice_call(gnb_log_tool_path, nb_ip, connection, ue_index=0, phone_number="6688", status=2,
                        is_rm_old_log_file=True, timeout=120, tool_arg="-s"):
    make_voice_call.set_params(gnb_log_tool_path, nb_ip, is_rm_old_log_file, timeout, tool_arg)
    voice_result = make_voice_call(connection=connection, ue_index=ue_index, phone_number=phone_number, status=status)
    return voice_result


def run_hang_up_voice_call(gnb_log_tool_path, nb_ip, connection, ue_index=0, status=0, is_rm_old_log_file=True,
                           timeout=120, tool_arg="-s"):
    hang_up_voice_call.set_params(gnb_log_tool_path, nb_ip, is_rm_old_log_file, timeout, tool_arg)
    voice_result = hang_up_voice_call(connection=connection, ue_index=ue_index, status=status)
    return voice_result


def return_l2_num_from_gnb_logs_tool_log(gnb_logs_tool_path, log_folder, nrCellIdentity, log_name="tool.log"):
    l2_num = GnbLogs.get_l2_num_from_gnb_logs_tool_log(gnb_logs_tool_path=gnb_logs_tool_path, log_folder=log_folder,
                                                       nrCellIdentity=nrCellIdentity, log_name=log_name)
    return l2_num


@GnbLogs.run_gnb_logs_tool(tool_path, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
def online_modify_parameter(parameters_to_update_via_api, should_activate=True, skip_parameter_errors=True,
                            connection="GNB_OAM", gnb_index=0, timeout=60):
    coam.connect_to(bts_host=tl.gnbs[gnb_index].cu.oam_ssh_connection_details.addr,
                    username=tl.gnbs[gnb_index].cu.oam_http_connection_details.username,
                    password=tl.gnbs[gnb_index].cu.oam_http_connection_details.password,
                    bts_port='443',
                    name=connection)
    para_file = create_update_parameters_delta(parameters=parameters_to_update_via_api,
                                               connection=connection, timeout=timeout)
    print(para_file)
    update_via_api_status = perform_scf_delta_commission(delta_file=para_file['updated'],
                                                         skip_parameter_relation_errors=skip_parameter_errors,
                                                         should_activate=should_activate,
                                                         timeout=timeout,
                                                         connection=connection,)
    if should_activate == 'True':
        if 'PASS' not in update_via_api_status:
            raise ValueError("parameters do not update successfully.")
    else:
        print(f"Parameter update activation for {parameters_to_update_via_api} is not executed, "
              f"due to flag should_activate is set to {should_activate}")

    coam.teardown(connection=connection)
    return update_via_api_status


def run_online_modify_parameter(gnb_log_tool_path, nb_ip, parameters_to_update_via_api, gnb_index=0,
                                should_activate=True, skip_parameter_relation_errors=True, connection="GNB_OAM",
                                is_rm_old_log_file='True', timeout=120, tool_arg="-s"):
    online_modify_parameter.set_params(gnb_log_tool_path, nb_ip, is_rm_old_log_file, timeout, tool_arg)
    update_status = online_modify_parameter(parameters_to_update_via_api=parameters_to_update_via_api,
                                            should_activate=should_activate,
                                            skip_parameter_errors=skip_parameter_relation_errors,
                                            connection=connection,
                                            gnb_index=gnb_index,
                                            timeout=timeout)
    return update_status


@GnbLogs.run_gnb_logs_tool(tool_path, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
def adjust_pa_value(att_ipaddr, att_api_port, vendor, att_ports, origin_values, target_values, att_connection_port=None,
                    max_attenuation_value=127, model="HBTE"):
    att = rf_attenuator()
    att.setup_attenuator(ip_addr=att_ipaddr, port=att_api_port, attenuation_port_numbers=att_connection_port,
                         max_attenuation=max_attenuation_value, model=model, vendor=vendor)
    num_att_port = len(att_ports)
    for num in range(num_att_port):
        att.set_attenuation(port=att_ports[num], value=origin_values[num])
        time.sleep(1)
        value_port = att.read_attenuation(port=att_ports[num])
        value_port = int(value_port)
        assert value_port == origin_values[
            num], f"Set attenuation value failed, port:{att_ports[num]}, value:{origin_values[num]}"
    for step_value in range(origin_values[0], target_values[0] + 1):
        for num in range(num_att_port):
            att.set_attenuation(port=att_ports[num], value=step_value)
            time.sleep(1)
            value_port = att.read_attenuation(port=att_ports[num])
            value_port = int(value_port)
            assert value_port == step_value, f"Set attenuation value failed, port:{att_ports[num]}, value:{step_value}"


def run_adjust_pa_value(gnb_log_tool_path, nb_ip, att_ipaddr, att_api_port, vendor, att_ports, origin_values,
                        target_values, att_connection_port=None, max_attenuation_value=127, model="HBTE",
                        is_rm_old_log_file=True, timeout=120, tool_arg="-s"):
    adjust_pa_value.set_params(gnb_log_tool_path, nb_ip, is_rm_old_log_file, timeout, tool_arg)
    adjust_pa_value(att_ipaddr=att_ipaddr, att_api_port=att_api_port, vendor=vendor, att_ports=att_ports,
                    origin_values=origin_values, target_values=target_values, att_connection_port=att_connection_port,
                    max_attenuation_value=max_attenuation_value, model=model)


@GnbLogs.run_gnb_logs_tool(tool_path, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
def start_dl_trafic_on_appserver(ue_index, dl_port, ue_addr, dl_time, dl_throughput,
                                 dl_length, process_num=5, connection="APPserver",
                                 timeout=120, iperf_index=2):
    sshconn = ssh.ssh()
    sshconn.connect_to(hostname=tl.ues[ue_index].iperf_details.ssh_connection_details.addr,
                       username=tl.ues[ue_index].iperf_details.ssh_connection_details.username,
                       password=tl.ues[ue_index].iperf_details.ssh_connection_details.password,
                       alias=connection)
    kill_command = f"ps -ef | grep iperf | grep -v grep | grep {dl_port} | awk '{{print $2}}' | xargs kill -9"
    sshconn.send_command(command=kill_command, connection=connection)
    time.sleep(2)

    # Start iperf process based on protocol
    iperf_command = f"iperf -c {ue_addr} -u -t {dl_time} -i 1 -p {dl_port} -P {process_num}" \
                    f" -f m -b {dl_throughput} -l {dl_length} -T 64 &"
    sshconn.send_command(command=iperf_command, connection=connection)
    time.sleep(2)
    check_command = f"ps -ef | grep iperf |grep {dl_port} |grep -v grep |awk '{{print ${iperf_index}}}'"
    sshconn.send_command(command=check_command, connection=connection, timeout=timeout)
    output = sshconn.read_output(connection=connection)
    iperf_pid = output.strip()
    if not iperf_pid or int(iperf_pid) <= 0:
        raise Exception("iperf process does not exist")
    return iperf_pid


def run_start_dl_traffic_during_bip(gnb_log_tool_path, nb_ip, ue_index, dl_port, ue_addr,
                                    dl_time, dl_throughput, dl_length, process_num=5,
                                    connection="APPserver", is_rm_old_log_file=True,
                                    timeout=60, tool_arg="-b"):
    start_dl_trafic_on_appserver.set_params(gnb_log_tool_path, nb_ip, is_rm_old_log_file, timeout, tool_arg)
    traffic_status = start_dl_trafic_on_appserver(ue_index=ue_index, dl_port=dl_port, ue_addr=ue_addr,
                                                  dl_time=dl_time, dl_throughput=dl_throughput,
                                                  dl_length=dl_length, process_num=process_num,
                                                  connection=connection, timeout=120)
    return traffic_status


@GnbLogs.run_gnb_logs_tool(tool_path, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
def start_paging_with_simulation(Simulation_IP, paging_command, connection="simulation_pc"):
    sshconn = ssh.ssh()
    connss = sshconn.connect_to(hostname=Simulation_IP,
                                username=tl.test_pc.default_ssh_connection_details.username,
                                password=tl.test_pc.default_ssh_connection_details.password,
                                alias=connection)
    tn = connss.invoke_shell()
    tn.send('telnet 0 20000\n')
    time.sleep(2)
    tn.recv(65535)
    time.sleep(2)
    tn.send('{}\n'.format(paging_command))
    time.sleep(20)
    tn.recv(65535)
    time.sleep(5)
    sshconn.disconnect(connection=connection)


def run_start_paging_during_bip(gnb_log_tool_path, nb_ip, Simulation_IP, paging_command,
                                connection="simulation_pc", is_rm_old_log_file=True,
                                timeout=60, tool_arg="-b"):
    start_paging_with_simulation.set_params(gnb_log_tool_path, nb_ip, is_rm_old_log_file, timeout, tool_arg)
    start_paging_status = start_paging_with_simulation(Simulation_IP=Simulation_IP, paging_command=paging_command,
                                                       connection=connection)
    return start_paging_status


@GnbLogs.run_gnb_logs_tool(tool_path, ip, rm_flag, timeout_arg, gnb_log_tool_arg)
def start_traffic_and_paging(action_mode, Simulation_IP, paging_command, dl_port,
                             ue_addr, dl_time, dl_throughput, dl_length):
    up = startpagingtraffic()
    up.start_via_threading(Simulation_IP, paging_command, dl_port, ue_addr,
                           dl_time, dl_throughput, dl_length, depart=action_mode)


def run_simulator_and_traffic_during_bip(gnb_log_tool_path, nb_ip, action_mode, Simulation_IP, paging_command,
                                         dl_port, ue_addr, dl_throughput, dl_time='3600', dl_length='1024B',
                                         is_rm_old_log_file=True, timeout=60, tool_arg="-b"):
    start_traffic_and_paging.set_params(gnb_log_tool_path, nb_ip, is_rm_old_log_file, timeout, tool_arg)
    start_traffic_andpaging_status = start_traffic_and_paging(action_mode, Simulation_IP, paging_command, dl_port,
                                                              ue_addr, dl_time, dl_throughput, dl_length)
    return start_traffic_andpaging_status
