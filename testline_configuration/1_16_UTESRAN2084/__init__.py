__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "piotr.frydryszak@nokia.com"
__customer__ = "Reliance India"
__bucket__ = "6.7"
__rack__ = "GTA-TS190"

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

# ********* PDU *********
# sm port 8; rm port 11, 12
_pdu_1 = Gude(
    addr="10.42.199.144",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# ********* RMODS *********
_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVNB",
    serial_number="1M252709278",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVNB",
    serial_number="1M252709276",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[11],
)

# ********* BBMODS **********
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244007751",
    rus=[_rmod_1, _rmod_2],
)
#_fsp_2 = CapacityUnit(
#    addr="192.168.253.24",
#    hardware_type="ABIO",
#    hardware_version="475266B.102",
#    serial_number="L1250309212",
#    rus=[_rmod_2],
#)

# ********* SMOD *********
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403336",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2],
    global_bts_id=55340, instance_id=55340
)

_pdus = [_pdu_1]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.50", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIM_1ABIP_1ABIO_2AVNB_UUF_1_UUFWRO",
)

__all__ = ["tl"]
