__maintainer__ = ""
__email__ = ""

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
from taf.config.testline.pdu import Gude, FACOM, HBTE, ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


_pdu_1 = ENICS(
    addr="10.2.20.235",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="ENICS",
)

_pdu_2 = ENICS(
    addr="10.2.20.236",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="ENICS",
)

_pdu_3 = ENICS(
    addr="10.2.20.233",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="ENICS",
)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHQN.value,
    serial_number="AH242603514",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.166", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9181028695",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIK",
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2],
    f1_m_ip_addr="10.2.81.13",
)
_cu = CU(
    backhaul_site_oam_ip="10.2.81.13",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(cu=_cu, dus=[_du_1])

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.2.80.6", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    tl_cloud_topology="CLOUD_31_22_GNB513",
)

__all__ = ["tl"]
