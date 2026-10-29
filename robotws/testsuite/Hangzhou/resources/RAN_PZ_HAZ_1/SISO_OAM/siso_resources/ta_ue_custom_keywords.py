# -*- coding: utf-8 -*-

"""
:copyright: NSN
:author: Bartosz Koperek
:contact: bartosz.koperek@nokia.com
:maintainer Bartosz Koperek:
:contact bartosz.koperek@nokia.com:
"""
from __future__ import absolute_import
from __future__ import print_function
from ute_common_abstract_core.aliases_registry import aliases_registry, release_aliases

import time


def _access_get_info(ue_alias, info_type, timeout=None):
    ue = aliases_registry()[ue_alias]
    result = ue.get_info(info_type, timeout)
    print("Ue %s has info %s = %s" % (ue_alias, info_type, result))
    return result


def ue_reboot(ue_alias):
    ue = aliases_registry()[ue_alias]
    ue.ue_reboot_and_wait_until_it_boots()


def ue_release(ue_alias):
    release_aliases(ue_alias)


def ue_ensure_that_ip_is_correct(ue_alias, timeout):
    ip = _access_get_info(ue_alias, 'IP', timeout)
    print(ip)


def ue_expect_technology(ue_alias, expected_technology, timeout):
    ue = aliases_registry()[ue_alias]
    ue.expect_technology(expected_technology, timeout)


def ue_get_cellid(ue_alias):
    cell = _access_get_info(ue_alias, "CELL_ID")
    return cell


def ue_get_signal_strength(ue_alias):
    signal = _access_get_info(ue_alias, "SIGNAL_STRENGTH")
    return signal


def ue_show_basic_info(ue_alias):
    _access_get_info(ue_alias, "MCC")
    _access_get_info(ue_alias, "MNC")
    _access_get_info(ue_alias, "IP")
    _access_get_info(ue_alias, "CELL_ID")
    _access_get_info(ue_alias, "SIGNAL_STRENGTH")
    _access_get_info(ue_alias, "PCI")
    _access_get_info(ue_alias, "UE_OS_VER")
    _access_get_info(ue_alias, "DEVICE_MODEL")


def transfer_file_from_ftp(ue_alias, ftp_ip, remote_file_path, ftp_port=21, ftp_user=None, ftp_pass=None):
    ue = aliases_registry()[ue_alias]
    ue.transfer_file_from_ftp(ftp_ip, remote_file_path, ftp_port, ftp_user, ftp_pass)


def transfer_file_to_ftp(ue_alias, ftp_ip, local_filepath, remote_dir_path, ftp_user, ftp_pass, ftp_port=21):
    ue = aliases_registry()[ue_alias]
    ue.transfer_file_to_ftp(ftp_ip, local_filepath, remote_dir_path, ftp_user, ftp_pass, ftp_port)


def http_request(ue_alias, url):
    ue = aliases_registry()[ue_alias]
    ue.http_request(url)


def start_rrc(ue_alias, diag_cfg_path=None):
    ue = aliases_registry()[ue_alias]
    ue.start_rrc_logs(diag_cfg_path)


def stop_rrc(ue_alias):
    ue = aliases_registry()[ue_alias]
    lst = ue.stop_rrc_logs()
    print(lst)


def read_file(filepath):
    file_lst = []
    with open(filepath, 'r') as f:
        for line in f:
            line = line.replace('\n', '')
            file_lst.append(line)
    return file_lst


def stop_and_analyze_rrc(ue_alias, messages_db_file):
    ue = aliases_registry()[ue_alias]
    msg_lst = ue.stop_rrc_logs()
    search_msgs(messages_db_file, msg_lst)


def search_msgs(messages_db_file, msg_lst):
    exp_msg_db_lst = read_file(messages_db_file)
    print('\n'.join(msg_lst))
    found_counter = []
    found_dict = {m: 0 for m in exp_msg_db_lst}
    for exp_msg in exp_msg_db_lst:
        print('looking for msg: {}'.format(exp_msg))
        find_msg(msg_lst, exp_msg, found_counter, found_dict)
    _verify_msgs(found_dict)


def _verify_msgs(found_dict):
    not_founds = [m for m, f in found_dict.items() if f == 0]
    if len(not_founds) > 0:
        raise Exception('Defined messages not found in collected rrc logs from UE : {}'.format(', '.join(not_founds)))


def find_msg(msg_lst, exp_msg, found_counter, found_dict):
    for msg in msg_lst:
        if exp_msg in msg:
            print('Message "{}" found in collected messages! line: {}'.format(exp_msg, msg))
            found_counter.append(exp_msg)
            found_dict[exp_msg] = 1
            break


def ue_detach(ue_alias):
    ue = aliases_registry()[ue_alias]
    ue.detach()


