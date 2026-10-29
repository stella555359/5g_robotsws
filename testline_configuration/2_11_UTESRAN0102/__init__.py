__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import (
    CapacityUnit,
    CommonUnit,
    CoreUnit,
    Airscale,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import (
    RealCore,
    RealCore4GDetails,
    MME,
    RealCore5GDetails,
    AMF,
)
from taf.config.testline.flexi import Flexi

_velocity = Velocity(
    addr=NetworkAddress(
        v4="velocity.linnanmaa.dyn.nesc.nokia.net",
        v6="None",
        vlan_id=None,
        routing_v4=None,
        routing_v6=None,
    )
)

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[12]
).pdu_ports[12]

_gnb_1_rms = []

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="DH201062203",
    product_code="474020A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[],
)

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIB",
        serial_number="DH214144483",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.230", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)
_enb_1_common_unit_1_pdu_port = ENICS(
    addr="0.0.0.0", model="ENICS", port_numbers=[2]
).pdu_ports[2]

_enb_1_ru_1_pdu_port = ENICS(addr="0.0.0.0", model="ENICS", port_numbers=[8]).pdu_ports[
    8
]

_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="ARMA",
    serial_number="1M242205429",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="474803A.101",
)

_enb_1_rms = [_enb_1_ru_1]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1162615950",
    product_code="None",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[_enb_1_ru_1],
)

_enb_1_cap_units = [_enb_1_cap_1]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIA",
        serial_number="EA194857330",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF5,
    )
]

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.45/27",
                v6="2a00:8a00:4000:4a43::110d/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            oam_ssh_connection_details=SshServiceDetails(
                addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            oam_http_connection_details=HttpConnectionDetails(
                addr="192.168.255.129",
                username="Nemuadmin",
                password="nemuuser",
                port=443,
            ),
            x2c=NetworkAddress(
                v4="100.68.98.77/27",
                v6="2a00:8a00:4000:4a43::120d/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            x2u=NetworkAddress(
                v4="100.68.98.45/27",
                v6="2a00:8a00:4000:4a43::110d/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            s1u=NetworkAddress(
                v4="100.68.98.45/27",
                v6="2a00:8a00:4000:4a43::110d/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngu=NetworkAddress(
                v4="100.68.98.45/27",
                v6="2a00:8a00:4000:4a43::110d/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngc=NetworkAddress(
                v4="100.68.98.77/27",
                v6="2a00:8a00:4000:4a43::120d/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnc=NetworkAddress(
                v4="100.68.98.77/27",
                v6="2a00:8a00:4000:4a43::120d/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnu=NetworkAddress(
                v4="100.68.98.45/27",
                v6="2a00:8a00:4000:4a43::110d/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
        ),
        dus=[
            DU(
                airscale=Airscale(
                    common_units=_gnb_1_common_units, product_code="None"
                ),
                rus=_gnb_1_rms,
                cablinks=[],
            )
        ],
        instance_id=101811,
        global_bts_id=101811,
    ),
]

_enbs = [
    RealEnb(
        system_module=Airscale(common_units=_enb_1_common_units, product_code="None"),
        instance_id=101822,
        global_bts_id=101822,
        oam_ip=NetworkAddress(
            v4="10.33.181.28/24",
            v6="2a00:8a00:4000:4a80::411c/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway="10.33.181.65", ip_prefix_length=None, destIpAddr=None
            ),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a80::4201",
                ip_prefix_length=None,
                destIpAddr=None,
            ),
        ),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=1),
            )
        ],
    ),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=None,
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=7000,
    ),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1],
    velocity=_velocity,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
)

__all__ = ["tl"]

sync = None
