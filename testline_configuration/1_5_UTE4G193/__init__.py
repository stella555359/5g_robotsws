__maintainer__ = "nicwu"
__email__ = "nick.1.wu@nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, HBTE, TopYoung
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


# ASOE, AHPD1, AHPG, AHPD2
_pdu_1 = TopYoung(addr="10.108.151.102", port_numbers=[1, 2, 4, 5])
# AEHB1 AEHB2
_pdu_2 = HBTE(addr="10.106.198.104", port_numbers=[1, 4])
# AEHB3
_pdu_3 = HBTE(addr="10.108.151.63", port_numbers=[2])

_ru_1 = RU(
    ru_hw_group="AEHB:mMIMO",
    radio_type="AEHB",
    serial_number="L1211113059",
    pdu_port=_pdu_2.pdu_ports[1],
)
_ru_2 = RU(
    ru_hw_group="AEHB:mMIMO",
    radio_type="AEHB",
    serial_number="L1213414030",
    pdu_port=_pdu_2.pdu_ports[4],
)
_ru_3 = RU(
    ru_hw_group="AEHB:mMIMO",
    radio_type="AEHB",
    serial_number="L1212814013",
    pdu_port=_pdu_3.pdu_ports[2],
)
_ru_4 = RU(
    ru_hw_group="AHPD1:FDD",
    radio_type="AHPD",
    serial_number="6Q184907618",
    pdu_port=_pdu_1.pdu_ports[2],
)
_ru_5 = RU(
    ru_hw_group="AHPD2:FDD",
    radio_type="AHPD",
    serial_number="6Q184907620",
    pdu_port=_pdu_1.pdu_ports[5],
)
_ru_6 = RU(
    ru_hw_group="AHPG:FDD",
    radio_type="AHPG",
    serial_number="RW220900054",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA214652511",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_ru_1, _ru_2, _ru_3],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA214652511",
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.106.198.115",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.198.115", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.198.115", username="Nemuadmin", password="nemuuser"
    ),
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
    port=22,
)
_appserver = AppServer(iperf_details=_iperf)


_ue_pc_ssh = SshServiceDetails(
    addr="10.106.198.94", username="siso3-tester", password="Nokia123!"
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
    serial_number="RFCRB18FEZW",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM7",
    iperf_details=_android_iperf,
    capabilities=["samsungS21", "REAL_UE"],
)

_du = DU(
    airscale=_airscale,
    rus=[
        _ru_1,
        _ru_2,
        _ru_3,
        _ru_4,
        _ru_5,
        _ru_6,
    ],
    f1_m_ip_addr="10.106.198.115",
)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du])

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "android_ue_config.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_android = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_android)
        for item in qci_port:
            _ue_android = _ue_android.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_android, Loader=yaml.FullLoader)
else:
    _ue_config = ""

print(_ue_config)

# import os
# os.environ["UTE_UE_CONFIG"] = _ue_config_path

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.231", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], _ue_config],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_android_ue, _ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOE_3xAEHB",
)
# print(os.environ["UTE_UE_CONFIG"])
__all__ = ["tl"]
