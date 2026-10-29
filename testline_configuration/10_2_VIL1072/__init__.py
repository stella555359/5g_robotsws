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
        addr="10.41.209.63", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = RRB(
    addr="10.41.155.231", 
    port_numbers=[5]
)

_pdu_2 = RRB(
    addr="10.41.155.229", 
    port_numbers=[4,5,6]
)

_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="6Q191004190",
    pdu_port=_pdu_2.pdu_ports[5],
    product_code="473941A.101",
    radio_type="AZHA",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="6Q191004224",
    pdu_port=_pdu_2.pdu_ports[6],
    product_code="473941A.101",
    radio_type="AZHA",
)

_rmod_3 = RU(
    ru_hw_group="",
    serial_number="6Q191004265",
    pdu_port=_pdu_2.pdu_ports[4],
    product_code="473941A.101",
    radio_type="AZHA",
)
_abia = CapacityUnit(
    addr="", 
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184979840",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="AH184600906",
    test_pc=_test_pc_master,
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.41.209.122", port="443", username="dcapuser", password="dcapadmin!"
    )
)
_cu_asia = CU(
    backhaul_site_oam_ip=NetworkAddress("10.41.211.201"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.41.211.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.41.211.201", username="Nemuadmin", password="nemuuser"
    ),
)
a = Airscale([_asia])
_du_asia = DU(airscale=a, rus=[_rmod_1, _rmod_2, _rmod_3])
_classicalBts = ClassicalBts(
    cu=_cu_asia,
    dus=[_du_asia],
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
    tl_cloud_topology="CLOUD_5G_1ASIA_1ABIA_3AZHA",
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_2_VIL1072/ta_ue_config.yaml"

__all__ = ["tl"]
