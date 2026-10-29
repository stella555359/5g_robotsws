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
    addr="10.108.153.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="HBTE",
)
_pdu_2 = FPFH(
    addr="10.106.245.165",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_3 = HBTE(
    addr="10.108.190.131",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="HBTE",
)

_rmod_1 = RU(
    ru_hw_group="FRMTDr3.4_AAS_64T64R",
    radio_type=RadioTypes.AAHF.value,
    serial_number="1M184743620",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMTDr3.3_8T8R",
    radio_type=RadioTypes.FZHR.value,
    serial_number="6Q165015097",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMTDr3.3_8T8R",
    radio_type=RadioTypes.FZHR.value,
    serial_number="6Q163504141",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9173315815",
    rus=[],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIC",
    hardware_version="474723A.101",
    serial_number="6Q191328176",
    rus=[],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIC",
    hardware_version="474723A.101",
    serial_number="6Q191328179",
    rus=[_rmod_1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170304501",
    rus=[_rmod_2],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="EA194262279",
    rus=[],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170501105",
    rus=[_rmod_3],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191004957",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1190309131",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.108.161.127"),
    instance_id=6474,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2, _rmod_3], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.161.191", username="ute"),
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
    SshServiceDetails(addr="10.108.161.192", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_L_1ASIB_2ABIC_1ABIA_1ASIB_2ABIA_1ABIC_2FZHR_1AAHF_6474",
)

__all__ = ["tl"]
