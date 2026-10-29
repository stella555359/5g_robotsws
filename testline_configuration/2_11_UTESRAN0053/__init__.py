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
from taf.config.testline.pdu import ENICS, DELTA
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

_snmp_user = {
    "userName": "user",
    "authKey": "aCoP_!123456",
    "privKey": "PoliCe_!123456",
    "authProtocol": "SHA",
    "privProtocol": "AES",
}

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.144", model="ENICS", port_numbers=[3]
).pdu_ports[3]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIP",
    serial_number="L1240602943",
    product_code="475792A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[],
)

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIM",
        serial_number="L1233304570",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            port=22,
            password="oZPS0POrRieRtu",
            private_key=None,
            proxy=None,
        ),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF3,
    )
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.102", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)

_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.144", model="ENICS", port_numbers=[4]
).pdu_ports[4]

_gnb_2_cap_1 = CapacityUnit(
    hardware_type="ABIP",
    serial_number="L1240602944",
    product_code="475792A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[],
)

_gnb_2_cap_units = [_gnb_2_cap_1]

_gnb_2_common_units = [
    CommonUnit(
        hardware_type="ASIM",
        serial_number="L1233302521",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119",
            username="toor4nsn",
            port=22,
            password="oZPS0POrRieRtu",
            private_key=None,
            proxy=None,
        ),
        capacity_units=_gnb_2_cap_units,
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF3,
    )
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.103", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_2_common_units[0]
        )
    ],
)

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.101.36/27",
                v6="2a00:8a00:4000:4a43::2904/120",
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
                v4="100.68.101.68/27",
                v6="2a00:8a00:4000:4a43::2a04/120",
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
                v4="100.68.101.36/27",
                v6="2a00:8a00:4000:4a43::2904/120",
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
                v4="100.68.101.36/27",
                v6="2a00:8a00:4000:4a43::2904/120",
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
                v4="100.68.101.36/27",
                v6="2a00:8a00:4000:4a43::2904/120",
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
                v4="100.68.101.68/27",
                v6="2a00:8a00:4000:4a43::2a04/120",
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
                v4="100.68.101.68/27",
                v6="2a00:8a00:4000:4a43::2a04/120",
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
                v4="100.68.101.36/27",
                v6="2a00:8a00:4000:4a43::2904/120",
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
                    common_units=_gnb_1_common_units, product_code="475765A.104"
                ),
                rus=[],
                cablinks=[],
            )
        ],
        instance_id=102102,
        global_bts_id=102102,
    ),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.101.37/27",
                v6="2a00:8a00:4000:4a43::2905/120",
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
                v4="100.68.101.69/27",
                v6="2a00:8a00:4000:4a43::2a05/120",
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
                v4="100.68.101.37/27",
                v6="2a00:8a00:4000:4a43::2905/120",
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
                v4="100.68.101.37/27",
                v6="2a00:8a00:4000:4a43::2905/120",
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
                v4="100.68.101.37/27",
                v6="2a00:8a00:4000:4a43::2905/120",
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
                v4="100.68.101.69/27",
                v6="2a00:8a00:4000:4a43::2a05/120",
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
                v4="100.68.101.69/27",
                v6="2a00:8a00:4000:4a43::2a05/120",
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
                v4="100.68.101.37/27",
                v6="2a00:8a00:4000:4a43::2905/120",
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
                    common_units=_gnb_2_common_units, product_code="475765A.104"
                ),
                rus=[],
                cablinks=[],
            )
        ],
        instance_id=102103,
        global_bts_id=102103,
    ),
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
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=7926,
    ),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2],
    velocity=_velocity,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
)

__all__ = ["tl"]

sync = {"top_server": "10.33.50.2", "top_type": "F"}
