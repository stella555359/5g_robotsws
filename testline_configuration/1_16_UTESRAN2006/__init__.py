__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "kamil.nowacki@nokia.com"
__customer__ = "Generic"
__bucket__ = "5.3"
__rack__ = "GTA-1048"

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

# smod port 2
_pdu_1 = Gude(
    addr="10.42.60.140",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 2, 4
_pdu_2 = Gude(
    addr="10.42.80.23",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 7
_pdu_3 = Gude(
    addr="10.42.80.25",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2035Y20N2",
    pdu_port=_pdu_3.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.221", port=5001),
        ]
    ),
)

_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQA",
    serial_number="L1251403412",
    pdu_port=_pdu_2.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.64.6", port=5001),
            Remote(addr="10.255.64.6", port=5002)
        ]
    ),
)

_rmod_3 = RU(
    ru_hw_group="ScRMr6.1_4T4R",
    radio_type="AHCI",
    serial_number="1M240507648",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.222", port=5001),
        ]
    ),
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASOH",
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.17",
            hardware_type="ABOG",
            rus=[_rmod_1, _rmod_2, _rmod_3],
        )
    ],
    hardware_version="476255A.102",
    serial_number="L1250205197",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3],
                      instance_id=55333, global_bts_id=55333)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.22", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NL_1ASOH_1AVQA_1AHCI_1AHBCC_2_UUFWRO",
)

__all__ = ["tl"]
