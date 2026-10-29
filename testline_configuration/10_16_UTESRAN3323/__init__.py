# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Katarzyna Kot"
__email__ = "katarzyna.kot@nokia.com"

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
    addr="10.44.200.134", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8041-1",
)
_pdu_2 = Gude(
    addr="10.44.205.209", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8041-1",
)
_pdu_3 = Gude(
    addr="10.44.177.163", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8221-1",
)
_pdu_4 = Gude(
    addr="10.44.205.65", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8041-1",
)
_pdu_5 = Gude(
    addr="10.44.200.176", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXCB",
    serial_number="1M173459078",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.10.128", port=2323),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHLOA",
    serial_number="BL2032G1GNG",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.37.129", port=2323),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_3 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FRHG",
    serial_number="K9170831633",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.11.127", port=2323),
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="EA201652664",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.128", port=2323),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type="AZNA",
    serial_number="6Q190109592",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.37.129", port=2323),
    pdu_port=_pdu_1.pdu_ports[9],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183943076",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213615729",
    rus=[_rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221801861",
    rus=[_rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183943037",
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_3],
    pdu_port=_pdu_5.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1191304508",
)
_fct_2 = CommonUnit(
    SshServiceDetails(addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_2, _fsp_4],
    pdu_port=_pdu_5.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192405956",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_4],
    oam_ip=NetworkAddress("10.42.86.161"),
    instance_id=100788,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_3, _rmod_5 ],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.181", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.156.182", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIB_1ABIA_1ABIO_1ASIB_1ABIN_1ABIA_1FRHG_1FXCB_1AHLOA_1AHDB_1AZNA_UTECA",
)

__all__ = ["tl"]

