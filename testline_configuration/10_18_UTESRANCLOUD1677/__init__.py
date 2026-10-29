__maintainer__ = "Valentin Suru"
__email__ = "valentin.suru@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = Gude(
    addr="10.255.1.90",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
	version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.91",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
	version="8220-1",
)

_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH221403536", pdu_port=_pdu_1.pdu_ports[6])

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.104",
    serial_number="L1164817872",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="A.104",
    serial_number="AH184206889",
    capacity_units=[_fsp_1],
)

_smod_1  = Flexi([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.47.14", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_10677_AIL_B4_3628_2CL1_T4_M_98_AZQC_CBRS_1",
)


__all__ = ["tl"]
