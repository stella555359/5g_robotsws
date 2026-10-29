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

_pdu1 = Gude(addr="10.42.169.162", port_numbers=[1, 2, 3], model="EPC", version="8220-1")
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB 1
_fsp_1 = CapacityUnit(
        addr="192.168.253.20",
        hardware_type="ABIO",
    )

_fsp_2 = CapacityUnit(
        addr="192.168.253.24",
        hardware_type="ABIO",
    )

_fsp_3 = CapacityUnit(
        addr="192.168.253.28",
        hardware_type="ABIN",
    )

_enb1_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2,_fsp_3],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIM"

)
#_enb1_airscale = Airscale(common_units=[_enb1_common_unit])
#_enb1 = RealEnb('', system_module=_enb1_airscale)

_enb1 = RealEnb(
    system_module=Airscale([_enb1_common_unit]),
)


# ENB 2
_fsp_4 = CapacityUnit(
        addr="192.168.253.32",
        hardware_type="ABIA",
    )

_fsp_5 = CapacityUnit(
        addr="192.168.253.38",
        hardware_type="ABIA",
    )

_fsp_6 = CapacityUnit(
        addr="192.168.253.42",
        hardware_type="ABIA",
    )

_enb2_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4,_fsp_5,_fsp_6],
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIM"

)
#_enb2_airscale = Airscale([_enb2_common_unit])
#_enb2 = RealEnb('', system_module=_enb2_airscale, master=_enb1,)

_enb2 = RealEnb(
    system_module=Airscale([_enb2_common_unit]),
)

#_enb1 = RealEnb(
#    system_module=Airscale([_enb1_common_unit, _enb2_common_unit]),
#)

# CUS1
_fsp_cus_1 = CapacityUnit(
        addr="192.168.253.84",
        hardware_type="ABIA",
    )

_fsp_cus_2 = CapacityUnit(
        addr="192.168.253.88",
        hardware_type="ABIA",
    )

_fsp_cus_3 = CapacityUnit(
        addr="192.168.253.92",
        hardware_type="ABIA",
    )

_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_cus_1, _fsp_cus_2, _fsp_cus_3],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIA"
)
#_cus_airscale1 = Airscale([_cus_common_unit1])
#_cus1 = CUS(l1=_cus_airscale1)

_cus1 = CUS(Airscale([_cus_common_unit1]))

# TestPC
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.90",
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
        )
    ]
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.92",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb2.system_module.common_units[0],
        )
    ]
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb1, _enb2],
    tl_cloud_topology="CLOUD_*_CUS",
    ues=[_cus1],
    pdus=[_pdu1],
)
__all__ = ["tl"]
