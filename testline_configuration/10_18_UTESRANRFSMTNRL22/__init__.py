__maintainer__ = "marius.roman@nokia.com"
__owner__ = "marius.roman@nokia.com"
__email__ = "marius.roman@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
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
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.fhs import FHS, FhsType
from taf.config.testline.lmi import SerialOverTcp, Remote, Local, SerialOverHost


_calient = Calient(
    addr="10.255.2.169",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.83", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

#_test_pc_2 = TestPc(
#   default_ssh_connection_details=SshServiceDetails(
#        addr="10.5.19.84", username="ute", password="uteUTE!"
#    ),
#    connections=[NetworkAddress(v4="192.168.255.126")],
#)

_pdu_1 = Gude(addr="10.255.5.215", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(addr="10.255.5.216", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHA.value,
    serial_number="6Q190128945",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
	attenuation_ports=[],
)

#_rmod_2 = RU(
#    ru_hw_group="",
#    radio_type=RadioTypes.AHEGA.value,
#    serial_number="K9182544304",
#    default_telnet_connection_details=TelnetConnectionDetails(
#        addr="172.16.41.132", port=2323
#    ),
#    lmi=SerialOverHost(
#        host=TestPc(
#            default_ssh_connection_details=SshServiceDetails(
#                addr="10.5.55.70",
#                username="rfs_5g",
#                password="Nokia2022!@1"
#           )
#        ),
#        uart_mapping=[  # windows
#            Local(
#                port="COM7"
#           )
#       ]
#    ),
#    pdu_port=_pdu_1.pdu_ports[1],
#	attenuation_ports=[],
#)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2330H60B5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
	attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211709893",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103431",
    rus=[_rmod_2],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171722174",
    rus=[_rmod_2],
)

#_fsp_4 = CapacityUnit(
#    addr="",
#    hardware_type="ABIA",
#    hardware_version="473096A.102",
#    serial_number="L1171013369",
#    rus=[_rmod_2, _rmod_3],
#)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234206604",
    test_pc=_test_pc_1,
)

#_fct_2 = CommonUnit(
#   SshServiceDetails(
#        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#    ),
#    capacity_units=[_fsp_3, _fsp_4],
#    pdu_port=_pdu_2.pdu_ports[6],
#    hardware_type="ASIL",
#    hardware_version="474767A.101",
#    serial_number="L1212609717",
#    test_pc=_test_pc_2,
#)

_smod_1 = Airscale(common_units=[_fct_1])
#_smod_2 = Airscale(common_units=[_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=621022,
    oam_ip=NetworkAddress("10.0.65.22"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

#_enb_lte_2 = RealEnb(
#    system_module=_smod_2,
#    rms=[_rmod_1, _rmod_2, _rmod_3],
#    instance_id=623022,
#    oam_ip=NetworkAddress("10.0.67.22"),
#)

#_test_pc_2.connections.append(
#    Connection(
#        interface="eth1",
#        device=_enb_lte_2.system_module.common_units[0],
#        interface_type="lmp",
#    )
#)

_rnc = RNC(
    rnc_id=9,
    oms_ip=NetworkAddress("10.94.92.156"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="_nokadmin", password="_P@ssword123"
    ),
)

_bsc = BSC(
     name="BSC_PAAVAI",
     logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.200", username="SYSTEM", password="SYSTEM"
     ),
     #logging_ssh_connection_details=SshServiceDetails(
     #    addr="10.27.126.200", username="SYSTEM", password="SYSTEM"
     #),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_MTNRL22",
    bscs=[_bsc],
    rncs=[_rnc],
    optical_switches=[_calient],
    
)


OPTICAL_SWITCH_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL22/optical_switch_ports.yaml"


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RSI_INFO_COLLECT": True,
}



__all__ = ["tl"]