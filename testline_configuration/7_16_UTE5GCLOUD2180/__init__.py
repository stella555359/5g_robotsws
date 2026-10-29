# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Bartosz Brozyna"
__team__ = "MN_RAN_PZ_OPER_WRO_1_VRF"
__email__ = "I_MN_RAN_PZ_OPER_WRO_1_VRF@internal.nsn.com"
__owner_email__ = "bartosz.brozyna@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import Gude
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation

# 5G section
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.82.34", username="ute", password="ute"
    )
)

_pdu1 = Gude("10.42.199.247", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu2 = Gude("10.42.80.20", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_pdus = [_pdu1, _pdu2]

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu2.pdu_ports[4],
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdu1.pdu_ports[6],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.19.199", v6="2a00:8a00:6000:603a::4", vlan_id=286),
    x2u=NetworkAddress(v4="10.42.18.199", v6="2a00:8a00:6000:6039::4", vlan_id=285),
    s1u=NetworkAddress(v4="10.42.21.199", v6="2a00:8a00:6000:603c::4", vlan_id=288),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])


# Common section
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK_ABIL_AHCA",
    pdus=_pdus,
)

__all__ = ["tl"]
