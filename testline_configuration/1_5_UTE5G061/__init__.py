__maintainer__ = "Huang, Lei 10."
__email__ = "lei.10.huang@nokia-sbell.com"

import os
import yaml
import re
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
from taf.config.testline.pdu import FPFH
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = FACOM(addr="10.69.67.117", port_numbers=[1])
_pdu_2 = FACOM(addr="10.56.7.190", port_numbers=[1, 3])
_pdu_3 = FACOM(addr="10.69.66.101", port_numbers=[1])
_pdu_4 = FACOM(addr="10.56.7.221", port_numbers=[2, 4])
_pdu_5 = FPFH(addr="10.56.7.171", port_numbers=[2])

_rmod_1 = RU(
    ru_hw_group="FRIJ:FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA170184675",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRIJ:FRMr4.3b_4T4R_Halo",
    radio_type="FRIJ",
    serial_number="EA170184670",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRGT:FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="L6142706683",
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRGT:FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="1M171027556",
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="FRHF:FRMr3.1_6T6R",
    radio_type="FRHF",
    serial_number="F7162842213",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRHF:FRMr3.1_6T6R",
    radio_type="FRHF",
    serial_number="F7164603342",
    pdu_port=_pdu_5.pdu_ports[2],
)


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ASOE",
    hardware_version="475587A.X21",
    serial_number="EA210150249",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)


_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_fct_1 = CommonUnit(
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOE",
    hardware_version="475587A.X21",
    serial_number="EA210150249",
    lmp_connection=_lmp_connection,
)

_smod_1 = Airscale([_fct_1])



_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    f1_m_ip_addr="10.56.7.31",
)

_cu = CU(
    backhaul_site_oam_ip="10.56.7.31",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.7.31", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(cu=_cu, dus=[_du_1])


_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "askey_ue_data.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.209", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOE_CRT_CB006876_CB008798",
)

__all__ = ["tl"]
