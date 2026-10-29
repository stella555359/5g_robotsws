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
    addr=NetworkAddress(v4="velocity.linnanmaa.dyn.nesc.nokia.net", v6="None")
)

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.164", model="ENICS", port_numbers=[8]
).pdu_ports[8]

_gnb_1_rms = []

_gnb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    serial_number="L1201402367",
    slot_id=SlotId.B4,
)

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        serial_number="L1190416397",
        capacity_units=_gnb_1_cap_units,
        hardware_type="ASIK",
        slot_id=SlotId.C2,
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.180", username="ute", password="None"
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
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1162615950",
    product_code="473096A.102",
    slot_id=SlotId.B1,
    rus=[_enb_1_ru_1],
)

_enb_1_cap_units = [_enb_1_cap_1]

_enb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        pdu_port=_enb_1_common_unit_1_pdu_port,
        capacity_units=_enb_1_cap_units,
        serial_number="EA194857330",
        hardware_type="ASIA",
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF5,
    )
]

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.97.169/27",
                v6="2a00:8a00:4000:4a43::d09/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::d01"),
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
                v4="100.68.97.201/27",
                v6="2a00:8a00:4000:4a43::e09/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.193"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::e01"),
            ),
            x2u=NetworkAddress(
                v4="100.68.97.169/27",
                v6="2a00:8a00:4000:4a43::d09/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::d01"),
            ),
            s1u=NetworkAddress(
                v4="100.68.97.169/27",
                v6="2a00:8a00:4000:4a43::d09/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::d01"),
            ),
            ngu=NetworkAddress(
                v4="100.68.97.169/27",
                v6="2a00:8a00:4000:4a43::d09/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::d01"),
            ),
            ngc=NetworkAddress(
                v4="100.68.97.201/27",
                v6="2a00:8a00:4000:4a43::e09/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.193"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::e01"),
            ),
            xnc=NetworkAddress(
                v4="100.68.97.201/27",
                v6="2a00:8a00:4000:4a43::e09/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.97.193"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::e01"),
            ),
            xnu=NetworkAddress(
                v4="100.68.97.169/27",
                v6="2a00:8a00:4000:4a43::d09/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.97.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::d01"),
            ),
        ),
        dus=[
            DU(
                airscale=Airscale(common_units=_gnb_1_common_units),
                rus=_gnb_1_rms,
                cablinks=[],
            )
        ],
        instance_id=100507,
        global_bts_id=100507,
    ),
]

_enbs = [
    RealEnb(
        system_module=Airscale(common_units=_enb_1_common_units),
        instance_id=101822,
        global_bts_id=101822,
        oam_ip=NetworkAddress(
            v4="10.33.181.26/24",
            v6="2a00:8a00:4000:4a80::411a/120",
            routing_v4=RoutingInformation(gateway="10.33.181.65"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a80::4201"),
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
            n2=NetworkAddress(v4="10.35.18.70", v6="2a00:8a00:4000:4a22::2:1146"),
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

sync = {
    "top_server": "10.33.50.2",
    "top_type": "F",
}
