__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "kamil.nowacki@nokia.com"
__customer__ = "AVENA"
__bucket__ = "AVENA"
__rack__ = "GTA-822"

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

########### PDUS ###########

# smod port 11
_pdu_1 = Gude(
    addr="10.42.80.142",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 1, 2, 3, 4, 5, 7
_pdu_2 = Gude(
    addr="10.42.80.195",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

########### RMODS ###########

_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="1M223901282",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.112", port=5001),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="1M223901280",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.113", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="1M223901281",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.126", port=5001),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPJ",
    serial_number="K9232737230",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.227", port=5001),
        ]
    ),
)


_rmod_6 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVNB",
    serial_number="1M255012803",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVNB",
    serial_number="1M255012805",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[7],
)
########### BBMODS ###########

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234103477",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232001212",
    rus=[_rmod_6, _rmod_7],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266B.102",
    serial_number="L1250309217",
    rus=[_rmod_6, _rmod_7],
)

########### SMODS ###########

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403351",
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(system_module=_smod_1,
                      rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_6, _rmod_7],
                      global_bts_id=55442, instance_id=55442)


_pdus = [_pdu_1, _pdu_2]

########### VMS ###########

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.9", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
# _test_pc_2 = TestPc(
#     SshServiceDetails(addr="10.42.133.10", username="ute"),
#     connections=[
#         Connection(
#             interface="eth1",
#             device=_enb_sbts_2.system_module.common_units[0],
#             interface_type="lmp",
#         )
#     ],
# )

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NL_PAPAMOBILE_AUTODRIVE_UUFWRO",
)

__all__ = ["tl"]
