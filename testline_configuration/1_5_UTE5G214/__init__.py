__owner__ = "Zhang Weilong"
__maintainer__ = "Zhang Weilong"
__email__ = "weilong.zhang@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import HBTE
from taf.config.testline.pdu import FPFH
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts
##ASIM
_pdu_1 = FPFH(
    addr="10.108.190.48",
    port_numbers=[3,4],
)
##AHFIB
_pdu_2 = FPFH(
    addr="10.108.190.45",
    port_numbers=[1,3,5],
)
##AHLOA
_pdu_3 = FPFH(
    addr="10.108.190.58",
    port_numbers=[1,2,3],
)
##AVHA
_pdu_4 = FPFH(
    addr="10.108.190.59",
    port_numbers=[1,2],
)
_pdu_5 = FPFH(
    addr="10.108.190.60",
    port_numbers=[1],
)
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211506359",
    pdu_port=_pdu_1.pdu_ports[3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231705708",
    pdu_port=_pdu_1.pdu_ports[4],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH244039952",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH244039926",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
##AHFIB1
_rmod_1 = RU(
    ru_hw_group="CPRI_RRH_2T3R",
    serial_number="BL2119V0CI7",
    radio_type="AHFIB",
    pdu_port=_pdu_2.pdu_ports[5],
)
##AHFIB2
_rmod_2 = RU(
    ru_hw_group="CPRI_RRH_2T3R",
    serial_number="BL2108V054W",
    radio_type="AHFIB",
    pdu_port=_pdu_2.pdu_ports[3],
)
##AHFIB3
_rmod_3 = RU(
    ru_hw_group="CPRI_RRH_2T3R",
    serial_number="BL2119V0CI8",
    radio_type="AHFIB",
    pdu_port=_pdu_2.pdu_ports[5],
)
##AHLOA1:
_rmod_4 = RU(
    ru_hw_group="CPRI_RRH_2T3R",
    serial_number="BL2034G1HH4",
    radio_type="AHLOA",
    pdu_port=_pdu_3.pdu_ports[1],
)
##AHLOA2:
_rmod_5 = RU(
    ru_hw_group="CPRI_RRH_2T3R",
    serial_number="BL2027G1AVX",
    radio_type="AHLOA",
    pdu_port=_pdu_3.pdu_ports[2],
)
##AHLOA3:
_rmod_6 = RU(
    ru_hw_group="CPRI_RRH_2T3R",
    serial_number="BL1934G11NX",
    radio_type="AHLOA",
    pdu_port=_pdu_3.pdu_ports[3],
)
##AVHA1
_rmod_7 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="L1251001336",
    radio_type="AEHC",
    pdu_port=_pdu_4.pdu_ports[1],
)
##AVHA2
_rmod_8 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="L1251101931",
    radio_type="AEHC",
    pdu_port=_pdu_4.pdu_ports[2],
)

##AVHA3
_rmod_9 = RU(
    ru_hw_group="CPRI_RRH_4T4R",
    serial_number="L1251101932",
    radio_type="AEHC",
    pdu_port=_pdu_5.pdu_ports[1],
)





_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_4, _rmod_5, _rmod_6],
    f1_m_ip_addr="10.68.181.202",
)
_du_2 = DU(
    airscale=_smod_2,
    rus=[_rmod_1, _rmod_2, _rmod_3,_rmod_7, _rmod_8],
#   rus=[_rmod_1, _rmod_2, _rmod_3,_rmod_7, _rmod_8, _rmod_9],
    f1_m_ip_addr="10.68.181.202",
)
# CU
_cu = CU(
    backhaul_site_oam_ip="10.106.198.18",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.202", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.181.202", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=6478, global_bts_id=6478
)
_classical_bts_2 = ClassicalBts(
    dus=[_du_2], cu=_cu, instance_id=6478, global_bts_id=6478
)
# _enb_sbts_1 = RealEnb(airscale=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(airscale=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.68.181.238", username="ute", password="ute"),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.68.181.239", username="ute", password="ute"),
    connections=[_classical_bts_2.dus[0].airscale.common_units[0]],
)

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
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    ues=[_ue_config],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_FULLRACK_ASIBL_ASIBR_ABIP_AHLOA_AHFIB_AVHA",
)
__all__ = ["tl"]
