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

_pdu_1 = FPFH(
    addr="10.108.190.11", 
    port_numbers=[1, 2, 3, 4, 5,6], 
)

_pdu_2 = FPFH(
    addr="10.108.190.12", 
    port_numbers=[1, 2, 3, 4, 5, 6], 
)

_pdu_3 = HBTE(
    addr="10.108.190.13", 
    port_numbers=[1, 2, 3], 
)

# 6RRUs of BTS2284
_rmod_1 = RU(
    ru_hw_group="RF.SRM6",
    radio_type="AEQP",
    serial_number="1M211008172",
    pdu_port=_pdu_3.pdu_ports[1],
)  # AEQP_1
_rmod_2 = RU(
    ru_hw_group="RF.SRM6",
    radio_type="AEQP",
    serial_number="1M211008286",
    pdu_port=_pdu_3.pdu_ports[2],
)  # AEQP_2
_rmod_3 = RU(
    ru_hw_group="RF.SRM6",
    radio_type="AEQP",
    serial_number="1M211008281",
    pdu_port=_pdu_3.pdu_ports[3],
)  # AEQP_3
_rmod_4 = RU(
    ru_hw_group="RF.FRU6",
    radio_type="AKNB",
    serial_number="1M223512394",
    pdu_port=_pdu_2.pdu_ports[1],
)  # AKNB_1
_rmod_5 = RU(
    ru_hw_group="RF.FRU6",
    radio_type="AKNB",
    serial_number="1M223512405",
    pdu_port=_pdu_2.pdu_ports[2],
)  # AKNB_2
_rmod_6 = RU(
    ru_hw_group="RF.FRU6",
    radio_type="AKNB",
    serial_number="1M223512409",
    pdu_port=_pdu_2.pdu_ports[3],
)  # AKNB_3

# 3RRUs of BTS2288
_rmod_7 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHEGHA",
    serial_number="K9241900895",
    pdu_port=_pdu_2.pdu_ports[5],
)  # AHEGHA_1
_rmod_8 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHEGHA",
    serial_number="K9241900621",
    pdu_port=_pdu_2.pdu_ports[6],
)  # AHEGHA_2
_rmod_9 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHPDA",
    serial_number="EA215151119",
    pdu_port=_pdu_1.pdu_ports[1],
)  # AHPDA_1

_rmod_10 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHPDC",
    serial_number="DH241428117",
    pdu_port=_pdu_1.pdu_ports[2],
)  # AHPDC_1
_rmod_11 = RU(
    ru_hw_group="FRMTDr2.2_4TRF.FRM5",
    radio_type="AHPDC",
    serial_number="DH241428114",
    pdu_port=_pdu_1.pdu_ports[3],
)  # AHPDC_2

_rmod_12 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHEGG",
    serial_number="RW242601489",
    pdu_port=_pdu_2.pdu_ports[4],
)  # AHEGG_1
_rmod_13 = RU(
    ru_hw_group="RF.FRM6",
    radio_type="AHEGHA",
    serial_number="K9242206134",
    pdu_port=_pdu_1.pdu_ports[6],
)  # AHEGHA_3

# ABIO of BTS10380
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="DH224348839",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204703420",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

# ABIO of BTS2235
_fsp_3 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206711",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_9],
)

# ASIL
# BTS10380
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1220604292",
#    rus=[_rmod_1, _rmod_2, _rmod_3,_rmod_4, _rmod_5, _rmod_6, 
#    _rmod_7, _rmod_8, _rmod_9,_rmod_10, _rmod_11, _rmod_12],
)


# BTS2235
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1203700866",
    rus=[_rmod_7, _rmod_8, _rmod_9,_rmod_10, _rmod_11, _rmod_12,_rmod_13],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.41", 
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
        addr="10.68.181.42", 
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


_smod_1 = Airscale([_fct_1])  # BTS10380
_smod_2 = Flexi([_fct_2])  # BTS2235

_du_1= DU(
    _smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3,_rmod_4, _rmod_5, _rmod_6, 
    _rmod_7, _rmod_8, _rmod_9,_rmod_10, _rmod_11, _rmod_12],

)

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.68.181.6"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, 
    _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)  # BTS10380

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=10380)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12,  _rmod_13],
    global_bts_id=2235,
)  # BTS2288



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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIL_ABIO_3AEQP_3AKQJ",
)

__all__ = ["tl"]
