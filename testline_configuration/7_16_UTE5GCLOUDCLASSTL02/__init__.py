__maintainer__ = "Jakub Kaszczyszyn"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "jakub.kaszczyszyn@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.radio import RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import Android

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.229", username="ute", password="ute"
    )
)

_pdu = Gude(addr="10.44.206.178", port_numbers=[8], model="EPC", version="8220-1")

_gnb_ru = RU(
    ru_hw_group="Below6GHz",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
)

# 4G radio units
_enb_rus = [RU(ru_hw_group="LTE_RADIO", radio_type="AHFB")]

_capacity_unit = CapacityUnit(addr="192.168.253.21")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asik = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[8]
)

_asia = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[8]
)

_airscale = Airscale(common_units=[_asik])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    f1m=NetworkAddress(v4="10.44.66.150"),
    x2c=NetworkAddress(v4="10.44.66.214"),
    x2u=NetworkAddress(v4="10.44.67.14"),
    s1u=NetworkAddress(v4="10.44.67.78"),
    tracing=NetworkAddress(v4="10.44.67.142"),
)

_du = DU(airscale=_airscale, rus=[_gnb_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50432, global_bts_id=50432)

_core = RealCore4G()

_enb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    rms=_enb_rus,
    instance_id=40432,
    global_bts_id=40432,
    oam_ip=NetworkAddress(v4="10.44.66.151"),
    x2_link_addr=NetworkAddress(v4="10.44.66.215"),
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.230", username="ute", password="ute"
    ),
    connections=[_enb],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.30", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)

_android0 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.30", username="wro5gcloud", password="Secret2.022!"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "samsung"],
    serial_number="R3CN20NC5PA",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=_appserver_ssh,
        network_interface_address="10.44.43.51",
        iperf_path="/usr/bin/iperf",
        port="8115",
    ),
)

_android1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.30", username="wro5gcloud", password="Secret2.022!"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "samsung"],
    serial_number="R3CN20N531X",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=_appserver_ssh,
        network_interface_address="10.44.43.51",
        iperf_path="/usr/bin/iperf",
        port="8815",
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_cbts],
    enbs=[_enb],
    ues=[_android0, _android1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_DSS_ASIKL_ABILB1_AHLOA_ENB_21A",
    core=_core,
    pdus=[_pdu],
)

__all__ = ["tl"]
