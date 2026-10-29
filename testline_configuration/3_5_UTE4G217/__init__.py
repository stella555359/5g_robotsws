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
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = HBTE(
    addr="10.108.151.210",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="HBTE",
)
_pdu_2 = FPFH(
    addr="10.108.151.88",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_3 = FACOM(
    addr="10.108.166.202",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_4 = FACOM(
    addr="10.108.166.201",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_5 = TopYoung(
    addr="10.106.205.36",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TOPYOUNG",
)
_pdu_6 = FPFH(
    addr="10.108.151.106",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_7 = FPFH(
    addr="10.106.205.135",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)


_rmod_1 = RU(
    ru_hw_group="FRMTDr3.4_AAS_64T64R",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M202800030",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M193000206",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.FXED.value,
    serial_number="1M180417795",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_7.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.FXCA.value,
    serial_number="K9151716311",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M194808589",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.4", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="EA222959262",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.3", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.FXEB.value,
    serial_number="1M164856169",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_6.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650627",
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172230629",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214208638",
    rus=[_rmod_1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1174201714",
    rus=[_rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1182603804",
    rus=[_rmod_7],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213014329",
    rus=[_rmod_5, _rmod_6],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212563170",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1185203389",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
    ],
    oam_ip=NetworkAddress("10.108.151.211"),
    instance_id=6490,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.205.57", username="ute"),
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
    SshServiceDetails(addr="10.106.205.58", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIB_1ABIL_2ABIN_3ABIA_1AEQP_1FXED_1FXEB_1FXCA_1FRBI",
)

__all__ = ["tl"]
