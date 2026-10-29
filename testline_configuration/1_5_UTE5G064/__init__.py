__maintainer__ = "blei"
__email__ = "bibo.lei@nokia-sbell.com"

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
    addr="10.106.208.45", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="facom"
)

_pdu_2 = FACOM(
    addr="10.106.208.42", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="facom"
)

_pdu_3 = FACOM(
    addr="10.68.94.109", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="facom"
)

_pdu_4 = FACOM(addr="10.68.160.4", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="hbte")

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101451",
    pdu_port=_pdu_1.pdu_ports[4],
)


_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_fct_1 = CommonUnit(
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1213506770",
    lmp_connection=_lmp_connection,
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRPA:FRMr3.1_6T6R",
    serial_number="EA170510098",
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRPA:FRMr3.1_6T6R",
    serial_number="EA170910440",
    pdu_port=_pdu_4.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FHDB:FRMr2.3_2T2R",
    serial_number="EA173412630",
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FHDB:FRMr2.3_2T2R",
    serial_number="EA173510838",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="FHDB:FRMr2.3_2T2R",
    serial_number="1M181001210",
    pdu_port=_pdu_3.pdu_ports[8],
)

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    f1_m_ip_addr="10.106.208.37",
)

_cu = CU(
    backhaul_site_oam_ip="10.106.208.37",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.208.37", username="toor4nsn", password="oZPS0POrRieRtu"
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


_ue_pc_ssh = SshServiceDetails(
    addr="10.106.208.49", username="siso1-tester", password="Nokia123!"
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
    diag_com="COM16",
    iperf_details=_android_iperf,
    capabilities=["samsungS21", "REAL_UE"],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.200", username="ute", password="ute"
    ),
    connections=[_classical_bts_1],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config, _android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASILR_ABIOB4_2xFRPA_3FHDB",
)

__all__ = ["tl"]
