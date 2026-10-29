__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "piotr.linek@nokia.com"
__customer__ = "Generic"
__bucket__ = "7.2"
__rack__ = "GTA-391"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.lmi import SerialOverTcp, SerialOverHost, Remote, Local
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

# sm port 3
_pdu_1 = Gude(
    addr="10.42.60.185",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 2, 3, 7, 11
_pdu_2 = Gude(
    addr="10.42.80.221",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 6, 7
_pdu_3 = Gude(
    addr="10.42.80.226",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDA",
    serial_number="K9194212386",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.81", port=5001),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245006259",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.117", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQC",
    serial_number="1M242008663",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.134", port=5001),
            Remote(addr="10.255.26.134", port=5002),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_8T8R",
    radio_type="AKQJ",
    serial_number="1M240337668",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.114", port=5001),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.2a_32T32R",
    radio_type="AQQF",
    serial_number="K9241700795",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.171", port=5005),
        ]
    ),
)
_rmod_6 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQQ",
    serial_number="1M242100046",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[6],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #         Remote(addr="", port=5002),
    #     ]
    # ),
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172606349",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234003090",
    rus=[_rmod_2, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203810548",
    rus=[_rmod_1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224206413",
    rus=[_rmod_6],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244806866",
    rus=[_rmod_5],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233001976",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240701329",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224704438",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_4],
                  instance_id=8806, global_bts_id=8806)
_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_3, _rmod_5, _rmod_6], master=_sbts_1
)
_sbts_1.slave = _sbts_2
_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.140", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.44", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_sbts_1, _sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIM_1ABIA_1ABIP_1ABIL_1ASIL_1ABIO_1ABIP_1ABIQ_1AHPMDA_1AHFII_1AKQJ_1AVQC_1AQQF_1AVQQ_3_UUFWRO",
)

__all__ = ["tl"]
