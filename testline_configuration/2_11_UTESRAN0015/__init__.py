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


# PDUs
_pdu_1 = ENICS(addr="100.68.226.171", model="ENICS", port_numbers=[3, 4])
_pdu_2 = ENICS(addr="100.68.226.78", model="ENICS", port_numbers=[5, 6, 7])
_pdu_3 = ENICS(addr="100.68.226.83", model="ENICS", port_numbers=[2, 4, 6, 7, 8, 9])

# Radio units
_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    pdu_port=_pdu_2.pdu_ports[5],
    serial_number="BL2135V0JYY",
)
_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    pdu_port=_pdu_2.pdu_ports[6],
    serial_number="BL2108V054R",
)
_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    pdu_port=_pdu_2.pdu_ports[7],
    serial_number="K9183140928",
)
_ru_4 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    pdu_port=_pdu_3.pdu_ports[7],
    serial_number="1M193000187",
)
_ru_5 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    pdu_port=_pdu_3.pdu_ports[8],
    serial_number="AS212914909",
)
_ru_6 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    pdu_port=_pdu_3.pdu_ports[9],
    serial_number="AS212914915",
)
_ru_7 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    pdu_port=_pdu_3.pdu_ports[2],
    serial_number="DH224501211",
)
_ru_8 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    pdu_port=_pdu_3.pdu_ports[4],
    serial_number="DH224501233",
)
_ru_9 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    pdu_port=_pdu_3.pdu_ports[6],
    serial_number="DH224306233",
)

# 5G side #

_rus_gnb = [_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9]

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="100.68.99.49/27",
        v6="2a00:8a00:4000:4a43::1911/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.33"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1901"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(
        v4="100.68.99.81/27",
        v6="2a00:8a00:4000:4a43::a11/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.65"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::a01"),
    ),
    x2u=NetworkAddress(
        v4="100.68.99.49/27",
        v6="2a00:8a00:4000:4a43::1911/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.33"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1901"),
    ),
    s1u=NetworkAddress(
        v4="100.68.99.49/27",
        v6="2a00:8a00:4000:4a43::1911/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.33"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1901"),
    ),
    ngu=NetworkAddress(
        v4="100.68.99.49/27",
        v6="2a00:8a00:4000:4a43::1911/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.33"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1901"),
    ),
    ngc=NetworkAddress(
        v4="100.68.99.81/27",
        v6="2a00:8a00:4000:4a43::a11/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.65"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::a01"),
    ),
    xnc=NetworkAddress(
        v4="100.68.99.81/27",
        v6="2a00:8a00:4000:4a43::a11/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.65"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::a01"),
    ),
    xnu=NetworkAddress(
        v4="100.68.99.49/27",
        v6="2a00:8a00:4000:4a43::1911/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.33"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1901"),
    ),
)

_abio_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
    slot_id=SlotId.B4,
    serial_number="DH221042184",
    product_code="475266A.103",
)
_abio_2 = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIO", rus=[_ru_7, _ru_8, _ru_9], slot_id=SlotId.B5, serial_number="L1214402851", product_code="475266A.103",
)

_common_unit_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abio_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    slot_id=SlotId.C2,
    trs_connections=TRSInterfaces.EIF1,
    serial_number="DH220640095",
)

_airscale_gnb = Airscale([_common_unit_gnb], product_code="474767A.101")

_du_gnb = DU(
    airscale=_airscale_gnb,
    rus=_rus_gnb,
)

_gnb = ClassicalBts(dus=[_du_gnb], cu=_cu_gnb, global_bts_id=100815)

gnb_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.58", username="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_common_unit_gnb, interface_type="lmp")
    ],
)

# 4G side #
_rus_shared = [_ru_1, _ru_2, _ru_3]

_abia = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA", rus=_rus_shared, serial_number="L1183612436")

_enb = RealEnb(
    system_module=Airscale(
        common_units=[
            CommonUnit(
                hardware_type="ASIA",
                lmp_connection=SshServiceDetails(
                    addr="192.168.255.129",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu",
                ),
                capacity_units=[_abia],
                slot_id=SlotId("C1"),
                pdu_port=_pdu_1.pdu_ports[3],
                trs_connections=TRSInterfaces.EIF1,
                serial_number="AH183904976",
            )
        ]
    ),
    global_bts_id=100814,
    oam_ip=NetworkAddress(
        v4="100.68.99.16/27",
        v6="2a00:8a00:4000:4a43::1810/120",
        routing_v4=RoutingInformation(gateway="100.68.99.1", destIpAddr=None),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:4000:4a43::1801",
            destIpAddr=None,
        ),
    ),
    rms=[_ru_1, _ru_2, _ru_3],
)

enb_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.57", username="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_enb.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=gnb_vm,
    test_pcs=[gnb_vm, enb_vm],
    gnbs=[_gnb],
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_2xABIO_3xAHCA_3xAEQK_3xAHFIB_RFS",
)

__all__ = ["tl"]
