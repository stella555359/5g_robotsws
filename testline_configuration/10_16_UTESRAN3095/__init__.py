# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Jakub Hirny"
__email__ = "jakub.hirny@nokia.com"


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
    addr="10.44.200.82",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.44.200.175",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)
_pdu_3 = Gude(
    addr="10.44.200.169",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr4.3a_2T2R",
    radio_type="FHEL",
    serial_number="EA164984350",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.225", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="FRMr4.3a_2T2R",
    radio_type="FHEL",
    serial_number="YK162500221",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.228", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_3 = RU(
    ru_hw_group="FRMr4.3a_2T2R",
    radio_type="FHEL",
    serial_number="YK162500239",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.227", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FRGX",
    serial_number="EA162610524",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.221", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FRGX",
    serial_number="EA162610525",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.222", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_6 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type="FXJB",
    serial_number="K9173634023",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.230", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6151242926",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6151132860",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.35",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1142608139",
    rus=[],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1142608115",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="L1173619178",
    rus=[],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="L1173619177",
    rus=[],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[],
    oam_ip=NetworkAddress("10.42.86.174"),
    instance_id=5020,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, 
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6], 
    master=_enb_sbts_1
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.87", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.88", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC25",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.89.4", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_1FSMF_2FBBC_1FSMF_2FBBC_3FHEL_2FRGX_1FXJB_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
