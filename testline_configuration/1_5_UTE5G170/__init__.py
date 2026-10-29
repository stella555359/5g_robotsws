__maintainer__ = "He Qing"
__email__ = "qing.2.he@nokia-sbell.com"

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
from taf.config.testline.pdu import EPC, FPFH
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = FACOM(
    addr="10.68.252.5", port_numbers=[1,3, 5]
)

_pdu_2 = HBTE(
    addr="10.68.252.4", port_numbers=[4]
)

_pdu_3 = FPFH(addr="10.68.252.32", port_numbers=[1,2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="EA204457590",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="EA204457636",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R_eCPRI",
    radio_type="AQQJ",
    serial_number="NQ232691556",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_32T32R_eCPRI",
    radio_type="AQQJ",
    serial_number="NQ232691549",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type="AQQJ",
    serial_number="NQ232691557",
    pdu_port=_pdu_3.pdu_ports[2],
)

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA214652547",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5]
)

_du_1 = DU(
    Airscale(common_units=[_fct_1]),
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    f1_m_ip_addr="10.68.252.66",
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=11227, global_bts_id=11227
)

_smod_1 = Flexi([_fct_1])
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.68.252.66"),
    instance_id=11227,
)


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


_ue_pc_ssh = SshServiceDetails(
    addr="10.68.252.6", username="siso1-tester", password="Nokia123!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.197",
    username="tdlte-tester",
    password="btstest",
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="RFCR9255A2H",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM5",
    iperf_details=_android_iperf,
    capabilities=["samsungS21", "REAL_UE"],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.114", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    enbs=[_enb_sbts_1],
    ues=[_android_ue, _ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOE_2xAHPB_3AQQJ",
)

__all__ = ["tl"]
