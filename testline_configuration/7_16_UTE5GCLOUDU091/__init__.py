__maintainer__ = "Magdalena Swierbutowicz"
__email__ = "magdalena.swierbutowicz@nokia.com"
__owner_email__ = "magdalena.swierbutowicz@nokia.com"
__team__ = "pz2wro2"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB


_pdu_1 = Gude("10.44.235.4", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1250407028",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.18", port=2323
    ),
)

_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1251903835",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.18", port=2323
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234301763",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1241103975",
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.47.49"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=55309, instance_id=55309)


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.71.91", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
#    SshServiceDetails(addr="10.42.71.91", username="ute"),
#    connections=[
#        NetworkAddress(v4="192.168.255.126"),
#        Connection(
#            interface="eth1",
#            device=_gnb_1.dus[0].airscale.common_units[0],
#            interface_type="lmp",
#       ),
#    ],
#)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_gnb_1],
    enbs=[],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_1xASIM_ABIP_1xAVHA",
    pdus=[_pdu_1],
)

__all__ = ["tl"]
