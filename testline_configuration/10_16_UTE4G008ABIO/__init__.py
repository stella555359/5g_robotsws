__owner__ = "ET_REG_TEAM"
__maintainer__ = "Agnieszka Chlon"
__email__ = "agnieszka.chlon@nokia.com"


from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    FSMr4,
    IPHY,
    Pdu,
    CUS,
)

host = [Host()]

cus = [
    CUS(pdu=Pdu(addr="10.42.168.62", port=6, device="APC", protocol="http"))
]

fsm = [
    FSMr4(
        hw_type="ASIL",
        pdu=Pdu(addr="10.42.168.62", port=4, device="APC", protocol="http"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import APC

# PDU1  port2=ENB port1=CUS1

_pdu1 = APC(addr="10.42.168.62", port_numbers=[4, 6])

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

### ENB
_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.20",
        hardware_type="ABIP"
    )],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIL"
)
_enb_airscale = Airscale(common_units=[_enb_common_unit])
_enb = RealEnb('', system_module=_enb_airscale)
## CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.84",
        hardware_type="ABIA"
    )],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIA"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)
# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.165.133",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_cus1
        )
    ]
)
tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_R4LP12_CUS",
    ues=[_cus1],
    pdus=[_pdu1],
)
__all__ = ["tl"]
