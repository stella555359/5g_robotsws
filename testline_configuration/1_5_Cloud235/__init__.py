__owner__ = "linlen"
__maintainer__ = "linlen"
__email__ = "len.lin@nokia-sbell.com"

import os
import re
import yaml

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
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails


# pdu
_pdu_1 = FACOM(addr="10.108.190.16", port_numbers=[1, 8])
_pdu_2 = HBTE(addr="10.108.190.10", port_numbers=[1, 2, 3, 4, 5])
_pdu_3 = TopYoung(addr="10.108.190.14", port_numbers=[1, 2])

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174908137",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1212901641",
    pdu_port=_pdu_1.pdu_ports[1],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212971853",
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.68.94.92",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.94.92", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.94.92", username="Nemuadmin", password="nemuuser"
    ),
)

# RU_info
_ru_1 = RU(
    ru_hw_group="AHEGB:RRH5.1",
    serial_number="EA204150818",
    pdu_port=_pdu_2.pdu_ports[4],
    radio_type="AHEGB",
)
_ru_2 = RU(
    ru_hw_group="AHEGB:RRH5.1",
    serial_number="K9195201520",
    pdu_port=_pdu_2.pdu_ports[5],
    radio_type="AHEGB",
)
_ru_3 = RU(
    ru_hw_group="AHEGB:RRH5.1",
    serial_number="K9192728082",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="AHEGB",
)
_ru_4 = RU(
    ru_hw_group="AKQJ:5GRU6.2",
    serial_number="1M223829878",
    pdu_port=_pdu_2.pdu_ports[3],
    radio_type="AKQJ",
)
_ru_5 = RU(
    ru_hw_group="AKQJ:5GRU6.2",
    serial_number="1M222600180",
    pdu_port=_pdu_3.pdu_ports[1],
    radio_type="AKQJ",
)
_ru_6 = RU(
    ru_hw_group="AKQJ:5GRU6.2",
    serial_number="1M222600175",
    pdu_port=_pdu_3.pdu_ports[2],
    radio_type="AKQJ",
)


_du = DU(
    airscale=_airscale,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
    f1_m_ip_addr="10.68.181.4",
)
_classical_bts = ClassicalBts(cu=_cu, dus=[_du])


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
    addr="10.68.180.81", username="T05-tester", password="Nokia123!"
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
    serial_number="R5CRA1Y260D",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM10",
    iperf_details=_android_iperf,
    capabilities=["samsungS21", "REAL_UE"],
)

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


def config():
    import env

    print(__name__)
    m = env
    test_line_config = {}
    for att in dir(m):
        value = getattr(m, att)
        print(type(value))
        if att.startswith("_") or type(value) == "function":
            continue
        else:
            test_line_config[att] = getattr(m, att)
            print(att, getattr(m, att))
    print(test_line_config)
    return test_line_config

# test pc
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.43", username="ute", password="ute"
    ),
    connections=[
        _classical_bts.dus[0].airscale.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts],
    ues=[_android_ue, _ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_NSA_ASIB_CA",
)
__all__ = ["tl"]
