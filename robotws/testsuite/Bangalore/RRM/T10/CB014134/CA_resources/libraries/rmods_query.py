# -*- coding: utf-8 -*-
"""
:author: Sebastian Dziewiecki
:contact: sebastian.dziewiecki@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from lxml import etree


def check_rmods_number_in_scf(scf_path):
    """
    :param scf_path: Path to SCF file
    :type scf_path: str
    :return: RMODS number found in SCF
    :rtype int
    """
    parsed_scf = etree.parse(scf_path)
    ns = {'ns': parsed_scf.getroot().nsmap[None]}
    rmods = parsed_scf.findall('.//ns:managedObject[@class="{}"]'.format('com.nokia.srbts.eqm:RMOD'), namespaces=ns)
    return len(rmods)
