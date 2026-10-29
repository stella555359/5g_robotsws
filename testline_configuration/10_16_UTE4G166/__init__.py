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

# PDU1  port11=ENB port12=CUS1
_pdu1 = Gude(addr="10.42.169.162", port_numbers=[11,12], model="EPC", version="8220-1")

# PDU2  port1=CUS2 port2=CUS3
_pdu2 = Gude(addr="10.42.169.163", port_numbers=[1,2], model="EPC", version="8220-1")

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB
_fsp_1 = CapacityUnit(
        addr="192.168.253.20",
        hardware_type="ABIO",
    )

_fsp_2 = CapacityUnit(
        addr="192.168.253.24",
        hardware_type="ABIN",
    )


_enb_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_pdu1.pdu_ports[11],
    hardware_type="ASIM"

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
    pdu_port=_pdu1.pdu_ports[12],
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
    pdu_port=_pdu2.pdu_ports[1],
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
    pdu_port=_pdu2.pdu_ports[2],
    hardware_type="ASIA"
)
_cus3_airscale1 = Airscale(common_units=[_cus3_common_unit1])
_cus3 = CUS(l1=_cus3_airscale1)

# TestPC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.93",
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
        )
    ]
)

    
tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_*_CUS",
    ues=[_cus1, _cus2, _cus3],
    pdus=[_pdu1,_pdu2],
)
__all__ = ["tl"]
