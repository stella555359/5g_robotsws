__maintainer__ = "Manu"
__owner_email__ = "b.manu@nokia.com"
__team__ = "VRF_BLR1_T10"
__email__ = "b.manu@nokia.com"

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
        addr="10.68.126.92", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = RRB(
    addr="10.68.126.24", 
    port_numbers=[8]
)

_pdu_2 = RRB(
    addr="10.68.126.41", 
    port_numbers=[6,7,8]
)

_pdu_3 = RRB(
    addr="10.68.126.42", 
    port_numbers=[3,8]
)

_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="K9232547436",
    pdu_port=_pdu_2.pdu_ports[6],
    product_code="476383A.108",
    radio_type="AQQJ",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="NQ232391252",
    pdu_port=_pdu_2.pdu_ports[7],
    product_code="476383A.108",
    radio_type="AQQJ",
)

_rmod_3 = RU(
    ru_hw_group="",
    serial_number="NQ233790849",
    pdu_port=_pdu_2.pdu_ports[8],
    product_code="476383A.108",
    radio_type="AQQJ",
)

_rmod_4 = RU(
    ru_hw_group="",
    serial_number="NQ233303572",
    pdu_port=_pdu_3.pdu_ports[3],
    product_code="474119A.303",
    radio_type="AHPB",
)

_rmod_5 = RU(
    ru_hw_group="",
    serial_number="DH242419235",
    pdu_port=_pdu_3.pdu_ports[8],
    product_code="474119A.101",
    radio_type="AHPB",
)

_asoe = CapacityUnit(
    addr="", 
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="EA221952822",
    rus=[_rmod_1],
)
_asoe = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_asoe],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="EA221952822",
    test_pc=_test_pc_master,
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.41.209.122", port="443", username="dcapuser", password="dcapadmin!"
    )
)
_cu_asoe = CU(
    backhaul_site_oam_ip=NetworkAddress("10.68.126.120"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.126.120", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.126.120", username="Nemuadmin", password="nemuuser"
    ),
)
a = Airscale([_asoe])
_du_asoe = DU(airscale=a, rus=[_rmod_1])
_classicalBts = ClassicalBts(
    cu=_cu_asoe,
    dus=[_du_asoe],
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
    tl_cloud_topology="CLOUD_5G_1ASOE_3AQQJ_2AHPB",
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/1_2_CLOUD1910/ta_ue_config.yaml"

__all__ = ["tl"]