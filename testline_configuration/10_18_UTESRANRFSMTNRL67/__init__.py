__maintainer__ = "sergiu.silaghi@nokia.com"
__owner__ = "sergiu.silaghi@nokia.com"
__email__ = "sergiu.silaghi@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.53", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.54", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude("10.255.5.18", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.19", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"


_fsp_abil1 = CapacityUnit(
    addr="", hardware_type="ABIL", hardware_version="B.102", serial_number="L1201705936"
)
_fsp_abia1 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="EA185174145"
)
_fsp_abia2 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="EA185174164"
)
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abia1, _fsp_abia2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1181219196",
    test_pc=_test_pc_slave,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abil1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211205004",
    test_pc=_test_pc_master,
)


_smod_1 = Airscale(common_units=[_fct_1])
_smod_2 = Airscale(common_units=[_fct_2])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED,
    serial_number="L1164504630",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED,
    serial_number="F7171155438",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRMC,
    serial_number="F7170524981",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)


_cu_smod = CU(
    backhaul_site_oam_ip="10.0.65.67",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.67", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.67", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod = DU(airscale=Airscale([_fct_2]), rus=[_rmod_1, _rmod_2])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.53", port="9443", username="dcapuser", password="dcapadmin!"
    )
)

_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=43188, dcap=_dcap_1)

_test_pc_master.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=42188,
    dcap=_dcap_1,
)

_bsc = BSC(
    name="BSC_AVENSIS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_slave.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_gnb_nr_1],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIR_B4_MTNRL67_2FXED",
    bscs=[_bsc],
)

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL67/dcap_profiles.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,

}

__all__ = ["tl"]
