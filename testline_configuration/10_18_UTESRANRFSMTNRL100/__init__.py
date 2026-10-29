__maintainer__ = "vlad-darius.mindrutau@nokia.com"
__owner__ = "vlad-darius.mindrutau@nokia.com"
__email__ = "vlad-darius.mindrutau@nokia.com"
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
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.24", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.25", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.123", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.5.114",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.115",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_3 = Gude (
    addr="10.255.5.129",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1934G10UW",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2138G1LCE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181717465",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9201904738",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NRT",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
    attenuation_ports=[],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9202300357",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.100", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM9"
           )
       ]
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1202503076",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.154", port=2323
    ),
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.100", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM24")],  # windows
    ),

    pdu_port=_pdu_3.pdu_ports[4],
    attenuation_ports=[],
    
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1205002792",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.158", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
    attenuation_ports=[],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1205002791",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.162", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
    attenuation_ports=[],
)
_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010434",
    rus=[_rmod_7, _rmod_8,_rmod_9],
)
_abil_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212360757",
    rus=[_rmod_1, _rmod_2],
)
_abil_3 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA210255366",
    rus=[_rmod_3],
)
_abil_4 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203201125",
    rus=[_rmod_4],
)
_abil_5 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201204054",
    rus=[_rmod_5],
)
_abil_6 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212360767",
    rus=[_rmod_6],
)
_abia_7 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW190402259",
    rus=[_rmod_4, _rmod_5],
)
_abia_8 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181415977",
    rus=[_rmod_6],
)
_abia_9 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW190402305",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_2, _abil_3, _abil_4],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220351691",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_7, _abia_8, _abia_9],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212874130",
    test_pc=_test_pc_2, 
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],    
) 
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abil_5, _abil_6],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1214908844",
    test_pc=_test_pc_3,
    rus=[_rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_cu_smod = CU(backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.200"),
         oam_ssh_connection_details=SshServiceDetails(addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'),
         oam_http_connection_details=HttpConnectionDetails(addr='10.0.65.200', username='Nemuadmin', password='nemuuser'))

_smod_1 = Airscale(common_units=[_fct_1, _fct_3])
_smod_2 = Airscale(common_units=[_fct_2])

_du_smod = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9])

_gnb_nr_1 = ClassicalBts(
    cu=_cu_smod,
    dus=[_du_smod],
    instance_id=623100,
    # dcap=_dcap_1
)

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=621100,
    oam_ip=NetworkAddress(v4="10.0.69.200"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[1],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnb_nr_1],
    enbs=[_enb_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL100",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_RSI_INFO_COLLECT": True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL100/rmod_setup.yaml"
    #    "USER_DCAP_TRACE_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT_Master": True,
    #    "USER_DCAP_TRACE_COLLECT_Slave": True,

}

__all__ = ["tl"]
