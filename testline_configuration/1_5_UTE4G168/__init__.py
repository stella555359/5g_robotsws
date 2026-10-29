__maintainer__ = "qianzhou"
__owner_email__ = "qiang.1.zhou@nokia-sbell.com"
__email__ = "qiang.1.zhou@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM, HBTE
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

_pdu_1 = HBTE(addr="10.106.198.48", port_numbers=[2, 3, 4])
_pdu_2 = HBTE(addr="10.106.198.47", port_numbers=[1, 2, 4])

# BBU

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASOE",
    hardware_version="475587A.101",
    serial_number="EA212356657",
)

# 5*RRU
_rmod_1 = RU(
    ru_hw_group="eCPRI_RRH_8T8R",  ###what it use for?
    serial_number="AH211900890",
    pdu_port=_pdu_2.pdu_ports[4],
    radio_type="AZHL"
)
_rmod_2 = RU(
    ru_hw_group="eCPRI_RRH_8T8R",
    serial_number="AH211600356",
    pdu_port=_pdu_2.pdu_ports[1],
    radio_type="AZHL"
)
_rmod_3 = RU(
    ru_hw_group="eCPRI_RRH_8T8R",
    serial_number="AH211900777",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="AZHL"
)

_rmod_4 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="6Q184821654",
    pdu_port=_pdu_1.pdu_ports[2],
    radio_type="AZHA"
)

_rmod_5 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="L1162105358",
    pdu_port=_pdu_1.pdu_ports[3],
    radio_type="AZNA"
)

_du_1 = DU(
    airscale=Airscale([_fct_1]),
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    f1_m_ip_addr="10.106.198.136",
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
    dus=[_du_1], cu=_cu, instance_id=10306, global_bts_id=10306
)

# _enb_sbts_1 = RealEnb(airscale=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(airscale=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)


#_ue_pc_ssh = SshServiceDetails(
#    addr="10.106.211.124", username="siso1-tester", password="Nokia123!"
#)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196",
    username="tdlte-tester",
    password="btstest",
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.108.144.107",
    iperf_path="iperf",
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "sim8200_config.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.198.196", username="ute"),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOE_AZNA_AZHA_3xAZHL_1_5_UTE4G168",
)
# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])


__all__ = ["tl"]