def ue_attach(ue_alias):
    ue = aliases_registry()[ue_alias]
    ue.attach()
    ue_ensure_that_ip_is_correct(ue_alias, 15)


def ue_detach_and_attach(ue_alias, timeout=60):
    ue = aliases_registry()[ue_alias]
    ue.detach()
    ue.attach()
    ue_expect_technology(ue_alias, 'LTE', timeout)
    ue_ensure_that_ip_is_correct(ue_alias, 15)


def ue_set_initial_conditions_for_lte_only(ue_alias, net_mode_time=6, exp_tech_time=60):
    ue = aliases_registry()[ue_alias]
    ue.attach()
    time.sleep(net_mode_time)
    ue.change_network_mode('LTE_GSM_WCDMA')
    time.sleep(net_mode_time)
    ue.change_network_mode('LTE_only')
    ue_expect_technology(ue_alias, 'LTE', exp_tech_time)
    ue_show_basic_info(ue_alias)


def ue_set_initial_conditions_for_lte_wcdma_gsm(ue_alias, net_mode_time=6, exp_tech_time=60):
    ue = aliases_registry()[ue_alias]
    ue.attach()
    time.sleep(net_mode_time)
    ue.change_network_mode('LTE_only')
    time.sleep(net_mode_time)
    ue.change_network_mode('LTE_GSM_WCDMA')
    ue_expect_technology(ue_alias, 'LTE', exp_tech_time)
    ue_show_basic_info(ue_alias)


def ue_wait_for_lte(ue_alias):
    ue_expect_technology(ue_alias, 'LTE', 600)
    ue_show_basic_info(ue_alias)


def ue_wait_for_cell(ue_alias, exp_cell, timeout=20, interval=5):
    n = int(timeout)
    i = float(interval)
    while n >= 0:
        cell_id = ue_get_cellid(ue_alias)
        #       print 'Current cell ID = {}'.format(cell_id)
        if cell_id != exp_cell and n >= 0:
            print('Cell ID different than expected.')
            time.sleep(i)
            n -= i
            continue
        elif cell_id == exp_cell:
            print('Cell ID equal to expected : {}'.format(cell_id))
            return 1
    else:
        raise Exception('Cell ID different than expected: {} with timeout {}!'.format(cell_id, n))


def ue_make_sure_is_in_correct_enb(ue_alias, enb):
    cell_id = ue_get_cellid(ue_alias)
    enb_cell_based = (int(cell_id) - 1) / 256
    if str(enb_cell_based) == enb:
        print('UE is in correct cell ID: {} and eNB: {}'.format(cell_id, enb_cell_based))
        return 1
    else:
        ue_show_basic_info(ue_alias)
        raise Exception('UE attached to wrong eNB: {}'.format(enb_cell_based))


def ue_make_sure_is_in_correct_cell(ue_alias, cell):
    cell_id = ue_get_cellid(ue_alias)
    if str(cell_id) == cell:
        print('UE is in correct cell ID: {}'.format(cell_id))
        return 1
    else:
        ue_show_basic_info(ue_alias)
        raise Exception('UE attached to wrong cell: {} should be in cell: {}'.format(cell_id, cell))


def ue_make_sure_is_capable_for_ps_service(ue_alias):
    ip = _access_get_info(ue_alias, 'IP', 20)
    print(ip)


def ue_get_avg_throughput(dt_alias):
    dt = aliases_registry()[dt_alias]
    avg_throughput = dt.get_average_throughput()
    print("In your custom keyword print_avg_throughput, you readed: %.2f" % avg_throughput)
    clinet_report = '\n'.join(dt.client_lines_report)
    server_report = '\n'.join(dt.server_lines_report)
    return [avg_throughput / 1024.00, clinet_report + '\n\n' + server_report]


def ue_print_avg_throughput(dt_alias):
    dt = aliases_registry()[dt_alias]
    avg_throughput = dt.get_average_throughput()
    print("In your custom keyword print_avg_throughput, you readed: %.2f" % avg_throughput)
    return avg_throughput


def ue_review_iperf_reports(dt_alias):
    dt = aliases_registry()[dt_alias]
    client_rows = dt.get_client_report_rows()
    server_rows = dt.get_server_report_rows()
    print("Row has fields:")
    print(dir(client_rows[0]))
    print("[Client Bandwidth]\t[Server Bandwidth]\t[Bandwidth Diff]")
    for c, s in zip(client_rows, server_rows):
        bandwidth_diff = float(c.bandwidth_amount) - float(s.bandwidth_amount)
        print("%s %s \t\t\t\t %s %s \t\t\t\t %.1f" % (c.bandwidth_amount,
              c.bandwidth_unit, s.bandwidth_amount, s.bandwidth_unit, bandwidth_diff))


def enacc_cell_to_block(loop, cells_lst):
    return cells_lst[loop]
