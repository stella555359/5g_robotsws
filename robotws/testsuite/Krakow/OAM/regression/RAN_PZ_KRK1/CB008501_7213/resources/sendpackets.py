import sys
from scapy.all import sendpfast
from scapy.layers.l2 import Ether
from scapy.layers.inet import IP, UDP, TCP, ICMP
import os


def scapy_send(src_macaddr, dst_macaddr, protocol, packets_number, pps, ru_ip, iface_val):
    """
    Sends packets using scapy command
    :param src_macaddr:       MAC address of the device from which packets will be sent
    :param dst_macaddr:       MAC address of the device which will receive packets
    :param protocol:          Type of protocol to use (ICMP/TCP/UDP) with specified type and code
    :param packets_number:    Number of packets to be sent in total
    :param pps:               Number of packets to be sent per second
    :param ru_ip:             IPv4 of RU
    :param iface_val:         Interface name of Test PC interface
    """
    eth = Ether(src=src_macaddr, dst=dst_macaddr)
    i = IP(dst=ru_ip)
    q = eval(protocol)
    p = (eth / i / q)
    send_res = sendpfast(p, pps=int(pps), iface=iface_val, loop=int(packets_number), parse_results=True)
    if int(send_res['successful']) == int(packets_number) and int(send_res['failed']) == 0:
        os.system("echo True")
    return os.system("echo " + str(send_res))


if __name__ == "__main__":
    result = scapy_send(
        sys.argv[1],
        sys.argv[2],
        sys.argv[3],
        sys.argv[4],
        sys.argv[5],
        sys.argv[6],
        sys.argv[7])
