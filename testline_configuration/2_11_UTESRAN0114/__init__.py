__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import CapacityUnit, CommonUnit, CoreUnit, Airscale, SlotId, TRSInterfaces
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME, RealCore5GDetails, AMF
from taf.config.testline.flexi import Flexi

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[8]).pdu_ports[8]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.46", model="ENICS", port_numbers=[4]).pdu_ports[4]

_gnb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.46", model="ENICS", port_numbers=[5]).pdu_ports[5]

_gnb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.46", model="ENICS", port_numbers=[6]).pdu_ports[6]

_gnb_1_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AVHA",
    serial_number="L1260402248",
    pdu_port=_gnb_1_ru_1_pdu_port,
    product_code="476542A.101")

_gnb_1_ru_2 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AVHA",
    serial_number="L1260402251",
    pdu_port=_gnb_1_ru_2_pdu_port,
    product_code="476542A.101")

_gnb_1_ru_3 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AVHA",
    serial_number="L1260402250",
    pdu_port=_gnb_1_ru_3_pdu_port,
    product_code="476268A.101")

_gnb_1_rms = [_gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3]

_gnb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1254860450",
    product_code="475792A.102",
    slot_id=SlotId.B4,
    rus=[_gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3])

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        capacity_units=_gnb_1_cap_units,
        hardware_type="ASIM",
        serial_number="L1233302566",
        slot_id=SlotId.C2,
        trs_connections=TRSInterfaces.EIF3)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.225", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_1_common_units[0])
    ])

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.41/27",
                v6="2a00:8a00:4000:4a43::1109/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101")),
            oam_ssh_connection_details=SshServiceDetails(
                addr="192.168.255.129",
                username="toor4nsn",
                password="oZPS0POrRieRtu"),
            oam_http_connection_details=HttpConnectionDetails(
                addr="192.168.255.129",
                username="Nemuadmin",
                password="nemuuser",
                port=443),
            x2c=NetworkAddress(
                v4="100.68.98.73/27",
                v6="2a00:8a00:4000:4a43::1209/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201")),
            x2u=NetworkAddress(
                v4="100.68.98.41/27",
                v6="2a00:8a00:4000:4a43::1109/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101")),
            s1u=NetworkAddress(
                v4="100.68.98.41/27",
                v6="2a00:8a00:4000:4a43::1109/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101")),
            ngu=NetworkAddress(
                v4="100.68.98.41/27",
                v6="2a00:8a00:4000:4a43::1109/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101")),
            ngc=NetworkAddress(
                v4="100.68.98.73/27",
                v6="2a00:8a00:4000:4a43::1209/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201")),
            xnc=NetworkAddress(
                v4="100.68.98.73/27",
                v6="2a00:8a00:4000:4a43::1209/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201")),
            xnu=NetworkAddress(
                v4="100.68.98.41/27",
                v6="2a00:8a00:4000:4a43::1109/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101")),
        ),
        dus=[
            DU(airscale=Airscale(
               common_units=_gnb_1_common_units, product_code="475765A.104"),
               rus=_gnb_1_rms,
               cablinks=[
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_1, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_2, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=3),
                       target=Endpoint(
                           unit=_gnb_1_ru_3, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=4),
                       target=Endpoint(
                           unit=_gnb_1_ru_1, label="SFP", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=5),
                       target=Endpoint(
                           unit=_gnb_1_ru_2, label="SFP", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=6),
                       target=Endpoint(
                           unit=_gnb_1_ru_3, label="SFP", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=7),
                       target=Endpoint(
                           unit=_gnb_1_ru_1, label="SFP", port_id=3)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=8),
                       target=Endpoint(
                           unit=_gnb_1_ru_2, label="SFP", port_id=3)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=9),
                       target=Endpoint(
                           unit=_gnb_1_ru_3, label="SFP", port_id=3)),
               ])
        ],
        instance_id=101807,
        global_bts_id=101807),
]

_enbs = []

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=None,
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70", v6="2a00:8a00:4000:4a22::2:1146")),
        tac=7926),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = None
