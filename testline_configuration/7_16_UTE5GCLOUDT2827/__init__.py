__maintainer__ = "Michal Gradowski-Nowak"
__team__ = "RRM team"
__email__ = "michal.gradowski-nowak@nokia.com"
__owner_email__ = "michal.gradowski-nowak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.205.248",
    port_numbers=[1, 7, 8, 9, 10],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.177.62",
    port_numbers=[1, 5, 6, 7, 8, 9, 10, 11],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.200.93",
    port_numbers=[1],
    model="EPC",
    version="8041-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_4T4R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV192800590",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M203000169",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[11],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="DH234520598",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[8],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_4T4R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194001630",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M203000385",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[1],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="DH234520612",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[9],
)

_rmod_7 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="L1144804033",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[5],
)

_rmod_8 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9170431065",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[10],
)

_rmod_9 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9162221787",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[1],
)

_rmod_10 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AHGA.value,
    serial_number="1M241005951",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[8],
)

_rmod_11 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AHGA.value,
    serial_number="1M241005956",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[9],
)

_rmod_12 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.AHGA.value,
    serial_number="1M240803664",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1210904949",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1210904943",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211201002",
    rus=[_rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224815360",
)

_core = RealCore5G(mcc=450, mnc=5)

_smod_1 = Airscale([_fct_1])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.70.205",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.70.205",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.205",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.205",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
    ),
    ngu=NetworkAddress(
        v4="10.44.70.205",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
)

_du = DU(_smod_1)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=50805, instance_id=50805)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.194.115", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_3xABIO_3xAEQN_3xAEQY_3xAQQL_3xFRGY_3xAHGA",
    core=_core,
    pdus=_pdus,
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
