__owner__ = "Ding Lisa"
__maintainer__ = "Ding Lisa"
__email__ = "lisa.ding@nokia-sbell.com"


import os
import yaml
import re

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FACOM, FPFH,HBTE
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = FACOM(
    addr="10.108.190.71", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], 
)

_pdu_2 = FACOM(
    addr="10.108.190.72", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], 
)

_pdu_3 = FACOM(
    addr="10.108.190.66", 
    port_numbers=[3], 
)

_pdu_4 = HBTE(
    addr="10.108.190.67",
    port_numbers=[4, 5, 6],
)

# 6RRUs of NR37676
_rmod_1 = RU(
    ru_hw_group="RF.MRM6",
    radio_type="AWHHF",
    serial_number="EB2105R9448",
    pdu_port=_pdu_2.pdu_ports[7],
)  # AWHHF_1
_rmod_2 = RU(
    ru_hw_group="RF.SRM6",
    radio_type="AWHHF",
    serial_number="AH232601259",
    pdu_port=_pdu_4.pdu_ports[5],
)  # AWHHF_2
_rmod_3 = RU(
    ru_hw_group="RF.SRM6",
    radio_type="AWHHF",
    serial_number="AH232601258",
    pdu_port=_pdu_2.pdu_ports[8],
)  # AWHHF_3
_rmod_4 = RU(
    ru_hw_group="RF.FRU6",
    radio_type="AWHHF",
    serial_number="AH232601252",
    pdu_port=_pdu_2.pdu_ports[3],
)  # AWHHF_4
_rmod_5 = RU(
    ru_hw_group="RF.FRU6",
    radio_type="AWHHF",
    serial_number="AH232601260",
    pdu_port=_pdu_4.pdu_ports[4],
)  # AWHHF_5
_rmod_6 = RU(
    ru_hw_group="RF.FRU6",
    radio_type="AWHHF",
    serial_number="AH232601262",
    pdu_port=_pdu_2.pdu_ports[5],
)  # AWHHF_6

# 12 RRUs of BTS37677
_rmod_7 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHIB",
    serial_number="EA174610828",
    pdu_port=_pdu_2.pdu_ports[2],
)  # AHIB_1
_rmod_8 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHFB",
    serial_number="EA182711167",
    pdu_port=_pdu_2.pdu_ports[6],
)  # AHFB_1

_rmod_9 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHIB",
    serial_number="AH193900766",
    pdu_port=_pdu_1.pdu_ports[8],
)  # AHIB_2

_rmod_10 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHFB",
    serial_number="EA174113443",
    pdu_port=_pdu_1.pdu_ports[7],
)  # AHFB_2

_rmod_11 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHIB",
    serial_number="EA174712204",
    pdu_port=_pdu_1.pdu_ports[6],
)  # AHIB_3

_rmod_12 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHFB",
    serial_number="AH220101105",
    pdu_port=_pdu_2.pdu_ports[1],
)  # AHFB_3
_rmod_13 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHIB",
    serial_number="EA174610795",
    pdu_port=_pdu_1.pdu_ports[5],
)  # AHIB_4

_rmod_14 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHFB",
    serial_number="EA184413453",
    pdu_port=_pdu_1.pdu_ports[4],
)  # AHFB_4

_rmod_15 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHIB",
    serial_number="EA174810843",
    pdu_port=_pdu_1.pdu_ports[3],
)  # AHIB_5
_rmod_16 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHFB",
    serial_number="EA175112698",
    pdu_port=_pdu_1.pdu_ports[2],
)  # AHFB_5

_rmod_17 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHIB",
    serial_number="EA175112759",
    pdu_port=_pdu_1.pdu_ports[1],
)  # AHIB_6
_rmod_18 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHFB",
    serial_number="EA175112747",
    pdu_port=_pdu_2.pdu_ports[4],
)  # AHFB_6

# ABIO of NR37676
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211506357",
    pdu_port=_pdu_3.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213905495",
    pdu_port=_pdu_3.pdu_ports[3],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

# ABIO of BTS2235
_fsp_3 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220503976",
    pdu_port=_pdu_4.pdu_ports[6],
    rus=[_rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211506356",
    pdu_port=_pdu_4.pdu_ports[6],
    rus=[_rmod_13, _rmod_14, _rmod_15, _rmod_16, _rmod_17, _rmod_18],
)

# ASIL
# NR37676
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_3.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1213507412",
#    rus=[_rmod_1, _rmod_2, _rmod_3,_rmod_4, _rmod_5, _rmod_6, 
#    _rmod_7, _rmod_8, _rmod_9,_rmod_10, _rmod_11, _rmod_12],
)


# BTS37677
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_4.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1213507412",
#    rus=[_rmod_7, _rmod_8, _rmod_9,_rmod_10, _rmod_11, _rmod_12,_rmod_13],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.96", 
        username="ute",
        password="ute"
        ),
#    connections=[NetworkAddress(v4="192.168.255.126")],
#    connections=[
#        NetworkAddress(v4="192.168.255.126"),
#        Connection(interface="eth1", device=_fct_1, interface_type="lmp"),
#    ],
    connections=[_fct_1,],
)  # Control VM - NR37676

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.103", 
        username="ute", 
        password="ute"
        ),
#    connections=[NetworkAddress(v4="192.168.255.126")],
#    connections=[
#        NetworkAddress(v4="192.168.255.126"),
#        Connection(interface="eth1", device=_fct_2, interface_type="lmp"),
#    ],
    connections=[_fct_2,],
)  # Control VM - BTS37677


_smod_1 = Airscale([_fct_1])  # NR37676
_smod_2 = Flexi([_fct_2])  # BTS37676

_du_1= DU(
    _smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3,_rmod_4, _rmod_5, _rmod_6],

) # NR37677

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.68.181.67"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12, 
    _rmod_13, _rmod_14, _rmod_15, _rmod_16, _rmod_17, _rmod_18],
)  # BTS37677

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=37676)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12, 
    _rmod_13, _rmod_14, _rmod_15, _rmod_16, _rmod_17, _rmod_18],
)  # BTS37677



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
    addr="10.68.180.80", 
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
    capabilities=["samsungS24", "REAL_UE"],
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
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_2],
    ues=[_android_ue,_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_NSA_ASIL_ABIO_6AWHHF_6AHFB_6AHIB",
)

__all__ = ["tl"]
