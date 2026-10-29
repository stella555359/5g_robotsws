__maintainer__ = "Bartosz Kozlowski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = "bartosz.1.kozlowski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation, Connection

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_su = Gude(
    addr="10.44.177.83",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
) # Port 6 - ASOE

_pdu_ru = Gude(
    addr="10.44.177.35",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
) # Port 11 - AHLOB

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2228D500Q",
    pdu_port=_pdu_ru.pdu_ports[11],
)

_smod = CommonUnit(
    hardware_type="ASOE",
    lmp_connection = SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port = _pdu_su.pdu_ports[6],
    capacity_units = [],
    hardware_version = "475587A.X21",
    serial_number = "EA210150234"
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.41.84",
        vlan_id=541,
        routing=RoutingInformation(gateway="10.42.41.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.42.41.148",
        vlan_id=542,
        routing=RoutingInformation(gateway="10.42.41.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.42.41.212",
        vlan_id=543,
        routing=RoutingInformation(gateway="10.42.41.193", ip_prefix_length=26),
    )
)

_cu.m=NetworkAddress(
    v4="10.42.41.20",
    vlan_id=540,
    routing=RoutingInformation(gateway="10.42.41.1", ip_prefix_length=24),
)

_cu.sync=NetworkAddress(
    v4="10.42.65.148",
    vlan_id=544,
    routing=RoutingInformation(gateway="10.42.65.129", ip_prefix_length=26),
)

_du = DU(Airscale([_smod]), rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50871, instance_id=50871)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.31", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts.dus[0].airscale.common_units[0]
        )
    ]
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_AHLOB_UTECA",
    pdus=[_pdu_su, _pdu_ru]
)

tl.tl_type = "sa"

__all__ = ["tl"]
