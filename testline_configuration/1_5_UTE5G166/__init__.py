__maintainer__ = "Chen Shaocheng"
__email__ = "shaocheng.chen@nokia-sbell.com"

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
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.198.194", username="ute", password="ute"
    )
)

_pdu_1 = FACOM(addr="10.106.198.36", port_numbers=[1], model="facom")
_pdu_2 = HBTE(addr="10.106.198.48", port_numbers=[6], model="hbte")
_pdu_3 = HBTE(addr="10.106.198.35", port_numbers=[1, 2], model="hbte")


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101568",
    pdu_port=_pdu_1.pdu_ports[1],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212076847",
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.106.208.38",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.208.38", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.208.38", username="Nemuadmin", password="nemuuser"
    ),
)

_ru_1 = RU(
    ru_hw_group="AENB:eCPRI_RRH_32T32R",
    serial_number="1M212306542",
    pdu_port=_pdu_2.pdu_ports[6],
)
_ru_2 = RU(
    ru_hw_group="AENB:eCPRI_RRH_32T32R",
    serial_number="1M212300161",
    pdu_port=_pdu_3.pdu_ports[1],
)
_ru_3 = RU(
    ru_hw_group="AENB:eCPRI_RRH_32T32R",
    serial_number="1M212300074",
    pdu_port=_pdu_3.pdu_ports[2],
)

_du = DU(
    airscale=_airscale,
    rus=[
        _ru_1,
        _ru_2,
        _ru_3,
    ],
    f1_m_ip_addr="10.106.198.134",
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


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_3xAENB",
)

__all__ = ["tl"]
