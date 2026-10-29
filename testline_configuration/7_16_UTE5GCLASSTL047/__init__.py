__maintainer__ = "Dawid Dzilinski"
__team__ = "MN 5G&SC Pz 5G I&V 7 WRO 7 SG"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "dawid.dzilinski@nokia.com"

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
from taf.config.testline.pdu import Gude


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.231", username="ute", password="ute"
    )
)

_gnb_ru = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
)

_pdu1 = Gude(
    addr="10.44.206.178",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_capacity_unit = CapacityUnit(addr="192.168.253.21")

# _common_unit_ssh = SshServiceDetails(addr='10.44.66.142',
_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asik = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu1.pdu_ports[4]
)

_airscale = Airscale(common_units=[_asik])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    # oam_ssh_connection_details=SshServiceDetails(addr='10.44.66.142',
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # oam_http_connection_details=HttpConnectionDetails(addr='10.44.66.142',
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(airscale=_airscale, rus=[_gnb_ru])

_enbs = RealEnb(oam_ip=NetworkAddress(v4="10.44.66.143"))

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_qc_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)


_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_qc_appserver_ssh,
    network_interface_address="xx.xx.xx.xx",
    iperf_path="/usr/bin/iperf",
)

_qc_host_ssh = SshServiceDetails(
    addr="10.42.22.151", username="wro5gcloud", password="Secret2.022!"
)


_iperf_details_on_qc = IperfDataTransferDetails(
    ssh_connection_details=_qc_host_ssh,
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

_qc = Android(
    ssh_connection_details=_qc_host_ssh,
    serial_number="6764ce0d",
    server_dir="c:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    imsi="540017000000501",
    iperf_details=_iperf_ue,
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_enbs],
    ues=[_qc],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_DSS_ASIKL_ABILB1_2xAHLOA_ENB",
    appserver=_appserver,
    pdus=[_pdu1],
)

__all__ = ["tl"]
