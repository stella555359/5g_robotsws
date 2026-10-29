from __future__ import division
from builtins import object
from past.utils import old_div
from robot.api import logger

from robot.libraries.BuiltIn import BuiltIn
import re
from ute_wtssim import *

LOCAL_MOID_CELL_1 = "DN:NE-LNBTS-1/LNCEL-1/MCC-244/MNC-09"
pdcp_sn_length_15bit = 32768
pdcp_sn_length_18bit = 262144

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

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')
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


def get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params=''):
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
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) <= float(value) / (float(expected_throughput) * units[unit]) <= (1.0 + float(margin)):
        raise ThroughputException(
            'QFI {} throughput {} {} is not in margin of {} of expected throughput {} {}'.format(
                qfi_id, float(value) / units[unit], unit, margin, expected_throughput, unit)
        )


def get_average_for_given_qfi(ue_id, pdu_id, qfi_id, direction, method='average', optional_params=''):
    # direction: up / dl / bi
    regexp = throughput_prefixes[method] + r" +\d+.+"
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)

    return value


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


def check_number_of_received_packets_is_bigger(ue_id, pdu_id, qfi_id, packet_number, direction, optional_params=''):
    regexp = r"Total packets received +\d+ +"
    value = _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (float(value) > float(packet_number)):
        raise ThroughputException(
            'QFI {} total packet number {} is not bigger than expected number {}'.format(
                qfi_id, value, packet_number)
        )


def perform_intracell_handover_with_nr_sec_cap_defined_and_wait_for_confirmation(ue_id, nr_sec_cap, timeout=5):
    # :param ue_id:
    # :param timeout:
    logger.console("Performing intracell handover for UE {}".format(ue_id))
    ute_wtssim_instance.execute_egate_command(
        cmd='ue_reauth id={} nr_sec_cap={}'.format(ue_id, nr_sec_cap),
        pass_regexp='Reauthentication procedure is complete.',
        timeout=timeout,
    )
