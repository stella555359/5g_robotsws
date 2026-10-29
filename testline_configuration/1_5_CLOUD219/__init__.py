__maintainer__ = "han jia"
__owner_email__ = "jia.han@nokia-sbell.com"
__email__ = "jia.han@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM, FPFH, TopYoung, HBTE
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

_pdu_1 = FPFH(
    addr="10.108.190.18",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="FPFH",
)
_pdu_2 = FPFH(
    addr="10.108.190.19",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="FPFH",
)
_pdu_3 = FPFH(
    addr="10.108.190.21",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="FPFH",
)
_pdu_4 = TopYoung(
    addr="10.108.190.20",
    port_numbers=[1, 2, 3, 4, 5, 6],
)
# _rmod_1 = RU(
#    ru_hw_group="AKFA:cMAAr6.2_8T8R_eCPRI",
#    radio_type="AKFA",
#    serial_number="4H245160481",
#    pdu_port=_pdu_4.pdu_ports[1],
# )
# _rmod_2 = RU(
#    ru_hw_group="AKFA:cMAAr6.2_8T8R_eCPRI",
#    radio_type="AKFA",
#    serial_number="4H245160480",
#    pdu_port=_pdu_2.pdu_ports[3],
# )
_rmod_3 = RU(
     ru_hw_group="cMAAr6.2_8T8R_eCPRI",
     serial_number="1M243101201",
     radio_type="AKHM",
     pdu_port=_pdu_3.pdu_ports[3],
 )
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101552",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="473096A.103",
    serial_number="EA190776209",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="DH243436247",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230610624",
)
_smod_1 = Airscale([_fct_1])


_du_1 = DU(
    airscale=_smod_1, rus=[_rmod_3], f1_m_ip_addr="192.168.255.129"
)  # 5G S1 IP
# CU
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
    dus=[_du_1], cu=_cu, instance_id=37614, global_bts_id=37614
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
    default_ssh_connection_details=SshServiceDetails(addr="10.68.254.36", username="ute",password="UTE.debian12"),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIM_AKHM",
)
# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])


__all__ = ["tl"]
