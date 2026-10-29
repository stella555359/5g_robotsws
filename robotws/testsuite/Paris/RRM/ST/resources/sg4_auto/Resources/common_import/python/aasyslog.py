import re
import time
from taf.transport.ssh.connection import SSHConnection
import logging


__all__ = ["aasyslog_realtime_output_configuration"]


def __expected_config_output(aa_sys_mode='2', aa_sys_addr='0x7F000001', aa_sys_udp_port='0xC738'):
    return [
        "[0x10041] 'AaSysLogOutputMode' = 0x{}".format(aa_sys_mode),
        "[0x10042] 'AaSysLogUdpAddress' = {}".format(aa_sys_addr),
        "[0x10043] 'AaSysLogUdpPort' = {}".format(aa_sys_udp_port),
    ]


def _aasyslog_realtime_output_configuration(host, username, password, aasyslog_port, aa_sys_mode='2',
                                            aa_sys_addr='0x7F000001', aa_sys_udp_port='0xC738'):
    sshconnection = SSHConnection()
    sshconnection.configure(hostname=host, username=username,
                            password=password)
    sshconnection.connect()
    logging.info("Start configure AaSysLog for realtime output")
    _cmd_kill_telnet = "ps -ef|grep telnet|grep "+str(aasyslog_port)+"|grep -v grep|awk '{print $2}'| xargs kill -9"
    sshconnection.send_command(_cmd_kill_telnet)
    tn = sshconnection.invoke_shell()
    tn.send('telnet 0 {}\n'.format(aasyslog_port))
    match_shell_til(tn, "AaShell>", 3)
    logging.info("Aashell created.")
    tn.send("rad -w 0x10041 {}\r".format(aa_sys_mode))
    match_shell_til(tn, "written succesfully", timeout=3)
    tn.send('rad -w 0x10042 {}\r'.format(aa_sys_addr))
    match_shell_til(tn, "written succesfully", timeout=3)
    tn.send('rad -w 0x10043 {}\r'.format(aa_sys_udp_port))
    match_shell_til(tn, "written succesfully", timeout=3)
    tn.send('rad -a\r')
    resp = match_shell_til(tn, "0x3F004F", timeout=10)
    logging.info("Commands sent in Aashell, checking result.")
    try:
        tn.send('quit\r')
        match_shell_til(tn, "Bye", timeout=3)
    except CommandOutputCollectionError:
        pass
    sshconnection.disconnect()
    logging.info("AaSysLog configuration done: {}".format(resp))
    for _exp in __expected_config_output(aa_sys_mode=aa_sys_mode,
                                         aa_sys_addr=aa_sys_addr,
                                         aa_sys_udp_port=aa_sys_udp_port):
        if _exp not in resp:
            raise AssertionError("AaSysLog configuration failed, can't found expected output: {}".format(_exp))
    return resp


def match_shell_til(shell, match, timeout):
    start = time.time()
    output = ""
    while (time.time() - start) <= timeout:
        output += str(shell.recv(65535))
        if re.search(match, output):
            return output
        time.sleep(0.1)
    else:
        raise TimeoutError("Match {} failed".format(match))


def aasyslog_realtime_output_configuration(host, username, password, type="mcu", aa_sys_mode='2',
                                           aa_sys_addr='0x7F000001', aa_sys_udp_port='0xC738'):
    """
    configure Aasyslog in aashell for real time output print.

    Author: Civen Chen
    Contact: civen.chen@nokia-sbell.com

    :param host: Address of ASIK.
    :param type: two type supported, MCU/ RT, corresponding to CCS_MCU/ CCS_RT
    :param aa_sys_mode: AaSysMode means the AaSysLog Output Mode,ex:2 means udp
    :param aa_sys_addr: AaSysLog Udp output Address change to Hex,if the first is 0 need add parameter like
    ...    ex:0x0A39A747 should use 0xA39A747
    :param aa_sys_udp_port: AaSysLog Udp Port used for log output
    details can see Conflunce:
    https://confluence.int.net.nokia.com/display/UPHWAPI/A+guide+to+check+AaSysLog
    :return:
    """
    if type.lower() == "mcu":
        port = 15007
    elif type.lower() == "rt":
        port = 35007
    else:
        raise ValueError("Wrong type: {}, should be MCU or RT".format(type))
    resp = _aasyslog_realtime_output_configuration(
        host=host, username=username, password=password, aasyslog_port=port, aa_sys_mode=aa_sys_mode,
        aa_sys_addr=aa_sys_addr, aa_sys_udp_port=aa_sys_udp_port)
    return resp
