__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Generic"
__bucket__ = "4.1"
__rack__ = "GTA-1542"

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
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

# smod port 8, 11
# rm port pdu_1 2, 3, 6
# rm port pdu_2 2

_pdu_1 = Gude(
    addr="10.42.80.246",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.42.80.192",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7173821292",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_2T4R_Medusa",
    radio_type="FXCC",
    serial_number="L6132919091",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.230", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7171208278",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.200", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="EA173714794",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.225", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.67",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6151214423",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.51",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172532132",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.52",
    hardware_type="FBBA",
    hardware_version="472182A.101",
    serial_number="L6132105011",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="NK163560484",
    rus=[_rmod_1, _rmod_3],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="L1132611695",
    rus=[_rmod_2, _rmod_4],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_3],
                      instance_id=8619, global_bts_id=8619)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2, _rmod_4], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.130", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.201", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_LWG_2FSMF_2FBBC_1FBBA_1FXDB_1FXCC_1FXED_1AHFB_UUF_1_UTECA",
)

__all__ = ["tl"]
