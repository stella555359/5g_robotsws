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


def launch_iperf(first_ue=1, number_of_ues=1, launch_server=True, kill_processes=True):
    if kill_processes:
        os.system("pkill -9 iperf")
        time.sleep(1)
    if launch_server:
        os.system("iperf -s -p 15612 -i 1 -B 10.0.2.1 -f m -w 3200k --nodelay > /tmp/iperf_server.log &")
        # os.system("iperf -s -u -b 88M -p 15612 -i 1 -B 10.0.2.1 -f m > /tmp/iperf_server.log &")
        time.sleep(1)
    ip_addresses = get_ip_addresses()
    for ue in range(first_ue, first_ue + number_of_ues):
        if ue in ip_addresses:
            command = f"iperf -c {ip_addresses[ue]} -p 15612 -i 1 -t 36000 -B 10.0.2.1 -f m -w 3200k " + \
                      f"--nodelay > /tmp/iperf_UE_{ue}.log &"
            # command = f"iperf -c {ip_addresses[ue]} -u -b 88M -p 15612 -i 1 -t 36000 -B 10.0.2.1 -f m " + \
            #           f"> /tmp/iperf_UE_{ue}.log &"
            print(f"Launching iperf for ue {ue} on {ip_addresses[ue]}\n{command}")
            os.system(command)
            time.sleep(1)
        else:
            raise Exception(f"Could not find IP address for ue {ue}")


if __name__ == '__main__':
    launch_iperf(int(sys.argv[1]), int(sys.argv[2]))
