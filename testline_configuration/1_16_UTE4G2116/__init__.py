__maintainer__ = "Szymon Romanowski"
__team__ = "MN RAN Pz WRO 3 SG05"
__email__ = "szymon.romanowski@nokia.com"
__owner_email__ = "szymon.romanowski@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = Gude(addr="10.42.80.214", port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_2 = Gude(addr="10.42.80.182", port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12], model="EPC", version="8221-1")


_rmod_1 = RU(
    ru_hw_group="cMAA_Gen3.14_64T64R",
    radio_type="AAHF",
    serial_number="6Q184613868",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.128", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL1943J3028",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.130", port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216184",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163500203",
	rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173708112",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233503536",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.193", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_AIL_B1_B3_1AAHF_1AAIB_mMIMO",
)

__all__ = ["tl"]