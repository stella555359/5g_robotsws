__maintainer__ = "Wu Amy"
__email__ = "amy.wu@nokia-sbell.com"

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
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = HBTE(addr="10.106.198.45", port_numbers=[1, 2, 3, 4, 5, 6])

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHIE",
    serial_number="AS210918787",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHIE",
    serial_number="AS210918795",
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHIE",
    serial_number="AS210708403",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHB",
    serial_number="L1212814013",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231609493",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101448",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508227",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_lmp_connection_1 = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_lmp_connection_2 = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_fct_1 = CommonUnit(
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503559",
    lmp_connection=_lmp_connection_1,
)

_fct_2 = CommonUnit(
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1182811441",
    lmp_connection=_lmp_connection_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    f1_m_ip_addr="10.106.198.14",
)

_du_2 = DU(
    airscale=_smod_2, rus=[_rmod_1, _rmod_2, _rmod_3], f1_m_ip_addr="10.106.198.14"
)

_cu = CU(
    backhaul_site_oam_ip="10.106.198.14",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.198.14", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(cu=_cu, dus=[_du_1])
_classical_bts_2 = ClassicalBts(cu=_cu, dus=[_du_2])
_classical_bts_1.secondary = _classical_bts_2

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
        addr="10.106.198.187", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.83", username="ute", password="ute"
    ),
    connections=[_classical_bts_2.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIBLR_ABIOB1B4_AEHC_3xAHCA_FULLRACK",
)

__all__ = ["tl"]
