__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "8.3"
__rack__ = "GTA-930"

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

# smod port 8, 9
_pdu_1 = Gude(
    addr="10.42.60.151",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 9, 10, 11, 12
_pdu_2 = Gude(
    addr="10.42.60.152",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 1, 2, 3, 4, 5
_pdu_3 = Gude(
    addr="10.42.60.153",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2239D50KX",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.178", port=5008),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2239D50KU",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.178", port=5014),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2239D50K4",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.178", port=5013),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2241N430W",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.178", port=5004),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2242N434O",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.178", port=5005),
        ]
    ),
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2242N434R",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.178", port=5006),
        ]
    ),
)
_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251001224",
    pdu_port=_pdu_3.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.7", port=5001),
            Remote(addr="10.255.26.7", port=5002),
        ]
    ),
)
_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="K9220703785",
    pdu_port=_pdu_3.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.178", port=5015),
        ]
    ),
)
_rmod_9 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251001208",
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.6", port=5001),
            Remote(addr="10.255.26.6", port=5002),
        ]
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223901077",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223901088",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172606374",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223901113",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223901114",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224102501",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224102462",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    global_bts_id=8422, instance_id=8422
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_7, _rmod_8, _rmod_9])
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.76", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.77", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLG_2ASIL_ABIA_4ABIO_3AHLOB_3AHFII_1AEHC_2AVHA_1_UTECA",
)

__all__ = ["tl"]
