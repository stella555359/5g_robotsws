# Here you have a template for TAF config format in LTE-GSM/WCDMA-LTE/NR-LTE/NR-NR Cases.
# Spacing and indentation MUST be taken into account, otherwise Gerrit commits will FAIL
# Please remove ALL comments before any commit

# add your email to the following 3 lines
__maintainer__ = "gheorghe.bran@nokia.com"
__owner__ = "gheorghe.bran@nokia.com"
__email__ = "gheorghe.bran@nokia.com"
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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.51", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.188", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(addr="10.255.5.84", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_2 = Gude(addr="10.255.5.85", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")


_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED" 
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED" 
#_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED" 
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="FRMr6.1_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2330H60B2",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.85.138", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.1_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2330H60B5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.85.137", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_abiq1 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232208158",
    rus=[_rmod_1, _rmod_2],
)
_fsp_abia1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184778040",   
    rus=[_rmod_1, _rmod_2], 
)
_fsp_abia2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171013417",
    rus=[],
)
_fsp_abia3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171013137",
    rus=[],
)
_asil = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abiq1],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202800725",
    test_pc=_test_pc_1,
)
_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abia1, _fsp_abia2, _fsp_abia3],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211107808",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_asil])
_smod_2 = Airscale([_asib])

##### NR Standalone RELATED #####
# PLEASE DELETE THIS SECTION IF YOU DON'T NEED IT - REMOVE ALSO FROM IMPORT SECTION lines with DU, ClassicalBts, CU
# CU class for Central Unit NR
# Data you need to provide: OAM IP, ssh service details (IP, username, pass), WEB acces details (IP, username, pass)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.57"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.57", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.57", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asil = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2])
_gnb_nr_1 = ClassicalBts(cu=_cu_1, dus=[_du_asil], instance_id=623057)


_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2],
    instance_id=621057,
    oam_ip=NetworkAddress("10.0.69.57")
)
 
_test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))


# BSC class for defining BSC entity used by GSM.
# Data you need to provide: name, TELNET/SSH connection details (IP address, username, pass)
# Please keep only the relevant connection details (either telenet or ssh), not both
_bsc = BSC(
    name="BSC_PAAVAI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.200", username="SYSTEM", password="SYSTEM"
        ),
)
 
# RNC class for defining RNC entity used by WCDMA.
# Data you need to provide: RNC ID, OMS ip, SSH connection details (IP address, username, pass)
_rnc = RNC(
    rnc_id=8,
    oms_ip="10.55.1.178",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.44.219", username="Nemuadmin", password="nemuuser"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_nr_1],
    enbs=[_enb_lte_1],
    bscs=[_bsc],
    rncs=[_rnc],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-2_AIR_B1_MTNRL8AND57_3xAHEGHA",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
}

__all__ = ["tl"]
