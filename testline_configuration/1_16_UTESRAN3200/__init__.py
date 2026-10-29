__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "AMID"
__bucket__ = "x"
__rack__ = "GTA-890"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

# rm port 6, 7, 10, 11
_pdu_1 = Gude(
    addr="10.42.80.174",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# smod port 3, 5,
# rm port 6
_pdu_2 = Gude(
    addr="10.42.60.49",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCA",
    serial_number="BL1914M002H",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.89", port=5001),
        ]
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2114G1A84",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.88", port=5001),
        ]
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9183827300",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.90", port=5001),
        ]
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXCB",
    serial_number="1M143530861",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_5 = RU(
    ru_hw_group="FRMr4.0a_2T2R_Corona",
    radio_type="FRCG",
    serial_number="K9154711329",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_abio_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1214804897",
    rus=[_rmod_2],
)
_abio_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1224305513",
    rus=[_rmod_1],
)
_abia_1 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1182901075",
    rus=[_rmod_4],
)
_abio_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1214706787",
    rus=[_rmod_5],
)
_abio_4 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH222548205",
    rus=[_rmod_3],
)

_asil_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abio_2, _abia_1],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1203803785",
)
_asil_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_3, _abio_4],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224704402",
)

_smod_1 = Airscale([_asil_1])
_smod_2 = Airscale([_asil_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_4])
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_5], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.100", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.101", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIL_1ABIA_4ABIO_1AHBCA_1AHLOA_1AHFIB_1FXCB_1FRCG_UTECA",
)

__all__ = ["tl"]
