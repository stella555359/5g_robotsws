__maintainer__ = "Chendong He"
__team__ = "I_MN_RAN_L3_SW_3_CN_04_SG_GMS"
__email__ = "i_mn_ran_l3_sw_3_cn_04_sg@internal.nsn.com"
__owner_email__ = "Chendong.he@nokia-sbell.com"



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
from taf.config.testline.pdu import FACOM


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_pdu = FACOM(addr="10.108.164.163", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdus = [_pdu]

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
    capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.24", hardware_type="ABIO")],
    pdu_port=_pdus[0].pdu_ports[7],
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
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=802),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=802),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=802),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

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
                pdu_port=_pdus[0].pdu_ports[8],
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.97.82.178", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_I_BOO_AP_LOO",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
