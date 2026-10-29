__maintainer__ = "Adam Masztalerz"
__team__ = "MN RAN RD VRF WRO1 4"
__email__ = "adam.masztalerz@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import Android
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.177.67", port_numbers=[9, 10], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(
    addr="10.44.177.57", port_numbers=[11], model="EPC", version="8221-1"
)

_gnb_ru_1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQQC",
    serial_number="L1250103471",
    product_code="476675A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.34",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.255.33.88", port=3000),
                                    Remote(addr="10.255.33.88", port=3001)]),
    pdu_port=_pdu_gnb_ru.pdu_ports[11],
)

_abip1_primary = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1250605527",
    rus=[_gnb_ru_1],
)

_abip2_primary = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIQ",
    hardware_version="A101",
    serial_number="L1232102429",
    rus=[_gnb_ru_1],
)

_abiq1_secondary = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIQ",
    hardware_version="A101",
    serial_number="L1232102417",
    rus=[_gnb_ru_1],
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip1_primary, _abip2_primary],
    pdu_port=_pdu_gnb.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1213511582",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abiq1_secondary],
    pdu_port=_pdu_gnb.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A102",
    serial_number="L1213506788",
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.153", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.240", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_gnb_secondary],
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_primary, _asil_gnb_secondary])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru_1],
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.201",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::290f", vlan_id=401),
    x2u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::290f", vlan_id=401),
    s1u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::290f", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50138
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIPB1_ABIQB2_ASILR_ABIQB4_AVQQC",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)
