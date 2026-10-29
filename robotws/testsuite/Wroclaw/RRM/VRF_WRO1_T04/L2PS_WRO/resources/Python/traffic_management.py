# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

from robot.api import logger
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
import subprocess
import threading
import time
import re


ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


class IperfServer(object):

    def __init__(self):
        self.iperf_server = None
        self.iperf_client = None

    def start(self, server, port, client, throughput, duration, packet_size):
        iperf_server_cmd = ['iperf', '-s', '-u', '-B', server, '-p', port, '-i', '1', '-t', duration]
        iperf_client_cmd =\
            ['iperf', '-c', client, '-u', '-b', throughput, '-p', port, '-l', packet_size, '-t', duration]

        logger.info("Executing {} ...".format(" ".join(iperf_server_cmd)), also_console=True)
        self.iperf_server = subprocess.Popen(iperf_server_cmd, stdout=subprocess.PIPE, universal_newlines=True)

        logger.info("Executing {} ...".format(" ".join(iperf_client_cmd)), also_console=True)
        self.iperf_client = subprocess.Popen(iperf_client_cmd)

        time.sleep(1)
        return self.iperf_server, self.iperf_client


class TrafficIperfHolder(object):
    """
    Holds lifetime of IperfServer and its running processes.
    """

    traffic_instance = IperfServer()
    iperf_server = None
    iperf_client = None


def __expected_throughput_reached(throughput, expected, margin='10%'):
    """
    Method checks if expected tput is reached from given iperf line.

    :param throughput: str actual tput
    :param expected: str expected tput
    :return: reached bool True if reached, False otherwise
    """
    margin = float(margin.replace('%', '')) * 0.01
    margin *= throughput
    expected = float(re.match(r'\s*(\d+).*', expected).group(1))
    if throughput + margin > float(expected):
        return True

    return False


def __check_if_tput_is_reached(expected_throughput, iperf_server):
    """
    Method checks in iperf_server output, if expected_tput is reached.

    :param expected_throughput: str expected tput
    :param iperf_server: subproccess ongoing iperf server receiving tput
    :return: reached bool True if reached, False otherwise
    """
    tput = 0
    is_tput_reached = False
    t1 = datetime.now()
    no_tput_timeout = 11
    timer = threading.Timer(no_tput_timeout, iperf_server.terminate)
    timer.start()
    while (datetime.now() - t1).seconds <= 10:
        try:
            nextline = iperf_server.stdout.readline()
            logger.info(nextline)
            tput = float(re.search(r'(\d+\.\d+)\s+Mbits/sec', nextline).group(1))
        except Exception:
            pass
        is_tput_reached = __expected_throughput_reached(tput, expected_throughput)
        if is_tput_reached:
            logger.console('Tput started correctly, continuing')
            break
    return is_tput_reached, tput


def send_uplink_iperf(duration_tput, ul_tput, ue_ip="72.23.0.1", pdu_gw_ip='10.0.2.1', port='7070',
                      packet_size='1400'):
    """
    Method starts UL tput using iperf. Give parameters that define what kind of traffic you want.
    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP

    :param throughput: str tput size, ex: 80m -> 80Megabits per second
    :param duration: str tput duration in seconds, ex: 300 -> 300 seconds
    :param ue_ip: str ip address of UE, check set_pdu_gateway cmd: ue_nat_ip=72.23.0.1
    :param ul_nat_gw: str gw IP addr, check set_pdu_gateway cmd: ul_nat_gw=$SERVER_IP=10.0.2.1
    :param port: str tput port, ex: 7070
    :param packet_size: str packet size, ex: 1400
    """
    logger.info("Starting UL traffic...", also_console=True)
    TrafficIperfHolder.iperf_server, TrafficIperfHolder.iperf_client =\
        TrafficIperfHolder.traffic_instance.start(server=pdu_gw_ip,
                                                  port=port,
                                                  client=ue_ip,
                                                  throughput=ul_tput,
                                                  duration=duration_tput,
                                                  packet_size=packet_size)


