__owner__ = "qling"
__maintainer__ = "qling"
__email__ = "ling>qin@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.ue import Android
from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE, TopYoung
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts

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

#ASIm
_pdu_1 = TopYoung(
    addr="10.108.190.4",
    port_numbers=[1, 2, 3, 4, 6],
    # model="JieXi"
)

_pdu_2 = HBTE(
    addr="10.108.190.3",
    port_numbers=[1, 2, 3, 4, 5, 6],
    # model="JieXi"
)

_rmod_1 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2147V0RAC", pdu_port=_pdu_1.pdu_ports[4],)
_rmod_2 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2147V0RGV", pdu_port=_pdu_1.pdu_ports[2],)
_rmod_3 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2147V0RJ6", pdu_port=_pdu_1.pdu_ports[1],)
_rmod_4 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2230V04RE", pdu_port=_pdu_2.pdu_ports[2],)
_rmod_5 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2232V06DP", pdu_port=_pdu_2.pdu_ports[1],)
_rmod_6 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2232V06HL", pdu_port=_pdu_2.pdu_ports[3],)
_rmod_7 = RU(ru_hw_group="AHFIG:CPRI_RP1", radio_type="AHFIG", serial_number="BL2112W24AW", pdu_port=_pdu_1.pdu_ports[3],)
_rmod_8 = RU(ru_hw_group="AHFIG:CPRI_RP1", radio_type="AHFIG", serial_number="BL2112W240E", pdu_port=_pdu_1.pdu_ports[6],)
_rmod_9 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2232V06HK", pdu_port=_pdu_2.pdu_ports[4],)
_rmod_10 = RU(ru_hw_group="AHFIB:CPRI_RP1", radio_type="AHFIB", serial_number="BL2232V069G", pdu_port=_pdu_2.pdu_ports[5],)

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233704778",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.101",
    serial_number="L1224401592",
    capacity_units=[_fsp_1],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.32", username="ute", password="UTE.debian12"
    ),
    connections=[_fct_1],
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
_ue_config_path = os.path.join(_cfg_dir, "android_ue_config.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_android = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_android)
        for item in qci_port:
            _ue_android = _ue_android.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_android, Loader=yaml.FullLoader)
else:
    _ue_config = ""
print(_ue_config)

_ue_pc_ssh = SshServiceDetails(
    addr="10.68.180.201", username="siso2-tester", password="Nokia123!"
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
    serial_number="UQG5T20B19007308",
    # server_dir="C:/pyro_server",
    server_dir="C:\Program Files (x86)\DingLi\Pilot Pioneer10.5.9.63---04271703/Pioneer.exe",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM31",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)

_smod_1 = Airscale([_fct_1])
#_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2])

_du_1 = DU(
   airscale=_smod_1,
   rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10],
   f1_m_ip_addr="192.168.255.1",
)  # 5G S1 IP

# _enb_sbts = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8])

_classical_bts_1 = ClassicalBts(
   dus=[_du_1], cu=_cu, instance_id=11, global_bts_id=11
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_classical_bts_1],
#     enbs=[_enb_sbts],
    ues=[_android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_NSA_ASILL_ABIPB1_4XAHFIB",
)

__all__ = ["tl"]
#
# _android_ue = Android(
#     ssh_connection_details=_ue_pc_ssh,
#     serial_number="UQG5T20B19007308",
#     server_dir="C:/pyro_server",
#     # server_dir="C:\Program Files (x86)\DingLi\Pilot Pioneer10.5.9.63---04271703/Pioneer.exe",
#     python_path="C:/Python27/python.exe",
#     qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
#     diag_cfg_path="C:/pyro_server/DIAG.cfg",
#     dmc_path="C:/Users/user-lab0/adam.dmc",
#     diag_com="COM22",
#     iperf_details=_android_iperf,
#     capabilities=["REAL_ANDROID_UE", "REAL_UE"],
# )
#
# _smod_1 = Airscale([_fct_1])
# #_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2])
#
# _du_1 = DU(
#    airscale=_smod_1,
#    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
#    f1_m_ip_addr="192.168.255.1",
# )  # 5G S1 IP
#
# # _enb_sbts = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8])
#
# _classical_bts_1 = ClassicalBts(
#    dus=[_du_1], cu=_cu, instance_id=11, global_bts_id=11
# )
#
# tl = TestLine(
#     test_pc=_test_pc,
#     test_pcs=[_test_pc],
#     gnbs=[_classical_bts_1],
# #     enbs=[_enb_sbts],
#     ues=[_android_ue, _ue_config],
#     appserver=_appserver,
#     tl_cloud_topology="CLOUD_5G_CLASSICAL_NSA_ASILL_ABIPB1_4XAHFIB",
# )
#
# __all__ = ["tl"]
