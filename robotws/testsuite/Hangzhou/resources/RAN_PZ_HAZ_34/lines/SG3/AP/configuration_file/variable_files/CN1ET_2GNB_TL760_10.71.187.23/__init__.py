# __maintainer__ = "zora.wang"
# __team__ = " I_MN_RAN_L3_SW_1_CN_BLUES_GMS"
# __email__ =I_MN_RAN_L3_SW_1_CN_BLUES@internal.nsn.com
# __owner_email__ = zora.wang@nokia-sbell.com

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import TopYoung
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Airphone

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.71.187.23",
        username="ute",
        password="ute",
    )
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.71.187.24",
        username="ute",
        password="ute",
    )
)

# pdu setting is adapted because local tl gnb1/gnb2/ap may be connected to different PDUs
# _pdu1 = FACOM(
#     port_numbers=[4, 5, 6],
#     addr="10.56.124.239",
# )
# _pdus = [_pdu1]

_pdu_gnb1 = TopYoung(
    port_numbers=[4],
    addr="10.71.182.239",
)

_pdu_gnb2 = TopYoung(
    port_numbers=[5],
    addr="10.71.182.239",
)

_pdu_ap = TopYoung(
    port_numbers=[6],
    addr="10.71.182.239",
)
_pdus = [_pdu_gnb1, _pdu_gnb2, _pdu_ap]

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=1122),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1122),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1122),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=1122),
)

_abio_du1 = CapacityUnit(addr="192.168.253.20")

_asib_du1 = CommonUnit(
    pdu_port=_pdus[0].pdu_ports[4],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_du1],
)

_du1 = DU(airscale=Airscale(common_units=[_asib_du1]))

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du1])

_cu2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id=1122),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=1122),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=1122),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=1122),
)

_abio_du2 = CapacityUnit(addr="192.168.253.36")

_asib_du2 = CommonUnit(
    pdu_port=_pdus[1].pdu_ports[5],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_du2],
)

_du2 = DU(airscale=Airscale(common_units=[_asib_du2]))

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du2])

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdus[2].pdu_ports[6],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                capacity_units=[CapacityUnit(addr="192.168.253.84")],
            )
        ]
    ),
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="LO_LO_KLLL_l1bypass",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
