__maintainer__ = "Jia Yu"
__email__ = "yu.jia@nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, HBTE, TopYoung
from taf.config.testline.pdu import FPFH
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine

_pdu_1 = FPFH(addr="10.108.190.43", port_numbers=[6])
#_pdu_2 = TopYoung(addr="10.68.252.10", port_numbers=[2])
#_pdu_3 = TopYoung(addr="10.68.252.12", port_numbers=[3])

_rmod_1 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPHB",
    serial_number="EB2341R0036",
    #pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPHB",
    serial_number="DH241200041",
    #pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPNB",
    serial_number="EB2330R0823",
    #pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPNB",
    serial_number="EB2330R0866",
    #pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPHB",
    serial_number="EB2317R0060",
    #pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPHB",
    serial_number="EB2341R0043",
    #pdu_port=_pdu_1.pdu_ports[2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212562896",
#    rus=[_rmod_1, _rmod_2]
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(
    airscale=_smod_1,
#    rus=[_rmod_1, _rmod_2],
    f1_m_ip_addr="10.68.180.9",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.180.9",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.180.9", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=37126, global_bts_id=37126
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "ta_ue_data.yaml")

if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""
print(_ue_config)


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
        addr="10.68.181.228", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD__4G_5G_CLASSICAL_SA_ASIB_ABIOB2_ABIPB3_AWPHB_AWPNB",
)


__all__ = ["tl"]
