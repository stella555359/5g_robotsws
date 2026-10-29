"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>
"""

import logging
from ta_egate_cmd_parser import ta_egate_cmd_parser
from robot.api.deco import keyword
# from robot.libraries.BuiltIn import BuiltIn

MBPS_1 = 1000000
SPLIT_BEARER_ID = 2


def verify_qfi_traffic(trf_rate, ue_id, pdu_id, qfi_id, direction):
    ta_egate = ta_egate_cmd_parser()
    cmd = ta_egate.get_command('bearer_stats')
    bearer_stats_out = cmd(ue=ue_id, pdu=pdu_id, qfi=qfi_id, dir=direction.lower()).execute_and_parse()
    avg_data_rate = int(bearer_stats_out['Average data rate']['Value'].split('(')[0])
    total_packets_lost = int(bearer_stats_out['Total packets lost']['Value'].split('(')[0])
    logging.debug('Total packets lost: {}'.format(total_packets_lost))
    if trf_rate * 0.8 < avg_data_rate < trf_rate * 1.2:
        logging.info('Avg {} data traffic rate occurred as expected - equals to {} '.format(direction, avg_data_rate))
    else:
        raise AssertionError('Unexpected {} avg data traffic rate - equals to {} '.format(direction, avg_data_rate))


def verify_split_bearer_traffic(trf_rate, ue_id, bearer_type, direction):
    ta_egate = ta_egate_cmd_parser()
    cmd = ta_egate.get_command('bearer_stats')
    bearer_stats_out = cmd(ue=ue_id, id=SPLIT_BEARER_ID, dir=direction.lower(),
                           dc_cell_group=bearer_type).execute_and_parse()
    avg_data_rate = int(bearer_stats_out['Average data rate']['Value'].split('(')[0])
    total_packets_lost = int(bearer_stats_out['Total packets lost']['Value'].split('(')[0])
    logging.debug('Total packets lost: {}'.format(total_packets_lost))
    if trf_rate * 0.8 < avg_data_rate < trf_rate * 1.2:
        logging.info('Avg {} data traffic rate occurred as expected - equals to {} '.format(direction, avg_data_rate))
    else:
        raise AssertionError('Unexpected {} avg data traffic rate - equals to {} '.format(direction, avg_data_rate))


@keyword("Verify ${traffic_rate}MBps UL and DL traffic on PDU-${pdu_id} QFI-${qfi_id} for UE${ue_id}")
def verify_dl_ul_qfi_traffic(traffic_rate, pdu_id, qfi_id, ue_id):
    """
    Check average traffic rate specified QFI
    :param traffic_rate: expected average traffic rate
    :param qfi_id:
    :param pdu_id:
    :param ue_id:
    :return:
    """
    trf_rate = int(traffic_rate) * MBPS_1
    verify_qfi_traffic(trf_rate, ue_id, pdu_id, qfi_id, 'dl')
    verify_qfi_traffic(trf_rate, ue_id, pdu_id, qfi_id, 'ul')


@keyword("Verify ${traffic_rate}MBps ${direction:(UL|DL)} traffic on PDU-${pdu_id} QFI-${qfi_id} for UE${ue_id}")
def verify_dl_or_ul_qfi_traffic(traffic_rate, direction, pdu_id, qfi_id, ue_id):
    """
    Check average traffic rate specified QFI
    :param traffic_rate: expected average traffic rate
    :param direction:
    :param qfi_id:
    :param pdu_id:
    :param ue_id:
    :return:
    """
    trf_rate = int(traffic_rate) * MBPS_1
    verify_qfi_traffic(trf_rate, ue_id, pdu_id, qfi_id, direction)


@keyword("Verify ${traffic_rate}MBps UL and DL traffic on ${bearer_type:(ALL|MCG|SCG)} split bearer for UE${ue_id}")
def verify_dl_ul_dc_bearer_traffic(traffic_rate, bearer_type, ue_id):
    """
    Check average traffic rate on DC bearer
    :param traffic_rate: expected average traffic rate
    :param bearer_type: ALL|MCG|SCG
    :param ue_id:
    :return:
    """
    trf_rate = int(traffic_rate) * MBPS_1
    bearer_type = bearer_type.lower()
    verify_split_bearer_traffic(trf_rate, ue_id, bearer_type, 'dl')
    verify_split_bearer_traffic(trf_rate, ue_id, bearer_type, 'ul')


@keyword("Verify ${traffic_rate}MBps DL traffic on ${bearer_type:(ALL|MCG|SCG)} split bearer for UE${ue_id}")
def verify_dl_dc_bearer_traffic(traffic_rate, bearer_type, ue_id):
    """
    Check average traffic rate on DC bearer
    :param traffic_rate: expected average traffic rate
    :param bearer_type: ALL|MCG|SCG
    :param ue_id:
    :return:
    """
    trf_rate = int(traffic_rate) * MBPS_1
    bearer_type = bearer_type.lower()
    verify_split_bearer_traffic(trf_rate, ue_id, bearer_type, 'dl')


@keyword("Verify that traffic on ${cell_type:(PCELL|SCELL)} for UE${ue_id} is greater than ${traffic_rate}MBps")
def verify_ue_stats_nr_in_active_carrier_aggregation(cell_type, ue_id, traffic_rate):
    ta_egate = ta_egate_cmd_parser()
    cmd = ta_egate.get_command('ue_stats_nr')
    cell_index = '0' if cell_type == 'PCELL' else '1'
    ue_stats_nr_out = cmd(id=ue_id, scell=cell_index, type='pdsch').execute_and_parse()

    traffic_rate = float(traffic_rate)
    avg_data_rate = float(ue_stats_nr_out['CellIndex-{}'.format(cell_index)]['Average']['value'])

    if traffic_rate < avg_data_rate:
        logging.info('Avg traffic rate on {} occurred above expected {} - equals to {} '.format(cell_type,
                                                                                                traffic_rate,
                                                                                                avg_data_rate))
    else:
        raise AssertionError('Avg traffic rate on {} occurred below expected {} - equals to {} '.format(cell_type,
                                                                                                        traffic_rate,
                                                                                                        avg_data_rate))
