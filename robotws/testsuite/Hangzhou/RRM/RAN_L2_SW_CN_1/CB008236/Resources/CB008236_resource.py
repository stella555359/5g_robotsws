import re
import subprocess
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.api import logger
import time

throughput_prefixes = {"maximum": "Maximum data rate", "minimum": "Minimum data rate", "average": "Average data rate",
                       "last": "Last data rate"}

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')
indexes = {"am": 1, "um": 0, "total": 2}
units = {"bps": 1, "kbps": 1000, "mbps": 1000000, "gbps": 1000000000}


class ThroughputException(Exception):
    pass


def send_a4_measurement(ue_id='1', a4_params='phycell_id=52 nrsrp_nr=60 event=A4'):
    meas_id = check_a4_measurement_id(ue_id)
    wts = BuiltIn().get_library_instance('ute_wtssim')
    wts.execute_egate_command(
        cmd='ue_measurement_send_nr id={} meas_id={} {}'.format(ue_id, meas_id, a4_params))


def check_a4_measurement_id(ue_id):
    pat_nr_meas = (
        'NR MEASUREMENT IDENTITIES:.*MeasId  ObjectId  ReportCfgId.*\\d+')
    pat_meas_id = ('\\d+')
    regx_nr_meas = re.compile(pat_nr_meas, re.MULTILINE)
    regx_meas_id = re.compile(pat_meas_id)

    ue_meas_disp = disp_ue_measurement(ue_id=ue_id)
    nr_meas = (regx_nr_meas.findall(ue_meas_disp))

    if len(nr_meas) == 0:
        time.sleep(12)
        ue_meas_disp = disp_ue_measurement(ue_id=ue_id)
        nr_meas = (regx_nr_meas.findall(ue_meas_disp))
    meas_id = regx_meas_id.findall(nr_meas[0])
    a4_meas_id = int(meas_id[0])
    logger.info('Detected A4 MeasId= {}'.format(a4_meas_id))
    return a4_meas_id


def disp_ue_measurement(ue_id):
    wts = BuiltIn().get_library_instance('ute_wtssim')
    ue_meas_disp = wts.execute_egate_command(
        cmd='ue_meas_disp id={}'.format(ue_id), pass_regexp='Measurement Configuration', timeout='5')
    ue_meas_disp = ue_meas_disp.replace("\r\n", " ")
    return ue_meas_disp


def _get_values_from_egate(command, regexp_line, regexp_values):
    raw_result = ute_wtssim_instance.execute_egate_command(
        cmd=command, pass_regexp=regexp_line, timeout=10)
    re_line_pattern = re.compile(regexp_line)
    result_line = re_line_pattern.search(raw_result).group(0)
    re_values_pattern = re.compile(regexp_values)
    return re_values_pattern.search(result_line).group(0).split()


def _get_statistic_for_given_qfi(regexp, ue_id, pdu_id, qfi_id, direction, optional_params):
    # direction: up / dl / bi
    command = "qfi_stats ue={} pdu={} qfi={} dir={} {}".format(
        ue_id, pdu_id, qfi_id, direction, optional_params)
    return _get_values_from_egate(command, regexp, r" +\d+ +")[0]


def expected_throughput_for_qfi_should_be_reached(ue_id, pdu_id, qfi_id, expected_throughput, unit,
                                                  margin, direction, method='average', optional_params=''):
    # margin                 from 0.0 to 1.0
    # direction              ul, dl, bi
    # unit                   bps, kbps, mbps, gbps
    # method                 maximum, minimum, average, last
    # expected_throughput    > 0.0
    regexp = throughput_prefixes[method] + r" +\d+.+"
    value = _get_statistic_for_given_qfi(
        regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) <= float(value) / (float(expected_throughput) * units[unit]) <= (1.0 + float(margin)):
        raise ThroughputException(
            'QFI {} throughput {} {} is not in margin of {} of expected throughput {} {}'.format(
                qfi_id, float(value) / units[unit], unit, margin, expected_throughput, unit)
        )


def check_number_of_total_packets_lost(ue_id, pdu_id, qfi_id, packet_loss, margin, direction, optional_params=''):
    # margin 0.0 - 1.0
    regexp = r"Total packets lost +\d+ +"
    value = _get_statistic_for_given_qfi(
        regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) * float(packet_loss) <= float(value) <= (1.0 + float(margin)) * float(packet_loss):
        raise ThroughputException(
            'QFI {} total packet lost {} is not in margin of {} of expected number {}'.format(
                qfi_id, value, margin, packet_loss)
        )


def check_number_of_received_packets(ue_id, pdu_id, qfi_id, packet_number, direction, optional_params='', margin=0):
    # margin 0.0 - 1.0
    regexp = r"Total packets received +\d+ +"
    value = _get_statistic_for_given_qfi(
        regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) * float(packet_number) <= float(value) <= (1.0 + float(margin)) * float(packet_number):
        raise ThroughputException(
            'QFI {} total packet number {} is not in margin of {} of expected number {}'.format(
                qfi_id, value, margin, packet_number)
        )


def expected_throughput_for_qfi_should_be_reached(ue_id, pdu_id, qfi_id, expected_throughput, unit,
                                                  margin, direction, method='average', optional_params=''):
    # margin                 from 0.0 to 1.0
    # direction              ul, dl, bi
    # unit                   bps, kbps, mbps, gbps
    # method                 maximum, minimum, average, last
    # expected_throughput    > 0.0
    regexp = throughput_prefixes[method] + r" +\d+.+"
    value = _get_statistic_for_given_qfi(
        regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) <= float(value) / (float(expected_throughput) * units[unit]) <= (1.0 + float(margin)):
        raise ThroughputException(
            'QFI {} throughput {} {} is not in margin of {} of expected throughput {} {}'.format(
                qfi_id, float(value) / units[unit], unit, margin, expected_throughput, unit)
        )


def check_number_of_total_packets_lost(ue_id, pdu_id, qfi_id, packet_loss, margin, direction, optional_params=''):
    # margin 0.0 - 1.0
    regexp = r"Total packets lost +\d+ +"
    value = _get_statistic_for_given_qfi(
        regexp, ue_id, pdu_id, qfi_id, direction, optional_params)
    if not (1.0 - float(margin)) * float(packet_loss) <= float(value) <= (1.0 + float(margin)) * float(packet_loss):
        raise ThroughputException(
            'QFI {} total packet lost {} is not in margin of {} of expected number {}'.format(
                qfi_id, value, margin, packet_loss)
        )
