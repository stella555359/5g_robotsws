# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = 'Tomasz Januszkiewicz'
__email__ = 'tomasz.januszkiewicz@nokia.com'

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
    addr="10.42.60.103",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.42.199.248",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group='FRMr2.3_3T6R_Vegas',
    radio_type="FXDB",
    serial_number='L6143341561',
    default_telnet_connection_details=TelnetConnectionDetails(
        addr='172.16.8.128', port=2323
        ),
        pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group='cMAArChile_64T64R',
    radio_type="AEHC",
    serial_number='L1203007300',
    default_telnet_connection_details=TelnetConnectionDetails(
        addr='172.22.2.6', port=2323
        ),
        pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group='FRMr5.1a_4T4R',
    radio_type="AHLOA",
    serial_number='BL2027G1AQ1',
    default_telnet_connection_details=TelnetConnectionDetails(
        addr='172.16.33.128', port=2323
        ),
        pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group='FRMr2.3_3T6R_Vegas',
    radio_type="FXDB", serial_number='L1130900485',
    default_telnet_connection_details=TelnetConnectionDetails(
        addr='172.16.10.130', port=2323
        ),
        pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group='FRMr3.2_6T6R',
    radio_type="FXED",
    serial_number='L1151002019',
    default_telnet_connection_details=TelnetConnectionDetails(
        addr='172.16.10.132', port=2323
        ),
        pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr='192.168.253.22',
    hardware_type='ABIA',
    hardware_version='473096A.103',
    serial_number='L1172903055',
    rus=[_rmod_1, _rmod_4],
)
_fsp_2 = CapacityUnit(
    addr='192.168.253.26',
    hardware_type='ABIN',
    hardware_version='474824A.101',
    serial_number='L1204003822',
    rus=[_rmod_3, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr='192.168.253.30',
    hardware_type='ABIO',
    hardware_version='475266A.101',
    serial_number='L1204008345',
    rus=[_rmod_2, _rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr='192.168.255.1', username='toor4nsn', password='oZPS0POrRieRtu'
    ), 
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type='ASIB',
    hardware_version='A.102',
    serial_number='L1185106978',
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.18.57"),
    instance_id=5056,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.235", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.210"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.74", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.89.4", username="SYSTEM", password="SYSTEM"
    ),
)

_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIN_1ABIO_2FXDB_1AEHC_1AHLOA_1FXED_UTECA",
    bscs=[_bsc],
    rncs=[_rnc],
    pdus=_pdus,
)

__all__ = ["tl"]
