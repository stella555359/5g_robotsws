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
    addr="10.42.80.49",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.42.80.22",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3 = Gude(
    addr="10.42.80.24",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


_rmod_1 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2018J304F",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL2018HI02Z",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2014J3017",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.1", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL2019H206T",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHLOA",
    serial_number="BL2040G1M6T",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.3", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHLOA",
    serial_number="BL2040G1M59",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171402084",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171321502",
    rus=[_rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170113666",
    rus=[_rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164819598",
    rus=[_rmod_7, _rmod_8],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171420174",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171209419",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_6],
    oam_ip=NetworkAddress("10.42.20.11"),
    instance_id=19772,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_7, _rmod_8,
    ],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.198", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.199", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_2ABIA_1ASIA_2ABIA_2AHLOA_2AAFB_2AAIB_UTECA",
)

__all__ = ["tl"]
