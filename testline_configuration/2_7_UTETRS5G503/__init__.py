__maintainer__ = "Prabakar Sanikommu"
__team__ = "TRS VRF"
__email__ = "i_mn_bts_trs_pz_ute_key_users@internal.nsn.com"


import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import Airphone, IPHY


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.158.231", username="ute", password="ute"
    )
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.158.232", username="ute", password="ute"
    )
)

_pdu = RRB(addr="10.71.247.40", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdus = [_pdu]

_airscale_gnb = Airscale(
    common_units=[
        CommonUnit(
            lmp_connection=SshServiceDetails(
                addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")],
            pdu_port=_pdus[0].pdu_ports[6],
        )
    ]
)

_du = DU(_airscale_gnb)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=800),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=800),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=800),
)

_gnb = ClassicalBts(cu=_cu, dus=[_du])

_airscale_enb = Airscale(
    common_units=[
        CommonUnit(
            lmp_connection=SshServiceDetails(
                addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")],
            pdu_port=_pdus[0].pdu_ports[5],
        )
    ]
)

_enb = RealEnb(system_module=_airscale_enb)

_airscale_ap = Airscale(
    common_units=[
        CommonUnit(
            lmp_connection=SshServiceDetails(
                addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            capacity_units=[CapacityUnit(addr="192.168.253.84")],
            pdu_port=_pdus[0].pdu_ports[3],
        )
    ]
)

_ap = Airphone(
    egate=None,
    l3_ssh_connection_details=None,
    l2_ssh_connection_details=None,
    l1=_airscale_ap,
)

_iphy = IPHY(
    iphy_ssh_connection_details=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdus[0].pdu_ports[7],
)


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_gnb],
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_I_BL_AP_KL_SANSA_L1B_CPRI_CMWV_FDD-4G_I_BA_IPHY_F",
    ues=[_ap, _iphy],
    pdus=_pdus,
)

__all__ = ["tl"]
