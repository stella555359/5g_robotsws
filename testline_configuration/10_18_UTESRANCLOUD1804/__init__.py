# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Ovidiu Popa"
__email__ = "ovidiu.popa@nokia.com"

from taf.config.testline.airscale import Airscale
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote


_pdu_1 = Gude(
    addr="10.255.1.67",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

MUMIN_AHLOA_BL1844G11L5 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.9"), port=5001)])
MUMIN_AHLOA_BL2248G1DID = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.9"), port=5002)])
MUMIN_AHFIB_BL2108V05C1  = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.9"), port=5003)])
MUMIN_AHFIB_BL2146V0QE6 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.9"), port=5004)])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1844G11L5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
    lmi=MUMIN_AHLOA_BL1844G11L5,
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2248G1DID",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    lmi=MUMIN_AHLOA_BL2248G1DID,
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2108V05C1",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    lmi=MUMIN_AHFIB_BL2108V05C1,
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2146V0QE6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
    lmi=MUMIN_AHFIB_BL2146V0QE6,
)

_rmod_5 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AVHA",
    serial_number="L1244007372",
   default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.10", port=2323
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521984",
	rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164816641",
	rus=[_rmod_3, _rmod_4],

)
_fsp_3 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233704793",
	rus=[_rmod_5],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1204214732",
	rus=[_rmod_3, _rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233402507",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233402509",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.15.236.204"),
    instance_id=10804,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3,_rmod_4,_rmod_5], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.43", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.44", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1,]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_10804_1ASIM_1ABIO_1ABIA_1ASIM_2ABIP_2AHLOA_2AHFIB_1AVHA",
   )





__all__ = ["tl"]

