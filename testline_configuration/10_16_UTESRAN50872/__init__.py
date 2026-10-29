__maintainer__ = "Bartosz Kozlowski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = "bartosz.1.kozlowski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
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
) # Port 10 - ASIB

_pdu_ru = Gude(
    addr="10.44.177.37",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
) # Port 11 - AHFII

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="AirScale_RF_4T4R_B",
    radio_type="AHFII",
    serial_number="BL2217N402Y",
    pdu_port=_pdu_ru.pdu_ports[11],
)

_bbmod = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A.101",
    product_code="475266A.101",
    serial_number="L1204104938",
    rus=[_ru],
)

_smod = CommonUnit(
    hardware_type="ASIB",
    lmp_connection = SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port = _pdu_su.pdu_ports[10],
    capacity_units = [_bbmod],
    hardware_version = "473764A.102",
    serial_number = "DH200762511"
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
        v4="10.42.41.85",
        vlan_id=541,
        routing=RoutingInformation(gateway="10.42.41.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.42.41.149",
        vlan_id=542,
        routing=RoutingInformation(gateway="10.42.41.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.42.41.213",
        vlan_id=543,
        routing=RoutingInformation(gateway="10.42.41.193", ip_prefix_length=26),
    )
)

_cu.m=NetworkAddress(
    v4="10.42.41.21",
    vlan_id=540,
    routing=RoutingInformation(gateway="10.42.41.1", ip_prefix_length=24),
)

_cu.sync=NetworkAddress(
    v4="10.42.65.149",
    vlan_id=544,
    routing=RoutingInformation(gateway="10.42.65.129", ip_prefix_length=26),
)

_du = DU(Airscale([_smod]), rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50872, instance_id=50872)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.78", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_AHFII_UTECA",
    pdus=[_pdu_su, _pdu_ru]
)

tl.tl_type = "sa"

__all__ = ["tl"]
