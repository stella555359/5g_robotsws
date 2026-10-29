__maintainer__ = "Marta Koc"
__team__ = "I_5G_SISO_CRT_GMS"
__email__ = "marta.koc@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.signal_analyzer import KeysightN9935A

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.222",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2939", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2939", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2939", vlan_id=401),
)

_pdu_enb = Gude(addr="10.44.205.37", port_numbers=[6], model="EPC", version="8221-1")
_pdu_gnb = Gude(addr="10.44.205.37", port_numbers=[5], model="EPC", version="8221-1")
_pdu_gnb_ru_1 = Gude(
    addr="10.44.205.80", port_numbers=[5], model="EPC", version="8221-1"
)
_pdu_gnb_ru_2 = Gude(
    addr="10.44.205.80", port_numbers=[6], model="EPC", version="8221-1"
)
_pdu_enb_ru = Gude(addr="10.44.205.28", port_numbers=[3], model="EPC", version="8221-1")

_ru1 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="L1211203210",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.154", username="rfsw", password="bdS%ztWG3v7%SjreCVA79wTPb"
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
)

_ru2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPE",
    serial_number="1M222814880",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="rfsw", password=""
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[6],
)
_ru_enb = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="AS193612029",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="rfsw", password=""
    ),
    pdu_port=_pdu_enb_ru.pdu_ports[3],
)
_abil1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    serial_number="L1205102674",
    rus=[_ru1, _ru2],
)

_asik_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1],
    pdu_port=_pdu_gnb.pdu_ports[5],
    hardware_type="ASIB",
    serial_number="DH203064574",
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.215", username="ute", password="ute"
    ),
    connections=[_asik_gnb],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru1, _ru2])

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="K9171936954",
    rus=[_ru_enb],
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    pdu_port=_pdu_enb.pdu_ports[6],
    serial_number="DH192354895",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50536
)

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::2917", vlan_id=401),
    global_bts_id=40131,
    instance_id=40131,
    oam_ip=NetworkAddress(v4="10.44.67.235"),
    rms=[_ru_enb],
)

_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.216", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_enb_1.u_plane = NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2904")
_enb_1.c_plane = NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2904")

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb, _lmp_vm_enb],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_enb, _pdu_enb_ru],
)
