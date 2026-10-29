# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Katarzyna Kot"
__email__ = "katarzyna.kot@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.150", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.151", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.42.199.214", [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.199.216", [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170503975",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9170516499",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173706556",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170503702",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172804242",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173600398",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type=RadioTypes.UHBA,
    serial_number="LBALLU-YD161605C60",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type=RadioTypes.UHBA,
    serial_number="LBALLU-YD16470D7Q7",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.1", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type=RadioTypes.UHBA,
    serial_number="LBALLU-YD16470D7PC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type=RadioTypes.AAFB,
    serial_number="BL1944H1005",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type=RadioTypes.AAIB,
    serial_number="BL1943J1ZZJ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_8 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHID,
    serial_number="15W345R60100",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.8", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_9 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHID,
    serial_number="14W323R60313",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.9", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_11 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHID,
    serial_number="14W326R60311",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.7", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_8, _rmod_9, _rmod_11],
    oam_ip=NetworkAddress("10.42.20.16"),
    instance_id=101027,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_4, _rmod_5], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_2ABIA_1ASIA_2ABIA_3UHBA_3UHID_1AAFB_1AAIB",
)

__all__ = ["tl"]
