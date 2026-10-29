__maintainer__ = "Mohan"
__owner_email__ = "mohanavel.p@@nokia.com"
__team__ = "VRF_BLR1_T10"
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
        addr="10.53.164.19", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = RRB(
    addr="10.41.155.153", 
    port_numbers=[1,3]
)

_pdu_2 = RRB(
    addr="10.41.155.152", 
    port_numbers=[1,2,4,7]
)

_pdu_3 = RRB(
    addr="10.41.155.154", 
    port_numbers=[2]
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="L1151203688",
    pdu_port=_pdu_2.pdu_ports[4],
    product_code="472574A.101",
    radio_type="FXJB",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="L1151203680",
    pdu_port=_pdu_2.pdu_ports[2],
    product_code="472574A.101",
    radio_type="FXJB",
)

_rmod_3 = RU(
    ru_hw_group="",
    serial_number="EA172213057",
    pdu_port=_pdu_2.pdu_ports[1],
    product_code="473439A.202",
    radio_type="FXEF",
)

_rmod_4 = RU(
    ru_hw_group="",
    serial_number="EA172213055",
    pdu_port=_pdu_2.pdu_ports[7],
    product_code="473439A.202",
    radio_type="FXEF",
)

_rmod_5 = RU(
    ru_hw_group="",
    serial_number="EA233250038",
    pdu_port=_pdu_3.pdu_ports[2],
    product_code="473941A.101",
    radio_type="AZHA",
)

_rmod_6 = RU(
    ru_hw_group="",
    serial_number="EA204351249",
    pdu_port=_pdu_1.pdu_ports[3],
    product_code="473941A.101",
    radio_type="AZHA",
)
_abia = CapacityUnit(
    addr="", 
    hardware_type="ABIA",
    hardware_version="A.107",
    serial_number="DH223223450",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)
_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="DH221945564",
    rus=[_rmod_5, _rmod_6],
)
_asim = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia, _abio],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1250800103",
    test_pc=_test_pc_master,
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.41.209.122", port="443", username="dcapuser", password="dcapadmin!"
    )
)
_cu_asim = CU(
    backhaul_site_oam_ip=NetworkAddress("10.41.211.201"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.41.211.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.41.211.201", username="Nemuadmin", password="nemuuser"
    ),
)
a = Airscale([_asim])
_du_asim = DU(airscale=a, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6])
_classicalBts = ClassicalBts(
    cu=_cu_asim,
    dus=[_du_asim],
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
    tl_cloud_topology="CLOUD_5G_1ASIM_1ABIA_1ABIP_1ABIO_2FXJB_2FXEF_2AZHA",
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/1_2_CLOUD497/ta_ue_config.yaml"

__all__ = ["tl"]