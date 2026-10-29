__owner__ = "Jakub Pachana"
__maintainer__ = "Jakub Pachana"
__email__ = "jakub.pachana@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection, CUS
from taf.config.testline.pdu import Gude

# PDU1  port1=ENB  port2=CUS1 port2=CUS2 port2=CUS3 port2=CUS4 port2=CUS5 port2=CUS6 
_pdu1 = Gude(addr="10.42.169.241", port_numbers=[1, 2, 3, 4, 5, 6, 7], model="EPC", version="8221-1")

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# ENB
_fsp_1 = CapacityUnit(
        addr="192.168.253.20",
        hardware_type="ABIA",
    )

_fsp_2 = CapacityUnit(
        addr="192.168.253.24",
        hardware_type="ABIA",
    )

_fsp_3 = CapacityUnit(
        addr="192.168.253.28",
        hardware_type="ABIA",
    )

_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2,_fsp_3],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA"

)
_enb_airscale = Airscale(common_units=[_enb_common_unit])
_enb = RealEnb('', system_module=_enb_airscale)

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
    pdu_port=_pdu1.pdu_ports[2],
    hardware_type="ASIA"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# CUS2
_fsp_cus2_1 = CapacityUnit(
        addr="192.168.253.96",
        hardware_type="ABIA",
    )

_fsp_cus2_2 = CapacityUnit(
        addr="192.168.253.100",
        hardware_type="ABIA",
    )

_fsp_cus2_3 = CapacityUnit(
        addr="192.168.253.104",
        hardware_type="ABIA",
    )

_cus2_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_cus2_1, _fsp_cus2_2, _fsp_cus2_3],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIA"
)
_cus2_airscale1 = Airscale(common_units=[_cus2_common_unit1])
_cus2 = CUS(l1=_cus2_airscale1)

# CUS3
_fsp_cus3_1 = CapacityUnit(
        addr="192.168.253.96",
        hardware_type="ABIA",
    )

_fsp_cus3_2 = CapacityUnit(
        addr="192.168.253.100",
        hardware_type="ABIA",
    )

_fsp_cus3_3 = CapacityUnit(
        addr="192.168.253.104",
        hardware_type="ABIA",
    )

_cus3_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.3",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_cus3_1, _fsp_cus3_2, _fsp_cus3_3],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIA"
)
_cus3_airscale1 = Airscale(common_units=[_cus3_common_unit1])
_cus3 = CUS(l1=_cus3_airscale1)

# CUS4
_fsp_cus4_1 = CapacityUnit(
        addr="192.168.253.108",
        hardware_type="ABIA",
    )

_fsp_cus4_2 = CapacityUnit(
        addr="192.168.253.112",
        hardware_type="ABIA",
    )

_fsp_cus4_3 = CapacityUnit(
        addr="192.168.253.116",
        hardware_type="ABIA",
    )

_cus4_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.4",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_cus4_1, _fsp_cus4_2, _fsp_cus4_3],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIA"
)
_cus4_airscale1 = Airscale(common_units=[_cus4_common_unit1])
_cus4 = CUS(l1=_cus4_airscale1)

# CUS5
_fsp_cus5_1 = CapacityUnit(
        addr="192.168.253.120",
        hardware_type="ABIA",
    )

_fsp_cus5_2 = CapacityUnit(
        addr="192.168.253.124",
        hardware_type="ABIA",
    )

_fsp_cus5_3 = CapacityUnit(
        addr="192.168.253.128",
        hardware_type="ABIA",
    )

_cus5_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.5",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_cus5_1, _fsp_cus5_2, _fsp_cus5_3],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIA"
)
_cus5_airscale1 = Airscale(common_units=[_cus5_common_unit1])
_cus5 = CUS(l1=_cus5_airscale1)

# CUS6
_fsp_cus6_1 = CapacityUnit(
        addr="192.168.253.132",
        hardware_type="ABIA",
    )

_fsp_cus6_2 = CapacityUnit(
        addr="192.168.253.136",
        hardware_type="ABIA",
    )

_fsp_cus6_3 = CapacityUnit(
        addr="192.168.253.140",
        hardware_type="ABIA",
    )

_cus6_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.6",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_cus6_1, _fsp_cus6_2, _fsp_cus6_3],
    pdu_port=_pdu1.pdu_ports[7],
    hardware_type="ASIA"
)
_cus6_airscale1 = Airscale(common_units=[_cus6_common_unit1])
_cus6 = CUS(l1=_cus6_airscale1)

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.184.62",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb.system_module.common_units[0]
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
        ),
        Connection(
            interface="eth11",
            interface_type="lmp",
            device=_cus5
        ),
        Connection(
            interface="eth13",
            interface_type="lmp",
            device=_cus6
        )
    ]
)

tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_*_CUS",
    ues=[_cus1, _cus2, _cus3, _cus4, _cus5, _cus6],
    pdus=[_pdu1],
)

__all__ = ["tl"]
