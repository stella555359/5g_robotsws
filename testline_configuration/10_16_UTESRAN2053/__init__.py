# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Grzegorz Niedzwiedz"
__email__ = "grzegorz.niedzwiedz@nokia.com"

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
    addr="10.42.199.194",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.42.199.195",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXFC",
    serial_number="F7144036502",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.209", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXFC",
    serial_number="F7144036508",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRIE",
    serial_number="K9124916946",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.213", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRIE",
    serial_number="K9124916942",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.212", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_5 = RU(
    ru_hw_group="FRMr4.0b_4T2R_Corona",
    radio_type="FRBG",
    serial_number="K9172901321",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.216", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMr4.0b_4T2R_Corona",
    radio_type="FRBG",
    serial_number="K9172901385",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_7 = RU(
    ru_hw_group="FRMr4.0b_4T2R_Corona",
    radio_type="FRBG",
    serial_number="K9172901358",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.218", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.50",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6151242925",
    rus=[_rmod_3, _rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.51",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK161830266",
    rus=[_rmod_5, _rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="F7142844218",
    rus=[_rmod_1, _rmod_2],
)

_smod_1 = Flexi([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.42.182.25"),
    instance_id=101014,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.137", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_L_1FSMF_2FBBC_2FXFC_2FRIE_3FRBG_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
