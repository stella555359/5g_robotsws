__maintainer__ = "Klaudia Zbyrowska"
__team__ = "I_MN_RAN_PZ1_WRO_3"
__email__ = "I_MN_RAN_PZ1_WRO_3_SG@internal.nsn.com"
__owner_email__ = "klaudia.zbyrowska@nokia.com"

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


_pdu_asil = Gude(addr="10.44.205.90", port_numbers=[10], model="EPC", version="8221-1")
_pdu_rmod1 = Gude(addr="10.44.206.143", port_numbers=[3], model="EPC", version="8221-1")
_pdu_rmod2 = Gude(addr="10.44.206.131", port_numbers=[2], model="EPC", version="8220-1")


_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b64e",
        vlan_id=480,
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601", ip_prefix_length=120),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b750", vlan_id=481),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b852", vlan_id=482),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b955", vlan_id=483),
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[3],
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod2.pdu_ports[2],
)

_core = RealCore5G(mcc=555, mnc=10)

_abio1_du1 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1212907774",
    rus=[_gnb_ru1, _gnb_ru2]
)

_asil_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_du1],
    pdu_port=_pdu_asil.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1213511582",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50928, instance_id=50928)

_ue_pc_ssh = SshServiceDetails("10.44.72.194", "wro5goam", password="Uteadmin1@")

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.228", username="ute", password="ute"
    ),
    connections=[_asil_du1],
)

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="241ffa71",
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
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASILR_ABIOB1_2xAZQO",
    core=_core,
    pdus = [_pdu_rmod1, _pdu_rmod2, _pdu_asil],
    ues=[_android_ue],
    appserver=_appserver_ssh,
)

__all__ = ["tl"]
