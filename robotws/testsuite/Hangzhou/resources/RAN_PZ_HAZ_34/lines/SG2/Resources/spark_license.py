# -*- coding: utf-8 -*
"""
Author: Wang ming
Contacts: ming.5.wang@nokia-sbell.com
Description: Get and release spark license
"""

import socket
import json
import taf.transport.ssh as ssh
import time


def creat_tcp_connection(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    return s


def tcp_send_command(conn, cmd, param=None, index=None, timeout=310):
    conn.settimeout(timeout)
    msg = {"CMD": cmd}
    if index:
        msg['EQIndex'] = index
    if param:
        msg['Param'] = param
    msg = json.dumps(msg)
    msg = msg.encode('utf-8')
    conn.send(msg)
    result = conn.recv(1024)
    print(result)


def close_tcp_connection(conn):
    conn.close()


# get spark license
def get_spark_license_for_team(host, user, password):
    param = {"IP": "10.101.36.4", "Port": 3002, "Account": user, "Password": password}
    login = "LoginAuth"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=login, param=param)
    close_tcp_connection(conn=connection)


# release spark license
def release_spark_license_for_team(host):
    logout = "LogoutAuth"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=logout)
    close_tcp_connection(conn=connection)


def start_test_record(host, logpath, logname):
    param = {"LogPath": logpath, "LogName": logname}
    startlog = "StartLog"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=startlog, param=param)
    close_tcp_connection(conn=connection)


def stop_test_record(host):
    stoplog = "StopLog"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=stoplog)
    close_tcp_connection(conn=connection)


def export_report_for_T10812(host, Logfiles, ReportName, ReportGenerationPath):
    param = {"ReportName": ReportName, "ReportGenerationPath": ReportGenerationPath,
             "OpenReportResult": "false", "Logfiles": Logfiles}
    ExportReport = "ExportReport"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=ExportReport, param=param)
    close_tcp_connection(conn=connection)


def dele_report_on_pc(host, username, password, filename):
    sshconn = ssh.ssh()
    sshconn.connect_to(host, username, password)
    cmd = "rm -rf" + " " + filename
    print(cmd)
    sshconn.execute(cmd)
    sshconn.disconnect()


def run_python_script_on_TestPC(host, username, password, scriptpath, script):
    sshconn = ssh.ssh()
    sshconn.connect_to(host, username, password)
    cmd = "cd" + " " + scriptpath + ";" + script
    print(cmd)
    sshconn.execute(cmd)
    sshconn.disconnect()


def reset_spark_ue(host, ue):
    sendat = "SendAT"
    param1 = {"Command": "AT+GTCELLLOCK=0", "Timeout": 50000, "SuccStr": "+AT READY"}
    param2 = {"Command": "AT+CFUN=15", "Timeout": 50000, "SuccStr": "+AT READY"}
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=sendat, index=ue, param=param1)
    tcp_send_command(conn=connection, cmd=sendat, index=ue, param=param2)
    close_tcp_connection(conn=connection)


def stop_spark_ul_traffic(host, ue):
    stopultraffic = "StopULtraffic"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=stopultraffic, index=ue)
    close_tcp_connection(conn=connection)


def export_line_chartPic_for_T962(host, Logfiles, Template, ExportPath, minutes=30):
    param = {"Logfile": Logfiles, "Template": Template, "Minutes": minutes, "ExportPath": ExportPath}
    ExportReport = "ExportLineChartPic"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=ExportReport, param=param)
    close_tcp_connection(conn=connection)


def power_on_for_spark(host, ue_index):
    MTUPowerOn = "MTUPowerOn"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=MTUPowerOn, index=ue_index)
    close_tcp_connection(conn=connection)


def power_off_for_spark(host, ue_index):
    MTUPowerOff = "MTUPowerOff"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=MTUPowerOff, index=ue_index)
    close_tcp_connection(conn=connection)


def detach_spark_ue(host, ue):
    sendat = "SendAT"
    param1 = {"Command": "AT+CFUN=0", "Timeout": 50000}
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=sendat, index=ue, param=param1)
    close_tcp_connection(conn=connection)


def get_tput_from_spark(host, ue_index):
    GetParamMAC = "GetParamMAC"
    connection = creat_tcp_connection(host=host, port=30999)
    tcp_send_command(conn=connection, cmd=GetParamMAC, index=ue_index)
    close_tcp_connection(conn=connection)
