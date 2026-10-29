# -*- coding: utf-8 -*-

import cpe_command
import cpe
import logging
import time
import os
from ssh_command import send_iperf_data_via_remoteip, kill_inactive_iperf
import six

tput = {'dl': 'systemDataRateDlCurrent', 'ul': 'systemDataRateUlCurrent'}


def _get_lte_info(hostip, typy_name):
    cpe_0 = cpe.CPE(hostip, 3)
    cpe_0.login()
    pci = cpe_0.get_node_info(typy_name)
    return pci['items'][0][typy_name]


def _cpe_get_current_throughput_via_web(hostip, direction='dl'):
    cpe_0 = cpe.CPE(hostip)
    cpe_0.login()
    type_name = tput[direction]
    throughput = cpe_0.get_node_info(type_name)
    return int(throughput['items'][0][type_name])*8


def cpe_ue_attach(host_ip):
    lteMainStatusGet = _get_lte_info(host_ip, 'lteMainStatusGet')
    logging.info('lteMainStatusGet is {}'.format(lteMainStatusGet))
    if '{}'.format(lteMainStatusGet) == 'disconnected':
        command = cpe_command.CPE_command(host_ip)
        command.cpe_attach()


def cpe_ue_attach_cell(host_ip, cell_id):
    from scfc_for_zwc import get_cell_earfcn_and_pci
    lteMainStatusGet = _get_lte_info(host_ip, 'lteMainStatusGet')
    logging.info('lteMainStatusGet is {}'.format(lteMainStatusGet))
    if '{}'.format(lteMainStatusGet) == 'disconnected':
        cell_info = get_cell_earfcn_and_pci(cell_id)
        command = cpe_command.CPE_command(host_ip)
        command.cpe_lockcell(cell_id=cell_info)
        command.cpe_attach()


def cpe_ue_detach(host_ip):
    lteMainStatusGet = _get_lte_info(host_ip, 'lteMainStatusGet')
    logging.info('lteMainStatusGet is {}'.format(lteMainStatusGet))
    if '{}'.format(lteMainStatusGet) == 'connected':
        command = cpe_command.CPE_command(host_ip)
        command.cpe_detach()
        try:
            cpe_stop_ul_throughput(host_ip)
            cpe_stop_dl_throughput(host_ip)
        except Exception as result:
            pass


def cpe_send_ul_throughput(host_ip, send_target_ip, throughput_size):
    ul_thoughput = cpe_command.CPE_ul_thoughput(host_ip)
    ul_thoughput.cpe_send_ul_throughput(ul_iperf_ip=send_target_ip, ul_iperf_tp=throughput_size)


def cpe_send_dl_throughput(host_ip, throughput_size):
    cpe_command.cpe_send_dl_throughput(hostip=host_ip, thoughput=throughput_size)


def cpe_send_dl_throughput_longtime(host_ip, throughput_size):
    cpe_command.cpe_send_dl_throughput_longtime(hostip=host_ip, thoughput=throughput_size)


def cpe_send_ul_throughput_longtime(host_ip, send_target_ip, throughput_size):
    ul_thoughput = cpe_command.CPE_ul_thoughput(host_ip)
    ul_thoughput.cpe_send_ul_throughput(ul_iperf_ip=send_target_ip, ul_iperf_time=90000, ul_iperf_tp=throughput_size)


def cpe_send_dl_throughput_via_remote(host_ip, throughput_size, remote_pc_ip):
    server_addr = cpe_command.get_cpe_ipaddr(host_ip)
    send_iperf_data_via_remoteip(sys_ip=remote_pc_ip, active_s1_ip=server_addr, trans_data=throughput_size,
                                 len_size='1400B', duration_time='7200')


def cpe_stop_dl_throughput(host_ip):
    cpe_command.cpe_stop_dl_throughput(hostip=host_ip)


def cpe_stop_ul_throughput(host_ip):
    ul_thoughput = cpe_command.CPE_ul_thoughput(host_ip)
    ul_thoughput.cpe_stop_ul_throughput()


