__maintainer__ = "UUF"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "x"

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

# rm port 1, 2, 3, 4, 5, 6, 7, 8
_pdu_1 = Gude(
    addr="10.42.199.199",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# smod port 11, 12
_pdu_2 = Gude(
    addr="10.42.80.233",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="K9192414083",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIA",
    serial_number="K9192534205",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="K9193037131",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIA",
    serial_number="K9192534009",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="AH191500098",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="AH191500066",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="AH191500186",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_8 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="AH191500080",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174908001",
    rus=[_rmod_1, _rmod_2],
)
# _fsp_2 = CapacityUnit(
#     addr="192.168.253.24",
#     hardware_type="ABIA",
#     hardware_version="473096A.103",
#     serial_number="K9174929944",
# )
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602128",
    rus=[_rmod_3, _rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602178",
    rus=[_rmod_5, _rmod_6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171312775",
    rus=[_rmod_7, _rmod_8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1171407044",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173104605",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_5, _rmod_6, _rmod_7, _rmod_8], master=_enb_sbts_1
)

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.83.159", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.83.160", username="ute"),
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
    tl_cloud_topology="CLOUD_RF_AIL_B1_B3_AIR_B4_B5_2AHFIC_2AHFIA_4AZRB_UTECA",
)

__all__ = ["tl"]
