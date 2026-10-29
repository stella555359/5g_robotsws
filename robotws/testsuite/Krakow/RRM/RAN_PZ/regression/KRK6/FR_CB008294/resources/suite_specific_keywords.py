import re
from dataclasses import dataclass
from robot.api import logger
from robot.api.deco import keyword
from taf.analyzer.pcap import pcap


class DataTransferVerificationError(Exception):
    """Throws when verification of data transfer failed."""


def parse_expected_data_transfer_level(level: str, units: str = 'Gbits/sec') -> float:
    """
    Parses user defined expected level of data transfer.

    :param level: expected level (value and units as string)
    :param units: expected units in level parameter
    :return: flout values from passed string
    """

    if not isinstance(level, str) or units not in level:
        raise DataTransferVerificationError(f'Expected level of data transfer should be in STRING format '
                                            f'like: "4.1 {units}"')

    level_value = level.strip().rstrip(units).strip()

    try:
        level_value = float(level_value)
    except ValueError:
        raise DataTransferVerificationError(f'Expected level of data transfer cannot be converted '
                                            f'to float value: {level_value}')

    return level_value


class IperfOutputParsingError(Exception):
    """Throws when IPERF output cannot be parsed."""


@dataclass
class IperfLine:
    """Represents single line from iperf log."""

    bandwidth: int
    units: str
    interval: str
    raw: str

    @classmethod
    def parse_line(cls, line):
        """Creates instance based on iperf line: '[  9] 23.0-24.0 sec  1.03 MBytes  8.65 Mbits/sec'."""

        search_results = re.search(r'([\d.]+\s*-\s*[\d.]+)\s+sec\s+([\d.]+\s+\w?Bytes)\s+([\d.]+\s+\w?bits/sec)\s*',
                                   line)

        if not search_results:
            raise IperfOutputParsingError(f'Iperf line cannot be parsed: {line}')

        interval, _, raw_bandwidth = search_results.groups()
        bandwidth, units = raw_bandwidth.split()
        bandwidth = cls.cast_bandwidth(bandwidth.strip(), line)

        return cls(bandwidth, units.strip(), interval.strip(), line)

    @classmethod
    def has_data(cls, line: str) -> bool:
        """Returns true is line contains data of Bandwith and Transfer fields."""

        return 'Bytes' in line and 'bits/sec' in line

    @staticmethod
    def cast_bandwidth(value: str, line: str) -> float:
        """Dumps bandwith string value to float value."""

        try:
            value = float(value)
        except ValueError:
            raise IperfOutputParsingError(f'Iperf Bandwith value ({value}) cannot be casted to float: {line}')

        return value


def _convert_iperf_bandwidth(bandwidth: float, source_units: str, target_units: str) -> float:
    """
    Converts iperf bandwidth value between K/M/G bits-per-second units.

    :param bandwidth: Numeric bandwidth value to convert.
    :param source_units: Source units (Kbits/sec, Mbits/sec or Gbits/sec).
    :param target_units: Target units (Kbits/sec, Mbits/sec or Gbits/sec).
    :return: Converted bandwidth value in target units.
    """
    unit_to_mbits = {
        'Kbits/sec': 1 / 1000,
        'Mbits/sec': 1,
        'Gbits/sec': 1000,
    }

    source_to_mbits = unit_to_mbits.get(source_units)
    if source_to_mbits is None:
        raise DataTransferVerificationError(f'Unsupported data transfer units: {source_units}')

    bandwidth_mbits = bandwidth * source_to_mbits

    if target_units == 'Mbits/sec':
        return bandwidth_mbits
    if target_units == 'Gbits/sec':
        return bandwidth_mbits / 1000
    if target_units == 'Kbits/sec':
        return bandwidth_mbits * 1000

    raise DataTransferVerificationError(f'Unsupported target data transfer units: {target_units}')


@keyword()
def verify_tcp_uplink_data_transfer(minimum_level: str, maximum_level: str, iperf_log_path: str) -> None:
    """
    Verifies level of data transfer in iperf UL log file.
    Value of uplink data transfer is calculated by sum of value in all streams.

    :param minimum_level: minimum expected data transfer level in Mbits/sec units
    :param maximum_level: maximum expected data transfer level in Mbits/sec units
    :param iperf_log_path: path to iperf log file (from appserver for uplink)
    :return: None
    """

    minimum_value = parse_expected_data_transfer_level(minimum_level, units='Mbits/sec')
    maximum_value = parse_expected_data_transfer_level(maximum_level, units='Mbits/sec')

    with open(iperf_log_path, 'r', encoding='utf-8') as iperf_log_file:

        report_buffer = []

        for line in iperf_log_file:

            report_buffer.append(line)

            if len(report_buffer) > 9:
                report_buffer.pop(0)

        logger.info(f'UL data transfer summary per stream:\n{"".join(report_buffer)}')

        summary = next(filter(lambda item: 'SUM' in item, report_buffer[::-1]), '')

        if not summary:
            raise DataTransferVerificationError('SUM line not found in UL iperf log summary.')

        logger.info(f'UL data transfer summary line: {summary}')

        iperf_line = IperfLine.parse_line(summary)
        tput = _convert_iperf_bandwidth(iperf_line.bandwidth, iperf_line.units, target_units='Mbits/sec')

        logger.info(f'Average UL TCP data transfer level: {round(tput, 2)} Mbits/sec')

        if tput < minimum_value or tput > maximum_value:
            logger.info(f'TCP data transfer is out of range: ({minimum_value}, {maximum_value}): {tput} Mbits/sec.')
            raise DataTransferVerificationError(f'Incorrect TCP data transfer level: {round(tput, 2)} Mbits/sec.')


