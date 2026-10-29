__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Reliance India"
__bucket__ = "6.8"
__rack__ = "GTA-890"

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

# smod port 10
_pdu_1 = Gude(
    addr="10.42.60.80",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 5, 6, 7, 8
_pdu_2 = Gude(
    addr="10.42.60.82",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

# _lab_pc = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.42.199.76",
#         username="NOKLAB\\plwr4goam",
#         password="oampass12",
#         port="9092",
#     )
# )

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPB",
    serial_number="DH242335041",
    pdu_port=_pdu_2.pdu_ports[6],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.26.240", port=5001),
    #     ],
    # ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPJ",
    serial_number="K9232737231",
    pdu_port=_pdu_2.pdu_ports[5],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.26.240", port=5001),
    #     ],
    # ),
)
_rmod_3 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQA",
    serial_number="L1251403401",
    pdu_port=_pdu_2.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.26.198", port=5001),
    #     ],
    # ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQA",
    serial_number="L1251403411",
    pdu_port=_pdu_2.pdu_ports[8],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.26.198", port=5001),
    #     ],
    # ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244007811",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403343",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
                      global_bts_id=55345, instance_id=55345)

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.152", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_N_1ASIM_1ABIP_1AHPB_1AHPJ_2AVQA_1_UUFWRO",
)

__all__ = ["tl"]
