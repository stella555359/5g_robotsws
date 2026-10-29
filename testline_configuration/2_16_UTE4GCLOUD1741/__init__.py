__maintainer__ = "UTE"
__email__ = "ute@nokia.com"
__owner_email__ = "UTE"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import ATEN

# PDU1
_pdu1 = ATEN(addr="10.45.170.191", port_numbers=[5, 6])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type='ASOH')
    ],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASOH",
)

_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb('', system_module=_enb_airscale1, instance_id=21617411)

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
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIB"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.99.123",
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
tl = TestLine(
    test_pc=_test_pc1,
    enbs=[_enb1],
    tl_cloud_topology="CLOUD_ASOH_CUS",
    ues=[_cus1],
    pdus=[_pdu1],
)
__all__ = ["tl"]