@keyword()
def verify_tcp_downlink_data_transfer(minimum_level: str, maximum_level: str, iperf_log_path: str) -> None:
    """
    Verifies level of data transfer in iperf DL log file.
    Value of downlink data transfer is get from summary line.

    :param minimum_level: minimum expected data transfer level in Gbits/sec units
    :param maximum_level: maximum expected data transfer level in Gbits/sec units
    :param iperf_log_path: path to iperf log file (from appserver for downlink - mode is reversed)
    :return: None
    """

    minimum_value = parse_expected_data_transfer_level(minimum_level, units='Gbits/sec')
    maximum_value = parse_expected_data_transfer_level(maximum_level, units='Gbits/sec')

    with open(iperf_log_path, 'r', encoding='utf-8') as iperf_log_file:

        report_buffer = []

        for line in iperf_log_file:

            report_buffer.append(line)

            if len(report_buffer) > 9:
                report_buffer.pop(0)

        logger.info(f'Data transfer summary per stream:\n{"".join(report_buffer)}')

        summary = next(filter(lambda item: 'SUM' in item, report_buffer[::-1]), '')

        logger.info(f'Data transfer summary line: {summary}')

        iperf_line = IperfLine.parse_line(summary)
        tput = _convert_iperf_bandwidth(iperf_line.bandwidth, iperf_line.units, target_units='Gbits/sec')

        logger.info(f'Average TCP data transfer level: {tput} Gbits/sec')

        if tput < minimum_value or tput > maximum_value:
            logger.info(f'TCP data transfer is out of range: ({minimum_value}, {maximum_value}): {tput} Gbits/sec.')
            raise DataTransferVerificationError(f'Incorrect TCP data transfer level: {tput} Gbits/sec.')


def get_ng_reset_message(pcap_file: str):
    """
    Returns NgReset message from pcap file.

    :param pcap_file: path to pcap file
    :return: found packet or None
    """

    pcap_ = pcap()
    pcap_verifier_id = 'one-keyword-verifier'
    pcap_.setup(infile=pcap_file, display_filter='ngap', alias=pcap_verifier_id)
    packets = pcap_.get_packets(pcap_parser=pcap_verifier_id)

    for packet in packets:
        packet_code = packet.get_field_value_by_name('ngap.procedureCode')
        if len(packet_code) > 0 and packet_code[0] == '20':
            return packet

    return None


class CounterNotIncrementedError(Exception):
    """Throws when counter value was not incremented."""


class CounterNotFoundError(Exception):
    """Throws when counter container is empty."""


def require_counter_values(counters, level):
    """
    Requires that counters have expected level.
    :param counters: dictionary with names of counters and theirs values
    :param level: one expected value for all counters in previous parameter
    :return: None
    """

    if len(counters) == 0:
        raise CounterNotFoundError('Counter container is empty.')

    invalid_counters_msg = ''

    for label, value in counters.items():

        logger.info(f'Counter {label} value: {value}')

        if int(value) != int(level):
            invalid_counters_msg += f'Counter {label} value is not equal: {value}\n'

    if len(invalid_counters_msg) != 0:
        logger.info(f'<b>{invalid_counters_msg}</b>', html=True)
        raise CounterNotIncrementedError(f'Some counter values have unexpected values (details in log.html file).')


def compare_counter_values(counters_a, counters_b):

    if len(counters_a) == 0:
        raise CounterNotFoundError('First counter container is empty.')

    if len(counters_b) == 0:
        raise CounterNotFoundError('Second counter container is empty.')

    invalid_counters_msg = ''

    for label, value_a in counters_a.items():
        value_b = counters_b.get(label)
        logger.info(f'Counter {label} value change: {value_a} -> {value_b}')

        if value_a >= value_b:
            invalid_counters_msg += f'Counter {label} value was not incremented: {value_a} <= {value_b}\n'

    if len(invalid_counters_msg) != 0:
        logger.info(f'<b>{invalid_counters_msg}</b>', html=True)
        raise CounterNotIncrementedError(f'Some counter values were not incremented (details in log.html file).')
