# -*- coding: utf-8 -*-
"""
Author: Linjiangjing
Contacts: jiangjing.lin@nokia-sbell.com
Squard: HGZ SG8
Description: include common Linux operations

"""
from taf.transport.ssh import ssh
import re

ssh = ssh()


def get_idle_port(connection, startport=15006, endport=65535):
    port_used_info = ssh.execute(command="netstat -ln", connection=connection)
    port_used = []
    if port_used_info:
        port_used_info = port_used_info.split("\r\n")
        for item in port_used_info:
            pattern = ""
            if item.startswith('tcp') or item.startswith('udp'):
                pattern = r'.*:(\d+)\s+'
            elif item.startswith('unix'):
                pattern = r'.*LISTENING\s+(\d+)\s+'
            if pattern:
                result = re.match(pattern, item)
                if result:
                    port = result.group(1)
                    port_used.append(int(port))
    for i in range(startport, endport):
        if i not in port_used:
            return i
        else:
            i += 1


def get_program_version(version):
    results = re.findall(r"\d\dR\d", str(version))
    if results:
        return results[0]
    else:
        return "Undefined"
