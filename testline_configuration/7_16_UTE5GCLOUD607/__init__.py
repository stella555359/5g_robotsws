__maintainer__ = "Kamil Ostrzolek"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "michal.lys@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import AppServer
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    IperfDataTransferDetails,
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ue import Android
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.pdu import ATEN, Gude, PduPort
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.158.198", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b616",
        vlan_id=480,
        routing=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b612", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b712", vlan_id=481),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b812", vlan_id=482),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b915", vlan_id=483),
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1)

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50332, instance_id=50332)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asik_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:bd0f", vlan_id=486),
    global_bts_id=40317,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:bc0f", vlan_id=486)

_ue_pc_ssh = SshServiceDetails("10.42.22.243", "wro5goam", password="Uteadmin1@")

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="bdb9b257",
    server_dir="/cygdrive/c/pyro_server/ta_ue_android_plugin/ue",
    python_path="python2",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/opt/iperf/",
)
_appserver_ssh = AppServer(iperf_details=_iperf)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AZQO",
    test_pc=_test_pc,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
    ues=[_android_ue],
    appserver=_appserver_ssh,
)

__all__ = ["tl"]