def validate_uplink_traffic(duration_tput, ul_tput):
    """Validates UL traffic and prints logger.info about current tput state.

    :param duration_tput: duration in seconds, the same as in iperf -t <timeout>
    :param ul_tput: exepcted tput
    """
    duration_int = int(duration_tput)
    # minutes_int = int(duration_int / 60)

    if duration_int < 60:
        logger.info("Duration UL tput under 60sec: {}".format(duration_tput), also_console=True)
        time.sleep(duration_int)
    else:
        logger.info("Duration UL tput more than 60sec: {}".format(duration_tput), also_console=True)
        time.sleep(duration_int)
        # for minute in range(minutes_int):
        #     is_tput_reached, found_tput = __check_if_tput_is_reached(
        #         expected_throughput=ul_tput, iperf_server=TrafficIperfHolder.iperf_server
        #     )

        #     if is_tput_reached:
        #         logger.info("Reached tput in minute {}: {}...".format(minute, found_tput), also_console=True)
        #     else:
        #         logger.info("Cannot reach tput in minute {}: {}...".format(minute, found_tput), also_console=True)
        #     time.sleep(60)

    logger.info("After tput sent...", also_console=True)
    time.sleep(5)


def stop_uplink_iperf():
    """
    Kills iperf processes on Linux.
    """
    logger.info("Stopping UL traffic...", also_console=True)
    TrafficIperfHolder.iperf_server.kill()
    TrafficIperfHolder.iperf_client.kill()


def get_ue_stats_for_given_cc(ue_id, cc, direction):
    if direction == 'dl':
        stats_type = 'pdsch'
    else:
        stats_type = 'pusch'
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd=f'ue_stats_nr id={ue_id} type={stats_type} scell={cc}',
        pass_regexp=f'UE-{ue_id}: NR {stats_type.upper()} Throughput')


def get_avg_data_traffic_for_given_cc(ue_id, cc, direction, unit):
    ue_stats = get_ue_stats_for_given_cc(ue_id, cc, direction)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(ue_stats)[-1][0]
    return float(avg_tput)


def start_data_dl_mbps(ue_id, pdu_id, trf_id1, amount):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd=f'trf_data_start ue={ue_id} pdu={pdu_id} dir=dl mbps={amount} trf_id={trf_id1}',
        pass_regexp=(
            f'UE{ue_id}: Started Downlink Internal traffic Receiver on Ue:{ue_id} '
            f'Pdu:{pdu_id} Qfi:1 TrfId:{trf_id1}'
        ))


def get_pdsch_ue_stats_for_given_cc(ue_id, cc):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd=f'ue_stats_nr id={ue_id} type=pdsch scell={cc}',
        pass_regexp=f'UE-{ue_id}: NR PDSCH Throughput')


def use_regex_to_get_tput(ue_stats):
    pattern1 = re.compile(r'CellIndex-[0-9].*')
    scell_tput = pattern1.findall(ue_stats)[0]
    scell_tput2 = re.sub(r'CellIndex-[0-9]', '', scell_tput)
    pattern2 = re.compile(r' 0 |\d*\.\d')
    scell_tput3 = float(pattern2.findall(scell_tput2)[0].strip())
    return scell_tput3


def verify_tput_on_scell(ue_id, cc, tput_expected):
    ue_stats = get_pdsch_ue_stats_for_given_cc(ue_id, cc)
    scell_tput = use_regex_to_get_tput(ue_stats)
    logger.info(f'cell-{cc}_tput= {scell_tput}', also_console=True)
    logger.info(f'cell-{cc}_tput_expected= {tput_expected}', also_console=True)
    logger.info(f'cell-{cc}_tput_expected_type= {tput_expected}', also_console=True)
    if ((int(scell_tput) == 0) and (not tput_expected)):
        logger.info(f'\nCheck passed, there is no data transmission on Scell-{cc}', also_console=True)
    elif (int(scell_tput) > 0 and tput_expected):
        logger.info(f'\nCheck passed, there is data transmission on Scell-{cc}', also_console=True)
    else:
        raise Exception(f"SCell-{cc} tput {scell_tput} was expected to be present={tput_expected}")
