# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Justyna Spiak"
__email__ = "justyna.spiak@nokia.com"

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
    SshServiceDetails(addr="10.42.250.152", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.153", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.42.199.212", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.199.213", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_3 = Gude("10.42.199.214", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_4 = Gude("10.42.199.215", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173643738",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824726",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162818425",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173706551",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_4.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172804249",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_4.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171715640",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHLA,
    serial_number="11W324Z10098",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.7", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHLA,
    serial_number="13W355Z10018",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHLA,
    serial_number="13W336Z10027",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.4", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHID,
    serial_number="14W326R60311",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.9", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)
_rmod_6 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHID,
    serial_number="15W345R60100",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.5", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_7 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHCB,
    serial_number="17YD41036837",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_8 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHCB,
    serial_number="17YD41036845",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_9 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHCB,
    serial_number="17YD41036796",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_10 = RU(
    ru_hw_group="CPRI_A_RRH_2T2R",
    radio_type=RadioTypes.UHID,
    serial_number="14W323R60313",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.11", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_13 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type=RadioTypes.UHNA,
    serial_number="LBALLU-YD1602038NJ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.10", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_14 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type=RadioTypes.UHNA,
    serial_number="LBALLU-YD17280LTGX",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.3", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_15 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type=RadioTypes.UHNA,
    serial_number="LBALLU-YD1602038NF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.8", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_16 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type=RadioTypes.UHFD,
    serial_number="15W350D90278",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_17 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type=RadioTypes.UHFD,
    serial_number="16W340D90968",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_18 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type=RadioTypes.UHFD,
    serial_number="15W350D90268",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.2", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[11],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_6,
        _rmod_10,
        _rmod_13,
        _rmod_14,
        _rmod_15,
        _rmod_16,
        _rmod_17,
        _rmod_18,
    ],
    oam_ip=NetworkAddress("10.42.146.28"),
    instance_id=101028,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_7, _rmod_8, _rmod_9], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_3ABIA_1ASIA_1ABIA_3UHLA_3UHID_3UHCB_3UHNA_3UHFB",
)

__all__ = ["tl"]
