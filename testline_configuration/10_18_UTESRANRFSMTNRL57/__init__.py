__maintainer__ = "cristinel.sava@nokia.com"
__owner__ = "cristinel.sava@nokia.com"
__email__ = "cristinel.sava@nokia.com"
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
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.51", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.52", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude("10.255.5.85", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.84", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_fsp_abil = CapacityUnit(
    addr="", hardware_type="ABIL", hardware_version="A.X22", serial_number="L1182710841"
)
_fsp_abia1 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.102", serial_number="L1163812827"
)
_fsp_abia2 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="EA184873480"
)
_fct_asik = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abil],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIK",
    hardware_version="A.M01",
    serial_number="L1182712671",
    test_pc=_test_pc_1,
)

_fct_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abia1, _fsp_abia2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201004607",
    test_pc=_test_pc_2,
)

_rmod_1 = RU(
    ru_hw_group="FRMrAA_0T0R",
    radio_type=RadioTypes.AAHJ,
    serial_number="1M165323625",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMrAA_0T0R",
    radio_type=RadioTypes.AAHJ,
    serial_number="1M165323519",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH_TD_2.0_4T4R",
    radio_type=RadioTypes.FZNJ,
    serial_number="1M170402041",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMrRH_TD_2.0_4T4R",
    radio_type=RadioTypes.FZNJ,
    serial_number="F7170434555",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_cu_asik = CU(
    backhaul_site_oam_ip="10.0.67.57",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.57", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.57", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asik = DU(airscale=Airscale([_fct_asik]), rus=[_rmod_1, _rmod_2, _rmod_3])

_gnb_nr_1 = ClassicalBts(cu=_cu_asik, dus=[_du_asik], instance_id=43157)

_enb_lte_1 = RealEnb(
    system_module=Airscale(common_units=[_fct_asib]),
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=42157,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B4_MTNRL57_3FHEB_1FRGT",
)

__all__ = ["tl"]
