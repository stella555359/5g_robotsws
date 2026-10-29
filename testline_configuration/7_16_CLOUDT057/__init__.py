__maintainer__ = "Kamil Ostrzolek"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "kamil.ostrzolek@nokia.com"

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
from taf.config.testline.attenuator import TopYoung

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.97", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(
    addr="10.44.206.141", port_numbers=[10], model="EPC", version="8221-1"
)
_pdu_rmod2 = Gude(addr="10.44.205.2", port_numbers=[8], model="EPC", version="8221-1")
_pdu_asib = Gude(addr="10.44.206.142", port_numbers=[1], model="EPC", version="8221-1")
_pdus = [_pdu_rmod1, _pdu_rmod2, _pdu_asib]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.64.61",
        vlan_id=454,
        routing_v4=RoutingInformation(gateway="10.44.64.1"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.44.64.125", vlan_id=455),
    x2u=NetworkAddress(v4="10.44.64.189", vlan_id=456),
    s1u=NetworkAddress(v4="10.44.64.253", vlan_id=457),
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1_master = CapacityUnit(addr="0.0.0.0")
_abil1_du1_slave = CapacityUnit(addr="0.0.0.0")

_asib_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1_master, _abil1_du1_slave],
    pdu_port=_pdu_asib.pdu_ports[1],
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHPD",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[10],
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod2.pdu_ports[8],
)

_du_1_gnb_1 = DU(Airscale(common_units=[_asib_du1]), rus=[_gnb_ru1, _gnb_ru2])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50301, instance_id=50301)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asib_du1]),
    x2_link_addr=NetworkAddress(v4="10.44.64.102", vlan_id=455),
    global_bts_id=40301,
)

_lte.m = NetworkAddress(v4="10.44.64.38", vlan_id=454)

_ue_pc_ssh = SshServiceDetails("10.42.22.102", "wro5goam", password="Uteadmin1@")

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="820d70bb",
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASKEY_ASIBL_ABILB1B2_AHCA_AHPD",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
    ues=[_android_ue],
    appserver=_appserver_ssh,
)

__all__ = ["tl"]
