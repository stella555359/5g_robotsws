from robot.libraries.BuiltIn import BuiltIn
import math
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.pcap.pcap_common import pdml_file_to_dict, get_packet
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.pcap.pcap_common import same_group_packets
from robot.api import logger


def log_robot(e=''):
    BuiltIn().log_to_console(e)
    BuiltIn().log(e)


def dBm(mv_val):
    return 10 * math.log10(mv_val)


def verify_counters_04(counters, cell_id):
    for k in sorted(counters.keys()):
        log_robot((k, counters[k][str(cell_id)]))
    pass


def verify_counters_05(counters, cell_id):
    print_counters_dict(counters, cell_id)

    # counters values
    c_000 = 3000
    c_101 = 0
    c_121 = 32
    c_125 = 36.5
    c_126 = 36.5
    c_135 = 36
    c_136 = 36

    c_401 = 0
    c_406 = 0
    c_40x = 12.5

    # 000, 101
    assert is_in_interval(counters['M55324C00000'][cell_id], c_000,
                          10), 'counter M55324C00000 incorrect, expected: %d' % c_000
    assert is_in_interval(counters['M55324C00101'][cell_id], c_101,
                          1.5), 'counter M55324C00101 incorrect, expected: %d' % c_101

    # 121, previous values of range 1.5
    assert is_in_interval(dBm(counters['M55324C00121'][cell_id] / counters['M55324C00000'][cell_id]), c_121,
                          12.5), 'counter M55324C00121 incorrect, expected: %d' % c_121

    # 125, 126, previous values of range 1.5
    assert is_in_interval(dBm(counters['M55324C00125'][cell_id] / counters['M55324C00000'][cell_id]), c_125,
                          12.5), 'counter M55324C00125 incorrect, expected: %d' % c_125
    assert is_in_interval(dBm(counters['M55324C00126'][cell_id] / counters['M55324C00000'][cell_id]), c_126,
                          12.5), 'counter M55324C00126 incorrect, expected: %d' % c_126

    # 135, 136, previous values of range 1.5
    assert is_in_interval(dBm(counters['M55324C00135'][cell_id] / counters['M55324C00000'][cell_id]), c_135,
                          12.5), 'counter M55324C00135 incorrect, expected: %d' % c_135
    assert is_in_interval(dBm(counters['M55324C00136'][cell_id] / counters['M55324C00000'][cell_id]), c_136,
                          12.5), 'counter M55324C00136 incorrect, expected: %d' % c_136

    # 401, 406
    assert counters['M55324C00401'][cell_id] == c_401, 'counter M55324C00401 incorrect, expected: %d' % c_401
    assert counters['M55324C00406'][cell_id] == c_406, 'counter M55324C00406 incorrect, expected: %d' % c_406

    # 400, 402, 403, 404, 405, previous values of range 1.5
    assert is_in_interval(dBm(counters['M55324C00400'][cell_id] / counters['M55324C00000'][cell_id]), c_40x,
                          9.5), 'counter M55324C00400 incorrect, expected: %d' % c_40x
    assert is_in_interval(dBm(counters['M55324C00402'][cell_id] / counters['M55324C00000'][cell_id]), c_40x,
                          9.5), 'counter M55324C00402 incorrect, expected: %d' % c_40x
    assert is_in_interval(dBm(counters['M55324C00403'][cell_id] / counters['M55324C00000'][cell_id]), c_40x,
                          9.5), 'counter M55324C00403 incorrect, expected: %d' % c_40x
    assert is_in_interval(dBm(counters['M55324C00404'][cell_id] / counters['M55324C00000'][cell_id]), c_40x,
                          9.5), 'counter M55324C00404 incorrect, expected: %d' % c_40x
    assert is_in_interval(dBm(counters['M55324C00405'][cell_id] / counters['M55324C00000'][cell_id]), c_40x,
                          9.5), 'counter M55324C00405 incorrect, expected: %d' % c_40x


def is_in_interval(val, expected, deviation):
    if expected - deviation <= val <= expected + deviation:
        return True
    return False


def print_counters_dict(dictt, cell_id):
    keys = list(dictt.keys())
    keys.sort()
    log_robot('counters in dBm below')
    for k in keys:
        if dictt[k][cell_id] != 0 and k != 'M55324C00000':
            log_robot(
                (k + '/' + 'M55324C00000', dBm(dictt[k][cell_id] / dictt['M55324C00000'][cell_id])))
        else:
            log_robot((k, dictt[k][cell_id]))


def get_eirp_counter_list(n=25):
    # conter_prefix = 'M55324C001'
    # counters = [conter_prefix + str(x+13).zfill(2) for x in range(n)]
    # printing(counters)
    # return counters

    return ['M55324C00400', 'M55324C00401', 'M55324C00402', 'M55324C00403',
            'M55324C00404', 'M55324C00405', 'M55324C00406', 'M55324C00101',
            'M55324C00121', 'M55324C00125', 'M55324C00126', 'M55324C00135',
            'M55324C00136', 'M55324C00000']


