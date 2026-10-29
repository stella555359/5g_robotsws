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
    addr="10.44.177.67", port_numbers=[1], model="EPC", version="8221-1"
)

_pdu2 = Gude(addr="10.44.177.57", port_numbers=[1, 2, 3], model="EPC", version="8221-1"
             )

_pdu = [_pdu1, _pdu2]

_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQE.value,
    serial_number="L1215104277",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQE.value,
    serial_number="L1215104278",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQE.value,
    serial_number="DH232011163",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508264",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1212512853",
)

_smod_1 = Airscale([_fct_1])

_du = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.167",
        vlan_id=909,
        routing_v4=RoutingInformation(
            gateway="10.44.68.128", destIpAddr="255.255.255.192"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:af33",
        vlan_id=904,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:af01", ip_prefix_length=128, destIpAddr=None
        ),
    ),
    x2u=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b033",
        vlan_id=905,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b201", ip_prefix_length=128, destIpAddr=None
        ),
    ),
    s1u=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b133",
        vlan_id=906,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b201", ip_prefix_length=128, destIpAddr=None
        ),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51112, instance_id=51112)

_test_pc = TestPc(
    SshServiceDetails(addr="10.42.53.124", username="ute"),
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_3xAQQE",
    core=_core,
    pdus=_pdu,
    test_pcs=[_test_pc],
)

__all__ = ["tl"]
