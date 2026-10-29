__maintainer__ = "Pawel Gorczynski"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "pawel.gorczynski@nokia.com"

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
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.159", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:9720",
        vlan_id=851,
        routing=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:9701", ip_prefix_length=120
        ),
        v4="10.45.178.36",
        routing_v4=RoutingInformation(gateway="10.45.178.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:9820", vlan_id=852),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:9920", vlan_id=853),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:9a20", vlan_id=854),
)

_pdu_asil = Gude(addr="10.44.177.49", port_numbers=[8], model="EPC", version="8221-1")
_pdu_rmod2 = Gude(addr="10.44.177.164", port_numbers=[8], model="EPC", version="8221-1")
_pdu_rmod3 = Gude(addr="10.44.177.162", port_numbers=[5], model="EPC", version="8221-1")
_pdu_rmod4 = Gude(addr="10.44.177.163", port_numbers=[6], model="EPC", version="8221-1")
_pdu_rmod5 = Gude(addr="10.44.177.163", port_numbers=[1], model="EPC", version="8221-1")

_pdus = [
    _pdu_rmod2,
    _pdu_rmod3,
    _pdu_rmod4,
    _pdu_rmod5,
    _pdu_asil,
]

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.133", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod2.pdu_ports[8],
)

_gnb_ru3 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.134", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod3.pdu_ports[5],
)

_gnb_ru4 = RU(
    ru_hw_group="Unknown",
    radio_type="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.137", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod4.pdu_ports[6],
)

_gnb_ru5 = RU(
    ru_hw_group="Unknown",
    radio_type="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.130", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod5.pdu_ports[1],
)

_core = RealCore5G(mcc=1, mnc=1)

_abio1_du1 = CapacityUnit(addr="192.168.253.20")

_asil_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_du1],
    pdu_port=_pdu_asil.pdu_ports[8],
)

_airscale_gnb_1 = Airscale(common_units=[_asil_du1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _gnb_ru2,
        _gnb_ru3,
        _gnb_ru4,
        _gnb_ru5,
    ],
)

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50930, instance_id=50930)

_ue_pc_ssh = SshServiceDetails("10.44.72.217", "wro5goam", password="Uteadmin1@")

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="HZQN1876AAK90100295",
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

_lte = RealEnb(
    system_module=Airscale(common_units=[_asil_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:9e21", vlan_id=858),
    global_bts_id=41008,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:9d21", vlan_id=857)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASILL_ABIOB1_3xAHLOA_3xAHFIB_3xAHFIA",
    core=_core,
    pdus=_pdus,
    ues=[_android_ue],
    appserver=_appserver_ssh,
)

__all__ = ["tl"]
