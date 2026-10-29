__maintainer__ = "marian.ungureanu@nokia.com"
__owner__ = "marian.ungureanu@nokia.com"
__email__ = "marian.ungureanu@nokia.com"
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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient
from taf.config.testline.fhs import FHS, FhsType
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.175", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.176", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.174", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_smod = Gude(
    addr="10.255.2.120",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_rmod = Gude(
    addr="10.255.2.119",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu_smod, _pdu_rmod]


_ahfig_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIG",
    serial_number="K9203119588",
    pdu_port=_pdu_rmod.pdu_ports[5],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.221", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM35")],  # windows
    ),
)
_ahfig_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIG",
    serial_number="K9203119597",
    pdu_port=_pdu_rmod.pdu_ports[6],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.221", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM34")],  # windows
    ),
)
_ahfig_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIG",
    serial_number="K9203119593",
    pdu_port=_pdu_rmod.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.221", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM32")],  # windows
    ),
)
_ahloa_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2032G1GML",
    pdu_port=_pdu_rmod.pdu_ports[7],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.221", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM38")],  # windows
    ),
)
_ahloa_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2032G1GNJ",
    pdu_port=_pdu_rmod.pdu_ports[11],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.221", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM31")],  # windows
    ),
)
_ahloa_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2032G1GNI",
    pdu_port=_pdu_rmod.pdu_ports[12],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.221", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM33")],  # windows
    ),
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808026",
    rus=[_ahfig_1, _ahfig_2],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173907800",
    rus=[_ahfig_3],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1191509960",
    rus=[_ahloa_1, _ahloa_2, _ahloa_3],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1194509163",
    rus=[_ahloa_1, _ahloa_2, _ahloa_3],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203201130",
    rus=[_ahfig_1, _ahfig_2],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1194509184",
    rus=[_ahfig_3],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_smod.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201902157",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_smod.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="F7170924133",
    test_pc=_test_pc_3,
)
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_smod.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1244004850",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1, _fct_2])
_smod_2 = Airscale([_fct_3])

_cu_smod = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.201"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.201", username="Nemuadmin", password="nemuuser"
    ),
)
_du_smod = DU(airscale=_smod_2, rus=[_ahloa_1, _ahloa_2, _ahloa_3, _ahfig_1, _ahfig_2, _ahfig_3])
_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623101)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)
_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_ahloa_1, _ahloa_2, _ahloa_3, _ahfig_1, _ahfig_2, _ahfig_3],
    instance_id=621101,
    oam_ip=NetworkAddress(v4="10.0.69.201"),
#    dcap=_dcap_1,
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[1],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1],
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL101",
)
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
#    "USER_DCAP_TRACE_COLLECT": True,
#    "USER_DCAP_TRACE_COLLECT_Master": True,
#    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL101/MTNRL101_custom_rmod_setup.yaml",
    "RMOD_UDP_LOG_CONFIG_PATH": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL101/MTNRL101_rmod_udp_log.yaml",
}

__all__ = ["tl"]
