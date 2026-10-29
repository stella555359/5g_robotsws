__maintainer__ = "He Qing"
__email__ = "qing.2.he@nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, HBTE, FPFH
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import Connection, TestPc


_pdu_1 = FPFH(addr="10.68.252.217", port_numbers=[3, 6])
_pdu_2 = FPFH(addr="10.71.182.194", port_numbers=[1,2,3])
_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKNB",
    serial_number="1M222812804",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKNB",
    serial_number="1M242200241",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKNB",
    serial_number="K9170508833",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKNB",
    serial_number="1M174803368",
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    hardware_version="A.101",
    serial_number="L1231609495",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.101",
    serial_number="L1241210718",
)

_smod_1 = Airscale(common_units=[_fct_1])

_du = DU(
    airscale=_smod_1,
    rus=[_rmod_1,_rmod_2,_rmod_3,_rmod_4],
    f1_m_ip_addr="10.68.252.75",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.252.75",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.75", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)


_classical_bts = ClassicalBts(cu=_cu, dus=[_du])

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "nokia_cpe_data.yml")
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
        addr="10.68.252.136", username="uteUTE!", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIM_ABIP_AKNB",
)

__all__ = ["tl"]
