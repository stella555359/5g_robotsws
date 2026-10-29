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
    addr="100.68.226.145", model="ENICS", port_numbers=[8]
).pdu_ports[8]

_gnb_1_rms = []

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1223103575",
    product_code="475266A.104",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[],
)

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1233608822",
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
        addr="100.68.193.165", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)
_enb_1_common_unit_1_pdu_port = ENICS(
    addr="0.0.0.0", model="ENICS", port_numbers=[11]
).pdu_ports[11]

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

_enb_1_rms = [_enb_1_ru_1]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1162615950",
    product_code="473096A.102",
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
        trs_connections=TRSInterfaces.EIF1,
    )
]

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.101.53/27",
                v6="2a00:8a00:4000:4a43::2915/120",
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
                v4="100.68.101.85/27",
                v6="2a00:8a00:4000:4a43::2a15/120",
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
                v4="100.68.101.53/27",
                v6="2a00:8a00:4000:4a43::2915/120",
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
                v4="100.68.101.53/27",
                v6="2a00:8a00:4000:4a43::2915/120",
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
                v4="100.68.101.53/27",
                v6="2a00:8a00:4000:4a43::2915/120",
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
                v4="100.68.101.85/27",
                v6="2a00:8a00:4000:4a43::2a15/120",
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
                v4="100.68.101.85/27",
                v6="2a00:8a00:4000:4a43::2a15/120",
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
                v4="100.68.101.53/27",
                v6="2a00:8a00:4000:4a43::2915/120",
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
            DU(
                airscale=Airscale(
                    common_units=_gnb_1_common_units, product_code="474767A.103"
                ),
                rus=_gnb_1_rms,
                cablinks=[],
            )
        ],
        instance_id=102119,
        global_bts_id=102119,
    ),
]

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473095A.204"
        ),
        instance_id=101822,
        global_bts_id=101822,
        oam_ip=NetworkAddress(
            v4="100.68.98.24/27",
            v6="2a00:8a00:4000:4a43::1018/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway="100.68.98.1", ip_prefix_length=None, destIpAddr=None
            ),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1001",
                ip_prefix_length=None,
                destIpAddr=None,
            ),
        ),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="RF1", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="OPT1", port_id=1),
            )
        ],
    ),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None
            ),
            s1=NetworkAddress(
                v4="10.35.18.8",
                v6="2a00:8a00:4000:4a22::2:1108",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=7000,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6=None,
            vlan_id=None,
            routing_v4=None,
            routing_v6=None,
        ),
    ),
    five_g=None,
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

sync = {
    "top_server": "10.33.50.2",
    "top_type": "F",
}
