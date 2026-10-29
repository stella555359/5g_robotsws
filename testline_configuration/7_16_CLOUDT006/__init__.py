__maintainer__ = "Malgorzata Smelka"
__team__ = "MN 5G RAN I&V 3 Pz cOAM 12 SG"
__email__ = "I_UTE_CORE_5G@internal.nsn.com"
__owner_email__ = "malgorzata.smelka@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import ATEN


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = ATEN(addr="10.42.61.135", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu1]

_capacity_unit = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdu1.pdu_ports[8],
    hardware_type="ASIK",
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=459),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.1.1.1", vlan_id=460),
    x2u=NetworkAddress(v4="10.1.1.1", vlan_id=461),
    s1u=NetworkAddress(v4="10.1.1.1", vlan_id=462),
    s1c=NetworkAddress(v4="10.1.1.1", vlan_id=463),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=1, global_bts_id=1)

_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.53", username="ute", password="ute"
    ),
    dir_path="/opt/core",
    cfg_filename="basic_cfg_LteEmu.cfg",
    mme_ip="192.168.4.134",
    mcc=311,
    mnc=489,
    tac=333,
    edaemon_port=22222,
    egate_port=10000,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.53", username="ute", password="ute"
    ),
    connections=[_common_unit],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1",
    core=_lteemu,
    pdus=_pdus,
)
__all__ = ["tl"]
