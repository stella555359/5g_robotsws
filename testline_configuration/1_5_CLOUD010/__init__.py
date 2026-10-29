__maintainer__ = "Huang Dan"
__team__ = "siso"
__email__ = "dan.huang@nokia-sbell.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import FACOM
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.213.81", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = FACOM(addr="10.56.7.230", port_numbers=[8], model="facom")
_pdu_2 = FACOM(addr="10.56.7.125", port_numbers=[5], model="facom")
_pdu_3 = FACOM(addr="10.106.211.86", port_numbers=[5, 6, 7], model="facom")


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9174042741",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183241613",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183241425",
    pdu_port=_pdu_1.pdu_ports[8],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="473095A.202",
    serial_number="K9173149543",
)
# _fct_2 = CommonUnit(
#     SshServiceDetails(
#         addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_fsp_4, _fsp_5],
#     pdu_port=_pdu_2.pdu_ports[2],
#     hardware_type="ASIA",
#     hardware_version="A.203",
#     serial_number="L1173212320",
# )
_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="Panasonic(AHED)",
    serial_number="6Q175121185",
    pdu_port=_pdu_2.pdu_ports[5],
    product_code="473807A.101",
)

_rmod_2 = RU(
    ru_hw_group="Panasonic(FHPC)",
    serial_number="6Q184907521",
    pdu_port=_pdu_3.pdu_ports[5],
    product_code="473218A.102",
)

_rmod_3 = RU(
    ru_hw_group="Panasonic(FHPC)",
    serial_number="6Q184111146",
    pdu_port=_pdu_3.pdu_ports[6],
    product_code="473218A.102",
)

_rmod_4 = RU(
    ru_hw_group="Panasonic(FHPC)",
    serial_number="6Q184907524",
    pdu_port=_pdu_3.pdu_ports[7],
    product_code="473218A.102",
)


_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])
# _enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1, _test_pc_2], enbs=[_enb_sbts_1, _enb_sbts_2])

tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])

__all__ = ["tl"]
# from ta_gve_conf.interface import ta_gve_conf

# TL1 = {
#        'HOST_IP': '10.106.213.81',
#        'FR': {'6Q175121185': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.125', 'port': 5},#FHDI[35]
#                               'fiber_length': {'physical_port0': 5.13, 'physical_port1': 2, 'delta': 30},
#                               'link_proto': 'O3',
#                               'feg_without_mha': 30,
#                               'chain': '1.3.1.1',
#                               'qc': {'hw_config': 'Single Radio'}},
#               },
#        'BBMOD': {'K9174042741': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}},
#                  'L1162412049': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}},
#                  'L1162412066': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}},
#                  },
#
#        'FSM':  {'K9173149543': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}}}  #hw_version: X21, X31, A101; hw_type: FSME, FSMF, FSIP, FSIH
# }

# tl = ta_gve_conf(TL1, hw_type="fsmr4", fr=False)
# tl = ta_gve_conf(TL1, fr=True)
# node1 = tl[1]

# NODES = {
#     'TEAM': 'SISO_CRT',
#     'TL1': {
#           'HOST_IP': '10.106.213.81',
#           'FR': {'6Q175121185': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.125', 'port': 5},#FHDI[35]
#                               'fiber_length': {'physical_port0': 5.13, 'physical_port1': 2, 'delta': 30},
#                               'link_proto': 'O3',
#                               'feg_without_mha': 30,
#                               'chain': '1.3.1.1',
#                               'qc': {'hw_config': 'Single Radio'}},
#               },
#          #'EC': {'L9160700469': {'pdu': {'type': None, 'ip_addr': None, 'port': None}}},
#         'EC': {'K9174042741': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}},
#                  'L1162412049': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}},
#                  'L1162412066': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}},
#                  },
#
#          'FSM':  {'K9173149543': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.230', 'port': 8}}}
#     },
# }
#
# # SiSo additional variables
# RF_FACTORY_SW_STORAGE = {
#     'LOGIN': 'siso',
#     'PASSWORD': 'siso',
#     'HOST_IP': '10.106.211.194',
#     'SW_PATH': '/home/siso/LTE/Factory_SW/',
#     'CONFIG_PATH': '/home/siso/LTE/Factory_SW/',
#     'CONFIG_FILE': 'config.py',
#     'RRUpassword': '',
#     'IMAGE_FILE': 'FRM-rfsw-image-install_20170901151555-multi.tar',
#     'checksum': '0xd516d872',
#     'fileVersion': 'install_20170901151555-multi',
#     'BuildName': 'FRM57.08.R03C',
#     'BuildVersion': 'FRM57.08.R03C'
# }
#
# SW_BUILDS_DIR_PATH= "/home/ute/Downloads/"
# REQUIRE_PACKAGES= "Active"
#
# ALLOWED_ALARMS = ['Vendor BTS certificate',
#                   'Synchronization lost',
#                   'Diagnostic Files collected',
#                   'BTS booted at .*? due to trs management reset',
#                   '.*? ToP master service .*? unusable',
#                   'NTP Server .*? unavailable',
#                   'SSH enabled',
#                   'R&D Service Port enabled',
#                   'LMP access via port.*',
#                   'Service account root access is enabled',
#                   'BTS internal SW management problem',
#                   'Failure in optical interface',
#                   'Receiving failure in Optical Interface',
#                   'Unsigned software release has been successfully downloaded'
#                   'PPS reference missing',
#                   'BTS Reset Cause',
#                   'Ethernet port security is disabled',
#                   'Sanity Check Error'
#                   ]
