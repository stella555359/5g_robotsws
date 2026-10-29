__owner__ = "He Qing"
__maintainer__ = "He Qing"
__email__ = "qing.2.he@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM, HBTE,FPFH
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

_pdu_1 = FPFH(addr="10.108.190.53", port_numbers=[1,2,3])
_pdu_2 = FPFH(addr="10.108.190.51", port_numbers=[1,2,3])
_pdu_3 = FPFH(addr="10.108.190.52", port_numbers=[2,3,4,5])
_pdu_4 = FPFH(addr="10.108.190.46", port_numbers=[1,2,6])
_pdu_5 = FPFH(addr="10.108.190.48", port_numbers=[6])
_pdu_6 = FPFH(addr="10.108.190.45", port_numbers=[6])


_rmod_1 = RU(
    ru_hw_group="AHEGC:CPRI_RRH_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852668",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="AHEGC:CPRI_RRH_4T4R",
    radio_type="AHEGC",
    serial_number="EA223852874",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="AHEGC:CPRI_RRH_4T4R",
    radio_type="AHEGC",
    serial_number="DH231442049",
    pdu_port=_pdu_3.pdu_ports[2],
)


_rmod_6 = RU(
    ru_hw_group="FHFB:CPRI_RRH_4T4R",
    radio_type="FHFB",
    serial_number="L1151405165",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_7 = RU(
    ru_hw_group="FHFB:CPRI_RRH_4T4R",
    radio_type="FHFB",
    serial_number="L1151405170",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_8 = RU(
    ru_hw_group="FHFB:CPRI_RRH_4T4R",
    radio_type="FHFB",
    serial_number="K9171812459",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_9 = RU(
    ru_hw_group="FXED:CPRI_RRH_6T6R",
    radio_type="FXED",
    serial_number="L1170515234",
    pdu_port=_pdu_4.pdu_ports[6],
)

_rmod_10 = RU(
    ru_hw_group="FXED:CPRI_RRH_6T6R",
    radio_type="FXED",
    serial_number="F7182417303",
    pdu_port=_pdu_6.pdu_ports[6],
)

#BBU
# _fsp_1 = CapacityUnit(
#     addr="192.168.254.125",
#     hardware_type="ABIQ",
#     hardware_version="476397A.101",
#     serial_number="L1232102435",
#     pdu_port=_pdu_1.pdu_ports[5],
#     rus=[_rmod_1,_rmod_2,_rmod_3],
# )

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_fct_1 = CommonUnit(
    capacity_units=[],
    pdu_port=_pdu_4.pdu_ports[1],
    hardware_type="ASOG",
    hardware_version="473764A.102",
    serial_number="L1243303666",
    lmp_connection=_lmp_connection,
)


_du_1 = DU(
    airscale=Airscale([_fct_1]),
    rus=[_rmod_1, _rmod_2, _rmod_3,_rmod_6, _rmod_7, _rmod_8,_rmod_9, _rmod_10],
    f1_m_ip_addr="10.68.181.194",
)
_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=37646, global_bts_id=37646
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

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.68.181.230", username="ute"),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOG_AHEGC_FHFB_FXED_1_5_Cloud206",
)
# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])


__all__ = ["tl"]
