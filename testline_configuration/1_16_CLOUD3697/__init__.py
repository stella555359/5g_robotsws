__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TEF Germany"
__bucket__ = "CIT"
__rack__ = "GTA-833"

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

# smod port 9
# rm port 4, 5, 7, 8
_pdu_1 = Gude(
    addr="10.42.60.57",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXEB",
    serial_number="NK164202783",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXEB",
    serial_number="NK164202777",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="L1173012611",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHF",
    serial_number="L1144408722",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:123d",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808192",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:133d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171308664",
    rus=[_rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:143d",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162818408",
    rus=[_rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH241304174",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
                      global_bts_id=100745, instance_id=100745)

_pdus = [_pdu_1]

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.101", username="ute", password="ute"
    ),
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
    tl_cloud_topology="CLOUD_RF_AIBL_B1_B2_B3_2xFXEB_FRMF_FRHF_UUF_UTECA",
)

__all__ = ["tl"]
