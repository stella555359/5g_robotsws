__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "STRESSED_TEST_LINES"
__rack__ = "GTA-391"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

# ************************************************ PDUs ************************************************

# smod port 5-ASIL1, 6-ASIL2
_pdu_1 = Gude(
    addr="10.42.60.185",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 9-AHLOA2, 10-AHFIB2, 11-AHFIB1, 12-AEHC2
_pdu_2 = Gude(
    addr="10.42.199.208",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 4-AHLOA3, 7-AEHC3
_pdu_3 = Gude(
    addr="10.42.80.20",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# rm port 9-AEHC1, 10-AHLOA1, 11-AHFIB3
_pdu_4 = Gude(
    addr="10.42.80.217",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

# ************************************************ RMs *************************************************

_ahloa1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G102Z",
    pdu_port=_pdu_4.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.53", port=5001),
        ]
    ),
)

_ahloa2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="K9182017483",
    pdu_port=_pdu_2.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.51", port=5001),
        ]
    ),
)

_ahloa3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2003G10RY",
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.52", port=5001),
        ]
    ),
)

_ahfib1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1945V00KQ",
    pdu_port=_pdu_2.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.56", port=5001),
        ]
    ),
)
_ahfib2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1944V00EN",
    pdu_port=_pdu_2.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.55", port=5001),
        ]
    ),
)
_ahfib3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9181046194",
    pdu_port=_pdu_4.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.54", port=5001),
        ]
    ),
)
_aehc1 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="K9222600543",
    pdu_port=_pdu_4.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.167", port=5001),
        ],
    ),
)

_aehc2 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH231800662",
    pdu_port=_pdu_2.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.167", port=5003),
        ],
    ),
)

_aehc3 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH231800612",
    pdu_port=_pdu_3.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.167", port=5002),
        ],
    ),
)

_abil3_l = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0301",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA213653715",
    rus=[_ahfib3],
)
_abil2_l = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0201",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA194457485",
    rus=[_ahfib1, _ahfib2],
)
_abil1_l = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA213653796",
    rus=[_ahloa1, _ahloa2, _ahloa3],
)
_abio1_r = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:1101",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010381",
    rus=[_aehc1, _aehc2, _aehc3],
)

_asil1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abil1_l, _abil2_l, _abil3_l],
    pdu_port=_pdu_1.pdu_ports[5],
)
_asil2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abio1_r],
    pdu_port=_pdu_1.pdu_ports[6],
)

_airscale_asil1 = Airscale([_asil1])
_airscale_asil2 = Airscale([_asil2])

_sbts_1 = RealEnb(
    system_module=_airscale_asil1,
    rms=[_ahfib1, _ahfib2, _ahfib3, _ahloa1, _ahloa2, _ahloa3, _aehc1, _aehc2, _aehc3],
    global_bts_id=55273,
    instance_id=55273,
)
_sbts_2 = RealEnb(
    system_module=_airscale_asil2,
    rms=[_ahfib1, _ahfib2, _ahfib3, _ahloa1, _ahloa2, _ahloa3, _aehc1, _aehc2, _aehc3],
    master=_sbts_1
)

_sbts_1.slave = _sbts_2

# ************************************************ VMs ************************************************
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.133.70", username="ute", password="qwe123QWE!@#"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.133.71", username="ute", password="qwe123QWE!@#"
    ),
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
    tl_cloud_topology="CLOUD_SRAN_N_HEDORA_1_UUFWRO",
    pdus=_pdus,
)

__all__ = ["tl"]
