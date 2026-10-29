__maintainer__ = "Bibo Lei"
__email__ = "bibo.lei@nokia-sbell.com"

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
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import Android


_pdu_1 = FPFH(addr="10.68.252.199", port_numbers=[1, 2, 3, 4, 5, 6])

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_rmod_1 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="EB2118R0523",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="AH232601217",
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type="AWHHF",
    serial_number="EB194060094",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASOF",
    hardware_version="476147A.101",
    serial_number="EA232850581",
    lmp_connection=_lmp_connection,
    rus=[_rmod_1, _rmod_2, _rmod_3]
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1,_rmod_2,_rmod_3],
    f1_m_ip_addr="10.68.252.214",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.252.214",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.214", username="toor4nsn", password="oZPS0POrRieRtu"
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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.134", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.68.252.211", username="T04-tester", password="Nokia123!"
)

_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="95MC1G002",
    server_dir="C:\Program Files (x86)\DingLi\Pilot PioneerX11.0.9.0---10131620/Pioneer.exe",
    python_path="C:/Python27/python.exe",
    qcat_path="C:\Program Files\Qualcomm\QCAT7\Bin\QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM24",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
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


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOF_3xAHWWF",
)

__all__ = ["tl"]
