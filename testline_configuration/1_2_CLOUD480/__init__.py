__maintainer__ = "Mohan"
__owner_email__ = "mohanavel.p@@nokia.com"
__team__ = "VRF_BLR1_T11"
__email__ = "mohanavel.p@@nokia.com"

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
        addr="10.43.54.232", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = RRB(
    addr="10.41.155.130", 
    port_numbers=[1, 2, 3]
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="AH211300315",
    pdu_port=_pdu_1.pdu_ports[3],
    product_code="474036A.103",
    radio_type="AHFB",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="EA174412618",
    pdu_port=_pdu_1.pdu_ports[2],
    product_code="474050A.102",
    radio_type="AHIB",
)

_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIO",
    hardware_version="A.107",
    serial_number="DH234622924",
    rus=[_rmod_1, _rmod_2],
)
_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH250409429",
    test_pc=_test_pc_master,
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.41.209.122", port="443", username="dcapuser", password="dcapadmin!"
    )
)
_cu_asil = CU(
    backhaul_site_oam_ip=NetworkAddress("10.53.203.223"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.53.203.223", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.53.203.223", username="Nemuadmin", password="nemuuser"
    ),
)
a = Airscale([_asil])
_du_asil = DU(airscale=a, rus=[_rmod_1, _rmod_2])
_classicalBts = ClassicalBts(
    cu=_cu_asil,
    dus=[_du_asil],
    instance_id=43126,
    )
_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)
tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master],
    gnbs=[_classicalBts],
    tl_cloud_topology="CLOUD_5G_1ASIL_1ABIO_1AHIB_1AHFB",
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/1_2_CLOUD480/ta_ue_config.yaml"

__all__ = ["tl"]
