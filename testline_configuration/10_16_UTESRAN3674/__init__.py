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
    addr="10.42.80.58",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC", 
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7154747245",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="K9170432280",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH4.0_2T2R",
    radio_type="FRGY",
    serial_number="L1144802146",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="FRMrRH4.0_2T2R",
    radio_type="FRGY",
    serial_number="EA172634201",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_5 = RU(
    ru_hw_group="FRMrRH4.0_2T2R",
    radio_type="FRIE",
    serial_number="K9131115734",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805312",
    rus=[_rmod_1, _rmod_2, _rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="RW192203002",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.35",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6143709852",
    rus=[_rmod_3, _rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1143025273",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1174814982",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA144165312",
    rus=[_rmod_1, _rmod_2],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.18.62"),
    instance_id=5019,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, 
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4], 
    master=_enb_sbts_1
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.94", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.62.95", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_rnc = RNC(
    rnc_id=9,
    oms_ip=NetworkAddress("10.27.127.36"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.94.92.19", username="_nokadmin", password="password123"
    ),
)

_bsc = BSC(
    name="mcBSC-R2D2",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.4.132", username="SYSTEM", password="SYSTEM1"
    ),
)

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_2ABIA_1FSMF_2FBBC_1FXED_1FRGU_2FRGY_1FRIE_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
