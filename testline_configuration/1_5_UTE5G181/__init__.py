__maintainer__ = "Lei Bibo"
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


_pdu_1 = HBTE(addr="10.68.252.196", port_numbers=[3])
_pdu_2 = FPFH(addr="10.68.252.201", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_3 = FPFH(addr="10.68.252.202", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")


_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852835",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852828",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852833",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9195201559",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852807",
    pdu_port=_pdu_3.pdu_ports[3],   
)    
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9184605656",
    pdu_port=_pdu_3.pdu_ports[4],   
)    
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA223653699",
    pdu_port=_pdu_3.pdu_ports[5],   
)    
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGC",
    serial_number="DH230253290",
    pdu_port=_pdu_3.pdu_ports[6],   
)


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233104916",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6,_rmod_7,_rmod_8],
)

_fct_1 = CommonUnit(
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230610648",
    lmp_connection=_lmp_connection,
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6,_rmod_7,_rmod_8],
    f1_m_ip_addr="10.68.252.204",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.252.204",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.204", username="toor4nsn", password="oZPS0POrRieRtu"
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
        addr="10.68.252.133", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIM_ABIQ_5xAHEGC_3xAHEGB",
)

__all__ = ["tl"]
