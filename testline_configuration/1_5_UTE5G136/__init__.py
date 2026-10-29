__maintainer__ = "Lin Weicheng"
__email__ = "weicheng.lin@nokia-sbell.com"

import os
import re
import yaml
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import FACOM, HBTE, TopYoung
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit

from taf.config.testline.ue import Android
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = FACOM(
    addr="10.106.208.152", 
    port_numbers=[5], 
#    model="facom"
    )  # PB of AirScale
_pdu_2 = HBTE(
    addr="10.106.208.210", 
    port_numbers=[1, 2, 3, 4, 5, 6], 
#    model="hbte"
    )  # PB of 3AKQJ+3AEQP

#_pdu_3 = TopYoung(
#    addr="10.68.160.68", port_numbers=[1, 2], model="TopYoung"
#)  # PB of 2*AQNA

_ru_1 = RU(
    ru_hw_group="AEQP:RRH6.1",
    radio_type="AEQP", 
    serial_number="1M211008281", 
    pdu_port=_pdu_2.pdu_ports[4]
)  # cMAAr6.1_64T64R
_ru_2 = RU(
    ru_hw_group="AEQP:RRH6.1",
    radio_type="AEQP", 
    serial_number="1M211008172", 
    pdu_port=_pdu_2.pdu_ports[6]
)
_ru_3 = RU(
    ru_hw_group="AEQP:RRH6.1",
    radio_type="AEQP", 
    serial_number="1M211008286", 
    pdu_port=_pdu_2.pdu_ports[3]
)
# _ru_4 = RU(
#     ru_hw_group="AQNA:RRH6.2", serial_number="L1223802530", pdu_port=_pdu_3.pdu_ports[1]
# )
# _ru_5 = RU(
#     ru_hw_group="AQNA:RRH6.2", serial_number="L1223802531", pdu_port=_pdu_3.pdu_ports[2]
# )
_ru_4 = RU(
    ru_hw_group="AKQJ:RRH6.2",
    radio_type="AKQJ", 
    serial_number="1M222600184", 
    pdu_port=_pdu_2.pdu_ports[5]
)
_ru_5 = RU(
    ru_hw_group="AKQJ:RRH6.2",
    radio_type="AKQJ", 
    serial_number="1M223829898", 
    pdu_port=_pdu_2.pdu_ports[1]
)
_ru_6 = RU(
    ru_hw_group="AKQJ:RRH6.2",
    radio_type="AKQJ", 
    serial_number="1M223829888", 
    pdu_port=_pdu_2.pdu_ports[2]
)

# 1*ABIO
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="DH224348839",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)

# ASIL
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
        ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1220604292",
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.106.211.131",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.211.131", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.211.131", 
        username="Nemuadmin", 
        password="nemuuser"
    ),
)

###20230313################################
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
    addr="10.68.160.74", 
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
    serial_number="7TD0221409004072",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM31",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)
#########################################################

_du = DU(
    airscale=_airscale,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
    f1_m_ip_addr="10.106.211.131",
)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du])

#_cfg_dir = os.path.dirname(os.path.abspath(__file__))
#_ue_config_path = os.path.join(_cfg_dir, "askey_ue_data.yaml")
#if os.path.isfile(_ue_config_path):
#    with open(_ue_config_path) as f:
#        _ue_askey = f.read()
#        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
#        for item in qci_port:
#            _ue_askey = _ue_askey.replace(item, str(eval(item)))
#        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
#else:
#    _ue_config = ""

#def config():
#    import env

#    print(__name__)
#    m = env
#    test_line_config = {}
#    for att in dir(m):
#        value = getattr(m, att)
#        print(type(value))
#        if att.startswith("_") or type(value) == "function":
#            continue
#        else:
#            test_line_config[att] = getattr(m, att)
#            print(att, getattr(m, att))
#            print(test_line_config)
#    return test_line_config

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.211.223", 
        username="ute", 
        password="ute"
    ),
    connections=[_fct_1,],
)  # Control VM

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIL_ABIO_3AEQP_3AKQJ",
)

__all__ = ["tl"]
