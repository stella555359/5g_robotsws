__owner__ = "Nie Sue"
__maintainer__ = "Nie Sue"
__email__ = "sue.nie@nokia-sbell.com"

import os
import re
import yaml

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
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.76", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.234",
    port_numbers=[1, 5],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.232",
    port_numbers=[5, 6, 7, 8],
    model="facom",
)

_pdu_3 = FACOM(
    addr="10.56.7.238",
    port_numbers=[2, 5, 6, 7],
    model="facom",
)

_pdu_4 = FACOM(
    addr="10.56.7.144",
    port_numbers=[1, 2, 8],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBBC",
    hardware_version="A.102",
    serial_number="EA170728548",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="FBBC",
    hardware_version="A.102",
    serial_number="AS172533302",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A",
    serial_number="EA171661188",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRCJ:CPRI_A_RRH_4T4R",
    serial_number="6Q171725260",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRCJ:CPRI_A_RRH_4T4R",
    serial_number="6Q171716995",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRCJ:CPRI_A_RRH_4T4R",
    serial_number="6Q171716895",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="URCC:CPRI_A_RRH_4T4R",
    serial_number="TC09DF1558",
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_5 = RU(
    ru_hw_group="URCB:CPRI_A_RRH_4T4R",
    serial_number="TC09AS0322",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_6 = RU(
    ru_hw_group="URGA:CPRI_A_RRH_4T4R",
    serial_number="TC09CM1200",
    pdu_port=_pdu_3.pdu_ports[2],
)

_enb_sbts = RealEnb(
    system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6]
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FCC_CRT2_1006",
)

__all__ = ["tl"]

# TL1 = {
#   "HOST_IP": "10.106.213.76",
#  "FR": {
#     "6Q171725260": {
#        "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 8},  # FRCJ1
#       "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#      "link_proto": "CI6",
#     "feg_without_mha": 30,
#    "chain": "1.1.1",
#   "qc": {"hw_config": "Single Radio"},
# },
# "6Q171716995": {
#   "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 5},  # FRCJ2
#  "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
# "link_proto": "CI6",
# "feg_without_mha": 30,
#   "chain": "1.2.1",
#  "qc": {"hw_config": "Single Radio"},
# },
#   "6Q171716895": {
#       "pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 5},  # FRCJ3
#      "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#     "link_proto": "CI6",
#    "feg_without_mha": 30,
#   "chain": "1.3.1",
#  "qc": {"hw_config": "Single Radio"},
#     },
#    "TC09DF1558": {
#       "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 7},  # URCC1
#      "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#     "link_proto": "CI6",
#    "feg_without_mha": 30,
#   "chain": "1.1.1.1",
#  "qc": {"hw_config": "Single Radio"},
#       },
#      "TC09AS0322": {
#         "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 6},  # URCB2
#        "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#       "link_proto": "CI6",
#      "feg_without_mha": 30,
#     "chain": "1.1.2.1",
#    "qc": {"hw_config": "Single Radio"},
#      },
#      "TC09AS0275": {
#         "pdu": {"type": "FACOM", "ip_addr": "10.56.7.144", "port": 2},  # URCB3
#        "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#       "link_proto": "CI6",
#      "feg_without_mha": 30,
#     "chain": "1.1.3.1",
#    "qc": {"hw_config": "Single Radio"},
#       },
#'TC09FH0003': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.238', 'port': 1},  # URCC3
#              'fiber_length': {'physical_port0': 10, 'physical_port1': 2, 'delta': 30},
#              'link_proto': 'CI6',
#              'feg_without_mha': 30,
#              'chain': '1.1.4.1',
#              'qc': {'hw_config': 'Single Radio'}},
#      "6Q173115185": {
#         "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 7},  # FHPC1
#        "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#       "link_proto": "CI6",
#      "feg_without_mha": 30,
#     "chain": "1.1.1",
#    "qc": {"hw_config": "Single Radio"},
#     },
#    "6Q173210101": {
#       "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 5},  # FHPC2
#      "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#     "link_proto": "CI6",
#    "feg_without_mha": 30,
#   "chain": "1.2.1",
#  "qc": {"hw_config": "Single Radio"},
#       },
#      "6Q173210110": {
#         "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 6},  # FHPC3
#        "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#       "link_proto": "CI6",
#      "feg_without_mha": 30,
#     "chain": "1.3.1",
#    "qc": {"hw_config": "Single Radio"},
#      },
#     "TC09CM1200": {
#        "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 2},  # URGA1
#       "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#      "link_proto": "CI6",
#     "feg_without_mha": 30,
#    "chain": "1.1.1.1",
#   "qc": {"hw_config": "Single Radio"},
#      },
#      "TC09CM1210": {
#         "pdu": {"type": "FACOM", "ip_addr": "10.56.7.144", "port": 1},  # URGA2
#        "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#       "link_proto": "CI6",
#      "feg_without_mha": 30,
#     "chain": "1.1.2.1",
#    "qc": {"hw_config": "Single Radio"},
#      },
#     "TC09CL0615": {
#        "pdu": {"type": "FACOM", "ip_addr": "10.56.7.144", "port": 8},  # URGA3
#       "fiber_length": {"physical_port0": 10, "physical_port1": 2, "delta": 30},
#      "link_proto": "CI6",
#     "feg_without_mha": 30,
#    "chain": "1.1.3.1",
#    "qc": {"hw_config": "Single Radio"},
#    },
#'TC09CM1206': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.238', 'port': 3},  # URGA2
#   'fiber_length': {'physical_port0': 10, 'physical_port1': 2, 'delta': 30},
#   'link_proto': 'CI6',
#   'feg_without_mha': 30,
#   'chain': '1.1.2.1',
#   'qc': {'hw_config': 'Single Radio'}},
#'TC09CN0273': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.238', 'port': 4},  # URGA3
#   'fiber_length': {'physical_port0': 10, 'physical_port1': 2, 'delta': 30},
#   'link_proto': 'CI6',
#   'feg_without_mha': 30,
#   'chain': '1.1.4.1',
#   'qc': {'hw_config': 'Single Radio'}},
#   },
#  "BBMOD": {
#     "EA170728548": {"pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 1}},
#    "AS172533302": {"pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 1}},
#  },
#'BBMOD': {'L9160700469': {'pdu': {'type': None, 'ip_addr': None, 'port': None}},
#          }
# "FSM": {
#       "EA171661188": {"pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 1}}
#  },  # hw_version: X21, X31, A101; hw_type: FSME, FSMF, FSIP, FSIH
# }

# tl = ta_gve_conf(TL1, hw_type="fsmr4")
# tl = ta_gve_conf(TL1, fr=False)
# node1 = tl[1]

# NODES = {
#   "TEAM": "SISO_CRT",
#  "TL1": {
#     "HOST_IP": "10.106.213.76",
#    "FR": {
#       "6Q171725260": {
#          "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 8},  # FRCJ1
#         "fiber_length": {
#            "physical_port0": 10,
#           "physical_port1": 2,
#          "delta": 30,
#     },
#    "link_proto": "CI6",
#   "feg_without_mha": 30,
#  "chain": "1.1.1",
# "qc": {"hw_config": "Single Radio"},
#            },
#           "6Q171716995": {
#              "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 5},  # FRCJ2
#             "fiber_length": {
#                "physical_port0": 10,
#               "physical_port1": 2,
#              "delta": 30,
#              },
#             "link_proto": "CI6",
#            "feg_without_mha": 30,
#           "chain": "1.2.1",
#          "qc": {"hw_config": "Single Radio"},
#     },
#         "6Q171716895": {
#            "pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 5},  # FRCJ3
#           "fiber_length": {
#              "physical_port0": 10,
#             "physical_port1": 2,
#            "delta": 30,
#              },
#             "link_proto": "CI6",
#            "feg_without_mha": 30,
#           "chain": "1.3.1",
#          "qc": {"hw_config": "Single Radio"},
#     },
#         "TC09DF1558": {
#            "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 7},  # URCC1
#           "fiber_length": {
#              "physical_port0": 10,
#             "physical_port1": 2,
#            "delta": 30,
#       },
#              "link_proto": "CI6",
#             "feg_without_mha": 30,
#            "chain": "1.1.1.1",
#           "qc": {"hw_config": "Single Radio"},
#      },
#     "TC09AS0322": {
#              "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 6},  # URCB2
#             "fiber_length": {
#                "physical_port0": 10,
#               "physical_port1": 2,
#              "delta": 30,
#             },
#            "link_proto": "CI6",
#           "feg_without_mha": 30,
#          "chain": "1.1.2.1",
#         "qc": {"hw_config": "Single Radio"},
#    },
#'TC09FH0003': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.238', 'port': 1},  # URCC3
#              'fiber_length': {'physical_port0': 10, 'physical_port1': 2, 'delta': 30},
#              'link_proto': 'CI6',
#              'feg_without_mha': 30,
#              'chain': '1.1.4.1',
#              'qc': {'hw_config': 'Single Radio'}},
#           "6Q173115185": {
#              "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 7},  # FHPC1
#             "fiber_length": {
#                "physical_port0": 10,
#               "physical_port1": 2,
#              "delta": 30,
#         },
#              "link_proto": "CI6",
#             "feg_without_mha": 30,
#            "chain": "1.1.1",
#           "qc": {"hw_config": "Single Radio"},
#      },
#          "6Q173210101": {
#             "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 5},  # FHPC2
#            "fiber_length": {
#               "physical_port0": 10,
#                   "physical_port1": 2,
#                  "delta": 30,
#             },
#            "link_proto": "CI6",
#           "feg_without_mha": 30,
#          "chain": "1.2.1",
#         "qc": {"hw_config": "Single Radio"},
#          },
#           "6Q173210110": {
#              "pdu": {"type": "FACOM", "ip_addr": "10.56.7.232", "port": 6},  # FHPC3
#             "fiber_length": {
#                "physical_port0": 10,
#               "physical_port1": 2,
#              "delta": 30,
#         },
#                "link_proto": "CI6",
#               "feg_without_mha": 30,
#              "chain": "1.3.1",
#             "qc": {"hw_config": "Single Radio"},
#        },
#         "TC09CM1200": {
#            "pdu": {"type": "FACOM", "ip_addr": "10.56.7.238", "port": 2},  # URGA1
#           "fiber_length": {
#              "physical_port0": 10,
#             "physical_port1": 2,
#            "delta": 30,
#       },
#      "link_proto": "CI6",
#     "feg_without_mha": 30,
#    "chain": "1.1.1.1",
#   "qc": {"hw_config": "Single Radio"},
#         },
#'TC09CM1206': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.238', 'port': 3},  # URGA2
#             'fiber_length': {'physical_port0': 10, 'physical_port1': 2, 'delta': 30},
#            'link_proto': 'CI6',
#            'feg_without_mha': 30,
#            'chain': '1.1.2.1',
#            'qc': {'hw_config': 'Single Radio'}},
#'TC09CN0273': {'pdu': {'type': 'FACOM', 'ip_addr': '10.56.7.238', 'port': 4},  # URGA3
#          'fiber_length': {'physical_port0': 10, 'physical_port1': 2, 'delta': 30},
#          'link_proto': 'CI6',
#         'feg_without_mha': 30,
#         'chain': '1.1.4.1',
#         'qc': {'hw_config': 'Single Radio'}},
#      },
#     "EC": {
#        "EA170728548": {
#           "pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 1}
#      },
#     "AS172533302": {
#        "pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 1}
#   },
#   },
#  "FSM": {
#     "EA171661188": {
#        "pdu": {"type": "FACOM", "ip_addr": "10.56.7.234", "port": 1}
#   }
#      },
#   },
# }

# TL1 = {
# 'FR': {'SH1347G00KZ': {'pdu': {'type': 'ATEN', 'ip_addr': '10.42.168.119', 'port': 1},#UHED[35]
# 'fiber_length': {'physical_port0': 18, 'physical_port1': 2, 'delta': 30},
# 'link_proto': 'C4',
# 'feg_without_mha': 30,
# 'chain': '1.1.1.1',
# 'qc': {'hw_config': '#3107_2b'}},
# 'LBALLUANZ154200121': {'pdu': {'type': 'ATEN', 'ip_addr': '10.42.168.119', 'port': 2},#UHMB[42]
# 'fiber_length': {'physical_port0': 17, 'physical_port1': 2, 'delta': 30},
# 'link_proto': 'C4',
# 'feg_without_mha': 30,
# 'chain': '1.1.2.1',
# 'qc': {'hw_config': '#3107_2b'}},
# '12W332Z10065': {'pdu': {'type': 'ATEN', 'ip_addr': '10.42.168.119', 'port': 3},#UHLA[36]
# 'fiber_length': {'physical_port0': 12, 'physical_port1': 2, 'delta': 30},
# 'link_proto': 'O3',
# 'feg_without_mha': 30,
# 'chain': '1.1.3.1',
# 'qc': {'hw_config': '#3107_2b'}},
# 'LBALLU-U3155124837': {'pdu': {'type': 'ATEN', 'ip_addr': '10.42.168.119', 'port': 4},#UHIC[41]
# 'fiber_length': {'physical_port0': 17, 'physical_port1': 2, 'delta': 30},
# 'link_proto': 'O3',
# 'feg_without_mha': 30,
# 'chain': '1.1.4.1',
# 'qc': {'hw_config': '#3107_2b'}},
# '16W323D90385': {'pdu': {'type': 'ATEN', 'ip_addr': '10.42.168.119', 'port': 5},#UHFD[33]
# 'fiber_length': {'physical_port0': 7, 'physical_port1': 2, 'delta': 30},
# 'link_proto': 'O3',
# 'feg_without_mha': 30,
# 'chain': '1.1.5.1',
# 'qc': {'hw_config': '#3107_2b'}},
# '14W325D70127': {'pdu': {'type': 'ATEN', 'ip_addr': '10.42.168.119', 'port': 6},#UHFF[45]
# 'fiber_length': {'physical_port0': 25, 'physical_port1': 2, 'delta': 30},
# 'link_proto': 'O3',
# 'feg_without_mha': 30,
# 'chain': '1.1.6.1',
# 'qc': {'hw_config': '#3107_2b'}},
# 'LBALLU-U3151000419': {'pdu': {'type': 'ATEN','ip_addr': '10.42.168.119', 'port': 7},#UHCA[51]
# 'fiber_length': {'physical_port0': 15, 'physical_port1': 2, 'delta': 30},
# 'link_proto': 'O3',
# 'feg_without_mha': 30,
# 'chain': '1.2.1.1',
# 'qc': {'hw_config': '#3107_1a1'}},
# },
# #'BBMOD': {'L9160700469': {'pdu': {'type': None, 'ip_addr': None, 'port': None}},
# #          }
# 'FSM':  {'L1162409634': {'pdu': {'type': 'ATEN', 'ip_addr': '10.42.168.120', 'port': 1},'hw_version': 'A101', 'hw_type': 'FSIP', 'fbip1': True, 'fbip2': True, 'fbip3': False}}  #hw_version: X21, X31, A101; hw_type: FSME, FSMF, FSIP, FSIH
# }

# tl = GVeAdapter(host_ip='10.42.184.8', fsm=TL1['FSM'], rf=None, los=None, bbmod=None)
# tl = ConfigComposer(tl1)

# SiSo additional variables

# SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT1/Airscale_RB_ALU/SCFC_1.xml"
# SCFC_REFERENCE_FILE_PATH = (
#   "/home/ute/robotlte/config/Hangzhou/1_5_CLOUD006/node1/FL00/CONF_1_5_2021_1a1.xml"
# )
# SCFC_REFERENCE_FILE_PATH= "/home/ute/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT1/R4P12_CRT1_02/SCFC_CIT.xml"

# SW_BUILDS_DIR_PATH= "/home/ute/SW/FL17SP"
# SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

# REQUIRE_PACKAGES = "Active"

# ALLOWED_ALARMS = [
#   "Vendor BTS certificate",
#  "Synchronization lost",
# "Diagnostic Files collected",
# "BTS booted at .*? due to trs management reset",
#   ".*? ToP master service .*? unusable",
#  "NTP Server .*? unavailable",
#    "SSH enabled",
#   "R&D Service Port enabled",
#  "LMP access via port 12000",
#    "FR not critical functionality not supported",
#   "LMP access via port .*?",
#  "BTS Reset Cause",
# "Validation of signed file failed",
# "Service account root access is enabled",
#    "Failure in optical interface",
#   "Receiving failure in Optical Interface",
#  "Unsigned software release has been successfully downloaded",
# "Ethernet port security is disabled",
#  "Sanity Check Error",
# ]

# tl = sys.modules[__name__]

# __all__ = ["tl"]
