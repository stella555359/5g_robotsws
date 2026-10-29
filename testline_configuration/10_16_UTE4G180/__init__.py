__team__ = 'SiSo CRT CUS'
__maintainer__ = "Katarzyna Zacharuk"
__email__ = 'katarzyna.zacharuk@nokia.com'

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import Gude

_pdu1 = Gude(addr="10.42.168.85", port_numbers=[1, 2, 3, 4, 5, 6], model="EPC", version="8220-1")
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB
_fsp_1 = CapacityUnit(
        addr="192.168.253.20",
        hardware_type="ABIP",
    )

_fsp_2 = CapacityUnit(
        addr="192.168.253.24",
        hardware_type="ABIP",
    )

_fsp_3 = CapacityUnit(
        addr="192.168.253.28",
        hardware_type="ABIP",
    )

_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2,_fsp_3],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIM"
)    
_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb('', system_module=_enb_airscale1)

_fsp_4 = CapacityUnit(
        addr="192.168.253.32",
        hardware_type="ABIP",
    )

_fsp_5 = CapacityUnit(
        addr="192.168.253.36",
        hardware_type="ABIP",
    )

_fsp_6 = CapacityUnit(
        addr="192.168.253.40",
        hardware_type="ABIP",
    )

_enb_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4,_fsp_5,_fsp_6],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIM"
   )
   
_enb_airscale2 = Airscale(common_units=[_enb_common_unit2])
_enb2 = RealEnb('', system_module=_enb_airscale2)
	
_enb1.slave = _enb2

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
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIA"
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
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIA"
)
_cus_airscale2 = Airscale(common_units=[_cus_common_unit2])
_cus2 = CUS(l1=_cus_airscale2)

## CUS3
_cus_common_unit3 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.3",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.84",
        hardware_type="ABIA"
    )],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA"
)
_cus_airscale3 = Airscale(common_units=[_cus_common_unit3])
_cus3 = CUS(l1=_cus_airscale3)

## CUS4
_cus_common_unit4 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.4",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.84",
        hardware_type="ABIA"
    )],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIA"
)
_cus_airscale4 = Airscale(common_units=[_cus_common_unit4])
_cus4 = CUS(l1=_cus_airscale4)


# TestPC
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.165.66",
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
        Connection(
            interface="eth7",
            interface_type="lmp",
            device=_cus3
        ),
        Connection(
            interface="eth9",
            interface_type="lmp",
            device=_cus4
        )
    ]
)

# TestPC2
_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.165.67",
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
    tl_cloud_topology="CLOUD_*_4CUS",
    ues=[_cus1, _cus2, _cus3, _cus4],
    pdus=[_pdu1],
)

__all__ = ["tl"]
