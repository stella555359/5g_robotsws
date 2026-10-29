__maintainer__ = "Malgorzata Piecyk-Celuch"
__team__ = "siso"
__email__ = "malgorzata.piecyk-celuch@nokia.com"
__owner_email__ = "malgorzata.piecyk-celuch@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.42.169.6", [9, 10], "EPC", "8220-1")
_pdu_2 = Gude("10.42.168.100", [3, 4, 5], "EPC", "8220-1")
_pdu_3 = Gude("10.42.168.107", [3], "EPC", "8221-1")

_rmod_1 = RU(
    radio_type=RadioTypes.AHEGC.value,
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA200262091",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    radio_type=RadioTypes.AHFIB.value,
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL1909V001Y",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_3 = RU(
    radio_type=RadioTypes.AHEGG.value,
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="RW233401186",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_4 = RU(
    radio_type=RadioTypes.AHCA.value,
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="L1172402488",
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1204104979",
    pdu_port=_pdu_1.pdu_ports[9],
    rus=[_rmod_1, _rmod_3],
    #    hardware_version="475266A.101",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1164413220",
    pdu_port=_pdu_1.pdu_ports[9],
    rus=[_rmod_1, _rmod_2, _rmod_3],
    #    hardware_version="473096A.102",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1211506476",
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_2],
    #    hardware_version="475266A.102",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1170303231",
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_4],
    #    hardware_version="475266A.102",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIB",
    #    hardware_version="473764A.102",
    serial_number="L1192405936",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIB",
    #    hardware_version="473764A.102",
    serial_number="L1204202688",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.174.208"),
    instance_id=1464,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_4],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2


_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.42.91.81"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.44.90", username="SYSTEM", password="SYSTEM"
    ),
)

_bsc = BSC(
    name="asBSC_21",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.28.126", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.141", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.184.28", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
