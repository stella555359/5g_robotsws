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

_gnb_1_core_unit_1_pdu_port = ENICS(
    addr="100.68.226.175", model="ENICS", port_numbers=[11]
).pdu_ports[11]

_gnb_1_rms = []

_gnb_1_core_unit = CoreUnit(
    hardware_type="ASOE",
    serial_number="DH245018258",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        port=22,
        password="oZPS0POrRieRtu",
        private_key=None,
        proxy=None,
    ),
    pdu_port=_gnb_1_core_unit_1_pdu_port,
    sync_input=None,
    trs_connections=None,
    rus=[],
)

_gnb_1_core_units = [_gnb_1_core_unit]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.197.99", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_gnb_1_core_units[0])
    ],
)

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.100.56/27",
                v6="2a00:8a00:4000:4a43::2118/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2101",
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
                v4="100.68.100.88/27",
                v6="2a00:8a00:4000:4a43::2218/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            x2u=NetworkAddress(
                v4="100.68.100.56/27",
                v6="2a00:8a00:4000:4a43::2118/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            s1u=NetworkAddress(
                v4="100.68.100.56/27",
                v6="2a00:8a00:4000:4a43::2118/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngu=NetworkAddress(
                v4="100.68.100.56/27",
                v6="2a00:8a00:4000:4a43::2118/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngc=NetworkAddress(
                v4="100.68.100.88/27",
                v6="2a00:8a00:4000:4a43::2218/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnc=NetworkAddress(
                v4="100.68.100.88/27",
                v6="2a00:8a00:4000:4a43::2218/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnu=NetworkAddress(
                v4="100.68.100.56/27",
                v6="2a00:8a00:4000:4a43::2118/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.100.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
        ),
        dus=[
            DU(
                airscale=Airscale(
                    core_units=_gnb_1_core_units, product_code="475587A.103"
                ),
                rus=_gnb_1_rms,
                cablinks=[],
            )
        ],
        instance_id=101572,
        global_bts_id=101572,
    ),
]

_enbs = []

_core = RealCore(
    mcc="244",
    mnc="9",
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
        tac=8000,
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
