__maintainer__ = "ding lisa"
__owner_email__ = "lisa.ding@nokia-sbell.com"
__email__ = "lisa.ding@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM, FPFH
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

_pdu_1 = FPFH(addr="10.106.198.2", 
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin")
_pdu_2 = FACOM(addr="10.106.198.5", port_numbers=[1, 2, 3, 4, 5])
_pdu_3 = FPFH(addr="10.106.198.6", 
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin")

_rmod_1 = RU(
     ru_hw_group="CPRI_RRH_2T3R",
     serial_number="BL2032V0I5O",
     radio_type="AHFIB",
     pdu_port=_pdu_3.pdu_ports[3],
 )
_rmod_2 = RU(
     ru_hw_group="CPRI_RRH_1T3R",
     serial_number="BL2032V0IIP",
     radio_type="AHFIB",
     pdu_port=_pdu_3.pdu_ports[2],
 )
_rmod_3 = RU(
     ru_hw_group="CPRI_RRH_4T4R",
     serial_number="EA203660216",
     radio_type="AHEGB",
     pdu_port=_pdu_3.pdu_ports[4],
 )
_rmod_4 = RU(
     ru_hw_group="CPRI_RRH_2T2R",
     serial_number="EA203660126",
     radio_type="AHEGB",
     pdu_port=_pdu_3.pdu_ports[1],
 )
_rmod_5 = RU(
     ru_hw_group="CPRI_RRH_8T8R",
     serial_number="6Q190108279",
     radio_type="AZQE",
     pdu_port=_pdu_1.pdu_ports[4],
 )
_rmod_6 = RU(
     ru_hw_group="CPRI_RRH_32T32R",
     serial_number="1M203909482",
     radio_type="AZQE",
     pdu_port=_pdu_3.pdu_ports[6],
 )



_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184380597",
    pdu_port=_pdu_3.pdu_ports[3],
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174907932",
    pdu_port=_pdu_3.pdu_ports[3],
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170303356",
    pdu_port=_pdu_3.pdu_ports[3],
    rus=[_rmod_4],
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="EA200950182",
    pdu_port=_pdu_3.pdu_ports[1],
    rus=[_rmod_3],
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="DH212563609",
    pdu_port=_pdu_3.pdu_ports[1],
    rus=[_rmod_6],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184380689",
    pdu_port=_pdu_3.pdu_ports[1],
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH203864073",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH203864071",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_du_1 = DU(
    airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3], f1_m_ip_addr="192.168.255.1"
)  # 5G S1 IP
_du_2 = DU(
    airscale=_smod_2,
    rus=[_rmod_3, _rmod_4, _rmod_5, _rmod_6],
    f1_m_ip_addr="192.168.255.129",
)
# CU
_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
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

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

# _cfg_dir = os.path.dirname(os.path.abspath(__file__))
# _ue_config_path = os.path.join(_cfg_dir, "huawei_ue_data.yaml")
# if os.path.isfile(_ue_config_path):
#     with open(_ue_config_path) as f:
#         _ue_askey = f.read()
#         qci_port = re.findall("(_iperf.*?port)", _ue_askey)
#         for item in qci_port:
#             _ue_askey = _ue_askey.replace(item, str(eval(item)))
#         _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
# else:
#     _ue_config = ""
# print(_ue_config)

_ue_pc_ssh = SshServiceDetails(
    addr="10.106.198.30", username="siso2-tester", password="Nokia123!"
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
    serial_number="UQG5T20629005565",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM31",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.106.198.182", username="ute"),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.106.198.184", username="ute"),
    connections=[_classical_bts_2.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    ues=[_android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIR_B1-B2_CRT1_5G_1023",
)
# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])


__all__ = ["tl"]
