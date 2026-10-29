from ipaddress import ip_address
from ipaddress import ip_network
from typing import List
import re
import ipaddress


class networkKit(object):
    def get_ip_list_by_range(self, ip_range):
        start_ip, end_ip = ip_range.split("-")
        start = int(ipaddress.IPv4Address(start_ip))
        end = int(ipaddress.IPv4Address(end_ip)) + 1

        ip_list = []
        for i in range(start, end):
            ip_list.append(str(ipaddress.IPv4Address(i)))
        return ip_list
