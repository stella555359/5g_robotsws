__maintainer__ = "Karol Palac"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "karol.palac@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import MediaTek
from taf.config.testline.ue import Android
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.appserver import AppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.172.97", username="ute", password="Ut3pa5s#1be1"
    )
)
_abio_master = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101")
_abio_slave = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101")
_abio_loner = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101")
_pdu_1 = Gude("10.45.172.140", [9, 10, 11], "EPC", "8221-1")
_pdu_2 = Gude("10.45.177.14", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master, _abio_slave, _abio_loner],
    pdu_port=_pdu_2.pdu_ports[12],
)
_airscale = Airscale([_common_unit])
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.173.40",
        routing=RoutingInformation(gateway="10.45.173.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.45.173.104",
        routing=RoutingInformation(
            gateway="10.45.173.1",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.45.173.168",
        routing=RoutingInformation(gateway="10.45.173.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.45.173.228",
        routing=RoutingInformation(gateway="10.45.173.1", ip_prefix_length=26),
    ),
)

_du = DU(_airscale, rus=[_ru1, _ru2])
_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50894, instance_id=50894)
_core = RealCore5G(mcc=310, mnc=260)
_core_ssh = SshServiceDetails(addr="10.42.61.65", username="5g", password="2019H@slo")
_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="10.42.197.170",
    iperf_path="",
)

_attenuator = TopYoung(
    ip_addr="10.45.176.181",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
                              18, 19, 20, 21, 22, 23, 24],
)
_attenuator2 = TopYoung(
    ip_addr="10.45.176.182",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
                              18, 19, 20, 21, 22, 23, 24],
)
_appserver = AppServer(_iperf_ue)

_ue_pc_ssh = SshServiceDetails("10.44.234.144", "wro5grrm", password="5gpass!1")

_mtk_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="DUJAC-H0677",
    capabilities=["REAL_ANDROID_UE_SA"],
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf_ue,
    iperf_directory="/data/data/com.nokia.android.application/",
    clear_logs=True,
    clear_server_files=True,
)

_qualcomm_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="806d3b26",
    capabilities=["REAL_ANDROID_QUALCOMM_SDX65"],
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf_ue,
    iperf_directory="/data/data/com.nokia.android.application/",
    clear_logs=True,
    clear_server_files=True,
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIL_ABIO_MULTIRAT_WPT",
    core=_core,
    ues=[_mtk_ue, _qualcomm_ue],
    appserver=_appserver,
    attenuators=[_attenuator, _attenuator2]
)
__all__ = ["tl"]
