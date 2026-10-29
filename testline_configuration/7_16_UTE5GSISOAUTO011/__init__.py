__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "Filip Pawlowski"
__email__ = "filip.pawlowski@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb, Leoni, NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.signal_analyzer import KeysightN9935A

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.206",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::2919", vlan_id=370),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::2919", vlan_id=370),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::2919", vlan_id=370),
)

_pdu_gnb = Gude(addr="10.44.205.26", port_numbers=[9], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(addr="10.44.205.28", port_numbers=[6], model="EPC", version="8221-1")
_pdu_gnb_ru_2 = Gude(addr="10.44.205.28", port_numbers=[8], model="EPC", version="8221-1")
_pdu_gnb_ru_3 = Gude(addr="10.44.205.80", port_numbers=[1], model="EPC", version="8221-1")
_pdu_enb = Gude(addr="10.44.205.26", port_numbers=[10], model="EPC", version="8221-1")
_pdu_enb_ru = Gude(addr="10.44.205.57", port_numbers=[10], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AREA",
    serial_number="L1190702771",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHGB",
    serial_number="EA183590002",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[8],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHHB",
    serial_number="DH223843312",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru_3.pdu_ports[1],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
)

_abio_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    rus=[_ru_1],
    hardware_version="A101",
    serial_number="L1204108964",
)

_abip_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    rus=[_ru_2, _ru_3],
    hardware_version="A102",
    serial_number="L1224710393",
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_loner, _abip_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1204202780",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.127", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3])

_enb_ru = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHED",
    serial_number="6Q175121166",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_enb_ru.pdu_ports[10],
)

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A103",
    serial_number="L1173619779",
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="A203",
    serial_number="DH192355425",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50176
)

_core = RealCore5G()

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::291a", vlan_id=370),
    global_bts_id=40176,
    instance_id=40176,
    oam_ip=NetworkAddress(v4="10.44.67.236", vlan_id=370),
    rms=[_enb_ru],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.245", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AREA_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru_2, _pdu_gnb_ru_3, _pdu_enb, _pdu_enb_ru],
)
