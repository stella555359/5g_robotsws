from __future__ import division
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
import re
from ute_wtssim import *
from ta5g_throughput import ta5g_throughput
from robot.libraries.OperatingSystem import OperatingSystem
from robot.api import logger

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')

postfix_three_numbers_with_spaces_regexp = r" +\d* +\d+ +\d+ +"
postfix_one_number_regexp = r" +\d"
prefixes_of_ROHC_statistics = {"compressed_pdu": r"Compressed PDUs \(ROHC\)",
                               "size_of_compressed_pdus": "Size of compressed PDUs, bytes",
                               "decompressed_pdus": r"Decompressed PDUs \(ROHC\)",
                               "size_of_decompressed_pdus": "Size of decompressed PDUs, bytes",
                               "decompressed_profile_0_pdus": "Decompressed Profile 0 PDUs",
                               "decompressed_profile_0_bytes": "Decompressed Profile 0 bytes",
                               "decompressed_profile_1_pdus": "Decompressed Profile 1 PDUs",
                               "decompressed_profile_1_bytes": "Decompressed Profile 1 bytes",
                               "decompressed_profile_2_pdus": "Decompressed Profile 2 PDUs",
                               "control_pdu_sent": "Control PDUs sent",
                               "rohc_feedback_sent": "ROHC Feedback sent",
                               "rohc_feedbacks": "ROHC feedbacks",
                               "decompressed_profile_2_bytes": "Decompressed Profile 2 bytes"}

throughput_prefixes = {"maximum": "Maximum data rate", "minimum": "Minimum data rate", "average": "Average data rate",
                       "last": "Last data rate"}

indexes = {"am": 1, "um": 0, "total": 2}
units = {"bps": 1, "kbps": 1000, "mbps": 1000000, "gbps": 1000000000}


class ThroughputException(Exception):
    pass


def _get_values_from_egate(command, regexp_line, regexp_values):
    raw_result = ute_wtssim_instance.execute_egate_command(cmd=command, pass_regexp=regexp_line, timeout=10)
    re_line_pattern = re.compile(regexp_line)
    result_line = re_line_pattern.search(raw_result).group(0)
    re_values_pattern = re.compile(regexp_values)
    return re_values_pattern.search(result_line).group(0).split()


def get_rohc_statistic(prefix, enb_id, cell_id, mode='am'):
    command = "uec_stats display type=cell_data_pdcp enb={} cell={} format=long".format(enb_id, cell_id)
    regexp = prefixes_of_ROHC_statistics[prefix] + postfix_three_numbers_with_spaces_regexp
    return _get_values_from_egate(command, regexp, postfix_three_numbers_with_spaces_regexp)[indexes[mode]]


def _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params):
    # direction: up / dl / bi
    command = "qfi_stats ue={} pdu={} qfi={} dir={} {}".format(ue_id, pdu_id, qfi_id, direction, optional_params)
    return _get_values_from_egate(command, regexp, r" +\d+ +")[0]


def rohc_statistic_greater_than_given_value(rohc_statistic_prefix, mode, value, enb_id, cell_id):
    list_of_values = get_rohc_statistic(rohc_statistic_prefix, enb_id, cell_id, mode)
    if not int(list_of_values) > int(value):
        raise ThroughputException(
            '{} actual value {} is not greater than expected value {} '.format(
                rohc_statistic_prefix, list_of_values, value)
        )


def rohc_statistic_smaller_than_given_value(rohc_statistic_prefix, mode, value, enb_id, cell_id):
    list_of_values = get_rohc_statistic(rohc_statistic_prefix, enb_id, cell_id, mode)
    if not int(list_of_values) < int(value):
        raise ThroughputException(
            '{} actual value {} is not smaller than expected value {} '.format(
                rohc_statistic_prefix, list_of_values, value)
        )


def rohc_statistic_equal_to_given_value(rohc_statistic_prefix, mode, value, enb_id, cell_id):
    list_of_values = get_rohc_statistic(rohc_statistic_prefix, enb_id, cell_id, mode)
    if not int(list_of_values) == int(value):
        raise ThroughputException(
            '{} actual value {} is not equal to expected value {} '.format(
                rohc_statistic_prefix, list_of_values, value)
        )


def verify_rohc_compression_ratio(compression_prefix, decompression_prefix, mode, value, margin, enb_id, cell_id):
    compressed_pdus_size = get_rohc_statistic(compression_prefix, enb_id, cell_id, mode)
    decompressed_pdus_size = get_rohc_statistic(decompression_prefix, enb_id, cell_id, mode)
    compression_ratio = float(compressed_pdus_size) / float(decompressed_pdus_size)
    if not (1.0 - float(margin)) <= compression_ratio / float(value) <= (1.0 + float(margin)):
        raise ThroughputException(
            'Compression ratio {} is not in margin {} of {}'.format(
                compression_ratio, margin, value)
        )


