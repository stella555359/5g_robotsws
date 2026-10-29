__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "x"
__rack__ = "GTA-881"

from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU, DU
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

# smod port 12 rm port 11
_pdu_sm = Gude(
    addr="10.42.80.185",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# rm port 4
_pdu_2 = Gude(
    addr="10.42.80.61",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# rm port 11
_pdu_3 = Gude(
   addr="10.42.80.107",
   port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
   model="EPC",
   version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH231800627",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.250", port="4007"),
        ],
    )
)

_rmod_2 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="AH191500066",
    pdu_port=_pdu_3.pdu_ports[11],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="EA173714597",
    pdu_port=_pdu_sm.pdu_ports[11],
)

_abil = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:10b",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH212564320",
    rus=[],
)

_abin = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:20b",
    hardware_type="ABIN",
    hardware_version="474723A.101",
    serial_number="6Q191215381",
    rus=[_rmod_1],
)

_abia = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:30b",
    hardware_type="ABIA",
    hardware_version="474723A.101",
    serial_number="AH180603446",
    rus=[_rmod_2],
)

_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil, _abin, _abia],
    pdu_port=_pdu_sm.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="473098A.102",
    serial_number="L1204208745",
)

_smod_1 = Airscale([_asib])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2],
                      global_bts_id=4052, instance_id=4052)

_pdus = [_pdu_sm]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.148", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_L_1ASIB_1ABIA_2ABIC_1AZRB_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
