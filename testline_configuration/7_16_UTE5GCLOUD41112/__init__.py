__maintainer__ = "Adam Proszek"
__team__ = "I_MN_RAN_PZ1_WRO_8_SG_GMS"
__email__ = "adam.proszek@nokia.com"
__owner_email__ = "adam.proszek@nokia.com"

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
from taf.config.testline import (
    DU,
    RU,
    RadioTypes,
    NetworkAddress,
    RoutingInformation,
    RealEnb,
)
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_pdu1 = Gude(
    addr="10.44.177.67", port_numbers=[11], model="EPC", version="8221-1"
)

_pdu2 = Gude(addr="10.44.177.57", port_numbers=[7, 8, 9, 11, 12], model="EPC", version="8221-1"
             )

_pdu3 = Gude(addr="10.44.177.56", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 11, 12], model="EPC", version="8221-1"
             )

_pdu = [_pdu1, _pdu2, _pdu3]

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2043Y21VS",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[8],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2043Y21VV",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[11],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2043Y21YF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[12],
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2049V0V8P",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2049V0V8S",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2049V0V8Q",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[6],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212360066",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212360065",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[4],
)

_rmod_14 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212360067",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[11],
)

_rmod_10 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212360064",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[3],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212359952",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[9],
)

_rmod_11 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212359957",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[2],
)

_rmod_13 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="BL2118G2JJU",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[7],
)

_rmod_15 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="BL2118G2JN4",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[8],
)

_rmod_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="BL2118G2JOC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1180418261",
    rus=[_rmod_15, _rmod_13, _rmod_12, _rmod_9, _rmod_8],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193577734",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_10, _rmod_14],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA194454292",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_11],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.204",
    serial_number="L1192210876",
)

_smod_1 = Airscale([_fct_1])

_du = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.78.234",
        vlan_id=909,
        routing_v4=RoutingInformation(
            gateway="10.44.78.192", destIpAddr="255.255.255.192"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b535",
        vlan_id=910,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b201", ip_prefix_length=128, destIpAddr=None
        ),
    ),
    x2u=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b535",
        vlan_id=910,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b201", ip_prefix_length=128, destIpAddr=None
        ),
    ),
    s1u=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b535",
        vlan_id=910,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b201", ip_prefix_length=128, destIpAddr=None
        ),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=41112, instance_id=41112)

_test_pc = TestPc(
    SshServiceDetails(addr="10.42.53.117", username="ute"),
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
    test_pc=[_test_pc],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIA_3xABIA_3xAHFIB_3xAHBCC_6xAHHB_2xAHLBBA",
    core=_core,
    pdus=_pdu,
    test_pcs=[_test_pc],
)

__all__ = ["tl"]
