__owner__ = "Sheng Haoyun"
__maintainer__ = "Sheng Haoyun"
__email__ = "haoyun-lyle.sheng@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.70", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.74", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = HBTE(
    addr="10.108.151.133",
    port_numbers=[5],
    model="hbte",
)

_pdu_2 = FACOM(
    addr="10.108.151.66",
    port_numbers=[5, 6],
    model="facom",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607775",
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607766",
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607774",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607786",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607783",
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607776",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162206446",
    capacity_units=[_fsp_1, _fsp_2, _fsp_5],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162013322",
    capacity_units=[_fsp_3, _fsp_4, _fsp_6],
)

_smod1 = Airscale([_fct_1])
_smod2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="AZQC:cMAA_Gen3.14_64T64R",
    serial_number="6Q183834501",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_2 = RU(
    ru_hw_group="AZQC:cMAA_Gen3.14_64T64R",
    serial_number="6Q183834501",
    pdu_port=_pdu_1.pdu_ports[5],
)

_enb_sbts1 = RealEnb(system_module=_smod1, rms=[_rmod_1])
_enb_sbts2 = RealEnb(system_module=_smod2, rms=[_rmod_2])


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb_sbts1, _enb_sbts2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AILR_B1_B6_CRT2_1039",
)

__all__ = ["tl"]
# TL1 = {
#        'HOST_IP': '10.108.152.70',
#        'FR': {'6Q183834501': {'pdu': {'type': 'HBTE', 'ip_addr': '10.108.151.133', 'port': 5},
#                               'fiber_length': {'physical_port0': 10.2, 'physical_port1': 2, 'delta': 30},
#                               'link_proto': 'C4',
#                               'feg_without_mha': 30,
#                               'chain': '1.1.1.1',
#                               'qc': {'hw_config': 'Single Radio'}
#                              }},
#        'FSM': {'L1181008950': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 6}}}
# }
#
# #tl = ta_gve_conf(TL1, hw_type="fsmr4")
#
# NODES = {
#     'TEAM': 'SISO_CRT',
#     'TL1': {
#           'HOST_IP': '10.108.152.70',
#           'FR': {'6Q183834501': {'pdu': {'type': 'HBTE', 'ip_addr': '10.108.151.133', 'port': 5},#AAHJ
#                 'fiber_length': {'physical_port0': 10.2, 'physical_port1': 2, 'delta': 30},
#                 'link_proto': 'C4',
#                 'feg_without_mha': 30,
#                 'chain': '1.1.1.1',
#                 'qc': {'hw_config': 'Single Radio'}},
#               },
#          'EC': {'AH173607783': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 5}},'AH173607775': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 5}},'AH173607766': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 5}}},
#
#          'FSM':  {'L1181008950': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 5}}}
#     },
# 	'TL2': {
#           'HOST_IP': '10.108.152.74',
#           'FR': {'6Q183834501': {'pdu': {'type': 'HBTE', 'ip_addr': '10.108.151.133', 'port': 5},#AAHJ
#                 'fiber_length': {'physical_port0': 10.2, 'physical_port1': 2, 'delta': 30},
#                 'link_proto': 'C4',
#                 'feg_without_mha': 30,
#                 'chain': '1.1.1.1',
#                 'qc': {'hw_config': 'Single Radio'}},
#               },
#          'EC': {'AH173607774': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 6}},'AH173607786': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 6}},'AH173607776': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 6}}},
#
#          'FSM':  {'L1171305130': {'pdu': {'type': 'FACOM', 'ip_addr': '10.108.151.66', 'port': 6}}}
#     },
# }


# SiSo additional variables

# SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/config/Hangzhou/1_5_CLOUD052/node1/BTS_CLOUD_RF_AIL_B1_CRT1_1052_AZQC_T1_TL00.xml"

# SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
# REQUIRE_PACKAGES = "Active"

# RF_FACTORY_SW_STORAGE = {
#     'LOGIN': 'siso',
#     'PASSWORD': 'siso',
#     'HOST_IP': '10.106.211.11',
#     'SW_PATH': '/home/siso/LTE/Factory_SW/',
#     'CONFIG_PATH': '/home/siso/LTE/Factory_SW/',
#     'CONFIG_FILE': 'config.py'
# }

# ALLOWED_ALARMS = ['Vendor BTS certificate',
#                   'Synchronization lost',
#                   'Diagnostic Files collected',
#                   'BTS booted at .*? due to trs management reset',
#                   '.*? ToP master service .*? unusable',
#                   'NTP Server .*?',
#                   'BTS time not corrected',
#                   'SSH enabled',
#                   'R&D Service Port enabled',
#                   'LMP access via port .*?',
#                   'Ethernet port security is disabled',
#                   'Sanity Check Error',
#                   'Service account root access is enabled',]
#
# RF_FACTORY_SW_STORAGE = {
#     'LOGIN': 'siso',
#     'PASSWORD': 'siso',
#     'HOST_IP': '10.106.211.194',
#     'SW_PATH': '/home/siso/LTE/Factory_SW/',
#     'RRUpassword': '',
#     'IMAGE_FILE': 'rfsw-image_20180830094706.tar',
#     'checksum': '0x26e88959',
#     'fileVersion': '20180830094706',
#     'BuildName': '3DC58.09.R05',
#     'BuildVersion': '3DC58.09.R05'
# }
