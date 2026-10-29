__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "mikolaj.lukaszewicz@nokia.com"
__customer__ = "UUF"
__bucket__ = "Special"

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


# ************************************************ PDUs ************************************************
# rm port 1, 2

_pdu_1 = Gude(
    addr="10.42.80.162",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# smod port 7
_pdu_2 = Gude(
    addr="10.42.80.164",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu_1, _pdu_2]

# ************************************************ RMs *************************************************
_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQC",
    serial_number="1M241103666",
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="L1231007796",
    pdu_port=_pdu_1.pdu_ports[2],
)


# ************************************************ ENB1 ************************************************

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASOE",
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.20",
            hardware_type="ABOE",
            rus=[_rmod_1, _rmod_2],
        )
    ],
    hardware_version="475587A.103",
    serial_number="DH224811715",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2],
                      global_bts_id=55255, instance_id=55255)

# ************************************************ VMs ************************************************

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.131", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

# ************************************************ SUM ************************************************

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_KANDELABR_UUFWRO",
)

__all__ = ["tl"]
