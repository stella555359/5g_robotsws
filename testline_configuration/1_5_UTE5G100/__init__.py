__maintainer__ = "lenlin"
__email__ = "len.lin@nokia-sbell.com"

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


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.236", username="ute", password="ute"
    )
)

_pdu_1 = FACOM(addr="10.56.7.241", port_numbers=[8], model="facom")
_pdu_2 = HBTE(addr="10.106.211.106", port_numbers=[1, 2], model="hbte")
_pdu_3 = HBTE(addr="10.56.7.153", port_numbers=[1, 2, 4], model="hbte")


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213153906",
    pdu_port=_pdu_1.pdu_ports[8],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213153906",
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.56.7.44",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.7.44", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.7.44", username="Nemuadmin", password="nemuuser"
    ),
)

_ru_1 = RU(
    ru_hw_group="AHFIG:RRH5.1",
    serial_number="BL2112W240B",
    pdu_port=_pdu_2.pdu_ports[1],
)
_ru_2 = RU(
    ru_hw_group="AHFIG:RRH5.1",
    serial_number="BL2112W240A",
    pdu_port=_pdu_3.pdu_ports[4],
)
_ru_3 = RU(
    ru_hw_group="AHPF:RRH5.1",
    serial_number="EA214254811",
    pdu_port=_pdu_3.pdu_ports[1],
)
_ru_4 = RU(
    ru_hw_group="AHPF:RRH5.1",
    serial_number="EA214254803",
    pdu_port=_pdu_3.pdu_ports[2],
)


_du = DU(
    airscale=_airscale,
    rus=[
        _ru_1,
        _ru_2,
        _ru_3,
        _ru_4,
    ],
    f1_m_ip_addr="10.56.7.44",
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


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_ue_config],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOE_2xAHFIG_2xAHPF",
)

__all__ = ["tl"]
