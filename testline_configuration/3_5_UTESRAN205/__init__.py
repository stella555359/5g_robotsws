__maintainer__ = "Henry Wang"
__email__ = "henry.1.wang@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.radio import RU
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


_pdu_1 = HBTE(
    addr="10.106.205.50",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_2 = FACOM(
    addr="10.108.151.127",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650633",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH212563566",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650631",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA194155755",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    radio_type=RadioTypes.AEQA,
    serial_number="6Q193904511",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    radio_type=RadioTypes.AEQA,
    serial_number="6Q194202507",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    radio_type=RadioTypes.AEQA,
    serial_number="6Q192808876",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3],
    f1_m_ip_addr="10.106.205.198",
)
_cu = CU(
    backhaul_site_oam_ip="10.106.205.198",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.205.198", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(cu=_cu, dus=[_du_1])

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.250", username="ute", password="ute"
    ),
    connections=[_classical_bts_1],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    tl_cloud_topology="CLOUD_SRAN_N_ASIKL_3xABIL_3xAEQA",
)

__all__ = ["tl"]
