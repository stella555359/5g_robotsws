# -*- coding: utf-8 -*-
import re
import time
import select
from taf.transport.ssh.connection import SSHConnection
from taf.transport.ssh import ssh


check_edaemon = "ps -ef|grep edaemon |grep -v grep|awk '{print $2}'"
check_egate = "ps -ef|grep egate |grep -v grep|awk '{print $2}'"
start_edaemon = "sudo ./edaemon --port 22222"
start_egate = "cd /opt/iphy/latest; ./egate --port 20000"
is_egate_start = "EGATE: SERVER PID"


def match_shell_til(shell, match, timeout):
    start = time.time()
    output = ""
    while (time.time() - start) <= timeout:
        if select.select([shell], [], [], timeout)[0]:
            output += str(shell.recv(65535).decode())
            time.sleep(0.5)
            if re.search(match, output):
                return output
        time.sleep(0.1)
    else:
        raise TimeoutError("Match {} failed".format(match))
        # print("Match {} failed".format(match))


def start_egate_on_vm(host, username, password):
    check_edaemon = "ps -ef|grep edaemon |grep -v grep|awk '{print $2}'"
    check_egate = "ps -ef|grep egate |grep -v grep|awk '{print $2}'"
    connection = ssh()
    connection.connect_to(hostname=host, username=username, password=password)
    edaemon_out = connection.execute(check_edaemon)
    egate_out = connection.execute(check_egate)
    if edaemon_out.split() == []:
        connection.execute(start_edaemon)
    if egate_out.split() == []:
        result = connection.execute(start_egate)
        if re.search(is_egate_start, result):
            return result
        else:
            raise AssertionError("EGATE START FAILED: {}".format(result))
    connection.disconnect()


def egate_load_config(host, username, password, config_file):
    sshconnection = SSHConnection()
    sshconnection.configure(
        hostname=host, username=username, password=password, timeout=30
    )
    sshconnection.connect()
    ts = sshconnection.invoke_shell()
    ts.send("telnet 0 20000\n")
    match_shell_til(ts, "EGATE>", 5)
    ts.send("sim_reset\n")
    match_shell_til(ts, "EGATE>", 5)
    ts.send("cfg_sim file={}\n".format(config_file))
    match_shell_til(ts, "NG link is Up", 15)
    ts.close()
    sshconnection.disconnect()


def ue_attach_for_AP(host, username, password, ue_index):
    sshconnection = SSHConnection()
    sshconnection.configure(
        hostname=host, username=username, password=password, timeout=30
    )
    sshconnection.connect()
    ts = sshconnection.invoke_shell()
    ts.send("telnet 0 20000\n")
    match_shell_til(ts, "EGATE>", 5)
    ts.send("set_pdu_param ue={} pdu=1 trf_type=internal\n".format(ue_index))
    match_shell_til(ts, "EGATE>", 2)
    ts.send("ue_register id={}\n".format(ue_index))
    match_shell_til(ts, "Received REGISTRATION COMPLETE", 5)
    ts.send("ue_pdu_session_setup pdu=1 ue={} nwslice=1 gw=1\n".format(ue_index))
    match_shell_til(ts, "Initial Context Setup Successful", 10)
    ts.close()
    sshconnection.disconnect()


def send_DL_traffic_for_AP(
    host, username, password, ue_index, traffic_num, send_traffic
):
    sshconnection = SSHConnection()
    sshconnection.configure(
        hostname=host, username=username, password=password, timeout=30
    )
    sshconnection.connect()
    ts = sshconnection.invoke_shell()
    ts.send("telnet 0 20000\n")
    match_shell_til(ts, "EGATE>", 5)
    trf = int(traffic_num)
    for index in range(1, trf + 1):
        trf_num = str(index)
        cmd = (
            "trf_data_start ue={} ".format(ue_index)
            + "pdu=1 qfi=1 dir=dl "
            + "trf_id="
            + "{}".format(index)
            + " protocol=udp "
            + "mbps={}\n".format(send_traffic)
        )
        ts.send(cmd)
        match_shell_til(ts, "Started Downlink Internal traffic Receiver", 5)
    ts.close()
    sshconnection.disconnect()


def send_UL_traffic_for_AP(
    host, username, password, ue_index, traffic_num, send_traffic
):
    sshconnection = SSHConnection()
    sshconnection.configure(
        hostname=host, username=username, password=password, timeout=30
    )
    sshconnection.connect()
    ts = sshconnection.invoke_shell()
    ts.send("telnet 0 20000\n")
    match_shell_til(ts, "EGATE>", 5)
    trf = int(traffic_num)
    for index in range(1, trf + 1):
        cmd = (
            "trf_data_start ue={} ".format(ue_index)
            + "pdu=1 qfi=1 dir=ul "
            + "trf_id="
            + "{}".format(index)
            + " protocol=udp "
            + "mbps={}\n".format(send_traffic)
        )
        ts.send(cmd)
        match_shell_til(ts, "Started Uplink Internal traffic Receiver", 5)
    ts.close()
    sshconnection.disconnect()


def stop_DL_traffic_for_AP(host, username, password, ue_index):
    sshconnection = SSHConnection()
    sshconnection.configure(
        hostname=host, username=username, password=password, timeout=30
    )
    sshconnection.connect()
    ts = sshconnection.invoke_shell()
    ts.send("telnet 0 20000\n")
    match_shell_til(ts, "EGATE>", 5)
    ts.send("trf_data_stop ue={} pdu=1 qfi=1 dir=dl\n".format(ue_index))
    match_shell_til(ts, "Stopped Downlink Internal traffic", 5)
    ts.close()
    sshconnection.disconnect()


def stop_UL_traffic_for_AP(host, username, password, ue_index):
    sshconnection = SSHConnection()
    sshconnection.configure(
        hostname=host, username=username, password=password, timeout=30
    )
    sshconnection.connect()
    ts = sshconnection.invoke_shell()
    ts.send("telnet 0 20000\n")
    match_shell_til(ts, "EGATE>", 5)
    ts.send("trf_data_stop ue={} pdu=1 qfi=1 dir=ul\n".format(ue_index))
    match_shell_til(ts, "Stopping Uplink Internal traffic", 5)
    ts.close()
    sshconnection.disconnect()


def ue_detach_for_AP(host, username, password, ue_index):
    sshconnection = SSHConnection()
    sshconnection.configure(
        hostname=host, username=username, password=password, timeout=30
    )
    sshconnection.connect()
    ts = sshconnection.invoke_shell()
    ts.send("telnet 0 20000\n")
    match_shell_til(ts, "EGATE>", 5)
    ts.send("ue_pdu_session_release ue={} pdu=1\n".format(ue_index))
    match_shell_til(ts, "Successfully released PDU Session", 5)
    ts.send(
        "ue_deregister id={} ue_deregister_type=switch_off by=ue\n".format(ue_index)
    )
    match_shell_til(ts, "detached", 5)


if __name__ == "__main__":
    # host = "10.57.159.90"
    # username = "ute"
    # password = "iW_K#8.ute%A10h0m0ra"
    # config_file = "basic_modify.cfg"
    # egate_load_config(host=host, username=username, password=password, config_file=config_file)
    # ue_attach_for_AP(host=host, username=username, password=password, ue_index=1)
    # time.sleep(10)
    # stop_DL_traffic_for_AP(host=host, username=username, password=password, ue_index=1)
    # stop_UL_traffic_for_AP(host=host, username=username, password=password, ue_index=1)
    time.sleep(3)
    # ue_detach_for_AP(host=host, username=username, password=password, ue_index=1)
