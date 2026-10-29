__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "8.11"
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

# smod port 5
_pdu_1 = Gude(
    addr="10.42.60.80",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 1, 2, 12 AWMFIA
_pdu_2 = Gude(
    addr="10.42.60.38",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 10, 11, 12 AWHHJ
_pdu_3 = Gude(
    addr="10.42.80.26",
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
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AWMFIA",
    serial_number="AH252311419",
    pdu_port=_pdu_2.pdu_ports[8],
    lmi=SerialOverTcp(
         uart_mapping=[
             Remote(addr="10.42.60.166", port=5002),
         ],
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AWMFIA",
    serial_number="AH252311421",
    pdu_port=_pdu_2.pdu_ports[9],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #     ],
    # ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AWMFIA",
    serial_number="AH252311433",
    pdu_port=_pdu_2.pdu_ports[10],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #     ],
    # ),
)
_rmod_4 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHHJ",
    serial_number="1M244307340",
    pdu_port=_pdu_3.pdu_ports[4],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #     ],
    # ),
)
_rmod_5 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHHJ",
    serial_number="1M244307342",
    pdu_port=_pdu_3.pdu_ports[6],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #     ],
    # ),
)
_rmod_6 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHHJ",
    serial_number="1M244307345",
    pdu_port=_pdu_3.pdu_ports[5],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #     ],
    # ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105756",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244806868",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403420",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
                      global_bts_id=55347, instance_id=55347)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.175", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIM_2ABIP_3AWMFIA_3AWHHJ_2_UUFWRO",
)

__all__ = ["tl"]
