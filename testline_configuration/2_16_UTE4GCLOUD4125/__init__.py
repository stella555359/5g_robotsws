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

# PDU
_pdu1 = ATEN(addr="10.45.170.68", port_numbers=[1, 2, 3, 4])
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

### ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.21", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.22", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIM"
)
_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb('', system_module=_enb_airscale1, instance_id=21641251)
### ENB2
_enb_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.21", hardware_type="ABIP"),
        CapacityUnit(addr="192.168.253.22", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIM"
)
_enb_airscale2 = Airscale(common_units=[_enb_common_unit2])
_enb2 = RealEnb('', system_module=_enb_airscale2, instance_id=21641252)
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
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIB"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)
## CUS2
_cus_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.84",
        hardware_type="ABIA"
    )],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIB"
)
_cus_airscale2 = Airscale(common_units=[_cus_common_unit2])
_cus2 = CUS(l1=_cus_airscale2)
# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.98.117",
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
            device=_cus1
        ),
        Connection(
            interface="eth5",
            interface_type="lmp",
            device=_cus2
        ),
    ]
)
# TestPC2
_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.98.118",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb2.system_module.common_units[0],
        ),
    ]
)
tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb1, _enb2],
    tl_cloud_topology="CLOUD_2MAPO_2CUS",
    ues=[_cus1, _cus2],
    pdus=[_pdu1],
)
__all__ = ["tl"]
