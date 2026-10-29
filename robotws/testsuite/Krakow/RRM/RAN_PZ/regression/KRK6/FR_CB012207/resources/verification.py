"""
This file contains functions used in verification of tput and messages for CB012207.

:copyright: Nokia Networks
:author:   Kamil Bielecki <kamil.bielecki@nokia.com>
:maintainer:   Kamil Bielecki <kamil.bielecki@nokia.com>
"""

import re
from dataclasses import dataclass
from typing import Optional, Any

from robot.api import logger
from robot.api.deco import keyword
from taf.analyzer.pcap import pcap
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.sbts.oam.coam.admin.interface import admin
from taf.internal.sbts.admin import exceptions as admin_exceptions
from taf.rfrl.utilities.parsers.pcap_checker import pcap_checker

import testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB012207.resources.variables as msgs


class IperfOutputParsingError(Exception):
    """Throws when IPERF output cannot be parsed."""


class DataTransferVerificationError(Exception):
    """Throws when verification of data transfer failed."""


TPUT_UNIT = "Mbits/sec"

pc = pcap_checker()


def parse_expected_data_transfer_level(level: str, units: str = TPUT_UNIT) -> float:
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


@keyword()
def verify_tcp_data_transfer(minimum_level: str, maximum_level: str, iperf_log_path: str) -> None:
    """
    Verifies level of data transfer in iperf DL log file.
    Value of downlink data transfer is get from summary line.

    :param minimum_level: minimum expected data transfer level in Mbits/sec units
    :param maximum_level: maximum expected data transfer level in Mbits/sec units
    :param iperf_log_path: path to iperf log file (from appserver for downlink - mode is reversed)
    :return: None
    """

    minimum_value = parse_expected_data_transfer_level(minimum_level, units=TPUT_UNIT)
    maximum_value = parse_expected_data_transfer_level(maximum_level, units=TPUT_UNIT)

    with open(iperf_log_path, 'r', encoding='utf-8') as fh:

        report_buffer = []

        for line in fh:

            report_buffer.append(line)

            if len(report_buffer) > 9:
                report_buffer.pop(0)

        logger.info(f'Data transfer summary per stream:\n{"".join(report_buffer)}')

        summary = next(filter(lambda item: 'SUM' in item, report_buffer[::-1]), '')

        logger.info(f'Data transfer summary line: {summary}')

        iperf_line = IperfLine.parse_line(summary)

        logger.info(f"Line take from summary: {iperf_line}")
        logger.info(f"Value: {iperf_line.bandwidth}")
        logger.info(f"Units: {iperf_line.units}")

        if iperf_line.units == 'Gbits/sec':
            tput = iperf_line.bandwidth / 1000
        elif iperf_line.units == 'Mbits/sec':
            tput = iperf_line.bandwidth
        elif iperf_line.units == 'Kbits/sec':
            tput = iperf_line.bandwidth * 1000
        else:
            raise DataTransferVerificationError(f'Unsupported data transfer units: {iperf_line.units}')

        logger.info(f'Average TCP data transfer level: {tput} Mbits/sec')

        if tput < minimum_value or tput > maximum_value:
            logger.info(f'TCP data transfer is out of range: ({minimum_value}, {maximum_value}): {tput} Mbits/sec.')
            raise DataTransferVerificationError(f'Incorrect TCP data transfer level: {tput} Mbits/sec.')


def get_ng_reset_message(pcap_file: str) -> Optional[Any]:
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


