__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "8.8"
__rack__ = "GTA-366"

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

# smod port 4, 8
_pdu_1 = Gude(
    addr="10.42.80.164",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
_pdu_2 = Gude(
    addr="10.42.80.159",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH243521988",
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.102", port=5001),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH243522065",
    pdu_port=_pdu_2.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.144", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH243521986",
    pdu_port=_pdu_2.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.141", port=5001),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2317N451A",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.150", port=5001),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9244348163",
    pdu_port=_pdu_2.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.155", port=5001),
        ]
    ),
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2339N49IK",
    pdu_port=_pdu_2.pdu_ports[6],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.149", port=5001),
        ]
    ),
)
_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1245105077",
    pdu_port=_pdu_2.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.200", port=5001),
            # Remote(addr="10.255.26.200", port=5002),
        ]
    ),
)
_rmod_8 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1245105078",
    pdu_port=_pdu_2.pdu_ports[8],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.201", port=5001),
            # Remote(addr="10.255.26.201", port=5002),
        ]
    ),
)
_rmod_9 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1245105075",
    pdu_port=_pdu_2.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.202", port=5001),
            Remote(addr="10.255.26.202", port=5002),
        ]
    ),
)
_rmod_10 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQQA",
    serial_number="L1243403559",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.26", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.205", port=5001),
            Remote(addr="10.255.26.205", port=5002),
        ]
    ),
)
_rmod_11 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQQA",
    serial_number="L1243403560",
    pdu_port=_pdu_2.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.204", port=5001),
            Remote(addr="10.255.26.204", port=5002),
        ]
    ),
)
_rmod_12 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQQA",
    serial_number="L1243403558",
    pdu_port=_pdu_2.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.203", port=5001),
            Remote(addr="10.255.26.203", port=5002),
        ]
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234301802",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234003074",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_3 = CapacityUnit(
    addr="92.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234003077",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="92.168.253.44",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231807390",
    rus=[_rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240607077",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240607082",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3],
                      global_bts_id=55294, instance_id=55294)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
    ],
)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.81", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.82", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_2ASIM_4ABIP_3AHLOB_3AHFII_3AVHA_3AVQQA_UTECA",
)

__all__ = ["tl"]
