# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Aleksandra Trojak"
__email__ = "aleksandra.trojak@nokia.com"

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
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHEC",
    serial_number="6Q184414297",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="EA194260475",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXEB",
    serial_number="K9150528126",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="K9172602434",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.127", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_64T64R",
    radio_type="AEQP",
    serial_number="1M203309440",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2 ", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="K9172347993",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.125", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010371",
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1213805928",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223310039",
    rus=[_rmod_5],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173706552",
    rus=[_rmod_7],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906207",
    rus=[_rmod_4],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH212564284",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190601867",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH200762649",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_3, _rmod_5],
    oam_ip=NetworkAddress("10.42.183.24"),
    instance_id=101003,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, 
    rms=[_rmod_1, _rmod_4, _rmod_7], 
    master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.146", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.147", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIN_1ASIB_1ABIA_1ABIN_1ABIL_1AHEC_1AHDB_1FXEB_2FHFB_1AEQP_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
