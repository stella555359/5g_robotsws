__maintainer__ = "Pawel Duzalski"
__email__ = "pawel.duzalski@nokia.com"
__team__ = "siso"

from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.flexi import Flexi
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.44.167.141", [1, 2, 4, 6, 7, 8, 10, 11, 12], "EPC", "8221-1") #FPFH-port9; ASIB left-port8, ASIB right-port10; FPFH-port11
_pdu_2 = Gude("10.44.167.128", [1, 2, 4], "EPC", "8221-1") #AZNA ports 1,2,4
_pdu_3 = Gude("10.44.167.140", [6, 8, 10, 11], "EPC", "8221-1") #AHEC ports 6,8,10
_pdu_4 = Gude("10.44.167.131", [3, 4], "EPC", "8221-1")
# _pdu_3 = FPFH(port_numbers=[1, 2, 3, 4, 5, 6], addr="10.42.201.82", login="admin", password="admin",)
# _pdus = [_pdu_1, _pdu_2]
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_rmod_1 = RU(
    ru_hw_group='FRMr5.1_1_6T6R',
    radio_type=RadioTypes.ARDB.value,
    serial_number='L1194707340',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.129', port=2323),
    pdu_port=_pdu_3.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group='FRMr6.2_4T4R',
    radio_type=RadioTypes.AHEGHA.value,
    serial_number='K9244330699',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.131', port=2323),
    # pdu_port=_pdu_1.pdu_ports[12],
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group='FRMr6.2_4T4R',
    radio_type=RadioTypes.AHEGHA.value,
    serial_number='K9244409378',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.128', port=2323),
    # pdu_port=_pdu_1.pdu_ports[7],
    pdu_port=_pdu_3.pdu_ports[10],
)
_rmod_4 = RU(
    ru_hw_group='FRMTDr5.1_4T4R',
    radio_type=RadioTypes.AZNA.value,
    serial_number='6Q184708174',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.130', port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group='FRMTDr5.1_4T4R',
    radio_type=RadioTypes.AZNA.value,
    serial_number='6Q184708231',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.132', port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group='FRMTDr5.1_4T4R',
    radio_type=RadioTypes.AZNA.value,
    serial_number='6Q190504276',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.133', port=2323),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_7 = RU(
   ru_hw_group='cMAAr6.2a_32T32R',
   radio_type=RadioTypes.AQQF.value,
   serial_number='NQ242594383',
   default_telnet_connection_details=TelnetConnectionDetails(addr='172.22.8.6', port=2323),
   pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_8 = RU(
   ru_hw_group='cMAAr6.2a_32T32R',
   radio_type=RadioTypes.AQQF.value,
   serial_number='NQ242594387',
   default_telnet_connection_details=TelnetConnectionDetails(addr='172.22.8.22', port=2323),
   pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_9 = RU(
   ru_hw_group='cMAAr6.2a_32T32R',
   radio_type=RadioTypes.AQQF.value,
   serial_number='NQ242594382',
   default_telnet_connection_details=TelnetConnectionDetails(addr='172.22.8.10', port=2323),
   pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_10 = RU(
    ru_hw_group='FRMr6.2_4T4R',
    radio_type=RadioTypes.AHEGHA.value,
    serial_number='K9244404752',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.128', port=2323),
    # pdu_port=_pdu_1.pdu_ports[1],
    pdu_port=_pdu_3.pdu_ports[8],
)

#************************************Dualcore 4+4************************************************
_fsp_1 = CapacityUnit(
    addr='192.168.253.20',
    hardware_type='ABIA',
    product_code='473096A.103',
    serial_number='L1172707497',
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr='192.168.253.24',
    hardware_type='ABIA',
    product_code='473096A.103',
    serial_number='L1172906477',
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_3, _rmod_10],
)

_fsp_3 = CapacityUnit(
    addr='192.168.253.28',
    hardware_type='ABIA',
    product_code='473096A.103',
    serial_number='L1172712953',
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_4 = CapacityUnit(
    addr='192.168.253.28',
    hardware_type='ABIO',
    product_code='475266A.104',
    serial_number='L1215008515',
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH204667463",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1192405955",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_10],
    oam_ip=NetworkAddress('10.42.24.54'),
    instance_id=1191,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)
##*******************************************************************
_test_pc_1 = TestPc(
    SshServiceDetails(addr='10.42.121.111', username='ute'),
    connections=[
        NetworkAddress(v4='192.168.255.126'),
        Connection(interface="eth1",device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp")
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr='10.42.121.114', username='ute'),
    connections=[
        NetworkAddress(v4='192.168.255.126'),
        Connection(interface="eth1",device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp")
    ],
)

_enb_sbts_1.slave = _enb_sbts_2

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    # pdus=_pdus,
    # tl_cloud_topology='CLOUD_SRAN_NL_2ASIB_9RMODs_1191',
)
__all__ = ['tl']