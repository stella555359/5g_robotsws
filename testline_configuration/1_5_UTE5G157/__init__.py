__maintainer__ = "Wu Amy"
__email__ = "amy.wu@nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc


_pdu_1 = FACOM(addr="10.106.208.42", port_numbers=[4])
_pdu_2 = FACOM(addr="10.106.208.42", port_numbers=[1, 6, 7, 8])
_pdu_3 = FACOM(addr="10.68.94.106", port_numbers=[4, 5])
_pdu_4 = HBTE(addr="10.106.173.25", port_numbers=[5])
_pdu_5 = FACOM(addr="10.106.208.41", port_numbers=[3, 7])

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHIE",    
    serial_number="LBALLU-YD17050G55M",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHIE",   
    serial_number="LBALLU-YD17450P3VD",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHIE", 
    serial_number="LBALLU-YD17460PDJH",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA", 
    serial_number="L1174407170",
    pdu_port=_pdu_4.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA", 
    serial_number="AS202709846",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA", 
    serial_number="AS203806253",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_7 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD16410BGLP",
    pdu_port=_pdu_5.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD17440NX1V",
    pdu_port=_pdu_5.pdu_ports[3],
)

_rmod_9 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHFA",
    serial_number="LBALLU-YD17070GTKW",
    pdu_port=_pdu_2.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101568",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.101",
    serial_number="L1224401605",
)

_smod = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.106.208.38",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.208.38", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.208.38", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(
    airscale=_smod,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    f1_m_ip_addr="10.106.208.38",
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
        addr="10.68.94.11", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_ue_config],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_3xUHIE_3xAHCA",
)

__all__ = ["tl"]
