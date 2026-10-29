__maintainer__ = "Michal Kowalski"
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

# PDU - 10.253.166.179 - FPRB-E10.macro.krk-lab.nsn-rdnet.net port 2 = ENB  port 1 = CUS
_pdu1 = FPFH(addr="10.253.166.179", port_numbers=[1, 2], protocol="snmp")

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

### ENB
_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
    ],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIA",
)
_enb_airscale = Airscale(common_units=[_enb_common_unit])
_enb = RealEnb("", system_module=_enb_airscale)

## CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.84", hardware_type="ABIA")],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-ute4gtl016.macro.krk-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_enb),
        Connection(interface="eth2", interface_type="lmp", device=_cus1),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_R4A_CUS",
    ues=[_cus1],
    pdus=[_pdu1],
)

__all__ = ["tl"]