def get_muted_beams_counter_list():
    # beam1 and beam5 muted
    # checking M55305C000XX, M55305C070XX, M55305C120XX
    return ['M55305C00002', 'M55305C00006',
            'M55305C07002', 'M55305C07006',
            'M55305C12002', 'M55305C12006']


def bip_logs_2001_02(path):
    field_names = ['DlData_PdcchSendReq', 'DlData_SsBlockSendReq', 'DlData_CsiRsSendReq']
    packets_dict = pdml_file_to_dict(path, field_names)

    assert len(packets_dict) > 0, 'No packets found. Check luashark version'
    logger.debug('Found %d packets' % len(packets_dict))

    pdcchSendReq = (('packet_name_', 'patternId_item_0'), ('DlData_PdcchSendReq', '0x0038'))
    ssBlockSendReq1 = (('packet_name_', 'patternId_item_0'), ('DlData_SsBlockSendReq', '0x003d'))
    ssBlockSendReq2 = (('packet_name_', 'patternId_item_1'), ('DlData_SsBlockSendReq', '0x0038'))
    csiSendReq = (('packet_name_', 'patternId_item_0', 'patternId_item_1', 'patternId_item_2', 'patternId_item_3'),
                  ('DlData_CsiRsSendReq', '0x0038', '0x0038', '0x003d', '0x003d'))

    packets = [pdcchSendReq, ssBlockSendReq1, ssBlockSendReq2, csiSendReq]
    result = same_group_packets(packets_dict, packets)

    BuiltIn().log('ssblocks')
    BuiltIn().log(get_packet(packets_dict, ssBlockSendReq1[0], ssBlockSendReq1[1]))
    BuiltIn().log(get_packet(packets_dict, ssBlockSendReq2[0], ssBlockSendReq2[1]))

    BuiltIn().log('csi')
    BuiltIn().log(get_packet(packets_dict, csiSendReq[0], csiSendReq[1]))

    BuiltIn().log('pdcch')
    BuiltIn().log(get_packet(packets_dict, pdcchSendReq[0], pdcchSendReq[1]))

    assert result, 'Correct group of packets with the same sfn not found'
    return result


def bip_logs_2001_04(path):
    field_names = ['DlData_PdcchSendReq', 'DlData_SsBlockSendReq', 'DlData_CsiRsSendReq', 'UlData_PucchReceiveRespPs']
    packets_dict = pdml_file_to_dict(path, field_names)

    non_muted = r'(?!0x004c)(?!0x0060)0x\w{4}'

    assert len(packets_dict) > 0, 'No packets found. Check luashark version'
    logger.debug('Found %d packets' % len(packets_dict))

    ssBlockSendReq1 = (('packet_name_', 'patternId_item_0'), ('DlData_SsBlockSendReq', '0x0047'))
    ssBlockSendReq2 = (('packet_name_', 'patternId_item_0', 'patternId_item_1'),
                       ('DlData_SsBlockSendReq', '0x0051', '0x0056'))
    ssBlockSendReq3 = (('packet_name_', 'patternId_item_0'), ('DlData_SsBlockSendReq', '0x005b'))
    csiSendReq = (('packet_name_', 'patternId_item_0', 'patternId_item_1', 'patternId_item_2', 'patternId_item_3',
                   'trsInfo'),
                  ('DlData_CsiRsSendReq', non_muted, non_muted, non_muted, non_muted, '0'))
    pdcchSendReq = (('packet_name_', 'patternId_item_0'), ('DlData_PdcchSendReq', non_muted))
    puchReceiveRespPs = (('packet_name_', 'crc', 'dtx'), ('UlData_PucchReceiveRespPs', '0', '0'))

    packets = [pdcchSendReq, ssBlockSendReq1, ssBlockSendReq2, ssBlockSendReq3, csiSendReq, puchReceiveRespPs]
    result = same_group_packets(packets_dict, packets)

    BuiltIn().log('ssblocks')
    BuiltIn().log(get_packet(packets_dict, ssBlockSendReq1[0], ssBlockSendReq1[1]))
    BuiltIn().log(get_packet(packets_dict, ssBlockSendReq2[0], ssBlockSendReq2[1]))
    BuiltIn().log(get_packet(packets_dict, ssBlockSendReq3[0], ssBlockSendReq3[1]))

    BuiltIn().log('csi')
    BuiltIn().log(get_packet(packets_dict, csiSendReq[0], csiSendReq[1]))

    BuiltIn().log('pdcch')
    BuiltIn().log(get_packet(packets_dict, pdcchSendReq[0], pdcchSendReq[1]))

    BuiltIn().log('pucch')
    BuiltIn().log(get_packet(packets_dict, puchReceiveRespPs[0], puchReceiveRespPs[1]))

    assert result, 'Correct group of packets with the same sfn not found'
    return result
