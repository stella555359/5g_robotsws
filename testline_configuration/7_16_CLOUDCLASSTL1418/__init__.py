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
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.98.236", username="ute", password="ute"
    )
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=None,
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
    x2c=NetworkAddress(v4="10.1.1.1", vlan_id=1904),
    x2u=NetworkAddress(v4="10.1.1.2", vlan_id=3142),
    s1u=NetworkAddress(v4="10.1.1.2", vlan_id=3142),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])


_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                [CapacityUnit(addr="192.168.253.22")],
            )
        ]
    ),
)


# TODO: change tl_cloud_topology to CLOUD_5G_CLASSICAL_AP after setting PDUs ports for gNB and AP
tl = TestLine(test_pc=_test_pc, gnbs=[_cbts], tl_cloud_topology="NON_CM", ues=[_ue])

__all__ = ["tl"]
