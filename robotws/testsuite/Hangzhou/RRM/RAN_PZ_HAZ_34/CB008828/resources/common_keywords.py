# -*- coding: utf-8 -*-
import time
import paramiko
import json
from ta5g_admin_operations import ta_admin_interface
from ta5g_ue_mobility import ta5g_ue_mobility
from ta5g_throughput import ta5g_throughput
from robot.errors import ExecutionFailed
from robot.api import logger
import re
from ute_wtssim import ute_wtssim
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem


tl = BuiltIn().get_variable_value('${tl}')


def change_rad_param_with_aashell(param, value):
    ssh = connect_ssh(str(tl.gnbs[0].dus[0].f1_m_ip_addr), 22, 'toor4nsn', 'oZPS0POrRieRtu')
    channel = ssh.invoke_shell()
    print(send_ssh_cmd('telnet 127.0.0.1 15007', channel))
    print(send_ssh_cmd('rad -mpw ' + param + ' ' + value, channel))
    ssh.close()


def send_ssh_cmd(cmd, chann):
    chann.send(cmd + '\n')

    for _ in range(10):
        if chann.recv_ready():
            output = chann.recv(102400)
            return output
        else:
            time.sleep(2)
            # if not (chann.recv_ready()):
            #     break


def connect_ssh(ip, port, user, passw):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(ip, port, user, passw, allow_agent=False)
    return ssh


def check_bts_is_in_given_state(bts_state, timeout='480'):
    time_step = 10
    timeout = int(timeout)
    time_start = time.time()
    while time.time() < time_start + timeout:
        with ta_admin_interface.admin_interface() as admin_client:
            bts_info = admin_client.get_mrbts_state()
            logger.info('\nTime: {} ; Expected BTS state: {} ; Current BTS state: {}'.
                        format(str(time.ctime(int(time.time()))), bts_state, bts_info), also_console=True)
            if bts_info in bts_state:
                return True
            time.sleep(time_step)
    raise ExecutionFailed(message="BTS is not in expected status!")


def _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params):
    # direction: up / dl / bi
    command = "qfi_stats ue={} pdu={} qfi={} dir={} {}".format(ue_id, pdu_id, qfi_id, direction, optional_params)
    return _get_values_from_egate(command, regexp, r" +\d+ +")[0]


def expected_throughput_for_qfi_should_be_reached(ue_id, pdu_id, qfi_id, expected_throughput, unit,
                                                  margin, direction, method='average', optional_params=''):
    # margin                 from 0.0 to 1.0
    # direction              ul, dl, bi
    # unit                   bps, kbps, mbps, gbps
    # method                 maximum, minimum, average, last
    # expected_throughput    > 0.0
    regexp = throughput_prefixes[method] + r" +\d+.+"
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) <= float(value) / (float(expected_throughput) * units[unit]) <= (1.0 + float(margin)):
        raise ThroughputException(
            'QFI {} throughput {} {} is not in margin of {} of expected throughput {} {}'.format(
                qfi_id, float(value) / units[unit], unit, margin, expected_throughput, unit)
        )
