__maintainer__ = "UTEteam"
__email__ = "ute@nokia.com"
__owner_email__ = "UTELabTeam"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import ATEN
from taf.config.testline.adapters.ute_testline_adapter import (
    prepare_ute_testline_configuration_data,
)

# PDU1
_pdu1 = ATEN(addr="10.45.170.70", port_numbers=[1, 2])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type='ABIA')
    ],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA",
)

_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb(
    system_module=_enb_airscale1,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
    top_ip=NetworkAddress(v4="10.83.224.201"),
)
# CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIA"),
    ],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIB"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.98.125",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb1.system_module.common_units[0],
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_cus1,
        )
    ]
)
tl = prepare_ute_testline_configuration_data(
    TestLine(
        test_pc=_test_pc1,
        enbs=[_enb1],
        tl_cloud_topology="R4A_CUS",
        ues=[_cus1],
        pdus=[_pdu1],
    )
)
__all__ = ["tl"]