__maintainer__ = "Sahana TC"
__owner_email__ = "sahana.t_c@nokia.com"
__team__ = "VRF_BLR2_T05_02"
__email__ = "sahana.t_c@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import Gude, FACOM, PduPort, Pdu, HBTE, RRB
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.58.141.139", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_4 = RRB(addr="10.58.211.47", port_numbers=[5])

_pdu_1 = RRB(addr="10.58.140.193", port_numbers=[2])

_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="root", password=""
    ),
    radio_type=RadioTypes.AZHL,
    serial_number="AH211900813",
    pdu_port=_pdu_4.pdu_ports[5],
)

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASOE",
    capacity_units=[],
    serial_number="EA212356627",
    rus=[_rmod_1],
)

_airscale = Airscale([_common_unit])
_cu = CU(
    backhaul_site_oam_ip="10.71.241.145",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(_airscale)
_cbts = ClassicalBts(cu=_cu, dus=[_du])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.58.141.139", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        # _ue,
    ],
)
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_RF_ASOE_AZHL",
)

__all__ = ["tl"]
