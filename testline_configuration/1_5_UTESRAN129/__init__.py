__maintainer__ = "xilou"
__email__ = "xingxin.lou@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.198.185", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.106.198.186", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(addr="10.108.151.187", port_numbers=[1, 5], model="facom")
_pdu_2 = FACOM(addr="10.108.151.186", port_numbers=[4, 8], model="facom")

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204601138",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211508281",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191004943",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1185009188",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="EA210256469",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="L1182715982",
    pdu_port=_pdu_2.pdu_ports[8],
)

_du_1 = DU(airscale=_smod_1, rus=[_rmod_1], f1_m_ip_addr="10.108.151.182")  # 5G S1 IP
_du_2 = DU(airscale=_smod_2, rus=[_rmod_2], f1_m_ip_addr="10.108.151.182")
# CU
_cu = CU(
    backhaul_site_oam_ip="10.108.151.182",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.182", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(dus=[_du_1], cu=_cu, instance_id=335, global_bts_id=335)
_classical_bts_2 = ClassicalBts(dus=[_du_2], cu=_cu, instance_id=335, global_bts_id=335)


_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "askey_ue_data.yaml")
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
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    ues=[_ue_config],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIB2_ABIO_B1_B4_AHPMDA_AHHB",
)


__all__ = ["tl"]
