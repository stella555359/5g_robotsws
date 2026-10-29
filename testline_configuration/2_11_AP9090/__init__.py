__maintainer__ = "AP_DEV"
__team__ = "AP_DEV"
__email__ = "anirudha.mishra@nokia.com"
__owner_email__ = "anirudha.mishra@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import ENICS

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))



_pdu = ENICS(addr="10.35.36.201", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13])

_pdus = [_pdu]

_capacity_unit = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdus[0].pdu_ports[11],
    hardware_type="ASIL",
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1900),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1900),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1900),
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
                [
                    CapacityUnit(
                        addr="192.168.253.22",
                        hardware_type="ABIO",
                    ),
                ],
                pdu_port=_pdus[0].pdu_ports[10],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.35.36.210", username="ute", password="UTE.debian12"
    ),
    connections=[Connection(interface="eth1", device=_cbts.dus[0].airscale.common_units[0], interface_type="lmp"), _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_I_LO_AP_LOOO",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
