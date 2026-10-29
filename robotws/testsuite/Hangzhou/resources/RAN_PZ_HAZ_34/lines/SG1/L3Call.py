from taf.transport.ssh import ssh
from taf.transport.ssh.connection import connect
import re
import time
from robot.api import logger
import configparser
import os

iniconf = configparser.ConfigParser()
ssh = ssh()


def E500ASCConnectAndInvokeShell(ip, username, password, port):
    asccon = connect(hostname=ip, username=username, password=password, port=port)
    ascch = asccon.invoke_shell()
    time.sleep(5)
    result = ascch.recv(1024)
    print(result)
    return asccon, ascch


def E500ASCExecuteCommand(ascch, cmd):
    ascch.send(cmd)
    time.sleep(3)
    result = ascch.recv(1024)
    return result


def E500ASCDisconnect(accon):
    accon.disconnect()


def install_loadimage_by_yaft(svn_dir, addr, af_dir, connection):
    yaft_outcome = ssh.execute("cd {} && python ./yaft.py  -i {} -z {} -K".format(svn_dir, addr, af_dir),
                               connection=connection)
    if "Flashing done" in yaft_outcome:
        return True
    else:
        return False


def RemoveZeroString(data):
    return int(str(data))


def GetConfigIni(file, section, option):
    iniconf.read(file)
    return iniconf.get(section, option)


def SetConfigIni(file, section, option, value):
    iniconf.read(file)
    iniconf.set(section, option, value)
    iniconf.write(open(file, "w"))


def Get_And_Calculate_DL_throughput(alias, duration, location=17):
    ssh.send_command("journalctl -f | grep -i 'L2_LO_TB' | grep -i 'ttisFromUpdate'", bufsize=10000,
                     timeout=float(duration), connection=alias)
    time.sleep(float(duration))
    output = ssh.read_output(size=3000, connection=alias).split('\r\n')
    dl_output = output[0].split('\n')
    dl_output.pop()
    num = 0
    sum = 0
    for element in dl_output:
        # data = element.split(' ')[location]
        data = re.split(r"\s+", element)[location]
        traffic_data = data.split('|')[-1].split(']')[0]
        num += 1
        sum += int(traffic_data)
        logger.info("Traffic data {} bytes sent to UE".format(traffic_data))
    DL_Throughput = 8 * float(sum) / float(num) / 1000 / 1000
    logger.info("DL_Throughput is {}".format(DL_Throughput))
    return DL_Throughput


def Get_And_Calculate_UL_throughput(alias, duration):
    ssh.send_command("journalctl -f | grep rlcPdus",
                     bufsize=10000, timeout=float(duration), connection=alias)
    time.sleep(float(duration))
    output = ssh.read_output(size=3000, connection=alias).split('\r\n')
    ul_output = output[0].split('\n')
    ul_output.pop()
    num = 0
    sum = 0
    for element in ul_output:
        # traffic_data = element.split(' ')[11]
        traffic_data = re.split(r"\s+", element)[11]
        num += 1
        sum += int(traffic_data)
        logger.info("Traffic data {} bytes received from UE".format(traffic_data))
    UL_Throughput = 8 * float(sum) / float(num) / 1000 / 1000
    logger.info("UL_Throughput is {}".format(UL_Throughput))
    return UL_Throughput


def Calculate_DL_throughput(input):
    output = input.split('\r\n')
    dl_output = output[0].split('\n')
    dl_output.pop()
    num = 0
    sum = 0
    for element in dl_output:
        data = element.split(' ')[17]
        traffic_data = data.split('|')[-1].split(']')[0]
        num += 1
        sum += int(traffic_data)
        logger.info("Traffic data {} bytes sent to UE".format(traffic_data))
    DL_Throughput = 8 * float(sum) / float(num) / 1000 / 1000
    logger.info("DL_Throughput is {}".format(DL_Throughput))
    return DL_Throughput


def Calculate_UL_throughput(input):
    output = input.split('\r\n')
    ul_output = output[0].split('\n')
    ul_output.pop()
    num = 0
    sum = 0
    for element in ul_output:
        traffic_data = element.split('(')
        if len(traffic_data) >= 2:
            traffic_data = traffic_data[1].split(' ')[0]
            num += 1
            sum += int(traffic_data)
            logger.info("Traffic data {} bytes received from UE".format(traffic_data))
    UL_Throughput = 8 * float(sum) / float(num) / 1000 / 1000
    logger.info("UL_Throughput is {}".format(UL_Throughput))
    return UL_Throughput


def record_throughput_to_file(case_name, path='tp.txt', percent=0, tp=0, bler=0):
    mcs = case_name.split('_')[-1]
    key = case_name.split('Peakrate_')[1].split('_AM')[0]
    with open(path, 'a+') as f:
        f.writelines('{:10} {:}:{:<20.2f} PERCENT:{:<10.0f} BLER:{:.2f}\n'.format(mcs, key, tp, percent, bler))
