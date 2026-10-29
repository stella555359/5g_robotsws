__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import RU
from taf.config.testline.airscale import (
    Airscale,
    CommonUnit,
    CapacityUnit,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[2]
).pdu_ports[2]

_gnb_1_ru_1_shared_pdu_port = ENICS(
    addr="100.68.226.34", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[4]

_gnb_1_ru_2_shared_pdu_port = ENICS(
    addr="100.68.226.34", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[5]

_gnb_1_ru_3_shared_pdu_port = ENICS(
    addr="100.68.226.34", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[6]

_gnb_1_ru_4_shared_pdu_port = ENICS(
    addr="100.68.226.18", port_numbers=[11]).pdu_ports[11]

_gnb_1_ru_5_shared_pdu_port = ENICS(
    addr="100.68.226.18", port_numbers=[12]).pdu_ports[12]

_gnb_1_ru_6_shared_pdu_port = ENICS(
    addr="100.68.226.18", port_numbers=[10]).pdu_ports[10]

_gnb_1_ru_7_pdu_port = ENICS(
    addr="100.68.226.34", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[1]

_gnb_1_ru_8_pdu_port = ENICS(
    addr="100.68.226.34", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[2]

_gnb_1_ru_9_pdu_port = ENICS(
    addr="100.68.226.34", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[3]

_gnb_1_ru_1_shared = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2238V09RR",
    pdu_port=_gnb_1_ru_1_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_2_shared = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2032V0IHH",
    pdu_port=_gnb_1_ru_2_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_3_shared = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2032V0HOM",
    pdu_port=_gnb_1_ru_3_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_4 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    serial_number="L1174908887",
    pdu_port=_gnb_1_ru_4_shared_pdu_port,
    product_code="473966A.101",
)

_gnb_1_ru_5 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    serial_number="1M193000142",
    pdu_port=_gnb_1_ru_5_shared_pdu_port,
    product_code="473966B.101",
)

_gnb_1_ru_6 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    serial_number="AS201400002",
    pdu_port=_gnb_1_ru_6_shared_pdu_port,
    product_code="473966A.101",
)

_gnb_1_ru_7 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="DH224306198",
    pdu_port=_gnb_1_ru_7_pdu_port,
    product_code="475589A.101",
)

_gnb_1_ru_8 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="DH224306281",
    pdu_port=_gnb_1_ru_8_pdu_port,
    product_code="475589A.101",
)

_gnb_1_ru_9 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="DH213800780",
    pdu_port=_gnb_1_ru_9_pdu_port,
    product_code="475589A.101",
)

_gnb_1_rms = [
    _gnb_1_ru_1_shared,
    _gnb_1_ru_2_shared,
    _gnb_1_ru_3_shared,
    _gnb_1_ru_4,
    _gnb_1_ru_5,
    _gnb_1_ru_6,
    _gnb_1_ru_7,
    _gnb_1_ru_8,
    _gnb_1_ru_9,
]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1214606486",
    product_code="475266A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[
        _gnb_1_ru_1_shared,
        _gnb_1_ru_2_shared,
        _gnb_1_ru_3_shared,
        _gnb_1_ru_4,
        _gnb_1_ru_5,
        _gnb_1_ru_6,
    ],
)

_gnb_1_cap_2 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1220208414",
    product_code="475266A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B5,
    rus=[_gnb_1_ru_7, _gnb_1_ru_8, _gnb_1_ru_9],
)

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="DH223348534",
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
        addr="100.68.192.218", username="ute", password=None
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)
_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[1]
).pdu_ports[1]

_enb_1_rms = [_gnb_1_ru_1_shared, _gnb_1_ru_2_shared, _gnb_1_ru_3_shared]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1214503084",
    product_code="473096A.107",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[_gnb_1_ru_1_shared, _gnb_1_ru_2_shared, _gnb_1_ru_3_shared],
)

_enb_1_cap_units = [_enb_1_cap_1]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIA",
        serial_number="L1171806840",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.217", username="ute", password=None
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_enb_1_common_units[0]
        )
    ],
)

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.35/27",
                v6="2a00:8a00:4000:4a43::1103/120",
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
                v4="100.68.98.67/27",
                v6="2a00:8a00:4000:4a43::1203/120",
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
                v4="100.68.98.35/27",
                v6="2a00:8a00:4000:4a43::1103/120",
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
                v4="100.68.98.35/27",
                v6="2a00:8a00:4000:4a43::1103/120",
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
                v4="100.68.98.35/27",
                v6="2a00:8a00:4000:4a43::1103/120",
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
                v4="100.68.98.67/27",
                v6="2a00:8a00:4000:4a43::1203/120",
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
                v4="100.68.98.67/27",
                v6="2a00:8a00:4000:4a43::1203/120",
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
                v4="100.68.98.35/27",
                v6="2a00:8a00:4000:4a43::1103/120",
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
                    common_units=_gnb_1_common_units, product_code="474767A.103"
                ),
                rus=_gnb_1_rms,
            )
        ],
        instance_id=101801,
        global_bts_id=101801,
    )
]

_enbs = [
    RealEnb(
        system_module=Airscale(common_units=_enb_1_common_units, product_code="None"),
        instance_id=101800,
        global_bts_id=101800,
        oam_ip=NetworkAddress(
            v4="100.68.98.2/27",
            v6="2a00:8a00:4000:4a43::1002/120",
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
    )
]

tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_2xABIO_3xAHCA_3xAEQK_3xAHFIB_RFS",
)

__all__ = ["tl"]

sync = None
