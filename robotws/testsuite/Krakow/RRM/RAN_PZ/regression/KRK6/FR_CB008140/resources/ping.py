from taf.transport.ssh import ssh
from robot.api import logger
from taf.rfrl.utilities.robot.general import get_builtin_value


_tl = get_builtin_value(param_name="tl")
_prime_gnb_oam_ip = _tl.gnbs[0].cu.backhaul_site_oam_ip.v4
_extension_gnb_oam_ip = _tl.gnbs[1].cu.backhaul_site_oam_ip.v4
_prime_gnb_oam_password = _tl.gnbs[0].cu.oam_ssh_connection_details.password
_prime_gnb_oam_username = _tl.gnbs[0].cu.oam_ssh_connection_details.username

_ssh = ssh()
TIME_FORMAT = '%H:%M:%S.%f'


class PingNoRunProperly(Exception):
    """
    Exception raised when ping is not properly handled
    """


class IncorrectPingValue (Exception):
    """
    Exception raised when ping is higher or lower than expected range
    """


def perform_ping_test_to_gnb(count, packet_size, latency_threshold):
    """
    Performs ping from gNB to another gNB
    :param count:  number of icmp requests
    :param packet_size: size of packet send by icmp protocol
    :param latency_treshold: anticipated latency to be checked
    """
    logger.info('Start ping test on core...')
    target_gnb_ip = _extension_gnb_oam_ip.split("/")[0]
    output = send_ping_from_prime_gnb_to_ext_gnb(count, packet_size, target_gnb_ip)
    delays = get_ping_delays_from_output_on_gnb(output)
    logger.info('Delays: {} ms'.format(delays))
    delays = delays[1:]

    if not delays:
        raise PingNoRunProperly('No ping entries were found. Ping probably did not run properly.')

    avg_delay = sum(delays) / len(delays)
    logger.info('Avg. ping delay for packet_size={}: {} ms'.format(packet_size, avg_delay))
    logger.info('Target latency value: {} ms'.format(latency_threshold))

    if avg_delay > (1.1 * float(latency_threshold)):
        raise IncorrectPingValue('Ping delay is too large.')
    if avg_delay < (0.9 * float(latency_threshold)):
        raise IncorrectPingValue('Ping delay is too small.')

    logger.info('Ping test finished successfully.')


def send_ping_from_prime_gnb_to_ext_gnb(count, packet_size, ip):
    """
    Sends ping from gNB to another gNB
    :param count:  number of icmp requests
    :param packet_size: size of packet send by icmp protocol
    :param ip: given ip for target gNB
    :return: raw output from ping command
    """
    conn = _connect_to_gnb()
    cmd = construct_ping_cmd_from_gnb(count, packet_size, ip)
    logger.info('Sending command to appserver: {}'.format(cmd))
    output = _ssh.execute(command=cmd, connection=conn)
    return output


def construct_ping_cmd_from_gnb(count, packet_size, ip):
    """
    Creates ping command to be send target gNB
    :param count:  number of icmp requests
    :param packet_size: size of packet send by icmp protocol
    :param ip: given ip for target gNB
    :return: prepared command with ping
    """
    base_cmd = 'ping -c {} -s {} {}'
    return base_cmd.format(count, packet_size, ip)


def get_ping_delays_from_output_on_gnb(output):
    """
    Collects output from ping command
    :param output: forming data from retrieved output
    :return: list of specified delay values
    """
    lines = [line for line in output.split('\r\n') if 'bytes from' in line]
    return [get_ping_delay_from_line(line) for line in lines]


def get_ping_delay_from_line(line):
    """
    Parsing specific value from raw data
    :param line: retrieved raw line from output
    :return: value of delay from one line
    """
    time_field = line.split(' ')[-2]
    time_ms = time_field.split('=')[-1]
    return float(time_ms)


def _connect_to_gnb(hostname=_prime_gnb_oam_ip.split("/")[0], username=_prime_gnb_oam_username,
                    password=_prime_gnb_oam_password):
    """
    Connecting to host to allow ping command to target gNB
    :param hostname: hostname of source gNB
    :param username: username of source gNB
    :param password: credential to source gNB
    :return: object connection
    """
    return _ssh.connect_to(hostname=hostname,
                           username=username,
                           password=password)