@keyword()
def detect_bts_sw_version_via_rest_api(bts_host: str = '192.168.255.129',
                                       bts_port: int = 443,
                                       username: str = 'Nemuadmin',
                                       password: str = 'nemuuser',
                                       timeout: int = 30) -> str:
    """
    Detects the BTS software version via REST API.

    Args:
        bts_host (str): The IP address of the BTS host. Default is '192.168.255.129'.
        bts_port (int): The port to connect to the BTS. Default is 443.
        username (str): The username for login. Default is 'Nemuadmin'.
        password (str): The password for login. Default is 'nemuuser'.
        timeout (int): The connection timeout in seconds. Default is 30.

    Returns:
        str: The BTS software version.

    Raises:
        SWNotDetectedException: If the connection to the BTS is not possible via REST API.
    """

    admin_rest_api = admin()
    connection = None

    try:
        logger.debug("Try to connect to BTS via Rest API.")
        connection = admin_rest_api.connect_to(bts_host, bts_port, username, password, timeout)
        logger.debug("Connection successful. Try to get SW from BTS.")
        bts_sw = connection.get_sw_version()
        logger.debug("BTS SW check successful.")
    except (admin_exceptions.AdminApiConnectionClosedException, admin_exceptions.AdminApiProcedureFailureException,
            admin_exceptions.AdminApiNoResponseException, admin_exceptions.AdminApiTerminatedException) as error:
        logger.error(f"Error: Connection to BTS is not possible via REST API: {error}")
        raise SWNotDetectedException(f"Error: Connection to BTS is not possible via REST API: {error}")
    finally:
        if connection is not None:
            logger.debug("Close admin connection to BTS.")
            admin_rest_api.teardown()
            logger.debug("Admin connection closed.")

    logger.info(f"Detected BTS SW: {bts_sw}.")
    return bts_sw


@keyword()
def get_release_from_sw(bts_sw: str) -> str:
    """
    Retrieves the BTS software release version.

    Args:
        bts_sw Software of BTS.

    Returns:
        str: The BTS software release version.

    Raises:
        SWNotDetectedException: If the BTS software version cannot be detected.
    """

    logger.debug("Getting release from BTS SW.")
    bts_sw_release = SbtsSwVersion(bts_sw).release
    logger.info(f"BTS SW Release is: {bts_sw_release}.")
    return bts_sw_release


def check_counter_incremented(counter_id: str, counter_values: dict) -> None:
    """
    This function checks if given counter has been incremented (is not zero)

    :param counter_id: id of counter to be checked
    :param counter_values: dict containing related counter values
    """
    last_value = list(counter_values[counter_id].values())[-1]
    logger.info(f"Counter {counter_id} for cell A equals {last_value}")
    assert last_value > 0


def check_counter_zero(counter_id: str, counter_values: dict) -> None:
    """
        This function checks if given counter has not been incremented (is zero)

        :param counter_id: id of counter to be checked
        :param counter_values: dict containing related counter values
        """
    last_value = list(counter_values[counter_id].values())[-1]
    logger.info(f"Counter {counter_id} for cell A equals {last_value}")
    assert last_value == 0


