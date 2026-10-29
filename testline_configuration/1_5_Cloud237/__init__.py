__owner__ = "Lisa Ding"
__maintainer__ = "Lisa Ding"
__email__ = "lisa.ding@nokia-sbell.com"


import os
import yaml
import re

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.ue import Android
from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FACOM, FPFH,HBTE
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = FPFH(
    addr="10.108.190.24", 
    port_numbers=[1, 2, 3, 4, 5,6], 
)

_pdu_2 = HBTE(
    addr="10.108.190.7", 
    port_numbers=[1, 2, 3], 
)

_pdu_3 = FPFH(
    addr="10.108.190.8", 
    port_numbers=[1, 2, 3, 4, 5, 6], 
)

_pdu_4 = FPFH(
    addr="10.108.190.9", 
    port_numbers=[1, 2, 3], 
)

# _pdu_1 = FACOM(
    # addr="10.106.208.211", 
    # port_numbers=[1, 2, 6, 7, 8], 
# #    model="facom",
# )

# 6RRUs of BTS2284
_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7172517648",
    pdu_port=_pdu_2.pdu_ports[1],
)  # FXED_1
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="1M173038158",
    pdu_port=_pdu_2.pdu_ports[3],
)  # FXED_2
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="1M184413199",
    pdu_port=_pdu_3.pdu_ports[4],
)  # FXED_3
_rmod_4 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRPA",
    serial_number="EA170910432",
    pdu_port=_pdu_1.pdu_ports[5],
)  # FRPA_1
_rmod_5 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRPA",
    serial_number="EA170910437",
    pdu_port=_pdu_1.pdu_ports[4],
)  # FRPA_2
_rmod_6 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRPA",
    serial_number="EA163011611",
    pdu_port=_pdu_2.pdu_ports[2],
)  # FRPA_3

# 3RRUs of BTS2288
_rmod_7 = RU(
    ru_hw_group="FRMTDr2.2_4T4R",
    radio_type="FZNI",
    serial_number="RY145010929",
    pdu_port=_pdu_1.pdu_ports[6],
)  # FZNI_1
_rmod_8 = RU(
    ru_hw_group="FRMTDr2.2_4T4R",
    radio_type="FZNI",
    serial_number="RY130308619",
    pdu_port=_pdu_3.pdu_ports[1],
)  # FZNI_2
_rmod_9 = RU(
    ru_hw_group="FRMTDr2.2_4T4R",
    radio_type="FZNI",
    serial_number="RY125208952",
    pdu_port=_pdu_3.pdu_ports[2],
)  # FZNI_3

# 6RRUs of BTS2316
_rmod_10 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="L6142703168",
    pdu_port=_pdu_4.pdu_ports[1],
)  # FRGT_1
_rmod_11 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="L6135201902",
    pdu_port=_pdu_4.pdu_ports[3],
)  # FRGT_2
_rmod_12 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHF",
    serial_number="F7171645130",
    pdu_port=_pdu_3.pdu_ports[6],
)  # FRHF_1
_rmod_13 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHF",
    serial_number="F7171919117",
    pdu_port=_pdu_3.pdu_ports[5],
)  # FRHF_2
_rmod_14 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHF",
    serial_number="L1142022648",
    pdu_port=_pdu_3.pdu_ports[3],
)  # FRHF_3
_rmod_15 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="L6143953012",
    pdu_port=_pdu_4.pdu_ports[2],
)  # FRGT_3

# FBBC of BTS2284
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172533085",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172533077",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

# FBBA of BTS2288
_fsp_3 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="EA173720165",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_9],
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="L9133200593",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_7],
)

# FBBC of BTS2316
_fsp_5 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA173520941",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_6 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA173521497",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_10, _rmod_11, _rmod_15],
)

# FSMF
# BTS2284
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="EA173760683",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

# BTS2288
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="EA174252078",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

# BTS2316
_fct_3 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="EA173463690",
    rus=[_rmod_12, _rmod_13, _rmod_14],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.45", 
        username="ute",
        password="ute"
        ),
#    connections=[NetworkAddress(v4="192.168.255.126")],
#    connections=[
#        NetworkAddress(v4="192.168.255.126"),
#        Connection(interface="eth1", device=_fct_1, interface_type="lmp"),
#    ],
    connections=[_fct_1,],
)  # Control VM - BTS2284

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.46", 
        username="ute", 
        password="ute"
        ),
#    connections=[NetworkAddress(v4="192.168.255.126")],
#    connections=[
#        NetworkAddress(v4="192.168.255.126"),
#        Connection(interface="eth1", device=_fct_2, interface_type="lmp"),
#    ],
    connections=[_fct_2,],
)  # Control VM - BTS2288

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.47", 
        username="ute", 
        password="ute"
        ),
#    connections=[NetworkAddress(v4="192.168.255.126")],
#    connections=[
#        NetworkAddress(v4="192.168.255.126"),
#        Connection(interface="eth1", device=_fct_3, interface_type="lmp"),
#    ],
    connections=[_fct_3,],
)  # Control VM - BTS2316

_smod_1 = Flexi([_fct_1])  # BTS2284
_smod_2 = Flexi([_fct_2])  # BTS2288
_smod_3 = Flexi([_fct_3])  # BTS2316

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)  # BTS2284
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
)  # BTS2288
_enb_sbts_3 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_10, _rmod_11, _rmod_12, _rmod_13, _rmod_14, _rmod_15],
)  # BTS2316


_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", 
    username="tdlte-tester", 
    password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
    port=22,
)
_appserver = AppServer(iperf_details=_iperf)

_ue_pc_ssh = SshServiceDetails(
    addr="10.68.183.55", 
    username="siso3-tester", 
    password="Nokia123!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.197",
    username="tdlte-tester",
    password="btstest",
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="ce0617161882d62301",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM5",
    iperf_details=_android_iperf,
    capabilities=["samsungS21", "REAL_UE"],
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "android_ue_config.yaml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_android = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_android)
        for item in qci_port:
            _ue_android = _ue_android.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_android, Loader=yaml.FullLoader)
else:
    _ue_config = ""

print(_ue_config)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_sbts_1, _enb_sbts_2, _enb_sbts_3],
    ues=[_android_ue,_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FCA_F_T_F_4G105",
)

__all__ = ["tl"]