def expected_throughput_for_qfi_should_be_reached(ue_id, pdu_id, qfi_id, expected_throughput, unit,
                                                  margin, direction, method='average', optional_params=''):
    # margin                 from 0.0 to 1.0
    # direction              ul, dl, bi
    # unit                   bps, kbps, mbps, gbps
    # method                 maximum, minimum, average, last
    # expected_throughput    > 0.0
    regexp = throughput_prefixes[method] + r" +\d+.+"
    value_up = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, "ul", optional_params)
    value_down = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, "dl", optional_params)
    out = ""
    if direction == "bi" or direction == "ul":
        if not ((1.0 - float(margin)) <= float(value_up) / (float(expected_throughput) * units[unit])
                <= (1.0 + float(margin))):
            out = 'QFI {} throughput for uplink {} {} is not in margin of {} of expected throughput {} {}'.format(
                qfi_id, float(value_up) / units[unit], unit, margin, expected_throughput, unit)

    if direction == "bi" or direction == "dl":
        if not ((1.0 - float(margin)) <= float(value_down) / (float(expected_throughput) * units[unit])
                <= (1.0 + float(margin))):
            out += '\nQFI {} throughput for downlink {} {} is not in margin of {} of expected throughput {} {}'.format(
                qfi_id, float(value_down) / units[unit], unit, margin, expected_throughput, unit)

    if len(out) > 0:
        raise ThroughputException(out)


def check_number_of_total_packets_lost(ue_id, pdu_id, qfi_id, packet_loss, margin, direction, optional_params=''):
    # margin 0.0 - 1.0
    regexp = r"Total packets lost +\d+ +"
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) * float(packet_loss) <= float(value) <= (1.0 + float(margin)) * float(packet_loss):
        raise ThroughputException(
            'QFI {} total packet lost {} is not in margin of {} of expected number {}'.format(
                qfi_id, value, margin, packet_loss)
        )


def check_number_of_received_packets(ue_id, pdu_id, qfi_id, packet_number, direction, optional_params='', margin=0):
    # margin 0.0 - 1.0
    regexp = r"Total packets received +\d+ +"
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) * float(packet_number) <= float(value) <= (1.0 + float(margin)) * float(packet_number):
        raise ThroughputException(
            'QFI {} total packet number {} is not in margin of {} of expected number {}'.format(
                qfi_id, value, margin, packet_number)
        )


def check_packets_in_range(ue_id, pdu_id, qfi_id, min_packets, max_packets, direction, optional_params=''):
    regexp = r"Total packets received +\d+ +"
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (float(min_packets) <= float(value) <= float(max_packets)):
        raise ThroughputException(
            'QFI {} total packet number {} is not in the range of {} to {}'.format(
                qfi_id, value, min_packets, max_packets)
        )


def check_number_of_received_packets_is_bigger(ue_id, pdu_id, qfi_id, packet_number, direction, optional_params=''):
    regexp = r"Total packets received +\d+ +"
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (float(value) > float(packet_number)):
        raise ThroughputException(
            'QFI {} total packet number {} is not bigger than expected number {}'.format(
                qfi_id, value, packet_number)
        )


def check_number_of_pdcp_reorder_timeout(enb_id=2, cell_id=1, mode='total'):
    command = f'uec_stats id=1 enb={enb_id} cell={cell_id} type=cell_data_pdcp format=long'
    regexp = r'Number of tReorder timeouts +\d* +\d+ +\d+ +'
    reorder_value = _get_values_from_egate(command, regexp, postfix_three_numbers_with_spaces_regexp)[indexes[mode]]
    if int(reorder_value) > 0:
        raise ExecutionFailed(
            message=f'Number of PDCP tReorder timeouts {reorder_value} is bigger than expected 0',
            continue_on_failure=True
        )
    else:
        logger.info(
            f"Number of PDCP tReorder timeouts on cell id {cell_id} is {reorder_value}",
            html=True, also_console=True
        )


def check_bearer_throughput_for_single_ue(ue_id=11, bearer_id=2, throughput=5, direction='dl'):
    ta5g_throughput().expected_throughput_for_bearer_should_be_reached(
        ue_id=ue_id,
        throughput=throughput,
        direction=direction,
        bearer_id=bearer_id,
    )


def check_bearer_throughput_for_multiple_ues(first_ue_id=11, number_of_ues=3, bearer_id=2,
                                             throughput=5, direction='dl'):
    number_of_ues = int(number_of_ues)
    first_ue_id = int(first_ue_id)
    for ue_id in range(first_ue_id, first_ue_id + number_of_ues):
        check_bearer_throughput_for_single_ue(
            ue_id=ue_id,
            bearer_id=bearer_id,
            throughput=throughput,
            direction=direction,
        )


def display_bearer_statistics_for_multiple_nsa_ue(first_ue_id=11, last_ue_id=14, bearer_id=2, cell_group='mcg'):
    for i in range(int(first_ue_id), int(last_ue_id) + 1):
        ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
        ta5g_ue_wts.execute_egate_command_and_wait_for_data(
            cmd='bearer_stats ue={} id={} dc_cell_group={}'.
            format(i, int(bearer_id), cell_group))


def verify_ue_throughput(ue_id='1', type='pdsch', expected_tput='10'):
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    ue_stats_nr_output = ta5g_ue_wts.execute_egate_command(
        cmd='ue_stats_nr id={} type={}'.format(ue_id, type),
        pass_regexp='CellIndex-', timeout='150')
    OperatingSystem().create_file(path='/tmp/dl_stats.txt', content=ue_stats_nr_output)
    average_tput = OperatingSystem().run("cat /tmp/dl_stats.txt | grep -m 1 'CellIndex-' | awk '{print $8}'\n")
    logger.info('average_tput= {}'.format(average_tput))
    BuiltIn().should_be_true(float(average_tput) >= float(expected_tput))
