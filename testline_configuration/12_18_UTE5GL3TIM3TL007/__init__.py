__maintainer__ = "MN RAN L3 SW TIM 3 SG team"
__team__ = "MN RAN L3 SW TIM 3 SG team"
__email__ = "I_MN_RAN_L3_SW_TIM3_SG@internal.nsn.com"
__owner_email__ = "I_MN_RAN_L3_SW_TIM3_SG Team"


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
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# Power breakers
_pdu_du = Gude(addr="10.255.3.33", port_numbers=[1, 2], model="EPC", version="8220-1")

_pdu_du.pdu_ports[2].contactor = "NORMALLY_OPENED"

_pdus = [_pdu_du]

_capacity_unit = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdu_du.pdu_ports[2],
    hardware_type="ASIM",
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1507),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=1507),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=1507),
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
                        addr="192.168.253.80",
                        hardware_type="ABIO",
                    )
                ],
                pdu_port=_pdu_du.pdu_ports[1],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.50.9", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], _ue],
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_X_XX_AP_",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
