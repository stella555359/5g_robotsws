__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Generic"
__bucket__ = "7.1"
__rack__ = "GTA-938"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.lmi import SerialOverTcp, SerialOverHost, Remote, Local
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc

# smod port 7, 8
_pdu_1 = Gude(
    addr="10.42.80.67",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 1, 3, 4, 5
_pdu_2 = Gude(
    addr="10.42.199.154",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_lab_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.199.76",
        username="NOKLAB\\plwr4goam",
        password="oampass12",
        port="9092",
    )
)

_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type="AZHA",
    serial_number="RW191708349",
    pdu_port=_pdu_2.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.94", port=5001),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="DH242224789",
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.120", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2248D5185",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.121", port=5001),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="L1240603213",
    pdu_port=_pdu_2.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.138", port=5001),
            Remote(addr="10.255.26.138", port=5002),
        ]
    ),
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223901061",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1234006999",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234205713",
    rus=[_rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234205712",
    rus=[_rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234205679",
    rus=[_rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503204",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503179",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3],
                      instance_id=8792, global_bts_id=8792)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_4], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.17", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.62.19", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_2ASIM_1ABIO_1ABIQ_3ABIP_1AZHA_1AQQL_1AHLOB_1AVQL_UUF_3_UTECA",
)

__all__ = ["tl"]
