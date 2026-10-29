__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "piotr.linek@nokia.com"
__customer__ = "Generic"
__bucket__ = "5.1"
__rack__ = "GTA-880"

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

# smod port 10
# rm port 6, 12
_pdu_1 = Gude(
    addr="10.42.80.107",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP ",
    radio_type="AZRB",
    serial_number="1M185214780",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH192700105",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASOF",
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.17",
            hardware_type="ABOF",
            rus=[_rmod_1, _rmod_2],
        )
    ],
    hardware_version="476147A.101",
    serial_number="EA232850516",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2],
                      instance_id=8647, global_bts_id=8647)

_pdus = [_pdu_1]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.234", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_1ASOF_1AHFB_1AZRB_UTECA",
)

__all__ = ["tl"]
