__maintainer__ = "Krzysztof Wrobel"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "krzysztof.1.wrobel@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
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
        addr="10.44.156.69", username="ute", password="ute"
    )
)

_pdu = Gude(addr="10.44.206.178", port_numbers=[12], model="EPC", version="8220-1")

_gnb_ru = RU(
    ru_hw_group="Below6GHz",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
)

# 4G radio units
_enb_rus = [RU(ru_hw_group="LTE_RADIO", radio_type="AHFIB")]

_capacity_unit = CapacityUnit(addr="192.168.253.21")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asik = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[12]
)

_asia = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[12]
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
    f1m=NetworkAddress(v4="10.44.66.160"),
    x2c=NetworkAddress(v4="10.44.66.224"),
    x2u=NetworkAddress(v4="10.44.67.19"),
    s1u=NetworkAddress(v4="10.44.67.83"),
    tracing=NetworkAddress(v4="10.44.67.147"),
)

_du = DU(airscale=_airscale, rus=[_gnb_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50313, global_bts_id=50313)

_core = RealCore4G()

_enb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    rms=_enb_rus,
    instance_id=40313,
    global_bts_id=40313,
    oam_ip=NetworkAddress(v4="10.44.66.161"),
    x2_link_addr=NetworkAddress(v4="10.44.66.225"),
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.43", username="ute", password="ute"
    ),
    connections=[_enb],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.145", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)

# _iperf = IperfDataTransferDetails(
#    ssh_connection_details=_appserver_ssh,
#    network_interface_address="10.42.61.65",
#    iperf_path="/usr/bin/iperf",
# )

# _samsung = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
#     os.path.dirname(os.path.abspath(__file__)), "ue_config_at.yaml"
# )

# UE1
_android_0 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.145", username="wro5gcloud", password="Secret2.022!"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "samsung"],
    serial_number="RFCN604L87T",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=_appserver_ssh,
        network_interface_address="10.44.43.31",
        iperf_path="/usr/bin/iperf",
        port=52012,
    ),
)
# UE1

# UE2
_android_1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.145", username="wro5gcloud", password="Secret2.022!"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "samsung"],
    serial_number="R3CN20P7GVZ",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=_appserver_ssh,
        network_interface_address="10.44.43.31",
        iperf_path="/usr/bin/iperf",
        port=52013,
    ),
)
# UE2

tl = TestLine(
    test_pc=_test_pc,
    ues=[_android_0, _android_1],
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_cbts],
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_DSS_ASIKL_ABILB1_AHLOA_ENB",
    core=_core,
    pdus=[_pdu],
)

__all__ = ["tl"]
