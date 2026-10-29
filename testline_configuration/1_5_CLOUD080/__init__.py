__owner__ = "Wu Xiaotong"
__maintainer__ = "Wu Xiaotong"
__email__ = "xiaotong.wu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.223", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.106.211.92",
    port_numbers=[6],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.69.66.107",
    port_numbers=[7],
    model="facom",
)

_pdu_3 = FACOM(
    addr="10.106.211.88",
    port_numbers=[4, 6],
    model="facom",
)

_pdu_4 = FACOM(
    addr="10.106.211.92",
    port_numbers=[2, 8],
    model="facom",
)

_pdu_5 = FACOM(
    addr="10.56.7.123",
    port_numbers=[4, 7, 8],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9174042690",
    pdu_port=_pdu_2.pdu_ports[7],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1171105946",
    pdu_port=_pdu_2.pdu_ports[7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="EA185084291",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="UHLB:CPRI_A_RRH_4T4R",
    serial_number="14W352G40042",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="UHLC:CPRI_A_RRH_4T4R",
    serial_number="16W364G30104",
    pdu_port=_pdu_5.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="FRBI:CPRI_A_RRH_4T4R",
    serial_number="K9173717581",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="UHLB:CPRI_A_RRH_4T4R",
    serial_number="15W369G40020",
    pdu_port=_pdu_4.pdu_ports[8],
)

_rmod_5 = RU(
    ru_hw_group="FRBI:CPRI_A_RRH_4T4R",
    serial_number="K9173717578",
    pdu_port=_pdu_5.pdu_ports[8],
)

_rmod_6 = RU(
    ru_hw_group="UHLB:CPRI_A_RRH_4T4R",
    serial_number="14W346F20948",
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_7 = RU(
    ru_hw_group="FRBI:CPRI_A_RRH_4T4R",
    serial_number="K9173717577",
    pdu_port=_pdu_5.pdu_ports[7],
)

_enb_sbts = RealEnb(
    system_module=_smod,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_AIL_B1_CRT2_1080",
)

__all__ = ["tl"]
# TL1 = {
#     "HOST_IP": "10.106.233.212",
#     "FR": {
#         "1M181624819": {
#             "pdu": {"type": "FACOM", "ip_addr": "10.56.7.211", "port": 2},
#             "fiber_length": {"physical_port0": 10.2, "physical_port1": 2, "delta": 30},
#             "link_proto": "C4",
#             "feg_without_mha": 30,
#             "chain": "1.1.1.1",
#             "qc": {"hw_config": "Single Radio"},
#             "eac": {"ip_addr": "10.106.211.93", "port": "B"},
#         },
#     },
#     "EC": {
#         "L1204706784": {"pdu": {"type": "FACOM", "ip_addr": "10.56.7.211", "port": 1}},
#     },
#     "FSM": {
#         "L1185009186": {"pdu": {"type": "FACOM", "ip_addr": "10.56.7.211", "port": 1}}
#     },
# }
#
# NODES = {
#     "TEAM": "SISO_CRT",
#     "TL1": {
#         "HOST_IP": "10.106.233.212",
#         "FR": {
#             "1M181624819": {
#                 "pdu": {"type": "FACOM", "ip_addr": "10.56.7.211", "port": 2},
#                 "fiber_length": {
#                     "physical_port0": 10.2,
#                     "physical_port1": 2,
#                     "delta": 30,
#                 },
#                 "link_proto": "C4",
#                 "feg_without_mha": 30,
#                 "chain": "1.1.1.1",
#                 "qc": {"hw_config": "Single Radio"},
#                 "eac": {"ip_addr": "10.106.211.93", "port": "B"},
#             },
#         },
#         "EC": {
#             "L1204706784": {
#                 "pdu": {"type": "FACOM", "ip_addr": "10.56.7.211", "port": 1}
#             }
#         },
#         "FSM": {
#             "L1185009186": {
#                 "pdu": {"type": "FACOM", "ip_addr": "10.56.7.211", "port": 1}
#             }
#         },
#     },
# }
#
# SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
#
# REQUIRE_PACKAGES = "Active"
#
# ALLOWED_ALARMS = [
#     "Vendor BTS certificate",
#     "Synchronization lost",
#     "Diagnostic Files collected",
#     "BTS booted at .*? due to trs management reset",
#     ".*? ToP master service .*? unusable",
#     "NTP Server .*?",
#     "BTS time not corrected",
#     "SSH enabled",
#     "R&D Service Port enabled",
#     "LMP access via port .*?",
#     "BTS Reset Cause",
#     "Service account root access is enabled",
#     "Ethernet port security is disabled",
#     "Sanity Check Error",
#     "Nokia MN BTS SFP validation failure",
# ]
#
# UE_TYPE = "CPE"
#
# GLO_TL_DESCRIPTOR_FILE_PATH = (
#     "/home/ute/testline_configuration/1_5_CLOUD064/TLdescriptor.xml"
# )
#
# CPE_INFO = [
#     {
#         "TYPE": "ZMTEL",
#         "BAND": "42,43,48",
#         "IP": "192.168.1.1",
#         "LAN_IP": "192.168.1.2",
#         "STATUS": "Enabled",
#     }
# ]
#
# IPERF_SERVER_INFO = {
#     "IP": "10.69.64.197",
#     "CTRL_IP": "10.69.64.196",
#     "USERNAME": "tdlte-tester",
#     "PASSWORD": "btstest",
#     "PORT": "22",
#     "LOG_PATH": "/home/tdlte-tester/UDP",
# }
#
# FW_INFO = {
#     "TYPE": "GG",
#     "IP": "10.56.7.147",
#     "USERNAME": "BTS2251",
#     "PASSWORD": "SISO1_test",
#     "Model": "98",
# }
#
# GGMAP = [
#     {
#         "DEVICE": "GG",
#         "IP": "10.56.7.147",
#         "BTS2251": {
#             "USER": "BTS2251",
#             "PSWD": "SISO1_test",
#             "productName": "AIRSCALE",
#             "SMOD-1": {"SN": "L1185009186"},
#             "BBMOD-1": {"SN": "L1204706784"},
#             "BBU_GG_PORT_MAPPING": {
#                 "BBMOD-1(0)": "110",
#             },
#         },
#         "AZQC-1": {
#             "productName": "AZQC",
#             "SN": "1M181624819",
#             "RRU_GG_PORT_MAPPING": {
#                 "1": "97",
#             },
#         },
#     }
# ]
#
# RF_FAULT_INFO = {
#     "1907": {
#         "trigger": {
#             "telnet": {
#                 "before": [
#                     "/ action create ConfigAccess /ca /module",
#                     '/ca action fetch DECODED "dpdnahka_dlpath1.bin" "/ram/dpdnahka_dlpath1.json"',
#                 ],
#                 "after": [
#                     '/ca action store PERMANENT DECODED "dpdnahka_dlpath1.bin" "/ram/dpdnahka_dlpath1.json"'
#                 ],
#             },
#             "ssh": [
#                 'sed -i "1580s/"threshold": 0.1,/"threshold": 0.00000001,/" /ram/dpdnahka_dlpath1.json'
#             ],
#         },
#         "cancel": {
#             "telnet": {"before": [], "after": []},
#             "ssh": ["rm /mnt/runtime/configs/* -rf"],
#         },
#         "port": 2000,
#     }
# }
#
#
# def config():
#     m = sys.modules[__name__]
#     test_line_config = {}
#     for att in dir(m):
#         value = getattr(m, att)
#         print(type(value))
#         if att.startswith("_") or type(value) == "function":
#             continue
#         else:
#             test_line_config[att] = getattr(m, att)
#             print(att, getattr(m, att))
#     print(test_line_config)
#     return test_line_config
#
#
# tl = config()
#
# __all__ = ["tl"]
