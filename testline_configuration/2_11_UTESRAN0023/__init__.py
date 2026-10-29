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
    addr="100.68.226.168", model="ENICS", port_numbers=[3]).pdu_ports[3]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.22", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                    6]).pdu_ports[1]

_gnb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.22", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                    6]).pdu_ports[2]

_gnb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.22", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                    6]).pdu_ports[3]

_gnb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.22", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                    6]).pdu_ports[4]

_gnb_1_ru_5_pdu_port = ENICS(
    addr="100.68.226.22", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                    6]).pdu_ports[5]

_gnb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.22", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                    6]).pdu_ports[6]

_gnb_1_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    serial_number="EA224157060",
    pdu_port=_gnb_1_ru_1_pdu_port,
    product_code="474253A.101",
)

_gnb_1_ru_2 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    serial_number="EA224157046",
    pdu_port=_gnb_1_ru_2_pdu_port,
    product_code="474253A.101",
)

_gnb_1_ru_3 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    serial_number="EA224157041",
    pdu_port=_gnb_1_ru_3_pdu_port,
    product_code="474253A.101",
)

_gnb_1_ru_4 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    serial_number="EA224157059",
    pdu_port=_gnb_1_ru_4_pdu_port,
    product_code="474253A.101",
)

_gnb_1_ru_5 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    serial_number="EA201955028",
    pdu_port=_gnb_1_ru_5_pdu_port,
    product_code="474253A.101",
)

_gnb_1_ru_6 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    serial_number="EA224157055",
    pdu_port=_gnb_1_ru_6_pdu_port,
    product_code="474253A.101",
)

_gnb_1_rms = [
    _gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3, _gnb_1_ru_4, _gnb_1_ru_5, _gnb_1_ru_6
]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIP",
    serial_number="L1232001190",
    product_code="475792A.101",
    addr="192.168.253.36",
    slot_id=SlotId.B1,
    rus=[
        _gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3, _gnb_1_ru_4, _gnb_1_ru_5,
        _gnb_1_ru_6
    ])

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1213507383",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=None,
        trs_connections=None)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.118", username="ute", password="ute"),
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
                v4="100.68.98.164/27",
                v6="2a00:8a00:4000:4a43::1504/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.161",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501",
                    ip_prefix_length=None,
                    destIpAddr=None)),
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
                v4="100.68.98.196/27",
                v6="2a00:8a00:4000:4a43::1604/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.193",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            x2u=NetworkAddress(
                v4="100.68.98.164/27",
                v6="2a00:8a00:4000:4a43::1504/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.161",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            s1u=NetworkAddress(
                v4="100.68.98.164/27",
                v6="2a00:8a00:4000:4a43::1504/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.161",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            ngu=NetworkAddress(
                v4="100.68.98.164/27",
                v6="2a00:8a00:4000:4a43::1504/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.161",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            ngc=NetworkAddress(
                v4="100.68.98.196/27",
                v6="2a00:8a00:4000:4a43::1604/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.193",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            xnc=NetworkAddress(
                v4="100.68.98.196/27",
                v6="2a00:8a00:4000:4a43::1604/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.193",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            xnu=NetworkAddress(
                v4="100.68.98.164/27",
                v6="2a00:8a00:4000:4a43::1504/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.161",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501",
                    ip_prefix_length=None,
                    destIpAddr=None)),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_1_common_units, product_code="474767A.102"),
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
                           unit=_gnb_1_cap_1, label="SFP", port_id=7),
                       target=Endpoint(
                           unit=_gnb_1_ru_4, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=8),
                       target=Endpoint(
                           unit=_gnb_1_ru_5, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=9),
                       target=Endpoint(
                           unit=_gnb_1_ru_6, label="SFP", port_id=1))
               ])
        ],
        instance_id=101602,
        global_bts_id=101602),
]

_enbs = []

_core = RealCore(
    mcc="244",
    mnc="9",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="None", username="None", password=None),
            s1=NetworkAddress(
                v4="10.35.22.232",
                v6="2a00:8a00:4000:4a22::2:1308",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None)),
        tac=7000,
        ntp=None),
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None)),
        tac=7000),
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
