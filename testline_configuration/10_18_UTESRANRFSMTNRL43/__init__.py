__maintainer__ = "alin.bacos@nokia.com"
__owner__ = "alin.bacos@nokia.com"
__email__ = "alin.bacos@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.optical_switch import Calient
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote

# BTS1 Primary Core
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.177", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
# BTS1 Secondary Core
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.178", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# BTS2
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.179", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.255.5.108",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude(
    "10.255.5.109",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2214N400N",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.128 ", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.43",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM4"
            )
        ]
    )
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="YK234700040",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.45.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.43",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM5"
            )
        ]
    )
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233203457",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223303266",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164303987",
    rus=[_rmod_1],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233201704",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240903560",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233406394",
    test_pc=_test_pc_2,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1211905257",
    test_pc=_test_pc_3,
)

_smod_1 = Airscale([_fct_1, _fct_2])
_smod_2 = Airscale([_fct_3])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=623043,
    oam_ip=NetworkAddress("10.0.69.43"),
    bcf_id="3043",
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[1],
        interface_type="lmp",
    )
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2],
    instance_id=624043,
    oam_ip=NetworkAddress("10.0.71.43"),
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)
_rnc = RNC(
    rnc_id=8,
    oms_ip="10.44.44.219",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="root", password="root"
    ),
)
_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)

_calient = Calient(
    addr="10.255.5.250",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
    )

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_lte_1, _enb_lte_2],
    rncs=[_rnc],
    bscs=[_bsc],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL43",
    optical_switches=[_calient],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RSI_INFO_COLLECT": False,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_RMOD_UDP_LOG_COLLECT": False,
}

OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL43/optical_switch_ports.yaml"
)

__all__ = ["tl"]
