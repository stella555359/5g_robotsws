__maintainer__ = "Bartosz Busz"
__email__ = "bartosz.busz@nokia.com"

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

##


_pdu_1 = Gude('10.42.168.245', [1, 2, 3], 'EPC', '') #ASIK-port1; FSMF-port2; ASIB-port3
_pdu_2 = FPFH(port_numbers=[1, 4, 6], addr="10.42.168.235", login="admin", password="admin",) # K9191704492-port1; K9181741686-port4; BL2233W2D6M-port6
_pdu_3 = FPFH(port_numbers=[1, 3, 6], addr="10.42.168.236", login="admin", password="admin",) # K9200215155-port1; BL2116G1CFZ-port3; BL2027G1ANW-port6

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_rmod_1 = RU(
    ru_hw_group='FRMr5.1a_4T4R',
    radio_type=RadioTypes.AHFIG.value,
    serial_number='K9191704492',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.132', port=2323),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group='FRMr5.1a_4T4R',
    radio_type=RadioTypes.AHFIG.value,
    serial_number='BL2233W2D6M',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.133', port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group='FRMr5.1a_4T4R',
    radio_type=RadioTypes.AHFIG.value,
    serial_number='K9200215155',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.131', port=2323),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group='FRMr5.1a_4T4R',
    radio_type=RadioTypes.AHLOA.value,
    serial_number='K9181741686',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.130', port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group='FRMr5.1a_4T4R',
    radio_type=RadioTypes.AHLOA.value,
    serial_number='BL2027G1ANW',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.128', port=2323),
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group='FRMr5.1a_4T4R',
    radio_type=RadioTypes.AHLOA.value,
    serial_number='BL2116G1CFZ',
    default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.33.129', port=2323),
    pdu_port=_pdu_3.pdu_ports[3],
)
#_rmod_7 = RU(
#    ru_hw_group='FRMr5.1_1_4T4R',
#    radio_type=RadioTypes.AHEH.value,
#    serial_number='L1184200029',
#    default_telnet_connection_details=TelnetConnectionDetails(addr='192.168.254.239', port=2323),
#    pdu_port=_pdu_2.pdu_ports[8],
#)

#************************************Dualcore 4+3************************************************
_fsp_1 = CapacityUnit(
    addr='192.168.253.20',
    hardware_type='ABIA',
    product_code='473096A.103',
    serial_number='L1171213707',
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr='192.168.253.24',
    hardware_type='ABIA',
    product_code='473096A.103',
    serial_number='L1173514648',
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr='192.168.253.28',
    hardware_type='ABIA',
    product_code='473096A.103',
    serial_number='L1172712941',
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201102995",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="AS180433844",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress('10.42.175.26'),
    instance_id=1334,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[],
#   rms=[_rmod_7],
    master=_enb_sbts_1,
)
#**************************************gNB*****************************************************************
_abil_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:1101",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="EA200452582",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_abil_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:1101",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1185109721",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_asik = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIK",
    capacity_units=[_abil_1, _abil_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_version="474021A.102",
    serial_number="L1200806324",
)
##
_airscale_asik = Airscale(common_units=[_asik])

_du_asik = DU(
    airscale=_airscale_asik,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_cu_asik = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.175.27", v6="", vlan_id=74),
    x2u=NetworkAddress(v4="10.42.175.27", v6="", vlan_id=74),
    s1u=NetworkAddress(v4="10.42.175.27", v6="", vlan_id=74),
)

_classical_asik = ClassicalBts(
    dus=[_du_asik], cu=_cu_asik, instance_id=1333, global_bts_id=1333
)
##*******************************************************************
_test_pc_1 = TestPc(
    SshServiceDetails(addr='10.42.184.19', username='ute'),
    connections=[
        NetworkAddress(v4='192.168.255.126'),
        Connection(interface="eth1",device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp")
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr='10.42.184.20', username='ute'),
    connections=[
        NetworkAddress(v4='192.168.255.126'),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp")
    ],
)
_test_pc_3 = TestPc(
    SshServiceDetails(addr='10.42.184.21', username='ute'),
    connections=[
        NetworkAddress(v4='192.168.255.126'),
        Connection(
            interface="eth1",
            device=_airscale_asik.common_units[0],
            interface_type="lmp",
        )
    ],
)

_enb_sbts_1.slave = _enb_sbts_2

_rnc = RNC(rnc_id=25, oms_ip=NetworkAddress('10.44.44.219'), logging_ssh_connection_details=SshServiceDetails(addr='10.42.28.72', username='nokiadmin', password='system'))

_bsc = BSC(name="asBSC-21", logging_telnet_connection_details=TelnetConnectionDetails(addr="10.42.28.126", username="PZUSER4", password="Ut3pa5s#1be1"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_classical_asik],
    pdus=_pdus,
    tl_cloud_topology='CLOUD_SRAN_LG_1ASIB_3ABIA_1FSMF_1ASIK_2ABIL_3AHFIG_3AHLOA_001',
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ['tl']
