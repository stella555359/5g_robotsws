"""
:copyright: Nokia Networks
:author: Malgorzata Konior <malgorzata.konior@nokia.com>
:maintainer: Malgorzata Konior <malgorzata.konior@nokia.com>
"""

import logging
from ta_messaging.message_flows import get_flow

logger = logging.getLogger('messaging.flows.logic')


def check_ip_in_message(msg, flow, interface_ips, interface=None):
    binary_ip = get_binary_ip_from_message(msg, flow, interface)
    ip_in_message = convert_bin_to_ip_list(binary_ip)
    assert set(ip_in_message) == set(interface_ips), \
        'IP mismatch in message: {}. Expected: {}, got {}'.format(msg, interface_ips, ip_in_message)


def get_binary_ip_from_message(msg, flow, interface=None):
    message = get_flow(flow).get_message(msg)
    if msg == 'BearerContextSetupResponse' or msg == 'BearerContextModificationResponse_1':
        if interface == 'NG':
            ip_binary = message.get_value_by_unique_key(
                'nG-DL-UP-TNL-Information')['gTPTunnel']['transportLayerAddress']
        elif interface == 'XN':
            ip_binary = message.get_value_by_unique_key('dL-Data-Forwarding')['gTPTunnel']['transportLayerAddress']
        else:
            logger.error(f"Message: {msg} contains NG and XN IP address. Choose interface")
            raise Exception
    elif msg == 'BearerContextModificationRequest':
        ip_binary = message.get_value_by_unique_key(
            'dL-UP-Parameters')[1]['uP-TNL-Information']['gTPTunnel']['transportLayerAddress']
    elif msg == 'XnUAddressIndication':
        ip_binary = message.get_value_by_unique_key('tnl-address')
    else:
        ip_binary = message.get_value_by_unique_key('transportLayerAddress')
    return ip_binary


def convert_bin_to_ip_list(ip_binary):
    ip_list = []
    if len(ip_binary) == 34:
        ipv4_bin = ip_binary[2:]
        ipv4 = '.'.join(str(int(ipv4_bin[i:i + 8], 2)) for i in range(0, len(ipv4_bin), 8))
        ip_list.append(ipv4)
    elif len(ip_binary) == 130:
        ipv6_bin = ip_binary[2:]
        ipv6 = ':'.join(str(hex(int(ipv6_bin[i:i + 16], 2)))[2:] for i in range(0, len(ipv6_bin), 16))
        ip_list.append(ipv6)
    elif len(ip_binary) == 162:
        ipv4_bin = ip_binary[2:34]
        ipv6_bin = ip_binary[34:]
        ipv4 = '.'.join(str(int(ipv4_bin[i:i + 8], 2)) for i in range(0, len(ipv4_bin), 8))
        ipv6 = ':'.join(str(hex(int(ipv6_bin[i:i + 16], 2)))[2:] for i in range(0, len(ipv6_bin), 16))
        ip_list = [ipv4, ipv6]
    else:
        raise ValueError("Wrong binary length")
    return ip_list
