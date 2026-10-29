__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import (
    CapacityUnit,
    CommonUnit,
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

_common_units_gnb = [
    CommonUnit(
        hardware_type="ASIB",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            port=22,
            password="oZPS0POrRieRtu",
            private_key=None,
            proxy=None,
        ),
        capacity_units=[
            CapacityUnit(
                hardware_type="ABIL",
                addr="192.168.253.20",
                serial_number="L1192713669",
                slot_id=SlotId.B4,
                rus=[],
            )
        ],
        pdu_port=ENICS(
            addr="100.68.226.145", model="ENICS", port_numbers=[10]
        ).pdu_ports[10],
        serial_number="DH201860824",
        slot_id=SlotId.C2,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1,
    )
]
_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.101.55/27",
                v6="2a00:8a00:4000:4a43::2917/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901",
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
                v4="100.68.101.87/27",
                v6="2a00:8a00:4000:4a43::2a17/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            x2u=NetworkAddress(
                v4="100.68.101.55/27",
                v6="2a00:8a00:4000:4a43::2917/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            s1u=NetworkAddress(
                v4="100.68.101.55/27",
                v6="2a00:8a00:4000:4a43::2917/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngu=NetworkAddress(
                v4="100.68.101.55/27",
                v6="2a00:8a00:4000:4a43::2917/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngc=NetworkAddress(
                v4="100.68.101.87/27",
                v6="2a00:8a00:4000:4a43::2a17/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnc=NetworkAddress(
                v4="100.68.101.87/27",
                v6="2a00:8a00:4000:4a43::2a17/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnu=NetworkAddress(
                v4="100.68.101.55/27",
                v6="2a00:8a00:4000:4a43::2917/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.101.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
        ),
        dus=[
            DU(airscale=Airscale(common_units=_common_units_gnb), rus=[], cablinks=[])
        ],
        instance_id=102121,
        global_bts_id=102121,
    )
]


_common_unit_1_enb_pdu_port = ENICS(
    addr="0.0.0.0", model="ENICS", port_numbers=[2]
).pdu_ports[2]

_enb_1_ru_1_pdu_port = ENICS(addr="0.0.0.0", model="ENICS", port_numbers=[9]).pdu_ports[
    9
]

_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="ARMA",
    serial_number="1M242205429",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="474803A.101",
)

_rms_enb = [_enb_1_ru_1]

_cap_1_enb = CapacityUnit(
    hardware_type="ABIA",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    serial_number="L1162615950",
    rus=[_enb_1_ru_1],
)

_cap_units_enb = [_cap_1_enb]

_common_units_enb = [
    CommonUnit(
        hardware_type="ASIA",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            port=22,
            password="oZPS0POrRieRtu",
            private_key=None,
            proxy=None,
        ),
        capacity_units=_cap_units_enb,
        pdu_port=_common_unit_1_enb_pdu_port,
        slot_id=SlotId.C1,
        serial_number="EA194857330",
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF5,
    )
]

_enbs = [
    RealEnb(
        system_module=Airscale(common_units=_common_units_enb),
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
        rms=_rms_enb,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_cap_1_enb, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=1),
            )
        ],
    )
]


_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=None,
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.108.72",
                v6="2a00:8a00:4000:4a22::8086",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=8000,
    ),
)

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.167", username="ute", password="None"
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_common_units_gnb[0])
    ],
)

tl = TestLine(test_pc=_test_vm, velocity=_velocity, gnbs=_gnbs, enbs=_enbs, core=_core)

__all__ = ["tl"]

sync = {"top_server": "10.33.50.2", "top_type": "F"}
