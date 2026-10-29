__maintainer__ = 'UTE team'
__team__ = 'UTE team'
__email__ = 'ute@nokia.com'
__owner_email__ = 'UTE Lab Team'

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import ATEN

# PDU1  port1=ENB port2=CUS1
_pdu1 = ATEN(addr="10.45.170.110", port_numbers=[3, 4])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB
_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type='ABIO'),
        CapacityUnit(addr="192.168.253.24", hardware_type='ABIP'),
        CapacityUnit(addr="192.168.253.28", hardware_type='ABIQ')
    ],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIM"

)
_enb_airscale = Airscale(common_units=[_enb_common_unit])
_enb = RealEnb('', system_module=_enb_airscale, instance_id=21643261)

# CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIL"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.188.232",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb.system_module.common_units[0],
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
    tl_cloud_topology="CLOUD_*_CUS",
    ues=[_cus1],
    pdus=[_pdu1],
)
__all__ = ["tl"]