__maintainer__ = "UUF"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Generic"
__bucket__ = "9"

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

# rm port 10, 12
_pdu_1 = Gude(
    addr="10.42.60.49",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

# smod port 8
_pdu_2 = Gude(
    addr="10.42.60.80",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRMC",
    serial_number="F7161830671",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7154832808",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213014352",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906165",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1215007921",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.108", username="ute"),
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
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_AIBL_B1_B2_FRMC_FXED_UTECA",
)

__all__ = ["tl"]
