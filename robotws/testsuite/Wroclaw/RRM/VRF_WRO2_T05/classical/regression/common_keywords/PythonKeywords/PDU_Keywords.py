# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Kacper Falkiewicz
:contact: kacper.falkiewicz@nokia.com
"""
from robot.libraries.BuiltIn import BuiltIn
from collections import defaultdict
from taf.hw.pdu import pdu


def reset_pdu_port(ip, port, version="8221-1"):
    """
    Resets port on EPC pdu.

    :param ip: ip address to PDU
    :type ip:  str
    :param port: port number user wants to reset on PDU
    :type port: int/str
    :param version: version of EPC PDU model, '8221-1' at default
    :type str
    """
    pdu_dev = pdu()
    pdu_dev.setup_pdu(model="EPC", version=str(version), host=str(ip))
    pdu_dev.reset_ports(ports=list([port]), time_interval=15)


def get_port_number_from_init(pdu_obj):
    """
    Return from pdu object list of ports

    :param pdu_obj: Object pdu.
    :type pdu_obj: pdu object
    :return: list of port numbers
    :rtype: list
    """
    return [key for key, _ in pdu_obj.pdu_ports.iteritems()]


def get_radio_pdu_ip_and_ports_from_init():
    """
    Returns all ports and IP for RMODs connected to PDU from __init__ file.
    :return: dictionary with PDU ports and ip for radio units
    :rtype: dict
    """
    return {radio_units_objects.pdu_port.port_no: radio_units_objects.pdu_port.pdu.addr
            for radio_units_objects in BuiltIn().get_variable_value("${tl.gnbs[0].dus[0].rus}")}


def get_list_of_radio_pdu_ports_ip_types_and_versions_from_init():
    """
    Returns all PDU ports, IPs and types for RMODs specified in __init__ file.
    :return: list with PDU ports, ips, types and versions for radio units
    :rtype: list
    """
    rus = BuiltIn().get_variable_value("${tl.gnbs[0].dus[0].rus}")
    ru_pdu_spec_list = []
    for elem in rus:
        pdu_model, pdu_version = _get_pdu_model_and_version(elem.pdu_port.pdu.addr)
        ru_pdu_spec = [elem.pdu_port.port_no, elem.pdu_port.pdu.addr, pdu_model, pdu_version]
        ru_pdu_spec_list.append(ru_pdu_spec)
    return ru_pdu_spec_list


def get_pdu_port_status(pdu_ip, pdu_port, alias):
    """
    Get port status on PDU

    :param pdu_ip: Address ip PDU
    :type pdu_ip: str
    :param pdu_port: Port PDU which will be check
    :type pdu_port: str
    :param alias: alias to connection i.e 'pdu'
    :type alias: str
    :return: status of port
    :rtype: str
    """
    pdu_ = pdu()
    model, pdu_version = _get_pdu_model_and_version(pdu_ip)
    pdu_.setup_pdu(model=model, host=pdu_ip, version=pdu_version, alias=alias)

    return pdu_.get_port_status(port=int(pdu_port), pdu_device=alias)


def _get_pdu_model_and_version(pdu_ip):
    """
    Get model and version of PDU by PDU IP from __init__ file

    :param pdu_ip: Address ip PDU
    :type pdu_ip: str
    :return: tuple of pdu model and pdu version
    :rtype: list(str, str)
    """
    number_of_pdus = len(BuiltIn().get_variable_value('${tl.pdus}'))
    for pdu in range(number_of_pdus):
        pdu_from_init = BuiltIn().get_variable_value('${tl.pdus[%s]}' % pdu)
        if pdu_from_init.addr == pdu_ip:
            return pdu_from_init.__class__.__name__, pdu_from_init.version


def collect_list_of_ports_by_pdu_ip_and_model():
    """
    Returns list with list of PDU details and ports specify for taf.hw.pdu.reset_ports method.
    IP's, ports and PDU types for RMODs are specified in __init__ file.

    :return list of lists ex.[[('10.10.100.11', 'ATEN', 'None'), [7, 8]], [('10.10.100.12', 'Gude', '8221-1'), [5, 6]]]
    :rtype  list of lists
    """
    pdus = get_list_of_radio_pdu_ports_ip_types_and_versions_from_init()
    d = defaultdict(list)
    for pdu_port, pdu_address, pdu_model, pdu_version in pdus:
        d[pdu_address, pdu_model, pdu_version].append(pdu_port)

    return [[k] + [v] for k, v in d.items()]