def check_cb008806_counters(counters_bts_0: dict, counters_bts_1: dict) -> None:
    sw_gnb = detect_bts_sw_version_via_rest_api()
    counters_bts_0 = counters_bts_0['BTS']['MRBTS-79050']['NRBTS-79050']
    counters_bts_1 = counters_bts_1['BTS']['MRBTS-79225']['NRBTS-79225']
    nsl_bts_0 = counters_bts_0['MCC-001']['MNC-01']['SST-1']['SD-13714341']['NSL']
    nsl_bts_1 = counters_bts_1['MCC-001']['MNC-01']['SST-1']['SD-13714341']['NSL']
    nngcc_bts_0 = counters_bts_0['NRCELL-260']['NNGCC']
    nngcc_bts_1 = counters_bts_1['NRCELL-270']['NNGCC']
    ngccq_bts_0 = counters_bts_0['NRCELL-260']['NRPMQAP-1']['NGCCQ']
    ngccq_bts_1 = counters_bts_1['NRCELL-270']['NRPMQAP-1']['NGCCQ']
    nrrel = counters_bts_1['NRCELL-270']['NRCI-1295155460']['MCC-001']['MNC-01']['NRREL']
    if get_release_from_sw(sw_gnb) == 'SBTS25R1':
        check_counter_incremented('M55125C07525', nngcc_bts_1)
        check_counter_incremented('M55125C07526', nngcc_bts_1)
    else:
        siexm_bts_1 = counters_bts_1['NRCELL-270']['SIEXM']
        check_counter_incremented('M55178C00020', siexm_bts_1)
        check_counter_incremented('M55178C00022', siexm_bts_1)
    check_counter_zero('M55149C03001', nsl_bts_0)
    check_counter_zero('M55149C03002', nsl_bts_0)
    check_counter_zero('M55149C03003', nsl_bts_0)
    check_counter_incremented('M55149C03001', nsl_bts_1)
    check_counter_incremented('M55149C03002', nsl_bts_1)
    check_counter_incremented('M55149C03003', nsl_bts_1)
    check_counter_zero('M55125C01501', nngcc_bts_0)
    check_counter_zero('M55125C07502', nngcc_bts_0)
    check_counter_incremented('M55125C07503', nngcc_bts_0)
    check_counter_incremented('M55125C07504', nngcc_bts_0)
    check_counter_zero('M55125C07512', nngcc_bts_0)
    check_counter_zero('M55125C07514', nngcc_bts_0)
    check_counter_incremented('M55125C07520', nngcc_bts_0)
    check_counter_zero('M55125C07523', nngcc_bts_0)
    check_counter_incremented('M55125C09013', nngcc_bts_0)
    check_counter_incremented('M55125C09014', nngcc_bts_0)
    check_counter_zero('M55125C09015', nngcc_bts_0)
    check_counter_incremented('M55125C09516', nngcc_bts_0)
    check_counter_zero('M55125C01501', nngcc_bts_1)
    check_counter_incremented('M55125C07502', nngcc_bts_1)
    check_counter_zero('M55125C07503', nngcc_bts_1)
    check_counter_zero('M55125C07504', nngcc_bts_1)
    check_counter_incremented('M55125C07512', nngcc_bts_1)
    check_counter_incremented('M55125C07514', nngcc_bts_1)
    check_counter_zero('M55125C07520', nngcc_bts_1)
    check_counter_incremented('M55125C07523', nngcc_bts_1)
    check_counter_zero('M55125C09013', nngcc_bts_1)
    check_counter_zero('M55125C09014', nngcc_bts_1)
    check_counter_incremented('M55125C09015', nngcc_bts_1)
    check_counter_incremented('M55125C09516', nngcc_bts_1)
    check_counter_incremented('M55163C00513', ngccq_bts_0)
    check_counter_incremented('M55163C00514', ngccq_bts_0)
    check_counter_zero('M55163C00515', ngccq_bts_0)
    check_counter_incremented('M55163C00521', ngccq_bts_0)
    check_counter_zero('M55163C00513', ngccq_bts_1)
    check_counter_zero('M55163C00514', ngccq_bts_1)
    check_counter_incremented('M55163C00515', ngccq_bts_1)
    check_counter_incremented('M55163C00521', ngccq_bts_1)
    check_counter_incremented('M55153C00501', nrrel)
    check_counter_incremented('M55153C00502', nrrel)
    check_counter_incremented('M55153C00503', nrrel)


def check_cb008127_counters(counters_bts_0: dict, counters_bts_1: dict) -> None:
    counters_bts_0 = counters_bts_0['BTS']['MRBTS-79050']['NRBTS-79050']
    counters_bts_1 = counters_bts_1['BTS']['MRBTS-79225']['NRBTS-79225']
    nsl_bts_0 = counters_bts_0['MCC-001']['MNC-01']['SST-1']['SD-13714341']['NSL']
    nsl_bts_1 = counters_bts_1['MCC-001']['MNC-01']['SST-1']['SD-13714341']['NSL']
    nrans_bts_0 = counters_bts_0['NRCELL-260']['MCC-001']['MNC-01']['NRANS']
    nrans_bts_1 = counters_bts_1['NRCELL-270']['MCC-001']['MNC-01']['NRANS']
    nngcc_bts_0 = counters_bts_0['NRCELL-260']['NNGCC']
    nngcc_bts_1 = counters_bts_1['NRCELL-270']['NNGCC']
    check_counter_zero('M55149C00008', nsl_bts_0)
    check_counter_incremented('M55149C00008', nsl_bts_1)
    check_counter_incremented('M55145C00222', nrans_bts_0)
    check_counter_zero('M55145C00341', nrans_bts_0)
    check_counter_zero('M55145C00342', nrans_bts_0)
    check_counter_incremented('M55145C00362', nrans_bts_0)
    check_counter_zero('M55145C00222', nrans_bts_1)
    check_counter_incremented('M55145C00341', nrans_bts_1)
    check_counter_incremented('M55145C00342', nrans_bts_1)
    check_counter_zero('M55145C00362', nrans_bts_1)
    check_counter_incremented('M55125C09516', nngcc_bts_0)
    check_counter_incremented('M55125C09516', nngcc_bts_1)


