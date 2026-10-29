__maintainer__ = "Jakub Rychlik"
__team__ = "I_5GSC_5G_PZ1_WRO_4"
__email__ = "I_5GSC_5G_PZ1_WRO_4@internal.nsn.com"
__owner_email__ = "jakub.rychlik@nokia.com"

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

_pdu_asil = Gude(addr="10.44.177.48", port_numbers=[3], model="EPC", version="8221-1")
_pdu_rmod1 = Gude(addr="10.44.177.47", port_numbers=[10], model="EPC", version="8221-1")
_pdu_rmod2 = Gude(addr="10.44.177.47", port_numbers=[11], model="EPC", version="8221-1")
_pdu_rmod3 = Gude(addr="10.44.177.47", port_numbers=[12], model="EPC", version="8221-1")
_pdu_rmod4 = Gude(addr="10.44.205.233", port_numbers=[7], model="EPC", version="8221-1")
_pdu_rmod5 = Gude(addr="10.44.205.233", port_numbers=[8], model="EPC", version="8221-1")
_pdu_rmod6 = Gude(addr="10.44.205.233", port_numbers=[9], model="EPC", version="8221-1")
_pdu_rmod7 = Gude(addr="10.44.177.47", port_numbers=[4], model="EPC", version="8221-1")
_pdu_rmod8 = Gude(addr="10.44.177.47", port_numbers=[5], model="EPC", version="8221-1")
_pdus = [_pdu_rmod1, _pdu_rmod2, _pdu_rmod3, _pdu_rmod4, _pdu_rmod5, _pdu_rmod6, _pdu_rmod7, _pdu_rmod8, _pdu_asil]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::5a6f",
        vlan_id=459,
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5a01"),
        v4="10.44.65.249",
        routing_v4=RoutingInformation(gateway="10.44.65.193"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::5b6f", vlan_id=460),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::5c6f", vlan_id=461),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::5d6f", vlan_id=462),
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    serial_number="BL2048G1RCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.135",
        username="root",
        password=""
    ),
    pdu_port=_pdu_rmod1.pdu_ports[10],
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    serial_number="BL2048G1RE7",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.132",
        username="root",
        password=""
    ),
    pdu_port=_pdu_rmod2.pdu_ports[11],
)

_gnb_ru3 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    serial_number="BL2048G1RED",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.132", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod3.pdu_ports[12],
)

_gnb_ru4 = RU(
    ru_hw_group="Unknown",
    radio_type="AHCA",
    serial_number="1M190819375",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod4.pdu_ports[7],
)

_gnb_ru5 = RU(
    ru_hw_group="Unknown",
    radio_type="AHCA",
    serial_number="1M193018865",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod5.pdu_ports[8],
)

_gnb_ru6 = RU(
    ru_hw_group="Unknown",
    radio_type="AHCA",
    serial_number="1M190819362",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod6.pdu_ports[9],
)

_gnb_ru7 = RU(
    ru_hw_group="Unknown",
    radio_type="AHFIC",
    serial_number="DC2014007DM",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.131", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod7.pdu_ports[4],
)

_gnb_ru8 = RU(
    ru_hw_group="Unknown",
    radio_type="AHFIC",
    serial_number="K9200523328",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.133", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod8.pdu_ports[5],
)

_core = RealCore5G(mcc=555, mnc=10)

_abio1_du1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1204104958",
    rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru4, _gnb_ru5, _gnb_ru6, _gnb_ru7]
)

_abio2_du1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    serial_number="L1204104957",
    rus=[_gnb_ru8])

_asil_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_du1, _abio2_du1],
    pdu_port=_pdu_asil.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1203700857",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.80", username="ute", password="ute"
    ),
    connections=[_asil_du1]
)

_airscale_gnb_1 = Airscale(common_units=[_asil_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3, _gnb_ru4, _gnb_ru5, _gnb_ru6, _gnb_ru7,
                                                _gnb_ru8])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50913, instance_id=50913)

_ue_pc_ssh = SshServiceDetails("10.44.72.240", "wro5goam", password="Uteadmin1@")

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="HZQN1876BAKC2300330",
    server_dir="/cygdrive/c/pyro_server/ta_ue_android_plugin/ue",
    python_path="python2",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.45.168.53",
    iperf_path="/opt/iperf/",
)

_appserver_ssh = AppServer(iperf_details=_iperf)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASILL_ABIOB1B2_3xAHLOA",
    core=_core,
    pdus=_pdus,
    ues=[_android_ue],
    appserver=_appserver_ssh,
)

__all__ = ["tl"]
