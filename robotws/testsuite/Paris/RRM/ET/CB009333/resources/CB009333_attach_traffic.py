"""
:copyright: Nokia Networks
:author: Szymon Lange
:maintainer: Maryna Lukachyk
:contact: maryna.lukaczyk@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import time
from itertools import cycle

from robot.libraries.BuiltIn import BuiltIn
from ta5g_ue_mobility import ta5g_ue_mobility

from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import wait_for_requested_bts_state
from testsuite.Paris.RRM.ET.resources_KRK.python.common_wts import (
    stop_data_traffic_in_egate, register_ue, establish_pdu_session, deregister_ue, detach_ue, run_egate_cmd
)


def perform_5g_attach(ue_ids, net_arch='SA', cells='1', nwslice=None):
    if net_arch == 'SA':
        cells_list = str_to_list(cells)
        nwslices = '1' if not nwslice else str_to_list(nwslice)
        for ue_id, cell, nwslice in zip(ue_ids, cycle(cells_list), cycle(nwslices)):
            register_ue(ue_id=ue_id, cell_id=cell)
            run_egate_cmd(f'set_pdu_param ue={ue_id} pdu=1 trf_type=internal')
            establish_pdu_session(ue_id=ue_id, nwslice=nwslice, gw_id=ue_id)
    else:
        _multi_ue_nsa_attach_with_bearer_creation(ue_ids, cells)


def _multi_ue_nsa_attach_with_bearer_creation(ue_ids, cells):
    cells_list = str_to_list(cells)
    ta5g_ue_mobility().setup_x2_link()
    wait_for_requested_bts_state(bts_state='onair', retry=6, retry_interval=10)
    for ue_id, cell in zip(ue_ids, cycle(cells_list)):
        ta5g_ue_mobility().attach_ue_to_enb(
            ue_id=ue_id,
            pass_regexp='UE{}: === UE IS ACTIVE'.format(ue_id)
        )
        time.sleep(2)  # Wait for WTS to process UE attach before bearer creation
        run_egate_cmd(cmd=f'bearer_add ue={ue_id} id=3 filter=2 precedence=2 local_port=7072 proto=17 filter=3 '
                          f'precedence=3 remote_port=7073 proto=17', pass_regexp=r'Bearer-3 [(]EBI=6, QCI=8[)] created')
        ta5g_ue_mobility().start_gnb_addition_procedure(
            ue=ue_id,
            target_cells=cell,
            bearer='2,3',
            dc_type='split_scg',
            pass_regexp=r'UE{}: Proxy [(]eNB \d+ cell \d+[)] reported successful RA'.format(ue_id)
        )


def perform_5g_detach(ue_ids, net_arch='SA'):
    detach_function = deregister_ue if net_arch == 'SA' else detach_ue
    for ue in ue_ids:
        detach_function(ue_id=ue)


def merge_different_lengths_lists(l1, l2):
    list_of_tuples = zip(cycle(l1), l2) if len(l1) < len(l2) else zip(l1, cycle(l2))
    return list_of_tuples


def str_to_list(text):
    return text.replace(' ', '').split(',')


def generate_ue_ids(num_of_ues):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if 'NSA' in test_name:
        start_ue_id = 101
    elif 'FDD' in test_name:
        start_ue_id = 51
    else:
        start_ue_id = 1
    ue_ids = [ue for ue in range(start_ue_id, start_ue_id + int(num_of_ues))]
    return ue_ids


def start_burst_traffic_in_egate(ue_id, direction, period_ms=10, burst=2, size=6000, pdu=1, qfi=1, trf_id=1,
                                 protocol="udp", cl_trf_stats='on', timeout=30, net_arch='sa', bearer=2, **kwargs):
    """
    Start data traffic in egate for single UE

    :param ue_id: (int) UE id for which data traffic is started
    :param direction: (str) Traffic direction (ul, dl or bi)
    :param period_ms: (int) Period (4,6,8,...,20,30,40,...) between bursts
    :param burst: (int) Number of packets to be sent in burst
    :param size: (int) Layer 3 packet size range (size includes all headers beginning from IP)
                       {V}:{V}, where {V} is 42..9000
    :param pdu: (int) PDU id
    :param qfi: (int) QoS flow id
    :param trf_id: (int) Traffic id
    :param protocol: (str) Traffic protocol
    :param timeout: (int) Operation timeout
    :param cl_trf_stats: (str) Toggle for clear L3 statistics for the traffic instance (on, off)
    :param net_arch: (str) Type of 5G architecture: 'sa' or 'nsa'
    :param bearer: (int) Bearer id
    **kwargs: Additional parameters for egate command
    """

    command_args = ''
    dir_dict = {'dl': 'Downlink', 'ul': 'Uplink'}
    for key, value in kwargs.items():
        command_args += ' ' + str(key) + '=' + str(value)
    if net_arch == 'sa':
        cmd = f'trf_data_start ue={ue_id} dir={direction} period_ms={period_ms} burst={burst} size={size}' \
              f' pdu={pdu} qfi={qfi} trf_id={trf_id} protocol={protocol} cl_trf_stats={cl_trf_stats}{command_args}'
        pass_regexp = f'Started {dir_dict[direction]} Internal traffic over {protocol.upper()} on Ue:{ue_id}'
    else:
        cmd = f'trf_data_start ue={ue_id} dir={direction} period_ms={period_ms} burst={burst} size={size}' \
              f' id={bearer} trf_id={trf_id} protocol={protocol} cl_trf_stats={cl_trf_stats}{command_args}'
        pass_regexp = f'UE {ue_id}: {protocol.upper()} {direction.upper()} TRF'
    run_egate_cmd(cmd=cmd, pass_regexp=pass_regexp, timeout=timeout)
    logger_console(f'{direction.upper()} {protocol} data for UE {ue_id} is started')


def start_traffic(ue_ids, net_arch='SA', traffic_direction='dl', period_ms=10, burst=2, size_dl=6000, size_ul=1000,
                  qfi=None,
                  bearer=None, traffic_duration=15):
    """
    Start multiple traffics on desired QFIs or bearers.

    :param net_arch: (str)
    :param ue_ids: (list)
    :param traffic_direction: (str)
    :param period_ms: (int) Period (4,6,8,...,20,30,40,...) between bursts
    :param burst: (int) Number of packets to be sent in burst
    :param size: (int) Layer 3 packet size range (size includes all headers beginning from IP)
                       {V}:{V}, where {V} is 42..9000
    :param qfi: (str) QFIs on which to start traffic separated by ','. Order matters in case of multi-UE
    :param bearer: (str) bearers on which to start traffic separated by ','. Order matters in case of multi-UE
    :param traffic_duration: (int)
    """
    drb_param = 'qfi' if net_arch == 'SA' else 'bearer'
    drb_param_values = qfi if net_arch == 'SA' else bearer
    drb_param_values = [val.strip(' ') for val in drb_param_values.split(',')]
    for ue_id, drb_num in merge_different_lengths_lists(ue_ids, drb_param_values):
        logger_console(f'Start {traffic_direction.upper()} {net_arch} traffic on UE{ue_id} on {drb_param} {drb_num}')
        drb_arg = {drb_param: drb_num}
        if traffic_direction in ['bi', 'dl']:
            start_burst_traffic_in_egate(
                ue_id=ue_id, direction='dl', period_ms=period_ms, burst=burst, size=size_dl,
                trf_id=drb_num,
                net_arch=net_arch.lower(), **drb_arg
            )
        if traffic_direction in ['bi', 'ul']:
            start_burst_traffic_in_egate(
                ue_id=ue_id, direction='ul', period_ms=period_ms, burst=burst, size=size_ul,
                trf_id=drb_num,
                net_arch=net_arch.lower(), **drb_arg
            )


def stop_traffic(ue_ids, net_arch='SA', traffic_direction='dl', qfi=None, bearer=None,
                 wait_for_end_of_transmission_from_drb=2, delay_traffic_stop=None, **kwargs):
    """
    Stop multiple traffics on desired QFIs or bearers.

    :param net_arch: (str)
    :param ue_ids: (list)
    :param traffic_direction: (str)
    :param qfi: (str) QFIs on which to start traffic separated by ','. Order matters in case of multi-UE
    :param bearer: (str) bearers on which to start traffic separated by ','. Order matters in case of multi-UE
    :param wait_for_end_of_transmission_from_drb: (int)
    :param delay_traffic_stop: (bool) Delay traffic stop to acquire more data from second DRB
    """
    drb_param = 'qfi' if net_arch == 'SA' else 'bearer'
    drb_param_values = qfi if net_arch == 'SA' else bearer
    drb_param_values = [val.strip(' ') for val in drb_param_values.split(',')]

    for ue_id, drb_num in merge_different_lengths_lists(ue_ids, drb_param_values):
        logger_console(f'Stop {traffic_direction.upper()} {net_arch} traffic on UE{ue_id} on {drb_param} {drb_num}')
        drb_arg = {drb_param: drb_num}
        if traffic_direction in ['bi', 'dl']:
            stop_data_traffic_in_egate(
                ue_id=ue_id, direction='dl', pdu=1, trf_id=drb_num, net_arch=net_arch.lower(), **drb_arg
            )
        if traffic_direction in ['bi', 'ul']:
            stop_data_traffic_in_egate(
                ue_id=ue_id, direction='ul', pdu=1, trf_id=drb_num, net_arch=net_arch.lower(), **drb_arg
            )
        if delay_traffic_stop:
            time.sleep(2)  # Delay traffic stop to acquire more data from second DRB
    time.sleep(int(wait_for_end_of_transmission_from_drb))


def attach_with_traffic(net_arch, delay_traffic_stop, num_of_ues=1, cells='1', traffic_duration=15, **kwargs):
    ue_ids = generate_ue_ids(num_of_ues=num_of_ues)
    perform_5g_attach(net_arch=net_arch, ue_ids=ue_ids, cells=cells)
    start_traffic(net_arch=net_arch, ue_ids=ue_ids, traffic_duration=traffic_duration, **kwargs)
    time.sleep(int(traffic_duration))
    stop_traffic(net_arch=net_arch, ue_ids=ue_ids, delay_traffic_stop=delay_traffic_stop, **kwargs)
    perform_5g_detach(net_arch=net_arch, ue_ids=ue_ids)
