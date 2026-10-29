"""
Ping module for performing ping tests on UE and Core for Performance and Connectivity tests.

:author: Sara Nowak  Mateusz Potoniec
:contact: sara.nowak@nokia.com  mateusz.potoniec@nokia.com
:maintainer: sara.nowak@nokia.com  mateusz.potoniec@nokia.com
"""

import re
from typing import List, Tuple

from robot.api import logger as robot_logger
from robot.api.deco import keyword
from taf.transport.ssh import ssh
from taf.rfrl.utilities.logger import custom_logger as logger

_ssh = ssh()
TIME_FORMAT = '%H:%M:%S.%f'
UE_SERIAL_NUMBER = "R5CT51E5Y0W"


class PingEntriesNotFound(Exception):
    pass


class AveragePingDelayIsTooLarge(Exception):
    pass


@keyword()
def perform_ping_on_core(count: int, packet_size: int, latency_threshold: float) -> Tuple[float, List[float]]:
    """
    Perform a ping on the core.

    :param count: The number of ping packets to send.
    :param packet_size: The size of the ping packets.
    :param latency_threshold: The threshold for the average ping delay.

    :return: The average ping delay, ping delays.

    :raises PingEntriesNotFound: If no ping entries were found.
    :raises AveragePingDelayIsTooLarge: If the average ping delay is too large.
    """

    ue_ip = _find_ue_ip()
    robot_logger.debug(f"UE ip: {ue_ip}")
    cmd = f"ping -c {count} -s {packet_size} {ue_ip}"
    logger.log_info_to_console(msg=f"Executing Command: {cmd}", log_hierarchy=2)
    robot_logger.debug(f"Executing Command: {cmd}")

    appserver_connection_alias = _connect_to_appserver()
    output = _ssh.execute(command=cmd, connection=appserver_connection_alias)
    delays = _get_ping_delays_from_output(output)[1:]
    logger.log_info_to_console(msg=f"Ping delays: {delays}", log_hierarchy=2)
    robot_logger.info(f"Delays: {delays}")

    if delays:
        avg_delay = sum(delays) / len(delays)
    else:
        raise PingEntriesNotFound('No ping entries were found. Ping probably did not run properly.')

    logger.log_info_to_console(msg=f"Average ping delay: {avg_delay}", log_hierarchy=2)
    robot_logger.info(f"Average ping delay: {avg_delay}")
    if avg_delay >= float(latency_threshold):
        raise AveragePingDelayIsTooLarge(
            f'Averag ping delay: {avg_delay} is too large. Should be less than {latency_threshold}'
        )
    return avg_delay, delays


@keyword()
def perform_ping_on_ue(count: int, packet_size: int, ip: str, latency_threshold: float) -> Tuple[float, List[float]]:
    """
    Perform a ping on the UE.

    :param count: The number of ping packets to send.
    :param packet_size: The size of the ping packets.
    :param ip: The IP address to ping.
    :param latency_threshold: The threshold for the average ping delay.

    :return: The average ping delay, ping delays.

    :raises PingEntriesNotFound: If no ping entries were found.
    :raises AveragePingDelayIsTooLarge: If the average ping delay is too large.
    """

    cmd = _construct_ping_cmd(count, packet_size, ip)
    logger.log_info_to_console(msg=f"Executing Command: {cmd}", log_hierarchy=2)
    robot_logger.debug(f"Executing Command: {cmd}")

    uepc_connection_alias = _connect_to_uepc()
    output = _ssh.execute(command=cmd, connection=uepc_connection_alias)
    delays = _get_ping_delays_from_output(output)[1:]
    logger.log_info_to_console(msg=f"Ping delays: {delays}", log_hierarchy=2)
    robot_logger.info(f"Delays: {delays}")

    if delays:
        avg_delay = sum(delays) / len(delays)
    else:
        raise PingEntriesNotFound('No ping entries were found. Ping probably did not run properly.')

    logger.log_info_to_console(msg=f"Average ping delay: {avg_delay}", log_hierarchy=2)
    robot_logger.info(f"Average ping delay: {avg_delay}")
    if avg_delay >= float(latency_threshold):
        raise AveragePingDelayIsTooLarge(
            f'Averag ping delay: {avg_delay} is too large. Should be less than {latency_threshold}'
        )
    return avg_delay, delays


def _construct_ping_cmd(count: int, packet_size: int, ip: str) -> str:
    """
    Construct the ping command based on the IP address, packet size and ping count.

    :param count: The number of ping packets to send.
    :param packet_size: The size of the ping packets.
    :param ip: The IP address to ping.

    :return: The constructed ping command.
    """

    if len(ip.split(':')) == 8:
        return f'adb -s {UE_SERIAL_NUMBER} shell "ping6 -c {count} -s {packet_size} {ip}"'
    return f'adb -s {UE_SERIAL_NUMBER} shell "ping -c {count} -s {packet_size} {ip}"'


def _find_ue_ip() -> str:
    """
    Find the UE IP address.

    :return: The UE IP address.
    """

    conn = _connect_to_uepc()
    base_cmd = f'adb -s {UE_SERIAL_NUMBER} shell "ip a | grep 10.84"'
    output = _ssh.execute(command=base_cmd, connection=conn)
    ue_ip = output.split(' ')[-6][:-3]
    return ue_ip


def _get_ping_delays_from_output(output: str) -> List[float]:
    """
    Get the ping delays from the output.

    :param output: The output of the ping command.

    :return: The ping delays.
    """

    lines = [line for line in output.split('\r\n') if 'bytes from' in line]
    ping_pattern = re.compile(r'time=(\d+(\.\d+)?) ms')
    ping_values = list()
    for line in lines:
        match = ping_pattern.search(line)
        if match:
            ping_values.append(float(match.group(1)))
    return ping_values


def _connect_to_uepc(hostname: str = '10.84.183.163', username: str = 'pzkrk', password: str = 'NokiaBts2003',
                     connection_alias: str = 'uepc_connection') -> str:
    """
    Connect to the UEPC.

    :param hostname: The hostname of the UEPC.
    :param username: The username to connect with.
    :param password: The password to connect with.
    :param connection_alias: The alias of the connection.

    :return: The connection alias.
    """

    return _ssh.connect_to(hostname=hostname,
                           username=username,
                           password=password,
                           alias=connection_alias)


def _connect_to_appserver(hostname: str = '10.84.168.70', username: str = '5g', password: str = '5g') -> str:
    """
    Connect to the appserver.

    :param hostname: The hostname of the appserver.
    :param username: The username to connect with.
    :param password: The password to connect with.

    :return: The connection alias.
    """

    return _ssh.connect_to(hostname=hostname,
                           username=username,
                           password=password)
