__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import CapacityUnit, CommonUnit, CoreUnit, Airscale, SlotId, TRSInterfaces
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
from taf.config.testline.pdu import ENICS, DELTA
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME, RealCore5GDetails, AMF
from taf.config.testline.flexi import Flexi

_snmp = {
    "userName": "user",
    "authKey": "aCoP_!123456",
    "privKey": "PoliCe_!123456",
    "authProtocol": "SHA",
    "privProtocol": "AES",
}

_velocity = Velocity(
    addr=NetworkAddress(v4="velocity.linnanmaa.dyn.nesc.nokia.net"))

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.162", model="ENICS", port_numbers=[3]).pdu_ports[3]

_gnb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1233203344",
    product_code="475792A.102",
    slot_id=SlotId.B1,
    rus=[])

_gnb_1_cap_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="DH251255353",
    product_code="457266B.102",
    slot_id=SlotId.B2,
    rus=[])

_gnb_1_cap_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="DH251255236",
    product_code="475266B.102",
    slot_id=SlotId.B3,
    rus=[])

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2, _gnb_1_cap_3]

_gnb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        capacity_units=_gnb_1_cap_units,
        hardware_type="ASIL",
        serial_number="L1235102189",
        slot_id=SlotId.C1,
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.197.145", username="ute", password=None),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_1_common_units[0])
    ])
_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.162", model="ENICS", port_numbers=[4]).pdu_ports[4]

_gnb_2_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="DH251255212",
    product_code="475266B.102",
    slot_id=SlotId.B4,
    rus=[])

_gnb_2_cap_units = [_gnb_2_cap_1]

_gnb_2_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        capacity_units=_gnb_2_cap_units,
        hardware_type="ASIL",
        serial_number="L1235105124",
        slot_id=SlotId.C2,
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.197.146", username="ute", password=None),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_2_common_units[0])
    ])
_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.162", model="ENICS", port_numbers=[1]).pdu_ports[1]

_enb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1213104432",
    product_code="473096A.107",
    slot_id=SlotId.B1,
    rus=[])

_enb_1_cap_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1164416876",
    product_code="473096A.102",
    slot_id=SlotId.B2,
    rus=[])

_enb_1_cap_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="EA194352846",
    product_code="473096A.104",
    slot_id=SlotId.B3,
    rus=[])

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2, _enb_1_cap_3]

_enb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_enb_1_common_unit_1_pdu_port,
        capacity_units=_enb_1_cap_units,
        hardware_type="ASIA",
        serial_number="EA194857427",
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.197.142", username="ute", password=None),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_1_common_units[0])
    ])

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.97.36/27",
                v6="2a00:8a00:4000:4a43::904/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
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
                v4="100.68.97.68/27",
                v6="2a00:8a00:4000:4a43::a04/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01")),
            x2u=NetworkAddress(
                v4="100.68.97.36/27",
                v6="2a00:8a00:4000:4a43::904/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
            s1u=NetworkAddress(
                v4="100.68.97.36/27",
                v6="2a00:8a00:4000:4a43::904/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
            ngu=NetworkAddress(
                v4="100.68.97.36/27",
                v6="2a00:8a00:4000:4a43::904/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
            ngc=NetworkAddress(
                v4="100.68.97.68/27",
                v6="2a00:8a00:4000:4a43::a04/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01")),
            xnc=NetworkAddress(
                v4="100.68.97.68/27",
                v6="2a00:8a00:4000:4a43::a04/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01")),
            xnu=NetworkAddress(
                v4="100.68.97.36/27",
                v6="2a00:8a00:4000:4a43::904/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_1_common_units, product_code="474767A.103"),
               rus=None,)
        ],
        instance_id=100452,
        global_bts_id=100452),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.97.37/27",
                v6="2a00:8a00:4000:4a43::905/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
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
                v4="100.68.97.69/27",
                v6="2a00:8a00:4000:4a43::a05/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01")),
            x2u=NetworkAddress(
                v4="100.68.97.37/27",
                v6="2a00:8a00:4000:4a43::905/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
            s1u=NetworkAddress(
                v4="100.68.97.37/27",
                v6="2a00:8a00:4000:4a43::905/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
            ngu=NetworkAddress(
                v4="100.68.97.37/27",
                v6="2a00:8a00:4000:4a43::905/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
            ngc=NetworkAddress(
                v4="100.68.97.69/27",
                v6="2a00:8a00:4000:4a43::a05/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01")),
            xnc=NetworkAddress(
                v4="100.68.97.69/27",
                v6="2a00:8a00:4000:4a43::a05/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01")),
            xnu=NetworkAddress(
                v4="100.68.97.37/27",
                v6="2a00:8a00:4000:4a43::905/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::901")),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_2_common_units, product_code="474767A.103"),
               rus=None,
               cablinks=[])
        ],
        instance_id=100453,
        global_bts_id=100453),
]

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473095A.204"),
        instance_id=100450,
        global_bts_id=100450,
        oam_ip=NetworkAddress(
            v4="100.68.97.2/27",
            v6="2a00:8a00:4000:4a43::802/120",
            routing_v4=RoutingInformation(gateway="100.68.97.1"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::801")),
        rms=None,
        cablinks=[]),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None),
            s1=NetworkAddress(
                v4="10.35.18.8", v6="2a00:8a00:4000:4a22::2:1108")),
        tac=7000,
        ntp=NetworkAddress(v4="100.68.254.130")),
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70", v6="2a00:8a00:4000:4a22::2:1146")),
        tac=7000),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2, _test_vm_enb_1],
    velocity=_velocity,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = {
    "top_server": "10.33.50.2",
    "top_type": "F",
}
