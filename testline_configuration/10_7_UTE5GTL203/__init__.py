__maintainer__ = "Michal Kowalski"
__team__ = "MN RAN L2 SW 1 KRK Vrf"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"


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
from taf.config.testline.pdu import FPFH


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-ute5gtl203.vir.krk-lab.nsn-rdnet.net", username="ute", password="ute"
    )
)

_pdu1 = FPFH(
    port_numbers=[2, 6],
    addr="FPFH-GP07-3.macro-leg.krk-lab.nsn-rdnet.net",
    login="admin",
    password="admin",
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1703),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1703),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1703),
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
                pdu_port=_pdu1.pdu_ports[2],
            )
        ]
    ),
)


tl = TestLine(
    test_pc=_test_pc, gnbs=[_cbts], tl_cloud_topology="CLOUD_5G_CLASSICAL_AP", ues=[_ue]
)

__all__ = ["tl"]
