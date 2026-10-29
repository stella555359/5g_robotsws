__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "kamil.szczesniak@nokia.com"
__customer__ = "Generic"
__bucket__ = "3.2"
__rack__ = "GTA-1535"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

# ASIB port 12 ASIA 11
# FZNI port 2, FHFB 5
_pdu_1 = Gude(
    addr="10.42.60.56",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

# FXJB port 12
_pdu_2 = Gude(
    addr="10.42.60.57",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

# ARGA port 8, AHLOA 9
_pdu_3 = Gude(
    addr="10.42.60.86",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARGA",
    serial_number="AS212802821",
    pdu_port=_pdu_3.pdu_ports[8],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.71", port=5001),
        ]
    ),
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2027G1ATL",
    pdu_port=_pdu_3.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.68", port=5001),
        ]
    ),
)

_rmod_3 = RU(
    ru_hw_group="FRMTDr2.2_4T4R",
    radio_type="FZNI",
    serial_number="K9163123204",
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="L1151403687",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXJB",
    serial_number="K9170734958",
    pdu_port=_pdu_2.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.102",
    serial_number="L1250309183",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172908904",
    rus=[_rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171611613",
)
_fsp_4 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:223d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171321510",
    rus=[_rmod_3],
)
_fsp_5 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:233d",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808119",
    rus=[_rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:243d",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="L1172903748",
    rus=[_rmod_5],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1230408172",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1172804242",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_4],
                      instance_id=8644, global_bts_id=8644)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2, _rmod_3, _rmod_5], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.39", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.62.40", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_LWG_ASIB_ASIA_ABIO_5ABIA_1FHFB_1AHLOA_1ARGA_1FZNI_1FXJB_UUF_1_UTECA",
)

__all__ = ["tl"]
