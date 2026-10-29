__maintainer__ = "haifhuan"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "amaand.li@nokia-sbell.com"
__owner_email__ = "amaand.li@nokia-sbell.com"


import os
import yaml
from taf.config.testline.airscale import Airscale, CoreUnit
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude, TopYoung, FACOM
from taf.config.testline.pdu import HBTE as PBHBTE
from taf.config.testline.attenuator import HBTE
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RadioTypes
from taf.config.testline import LicenseKeeper

_pdu_1 = HBTE(
    addr="10.56.201.130",
    port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
    ],
)
_pdu_2 = HBTE(
    addr="10.56.201.131",
    port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
    ],
)

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="root"
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    ru_hw_group="ScRMr6.1_4T4R",
    serial_number="1M234601261",
    radio_type="AHCI",
)

_rmod_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    ru_hw_group="ScRMr6.1_4T4R",
    serial_number="1M234601260",
    radio_type="AHCI",
)

_rmod_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    ru_hw_group="ScRMr6.1_4T4R",
    serial_number="1M234601258",
    radio_type="AHCI",
)

_fct_1 = CoreUnit(
    SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASOE",
    hardware_version="475587A.103",
    serial_number="EA221952814",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_smod_1 = Airscale(core_units=[_fct_1])

_du_1 = DU(_smod_1)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.56.201.194"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    oam_http_connection_details=HttpConnectionDetails(addr="192.168.255.129", username="Nemuadmin", password="nemuuser"),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=11288, instance_id=11288)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.166", username="ute", password="uteUTE!"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_gnbs_1.dus[0].airscale.core_units[0], interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1],
    gnbs=[_gnbs_1],
    tl_cloud_topology="CLOUD_SRAN_NL_ASOE_3XAHCI",
    pdus=[_pdu_1, _pdu_2],
)

__all__ = ["tl"]
