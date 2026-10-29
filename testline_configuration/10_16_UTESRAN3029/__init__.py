# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Katarzyna Kot-Bartkowiak"
__email__ = "katarzyna.kot-bartkowiak@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.fhs import FHS
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
    addr="10.44.206.152",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.44.205.66",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)
_pdu_3 = Gude(
    addr="10.44.205.65",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)
_pdu_4 = Gude(
    addr="10.44.206.68",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="EA172750180",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="L6143341590",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type="FHKA",
    serial_number="EA172750180",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZQP",
    serial_number="1M203844931",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="1M183623606",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.134", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_9 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7153805186",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.136", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_10 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="L1151002016",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.137", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_11 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="1M171901605",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.126", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_12 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7174501710",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.27", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_13 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type="FHKA",
    serial_number="EA172750234",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.123", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_14 = RU(
    ru_hw_group="RF.FRM5.trunk.20220929.001",
    radio_type="AHDB",
    serial_number="6Q183043586",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_fhs_1 = FHS(
    fhs_type="MDEA",
    pdu_port=_pdu_2.pdu_ports[7],
    serial_number="6Q200801576",
    product_code="473922A.102",
    rus=[_rmod_14]
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="DH201592152",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181514927",
    rus=[_rmod_8, _rmod_9, _rmod_10],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204105027",
    rus=[_rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1214307726",
    rus=[_rmod_11, _rmod_12, _rmod_13],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906168",
    fhs=[_fhs_1],
    rus=[_rmod_14],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_4.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1202806388",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_4.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1204402787",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_8, _rmod_9, _rmod_10],
    oam_ip=NetworkAddress("10.42.86.171"),
    instance_id=101001,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_11, _rmod_12, _rmod_13, _rmod_14],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.178.67", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.178.68", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIB_2ABIA_1ABIO_1ASIB_1ABIO_1ABIN_2FRGP_4FXDB_3FXED_2FHKA_1AEQM_1AHDB_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
