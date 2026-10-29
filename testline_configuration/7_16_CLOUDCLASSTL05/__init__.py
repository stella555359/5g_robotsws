__maintainer__ = "Piotr Bebel "
__team__ = "MN 5G&SC 5G SW Eng WRO L3NRT 06 SG"
__email__ = "OU_MN_5G_SC_5G_SW_ENG_WRO_L3NRT_06_SG_52483892_GMS"
__owner_email__ = "piotr.bebel@nokia.comexi"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = ATEN(addr="10.44.206.47", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdus = [_pdu1]

_common_unit = CommonUnit(
    pdu_port=_pdus[0].pdu_ports[6],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.36", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.40", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.44", hardware_type="ABIO"),
    ],
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
    x2c=NetworkAddress(v4="10.0.0.1", vlan_id=217),
    x2u=NetworkAddress(v4="10.0.0.1", vlan_id=217),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=217),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=716000051)

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                pdu_port=_pdus[0].pdu_ports[5],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.92", hardware_type="ABIO"),
                ],
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.106", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_AP",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
