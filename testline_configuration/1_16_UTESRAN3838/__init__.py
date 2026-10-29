__maintainer__ = "UUF"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "AIS Thailand"
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

# smod port 6, 9 (lenny face)
_pdu_1 = Gude(
    addr="10.42.80.233",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 5, 6, 7, 8
_pdu_2 = Gude(
    addr="10.42.199.198",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 2, 3
_pdu_3 = Gude(
    addr="10.42.199.197",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_2_2T4R_VirtWB",
    radio_type="AHEGA",
    serial_number="K9183214914",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_2_2T4R_VirtWB",
    radio_type="AHEGA",
    serial_number="K9181423233",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_2_2T4R_VirtWB",
    radio_type="AHEGA",
    serial_number="K9191619148",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_2_2T4R_VirtWB",
    radio_type="AHEGA",
    serial_number="K9183214911",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_2_2T4R_VirtWB",
    radio_type="AHEGA",
    serial_number="K9181425767",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_2_2T4R_VirtWB",
    radio_type="AHEGA",
    serial_number="K9191619185",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172606286",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171218680",
    rus=[_rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173117564",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162013357",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.83.219", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.83.220", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_LW_2ASIA_2ABIA_6AHEGA_UTECA",
)

__all__ = ["tl"]