def cpe_stop_remote_dl_throughput(host_ip, remote_pc_ip):
    server_addr = cpe_command.get_cpe_ipaddr(host_ip)
    kill_inactive_iperf(sys_ip=remote_pc_ip, inactive_s1_ip=server_addr)


def get_cpe_ul_throughput(host_ip):
    try:
        throughput = _cpe_get_current_throughput_via_web(hostip=host_ip, direction='ul')
    except Exception as result:
        throughput = cpe_command.cpe_get_current_throughput(host_ip=host_ip, direction='ul')
    return throughput


def get_cpe_dl_throughput(host_ip):
    try:
        throughput = _cpe_get_current_throughput_via_web(hostip=host_ip, direction='dl')
    except Exception as result:
        throughput = cpe_command.cpe_get_current_throughput(host_ip=host_ip, direction='dl')
    return throughput


def cpe_reboot_and_wait_status_is_disconnect(host_ip, time_out=180):
    ul_thoughput = cpe_command.CPE_ul_thoughput(host_ip)
    ul_thoughput.cpe_reboot()
    start_time = time.time()
    while True:
        end_time = time.time()
        if (end_time-start_time) > time_out:
            return False
        else:
            try:
                lteMainStatusGet = _get_lte_info(host_ip, 'lteMainStatusGet')
                logging.info('lteMainStatusGet is {}'.format(lteMainStatusGet))
            except Exception as result:
                lteMainStatusGet = 'null'
                logging.info('lteMainStatusGet is {}'.format(lteMainStatusGet))
            if '{}'.format(lteMainStatusGet) == 'disconnected':
                return True
        time.sleep(1)


def throughput_should_be_meet_the_condition(host_ip, condition, target_value, direction, time_out=20):
    current_value = cpe_command.cpe_get_current_throughput(host_ip=host_ip, direction=direction)
    start_time = time.time()
    while True:
        end_time = time.time()
        if (end_time - start_time) > time_out:
            return False
        else:
            if '{}'.format(condition) == '>' and '{}'.format(current_value) > '{}'.format(target_value):
                return True
            elif '{}'.format(condition) == '>=' and '{}'.format(current_value) >= '{}'.format(target_value):
                return True
            elif '{}'.format(condition) == '==' and '{}'.format(current_value) == '{}'.format(target_value):
                return True
            elif '{}'.format(condition) == '<=' and '{}'.format(current_value) <= '{}'.format(target_value):
                return True
            elif '{}'.format(condition) == '<' and '{}'.format(current_value) < '{}'.format(target_value):
                return True


def override_cqi(host_ip, cqi_value):
    return cpe_command.override_cqi(host_ip, cqi_value)


def override_ri(host_ip, ri_value):
    return cpe_command.override_cqi(host_ip, ri_value)


def kill_iperf():
    os.system('killall iperf')
    return True


def cpe_reboot(host_ip):
    ul_thoughput = cpe_command.CPE_ul_thoughput(host_ip)
    ul_thoughput.cpe_reboot()
    logging.info('{} reboot finished'.format(host_ip))


def cpe_disable_tm9_and_reboot_waiting_for_disconnect(host_ip, time_out=180):
    tm9 = cpe_command.CPE_ul_thoughput(host_ip)
    tm9.disable_tm9_capability()
    status = cpe_reboot_and_wait_status_is_disconnect(host_ip, time_out)
    return status


def cpe_ensable_tm9_and_reboot_waiting_for_disconnect(host_ip, time_out=180):
    tm9 = cpe_command.CPE_ul_thoughput(host_ip)
    tm9.enable_tm9_capability()
    status = cpe_reboot_and_wait_status_is_disconnect(host_ip, time_out)
    return status


if __name__ == '__main__':
    # print cpe_reboot_and_wait_status_is_disconnect(host_ip='192.168.200.20')
    # print get_cpe_ul_throughput(host_ip='192.168.200.20')
    # cpe_ue_attach_cell(host_ip='192.168.200.19', cell_id=2)
    cpe_reboot_and_wait_status_is_disconnect(host_ip='192.168.200.19', time_out=180)
    pass
