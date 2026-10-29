__owner__ = "haosheng"
__maintainer__ = "haosheng"
__email__ = "haoyun-lyle.sheng@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc


#ASIA
_pdu_1 = FACOM(addr="10.69.66.101",port_numbers=[5])
#FHEF*2
_pdu_2 = FACOM(addr="10.56.7.123",port_numbers=[4, 6])
#URCC
_pdu_3 = FACOM(addr="10.56.7.238",port_numbers=[1])
#AHLBA
_pdu_4 = HBTE(addr="10.106.173.25",port_numbers=[4])
#AHBB*2
_pdu_5 = FACOM(addr="10.106.211.92",port_numbers=[3, 5])


_rmod_1 = RU(
    ru_hw_group="OBSAI_RRH_2T2R",
    radio_type="FHEF",
    serial_number="1M154518779",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="CPRI_FJ_RRH_2T2R",
    radio_type="URCC",
    serial_number="TC09FH0003",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="OBSAI_RRH_2T2R",
    radio_type="FHEF",
    serial_number="1M154518755",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="CPRI_RRH_2T2R",
    radio_type="AHLBA",
    serial_number="K9183736591",
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="CPRI_N_RRH_2T4R",
    radio_type="AHBB",
    serial_number="EA191010967",
    pdu_port=_pdu_5.pdu_ports[3],
)

_rmod_6 = RU(
    ru_hw_group="AHBB:CPRI_A_RRH_2T4R",
    radio_type="AHBB",
    serial_number="EB191760383",
    pdu_port=_pdu_5.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="AH173607787",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="6Q174523229",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts = RealEnb(
    system_module=_smod_1, 
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.56.7.92"),
    instance_id=2482,
)

_test_pc = TestPc(
    SshServiceDetails(addr="10.106.233.216", username="ute", password="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp")
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_AIR_B4_CRT_1068",
)

__all__ = ["tl"]
