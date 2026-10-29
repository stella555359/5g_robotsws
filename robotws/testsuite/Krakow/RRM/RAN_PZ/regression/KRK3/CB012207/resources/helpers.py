"""
author: Magda Chrostek
contact: magda.chrostek@nokia.com
ATEN Mgmt for tests.
"""
import logging
import time
import paramiko
from robot.libraries.BuiltIn import BuiltIn
from on_air_tl_preparation.testline_preparation_resources import power_on_all_pdu_ports
from taf.hw.pdu import pdu

MINICOM_DEVICE = '/dev/ttyUSB2'
MINICOM_PASSWORD = 'ute'
MINICOM_BANNER_TIMEOUT = 1
MINICOM_PASSWORD_TIMEOUT = 5
MINICOM_RECV_SIZE = 9999
AT_COMMANDS = ['AT+QENG="servingcell"\r', 'AT+CGPADDR\r']
IPERF_PORT = 50023
IPERF_BIND = '10.84.169.61'
IPERF_PARALLEL = 7
IPERF_ALGO = 'cubic'
IPERF_TIME = 700.0
IPERF_INTERVAL = 1.0
UE_IP_PREFIX = '10.84.171.'
MODEL = "ATEN"
HOST = "aten-tun-ab05-p04.p04-leg.ska-lab.nsn-rdnet.net"
PORT = 8
SERVING_CELL_INFO = ""
obj_pdu = pdu()
configured_pdu = obj_pdu.setup_pdu(model=MODEL, host=HOST, alias=None)


def aten_power_on():
    obj_pdu.power_on(port=PORT, pdu_device=configured_pdu)


def aten_power_off():
    obj_pdu.power_off(port=PORT, pdu_device=configured_pdu)


def run_keyword_with_fatal_exception_handling(keyword_name, *args):
    try:
        return BuiltIn().run_keyword(keyword_name, *args)
    except Exception as e:
        return f"Fatal exception caught {str(e)}"


def power_on_all_hw_in_testline():
    power_on_all_pdu_ports()


def ssh_connect(host, username, password):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=password)
    return client


def run_minicom(channel):
    channel.send(f'sudo minicom -D {MINICOM_DEVICE}\n')
    time.sleep(MINICOM_BANNER_TIMEOUT)
    output = channel.recv(MINICOM_RECV_SIZE).decode()
    if 'password' in output.lower():
        channel.send(MINICOM_PASSWORD + '\n')
        time.sleep(MINICOM_PASSWORD_TIMEOUT)
        channel.recv(MINICOM_RECV_SIZE)
    infos = []
    for cmd in AT_COMMANDS:
        channel.send(cmd)
        time.sleep(MINICOM_PASSWORD_TIMEOUT)
        info = channel.recv(MINICOM_RECV_SIZE).decode()
        logging.info(info)
        infos.append(info)
    return infos


def verify_if_ue_is_callable():
    try:
        client = ssh_connect('10.84.182.223', 'ute', 'ute')
        command = "ip addr | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1"
        stdin, stdout, stderr = client.exec_command(command)
        stdout.channel.set_combine_stderr(True)
        output = stdout.readlines()
        th_addr = [addr.strip() for addr in output if addr.strip().startswith(UE_IP_PREFIX)]
        if th_addr:
            command = f"iperf -s -i {IPERF_INTERVAL} -p {IPERF_PORT}"
            stdin, stdout, stderr = client.exec_command(command)
            stdout.channel.set_combine_stderr(True)
            th_addr = str(th_addr[0])
        else:
            channel = client.invoke_shell()
            time.sleep(MINICOM_BANNER_TIMEOUT)
            channel.recv(MINICOM_RECV_SIZE)
            SERVING_CELL_INFO = run_minicom(channel)
            th_addr = 0
        client.close()
        return th_addr
    except Exception as e:
        logging.error(f"SSH connection or command failed: {e}")
        return 0


def run():
    th_addr = verify_if_ue_is_callable()
    try:
        client = ssh_connect('10.84.168.121', '5g', '5g')
        if th_addr != 0:
            command = (f"iperf -c {th_addr} -p {IPERF_PORT} -t {IPERF_TIME} -i {IPERF_INTERVAL} "
                       f"-B {IPERF_BIND} -P {IPERF_PARALLEL} -Z {IPERF_ALGO}")
            stdin, stdout, stderr = client.exec_command(command)
            stdout.channel.set_combine_stderr(True)
            return True
        else:
            logging.info('UE network interface is removed from PC. '
                         'Verification based on counters and serving cell info. ')
            return False
    except Exception as e:
        logging.error(f"SSH connection or command failed: {e}")
        return None


def verify_serving_cell_info():
    client = ssh_connect('10.84.182.223', 'ute', 'ute')
    channel = client.invoke_shell()
    time.sleep(MINICOM_BANNER_TIMEOUT)
    channel.recv(MINICOM_RECV_SIZE)
    SERVING_CELL_INFO_HO = run_minicom(channel)
    client.close()
    logging.info(SERVING_CELL_INFO_HO)
    return SERVING_CELL_INFO != SERVING_CELL_INFO_HO
