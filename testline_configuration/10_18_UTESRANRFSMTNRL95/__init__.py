__maintainer__ = "denisa.barnescu@nokia.com"
__owner__ = "denisa.barnescu@nokia.com"
__email__ = "denisa.barnescu@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapRnD, DcapBasic

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.11", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
#_dcap_1 = DcapRnD(
#    HttpConnectionDetails(
#        addr="10.5.19.11", port="9443", username="dcapuser", password="dcapadmin!"
#    )
#)

_pdu_1 = Gude(addr="10.255.5.79", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(addr="10.255.5.80", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2138G1LCG",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2051G1U2A",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004053",
    rus=[_rmod_1, _rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234204951",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=623095,
    oam_ip=NetworkAddress(v4="10.0.65.195"),
#    dcap=_dcap_1,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))


#_bsc = BSC(
#    name="BSC_BUICK",
#    logging_telnet_connection_details=TelnetConnectionDetails(
#       addr="10.5.42.108", username="SYSTEM", password="SYSTEM")
#       )

#_test_pc_1.connections.append(_bsc)

#_calient = Calient(
#    addr="10.255.5.250",
#    username="rfshare",
#    password="Calient2016!",
#    port=80,
#    model="S320",
#)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_ASIM_MTNRL95_2xAHLOA",
#    bscs=[_bsc],
)

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL95/dcap_profiles.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
 
}


__all__ = ["tl"]