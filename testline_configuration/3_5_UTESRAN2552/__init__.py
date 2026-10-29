__maintainer__ = "nanli"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "nan.3.li@nokia-sbell.com"
__owner_email__ = "nan.3.li@nokia-sbell.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, FPFH, HBTE, TopYoung
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = TopYoung(
    addr="10.56.206.183",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TOPYOUNG",
)
_pdu_2 = TopYoung(
    addr="10.56.206.184",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TOPYOUNG",
)
_pdu_3 = TopYoung(
    addr="10.56.206.185",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TOPYOUNG",
)
_pdu_4 = TopYoung(
    addr="10.56.206.186",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TOPYOUNG",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AZHA.value,
    serial_number="6Q174615534",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_8T8R",
    radio_type=RadioTypes.AZHM.value,
    serial_number="1M224940979",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2223G1B34",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="6Q181922014",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.4", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.FXCB.value,
    serial_number="1M152148149",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.2_8T8R",
    radio_type=RadioTypes.AKNB.value,
    serial_number="1M222812797",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M194808588",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS194201764",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103995",
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233400600",
    rus=[_rmod_6, _rmod_8],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1212008153",
    rus=[_rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183241587",
    rus=[_rmod_5],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214610597",
    rus=[_rmod_2, _rmod_6],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH223748785",
    rus=[_rmod_1],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH232142005",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH224041240",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_3,
        _rmod_4,
        _rmod_6,
        _rmod_8,
    ],
    oam_ip=NetworkAddress("10.106.243.14"),
    instance_id=5348,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1, _rmod_2, _rmod_5, _rmod_7], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.161.193", username="ute"),
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
    SshServiceDetails(addr="10.108.161.194", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIL_2ABIO_1ABIL_1ASIL_1ABIN_2ABIA_1AZHA_1AHCA_1AEHC_1AHLOA_1AHDB_1FXCB_5348",
)

__all__ = ["tl"]
