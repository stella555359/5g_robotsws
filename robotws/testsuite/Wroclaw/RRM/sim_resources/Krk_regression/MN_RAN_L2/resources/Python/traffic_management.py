# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Mateusz Adamek
:contact: mateusz.adamek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.api import logger
from datetime import datetime
import subprocess
import threading
import time
import re


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

    def start_tcp(self, server, port, client, window, duration):
        if not self.iperf_server:
            self.start_tcp_server(server, port, window)
        iperf_client_cmd =\
            ['iperf', '-c', client, '-p', port, '-i', '1', '-t', duration, '-B', server, '-w', window]

        logger.info("Executing {} ...".format(" ".join(iperf_client_cmd)), also_console=True)
        self.iperf_client = subprocess.Popen(iperf_client_cmd)

        time.sleep(1)
        return self.iperf_server, self.iperf_client

    def start_tcp_server(self, server, port, window):
        iperf_server_cmd = ['iperf', '-s', '-p', port, '-B', server, '-i', '1', '-w', window]

        logger.info("Executing {} ...".format(" ".join(iperf_server_cmd)), also_console=True)
        self.iperf_server = subprocess.Popen(iperf_server_cmd)

        time.sleep(1)


class TrafficIperfHolder(object):
    """
    Holds lifetime of IperfServer and its running processes.
    """

    traffic_instance = IperfServer()
    iperf_server = None
    iperf_client = None


class TrafficIperfHolderV2(object):

    def __init__(self):
        self.server = None
        self.client = None


class TrafficIperfHolderList(object):

    holders = []


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


def send_downlink_iperf(duration_tput, dl_tput, ue_ip="1.2.4.2", pdu_gw_ip='10.0.2.1', port='7070',
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
                                                  throughput=dl_tput,
                                                  duration=duration_tput,
                                                  packet_size=packet_size)


def send_tcp_iperf(duration_tput, window, ue_ip="1.2.4.2", pdu_gw_ip='10.0.2.1', port='7070'):
    """
    Method starts UL tput using iperf. Give parameters that define what kind of traffic you want.
    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP

    :param throughput: str tput size, ex: 80m -> 80Megabits per second
    :param duration: str the socket buffer sizes to the specified value,
    :param ue_ip: str ip address of UE, check set_pdu_gateway cmd: ue_nat_ip=72.23.0.1
    :param ul_nat_gw: str gw IP addr, check set_pdu_gateway cmd: ul_nat_gw=$SERVER_IP=10.0.2.1
    :param port: str tput port, ex: 7070
    """
    logger.info("Starting UL traffic...", also_console=True)
    TrafficIperfHolder.iperf_server, TrafficIperfHolder.iperf_client =\
        TrafficIperfHolder.traffic_instance.start_tcp(server=pdu_gw_ip,
                                                      port=port,
                                                      client=ue_ip,
                                                      window=window,
                                                      duration=duration_tput)


def send_downlink_v2_iperf(duration_tput, dl_tput, ue_ip="1.2.4.2", pdu_gw_ip='10.0.2.1', port='7070',
                           packet_size='1400'):
    logger.info("Starting DL traffic V2...", also_console=True)
    i = len(TrafficIperfHolderList.holders)
    TrafficIperfHolderList.holders.append(TrafficIperfHolderV2())

    TrafficIperfHolderList.holders[i].server, TrafficIperfHolderList.holders[i].client =\
        IperfServer().start(server=pdu_gw_ip,
                            port=port,
                            client=ue_ip,
                            throughput=dl_tput,
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


def __stop_iperf():
    TrafficIperfHolder.iperf_client.kill()
    TrafficIperfHolder.iperf_server.kill()


def stop_uplink_iperf():
    """
    Kills iperf processes on Linux.
    """
    logger.info("Stopping Uplink traffic...", also_console=True)
    __stop_iperf()


def stop_downlink_iperf():
    """
    Kills iperf processes on Linux.
    """
    logger.info("Stopping Downlink traffic...", also_console=True)
    __stop_iperf()


def stop_downlink_v2_iperf(i):
    logger.info("Stopping Downlink V2 traffic {}...".format(i), also_console=True)
    i = int(i)
    TrafficIperfHolderList.holders[i].server.kill()
    TrafficIperfHolderList.holders[i].client.kill()
