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

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.226", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

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

#ASIL
_pdu_1 = FACOM(
    addr="10.56.7.187",
    port_numbers=[8],
    model="facom"
)
#1
_pdu_2 = TopYoung(
    addr="10.68.160.52",
    port_numbers=[1, 2, 3, 4, 6],
    model="JieXi"
)
#2
_pdu_3 = TopYoung(
    addr="10.68.160.51",
    port_numbers=[2, 3, 6],
    model="JieXi"
)

_rmod_1 = RU(ru_hw_group="AHFIB:CPRI_RP1", serial_number="BL2145V0OZJ", pdu_port=_pdu_2.pdu_ports[4],)
_rmod_2 = RU(ru_hw_group="AHFIB:CPRI_RP1", serial_number="BL2147V0RGV", pdu_port=_pdu_2.pdu_ports[2],)
_rmod_3 = RU(ru_hw_group="AHFIB:CPRI_RP1", serial_number="BL2147V0RJ6", pdu_port=_pdu_2.pdu_ports[1],)
_rmod_4 = RU(ru_hw_group="AHFIB:CPRI_RP1", serial_number="BL2230V04RE", pdu_port=_pdu_3.pdu_ports[3],)
_rmod_5 = RU(ru_hw_group="AHFIB:CPRI_RP1", serial_number="BL2232V06DP", pdu_port=_pdu_3.pdu_ports[2],)
_rmod_6 = RU(ru_hw_group="AHFIB:CPRI_RP1", serial_number="BL2232V06HL", pdu_port=_pdu_3.pdu_ports[6],)
_rmod_7 = RU(ru_hw_group="AHFIG:CPRI_RP1", serial_number="BL2112W24AW", pdu_port=_pdu_2.pdu_ports[3],)
_rmod_8 = RU(ru_hw_group="AHFIG:CPRI_RP1", serial_number="BL2112W240E", pdu_port=_pdu_2.pdu_ports[6],)

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="ABIP",
    hardware_version="475792A.X13",
    serial_number="L1223503836",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="474767A.M01",
    serial_number="L1202701622",
    capacity_units=[_fsp_1],
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

_ue_pc_ssh = SshServiceDetails(
    addr="10.69.64.227", username="siso2-tester", password="Nokia123!"
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
    server_dir="C:\Program Files (x86)\DingLi\Pilot Pioneer10.5.9.53---08221504/Pioneer.exe",
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
   rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
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
    tl_cloud_topology="CLOUD_RF_FHBB_CRT2_1083",
)

__all__ = ["tl"]