def check_cb008699_counters(counters_bts_0: dict, counters_bts_1: dict) -> None:
    counters_bts_0 = counters_bts_0['BTS']['MRBTS-79050']['NRBTS-79050']
    counters_bts_1 = counters_bts_1['BTS']['MRBTS-79225']['NRBTS-79225']
    nmocu_bts_0 = counters_bts_0['NRCELL-260']['NMOCU']
    nmocu_bts_1 = counters_bts_1['NRCELL-270']['NMOCU']
    check_counter_incremented('M55147C00036', nmocu_bts_0)
    check_counter_incremented('M55147C00037', nmocu_bts_0)
    check_counter_zero('M55147C00036', nmocu_bts_1)
    check_counter_zero('M55147C00037', nmocu_bts_1)


@keyword()
def get_nr_cell_id_in_hex(nr_cell_id: str, hex_len: int = 11) -> str:
    """
    The function dump nrcellid to hex format.

    :param nr_cell_id: cell's nrcellid in dec format
    :param hex_len: length of hex string after '0x'
    :return: cell's nrcellid in hex format
    """

    return "{0:#0{1}x}".format(int(nr_cell_id), hex_len)


@keyword()
def verify_ngap_initial_context_setup(pcap_file: str, nrcell_id: str, forbidden_msgs_check=False) -> None:
    """Verifies NGAP messages content based on pcap file.
    KW checks if UE perform Registration on desired cell and if PDU Session was established successfully.

    :param pcap_file: path to pcap file
    :param nrcell_id: nr cell identity in DECIMAL
    :param forbidden_msgs_check: bool whether to check forbidden_messages
    """
    hex_cell_id = get_nr_cell_id_in_hex(nr_cell_id=nrcell_id, hex_len=18)

    ng_ics_flow = "".join([msgs.initial_ue_message_nrcellid % hex_cell_id,
                           msgs.ics_setup_req_pdu_session,
                           msgs.ics_setup_resp_pdu_session])

    forbidden_messages = msgs.ue_ctx_rel_req if forbidden_msgs_check else None
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap',
                   awaited_messages=ng_ics_flow,
                   forbidden_messages=forbidden_messages)


@keyword()
def verify_xn_handover_performed(pcap_file: str) -> None:
    """Verifies NGAP and XNAP messages content based on pcap file.
    KW checks if UE perform XN based Handover to desired cell.

    :param pcap_file: path to pcap file
    """
    xn_ho_flow = "".join([msgs.xn_ho_request,
                          msgs.xn_ho_path_switch_request])

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap or xnap',
                   awaited_messages=xn_ho_flow)


@keyword()
def verify_ng_handover_performed(pcap_file: str) -> None:
    """Verifies NGAP messages content based on pcap file.
    KW checks if UE perform NG based Handover to desired cell.

    :param pcap_file: path to pcap file
    """
    ng_ho_flow = "".join([msgs.ng_ho_request,
                          msgs.ng_ho_notify])

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap',
                   awaited_messages=ng_ho_flow)


@keyword()
def verify_ecid_messages(pcap_file: str) -> None:
    """Verifies NRPPA messages content based on pcap file.
    KW checks if UE location request and response has been performed with Timing Advance measurement.

    :param pcap_file: path to pcap file
    """
    ecid_flow = "".join([msgs.ecid_initiation_request,
                         msgs.ecid_initiation_response])

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='nrppa',
                   awaited_messages=ecid_flow)
