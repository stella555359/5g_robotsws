__maintainer__ = "Anna Anzel"
__team__ = "I_5G_SW_MMW_PLKRK_04"
__email__ = "I_5G_SW_MMW_PLKRK_04 <I_5G_SW_MMW_PLKRK_04@nokia.com>"
__owner_email__ = "anna.banys@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Airphone

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = FPFH(
    port_numbers=[1, 2, 3],
    addr="fpfh-gb06-46-sc5g.sc5g-leg.krk-lab.nsn-rdnet.net",
    login="admin",
    password="admin",
)

_pdus = [_pdu1]

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=1584),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1584),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1584),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=1584),
)

_abio_du1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asib_du1 = CommonUnit(
    pdu_port=_pdu1.pdu_ports[2],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
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
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id=1584),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=1584),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=1584),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=1584),
)

_abio_du2 = CapacityUnit(addr="192.168.253.36", hardware_type="ABIO")

_asib_du2 = CommonUnit(
    pdu_port=_pdu1.pdu_ports[3],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
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
                pdu_port=_pdu1.pdu_ports[1],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.129", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIK",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIL"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIL"),
                    CapacityUnit(addr="192.168.253.86", hardware_type="ABIL"),
                ],
            )
        ]
    ),
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-7-UTE5GCLOUDT084-1.sc5g.krk-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        _ue,
    ],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-7-UTE5GCLOUDT084-2.sc5g.krk-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_FS_CPRI_CMWV_FDD",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
