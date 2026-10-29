__maintainer__ = "dacheng.zhang@nokia-sbell.com"
__team__ = "MN_VRF_HAZ1_T03"
__email__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_3_GMS <I_NSB_MN_RAN_RD_VRF_HAZ1_3@internal.nsn.com>"
__owner_email__ = "dacheng.zhang@nokia-sbell.com"


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
from taf.config.testline.pdu import FACOM, HBTE


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu = HBTE(addr="10.108.191.50", port_numbers=[1, 2, 3, 4, 5, 6])
_pdus = [_pdu]

_capacity_unit = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_pdus[0].pdu_ports[3],
    hardware_type="ASOE",
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=801),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=801),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=801),
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
                        addr="192.168.253.84",
                        hardware_type="ABIO",
                    ),
                ],
                pdu_port=_pdus[0].pdu_ports[2],
                hardware_type="ASIL",
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.61", username="ute", password="UTE.Debian12"
    ),
    connections=[Connection(interface="eth1", device=_cbts.dus[0].airscale.common_units[0], interface_type="lmp"), _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_AP_CA_ASOE_RJO",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
