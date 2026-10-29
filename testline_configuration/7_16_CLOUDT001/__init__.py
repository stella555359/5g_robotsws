__maintainer__ = "Artur Stepniak"
__team__ = "MN 5G RAN I&V 3 Pz cOAM 12 SG"
__email__ = "I_UTE_CORE_5G@internal.nsn.com"
__owner_email__ = "artur.stepniak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import EPCSim
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.ue import TM500
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.compatibility.configuration import TestlineWrapper

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.64", username="ute", password="ute"
    )
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=None,
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
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.64", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AEUA",
)

_du = DU(_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_core = EPCSim(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.64", username="ute", password="ute"
    ),
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
    mme_ip="10.1.1.100",
    mcc=311,
    mnc=489,
    tac=788,
    edaemon_port=10000,
    egate_port=20000,
)

_ue = TM500(
    SshServiceDetails(addr="10.42.158.109", username="", password=""),
    tma_command_port=5003,
)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_capacity_unit], pdu_port=None
)

_lteenb = RealEnb(airscale=_airscale, x2_link_addr="10.1.1.110")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKM01L_ABILX21B1_AEUA_ENB",
    core=_core,
    enbs=[_lteenb],
    ues=[_ue],
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
