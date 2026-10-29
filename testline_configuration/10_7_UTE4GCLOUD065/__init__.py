__maintainer__ = "MichalKowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import FPFH

# PDU1
_pdu1 = FPFH(addr="10.253.146.24", port_numbers=[3, 4])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.18", hardware_type="FBBC", pdu_port=_pdu1.pdu_ports[3]
        ),
        CapacityUnit(
            addr="192.168.253.19", hardware_type="FBBC", pdu_port=_pdu1.pdu_ports[3]
        ),
    ],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="FSMF",
)

_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb('', system_module=_enb_airscale1)

# CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIA")
    ],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIA"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-ute4gcloud065.vir.krk-lab.nsn-rdnet.net",
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
    tl_cloud_topology="CLOUD_FCC_CUS_A",
    ues=[_cus1],
    pdus=[_pdu1],
)
__all__ = ["tl"]