__maintainer__ = "Mateusz Pajor"
__team__ = "MN RAN RD VRF KRK 11"
__email__ = "I_VRF_KRK_11_GMS <I_VRF_KRK_11@internal.nsn.com>"
 
import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Airphone
 
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
 
_pdu_ap = FPFH(
    port_numbers=[1],
    addr="fpfh-hc12-17-p02.p02-leg.ska-lab.nsn-rdnet.net",
    login="admin",
    password="admin",
)
 
_pdu_gnb = FPFH(
    port_numbers=[2],
    addr="fpfh-hc11-34-p02.p02-leg.ska-lab.nsn-rdnet.net",
    login="admin",
    password="admin",
)
 
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASOH",
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[2],
)
 
_airscale = Airscale([_common_unit])
 
_cu = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=1548),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1548),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1548),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=1548),
)
 
_du = DU(_airscale)
 
_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=107420481)
 
_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
					CapacityUnit(addr="192.168.253.85", hardware_type="ABIO")
                ],
                pdu_port=_pdu_ap.pdu_ports[1],
            )
        ]
    ),
)
 
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G2SK048.p02.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], _ue],
)
 
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_X_XX_AP_",
    pdus=[_pdu_ap, _pdu_gnb],
    ues=[_ue],
)
 
__all__ = ["tl"]
