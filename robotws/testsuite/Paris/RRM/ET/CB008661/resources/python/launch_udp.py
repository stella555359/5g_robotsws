import os
import sys
import time


def get_ip_addresses():
    ip_addresses = {}
    with open("/opt/wts/latest/egate_console.log", "r") as egate_log:
        line = egate_log.readline()
        ue = -1
        while line:
            if "ue_pdu_session_setup ue=" in line:
                ue = int(line.split("ue_pdu_session_setup ue=")[1].split(" ")[0])
                if ue in ip_addresses:
                    del ip_addresses[ue]
            if "UE IP address:" in line:
                ip_addresses[ue] = line.split("UE IP address:")[1].split(" ")[0]
            line = egate_log.readline()
    return ip_addresses


def launch_udp(first_ue=1, number_of_ues=1, launch_server=True, kill_processes=True):
    if kill_processes:
        os.system("pkill -9 udpClient")
        os.system("pkill -9 udpServer")
        os.system("pkill -9 ping")
        time.sleep(1)
    if launch_server:
        os.system("resources/c/udpServer > /tmp/udpServer.log &")
        time.sleep(1)
    ip_addresses = get_ip_addresses()
    for ue in range(first_ue, first_ue + number_of_ues):
        if ue in ip_addresses:
            command = f"ping {ip_addresses[ue]} > /tmp/ping_UE_{ue}.log &"
            print(f"Launching ping for ue {ue} on {ip_addresses[ue]}\n{command}")
            os.system(command)
            time.sleep(1)
            command = f"resources/c/udpClient s=72.{22 + ue}.0.1 p={10022 + ue} r=1000 a=1 " + \
                      f"> /tmp/udpClient_UE_{ue}.log &"
            # command = f"resources/c/udpClient s=127.0.0.1 p={10022+ue} r=60000 a=0 > /tmp/udpClient_UE_{ue}.log &"
            print(f"Launching udpClient for ue {ue}\n{command}")
            os.system(command)
            time.sleep(1)
        else:
            raise Exception(f"Could not find IP address for ue {ue}")


if __name__ == '__main__':
    launch_udp(int(sys.argv[1]), int(sys.argv[2]))
