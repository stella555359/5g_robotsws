__maintainer__ = "Nie Sue"
__email__ = "sue.nie@nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, HBTE, TopYoung
from taf.config.testline.pdu import FPFH
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = HBTE(addr="10.68.252.7", port_numbers=[4])
_pdu_2 = TopYoung(addr="10.68.252.12", port_numbers=[2])
_pdu_3 = TopYoung(addr="10.68.252.10", port_numbers=[4])

_rmod_1 = RU(
    ru_hw_group="FRMr4.3b_4T4R_Halo",
    radio_type="AHCI",
    serial_number="1M233707168",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="AHCI:FRMr4.3b_4T4R_Halo",
    radio_type="AHCI",
    serial_number="1M233707174",
    pdu_port=_pdu_3.pdu_ports[4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA214652492",
    rus=[_rmod_1, _rmod_2]
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2],
    f1_m_ip_addr="10.68.252.69",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.252.69",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.69", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=11620, global_bts_id=11620
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "ta_ue_config.yml")
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

_ue_pc_ssh = SshServiceDetails(
    addr="10.68.252.26", username="siso1-tester", password="Nokia123!"
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.116", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOE_AHCI",
)

__all__ = ["tl"]
