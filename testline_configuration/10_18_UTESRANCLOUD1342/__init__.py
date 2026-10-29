__maintainer__ = "Andrada Lavinia Baleti"
__email__ = "andrada-lavinia.baleti@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.119", username="ute"
    ), 
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    "10.255.1.31", 
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    "EPC", 
    "",
)
_pdu_2 = Gude(
    "10.255.1.32", 
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    "EPC", 
    "",
)


_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="", 
    hardware_type="ABIA", 
    hardware_version="473096A.103",  
    serial_number="L1172906353",
)
_fsp_2 = CapacityUnit(
    addr="", 
    hardware_type="ABIA", 
    hardware_version="473096A.103",  
    serial_number="K9173824627",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ), 
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7], 
    hardware_type="ASIA", 
    hardware_version="473095A.101", 
    serial_number="L1164604270",
)


_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R", 
    radio_type=RadioTypes.AHEGB, 
    serial_number="K9190103762", 
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ), 
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R", 
    radio_type=RadioTypes.AHFIC, 
    serial_number="K9192414084", 
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ), 
    pdu_port=_pdu_2.pdu_ports[5],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.15.247.42"), 
    instance_id=10342,
)


_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.121", username="Nemuadmin", password="Nokia@123"
    ),
)


_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
)


tl = TestLine(
    test_pc=_test_pc_1, 
    test_pcs=[_test_pc_1], 
    enbs=[_enb_sbts_1], 
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_2ABIA_1AHEGB_1AHFIC",
    bscs=[_bsc],
    rncs=[_rnc],
)


__all__ = ["tl"]
