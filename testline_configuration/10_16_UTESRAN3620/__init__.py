# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Tomasz Marchewka"
__email__ = "tomasz.marchewka@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude(
    addr="10.42.63.107",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="F7173113640",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7171106679",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.19.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="FRMTDr2.2_4T4R",
    radio_type="FZNI",
    serial_number="K9183309682",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.136", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMTDr2.2_4T4R",
    radio_type="FZNI",
    serial_number="RY133408936",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="FRMTDr2.2_4T4R",
    radio_type="FZNI",
    serial_number="K9183309681",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.134", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARCA",
    serial_number="F7194708291",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173008347",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.27",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171715495",
    rus=[_rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.31",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824726",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1204200055",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.42.18.51"),
    instance_id=5014,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.22", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LG_ASIB_3ABIA_3FZNI_ARCA_FRGT_FXED_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
