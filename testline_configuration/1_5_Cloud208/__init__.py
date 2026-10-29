__maintainer__ = "Huang Lei"
__email__ = "lei.10.huang@nokia-sbell.com"

import os
import yaml
import re
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.ue import Android
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
from taf.config.testline.testpc import TestPc

_pdu_1 = FPFH(addr="10.108.190.50", port_numbers=[3,4,6])
_pdu_2 = FPFH(addr="10.108.190.40", port_numbers=[1,2,3])

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2222N4072",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2217N401N",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2221N405S",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="1M173038101",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="1M171916698",
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231609449",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206710",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183241468",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fct_1 = CommonUnit(
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233402469",
    lmp_connection=_lmp_connection,
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1],
    f1_m_ip_addr="10.68.181.149",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.181.149",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.149", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=37612, global_bts_id=37612
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

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.232", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_5G_CLASSICAL_ASIM_ABIP_ABIO_ABIA_3xAHFII_2xFXED",
)

__all__ = ["tl"]
