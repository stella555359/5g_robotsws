__maintainer__ = "Hu Shenghong"
__email__ = "shenghong.hu@nokia-sbell.com"

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


_pdu_1 = FACOM(addr="10.56.7.123", port_numbers=[7])

_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type="AZHL", 
    serial_number="AH222602968", 
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="rfsw", password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="rfsw", password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    hardware_version="A.101",
    serial_number="L1231505837",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214206739",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="475765A.101",
    serial_number="L1224401591",
)

_cu = CU(
    backhaul_site_oam_ip="10.106.208.173",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.208.173", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.208.173", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(
    Airscale(common_units=[_fct_1]),
    rus=[],
    f1_m_ip_addr="10.106.208.173",
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
        addr="10.106.233.246", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIM_ABIP_AZHL",
)

__all__ = ["tl"]
