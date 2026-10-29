__maintainer__ = "Sheng Haoyun"
__email__ = "haoyun-lyle.sheng@nokia-sbell.com"

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


_pdu_1 = HBTE(addr="10.68.252.194", port_numbers=[1, 2, 3, 4, 5, 6])

_pdu_2 = HBTE(addr="10.68.252.196", port_numbers=[1, 2, 3, 4, 5, 6])

_pdu_3 = FPFH(addr="10.68.252.217", port_numbers=[1, 2])

_rmod_1 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AREA",
    serial_number="EA210451535",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AREA",
    serial_number="K9220604298",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AREA",
    serial_number="K9220611845",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AREA",
    serial_number="K9220611844",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852853",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="CPRI_RRH_6T6R",
    radio_type="AREA",
    serial_number="EA210451467",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852838",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852855",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    radio_type="AHHB",
    serial_number="L1180315546",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_10 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    radio_type="AHHB",
    serial_number="L1180315547",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_11 = RU(
    ru_hw_group="OBSAI_RRH_6T6R",
    radio_type="FRPA",
    serial_number="L6153706653",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_12 = RU(
    ru_hw_group="OBSAI_RRH_6T6R",
    radio_type="FRPA",
    serial_number="EA171010775",
    pdu_port=_pdu_3.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231505887",
    pdu_port=_pdu_2.pdu_ports[2],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.101",
    serial_number="L1224401604",
)

_smod_1 = Airscale(common_units=[_fct_1])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10],
    f1_m_ip_addr="10.68.252.197",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.252.197",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.197", username="toor4nsn", password="oZPS0POrRieRtu"
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
    SshServiceDetails(addr="10.68.252.132", username="ute", password="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_classical_bts_1.dus[0].airscale.common_units[0], interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIML_ABIPB1_4xAREA_3xAHEGC",
)

__all__ = ["tl"]
