__maintainer__ = "Lisa Ding"
__email__ = "lisa.ding@nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, HBTE, FPFH, TopYoung
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = FPFH(addr="10.108.190.26", port_numbers=[2, 5],)

# PB of AHFB,model="hbte"

_ru_1 = RU(
    ru_hw_group="AHFB:RRH4.0", 
	radio_type="AHFB",
	serial_number="AH222602355", 
	pdu_port=_pdu_1.pdu_ports[2]
)  # cMAA_Gen4.0_32T32R


#1*ABIO
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220705753",
    pdu_port=_pdu_1.pdu_ports[5],
	rus=[_ru_1],
)

# ASIL
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="DH232141867",
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.106.215.41",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.10", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.181.10", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(
    airscale=_airscale,
    rus=[_ru_1],
    f1_m_ip_addr="10.68.181.10",
)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du])


_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "askey_ue_data.yaml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""


def config():
    import env

    print(__name__)
    m = env
    test_line_config = {}
    for att in dir(m):
        value = getattr(m, att)
        print(type(value))
        if att.startswith("_") or type(value) == "function":
            continue
        else:
            test_line_config[att] = getattr(m, att)
            print(att, getattr(m, att))
            print(test_line_config)
    return test_line_config

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.35", username="ute", password="ute"
    ),
    connections=[_fct_1,],
)  # Control VM

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_ue_config],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_NSA_ASIL_ABIO_AHFB",
)

__all__ = ["tl"]
