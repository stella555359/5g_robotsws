__maintainer__ = "Damian Silkowski"
__team__ = "MN 5G&SC Pz 5G I&V 7 WRO 7 SG"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "damian.silkowski@nokia.com"

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
from taf.config.testline.ue import Android
from taf.config.testline.appserver import AppServer
from taf.config.testline.gnb.networkaddress import NetworkAddress


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.214", username="ute", password="ute"
    )
)

_gnb_ru = RU(
    ru_hw_group="AHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
)

_capacity_unit = CapacityUnit(addr="192.168.253.21")

# _common_unit_ssh = SshServiceDetails(addr='10.44.66.162',
_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asik = CommonUnit(_common_unit_ssh, capacity_units=[_capacity_unit])

_airscale = Airscale(common_units=[_asik])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    # oam_ssh_connection_details=SshServiceDetails(addr='10.44.66.162',
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # oam_http_connection_details=HttpConnectionDetails(addr='10.44.66.162',
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(airscale=_airscale, rus=[_gnb_ru])

_enbs = RealEnb(oam_ip=NetworkAddress(v4="10.44.66.163"))

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_nokia_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)


_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_nokia_appserver_ssh,
    network_interface_address="xx.xx.xx.xx",
    iperf_path="/usr/bin/iperf",
)

_nokia_host_ssh = SshServiceDetails(
    addr="10.42.22.144", username="wro5gcloud", password="Secret2.022!"
)


_iperf_details_on_nokia = IperfDataTransferDetails(
    ssh_connection_details=_nokia_host_ssh,
    network_interface_address="",
    iperf_path="/usr/bin/iperf",
    # ports=[54000, 61615, 61616, 61617, 61618])
)

_appserver = AppServer(_iperf_details_on_appserver)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/opt/iperf/",
)

_nokia1 = Android(
    ssh_connection_details=_nokia_host_ssh,
    serial_number="6764ce0d",
    server_dir="c:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    imsi="540017000000429",
    iperf_details=_iperf_ue,
)

_nokia2 = Android(
    ssh_connection_details=_nokia_host_ssh,
    serial_number="6764ce0d",
    server_dir="c:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    imsi="540017000000428",
    iperf_details=_iperf_ue,
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_enbs],
    ues=[_nokia1, _nokia2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_DSS_ASIKL_ABILB1_ASIAR_ABIAB1_2xAHLOA_1xAHDB",
    appserver=_appserver,
)

__all__ = ["tl"]
