__maintainer__ = "Manu"
__owner_email__ = "b,manu@nokia.com"
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
        addr="10.41.209.111", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = RRB(
    addr="10.58.178.86", 
    port_numbers=[3]

)
    
_pdu_2 = RRB(
    addr="10.41.155.250", 
    port_numbers=[4,3,7]

)

_pdu_3 = RRB(
    addr="10.41.155.232", 
    port_numbers=[7,8]    
    
)

_pdu_4 = RRB(
    addr="10.41.155.234", 
    port_numbers=[7,8]
    
) 
   
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="K9191031752",
    pdu_port=_pdu_2.pdu_ports[4],
    product_code="474090A.101",
    radio_type="AHEGB",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="K9191019065",
    pdu_port=_pdu_3.pdu_ports[7],
    product_code="474090A.101",
    radio_type="AHEGB",
)

_rmod_3 = RU(
    ru_hw_group="",
    serial_number="K9191019072",
    pdu_port=_pdu_3.pdu_ports[8],
    product_code="474090A.101",
    radio_type="AHEGB",
)

_rmod_4 = RU(
    ru_hw_group="",
    serial_number="K9213005110",
    pdu_port=_pdu_4.pdu_ports[7],
    product_code="475122A.101",
    radio_type="ARDB",
)

_rmod_5 = RU(
    ru_hw_group="",
    serial_number="EA204859638",
    pdu_port=_pdu_4.pdu_ports[8],
    product_code="473941A.101",
    radio_type="AZHA",
)

_rmod_6 = RU(
    ru_hw_group="",
    serial_number="EA210257816",
    pdu_port=_pdu_2.pdu_ports[3],
    product_code="473941A.101",
    radio_type="AZHA",
)

_rmod_7 = RU(
    ru_hw_group="",
    serial_number="EA210257814",
    pdu_port=_pdu_2.pdu_ports[7],
    product_code="473941A.101",
    radio_type="AZHA",
)

_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204008303",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
)

_abia = CapacityUnit(
    addr="", 
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184980059",
    rus=[_rmod_1, _rmod_2, _rmod_3]
    
)
    
_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio,_abia],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1191006742",
    test_pc=_test_pc_master,
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.41.209.122", port="443", username="dcapuser", password="dcapadmin!"
    )
)
_cu_asib = CU(
    backhaul_site_oam_ip=NetworkAddress("10.41.211.195"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.41.211.195", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.41.211.195", username="Nemuadmin", password="nemuuser"
    ),
)
a = Airscale([_asib])
_du_asib = DU(airscale=a, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7])
_classicalBts = ClassicalBts(
    cu=_cu_asib,
    dus=[_du_asib],
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
    tl_cloud_topology="CLOUD_5G_1ASIB_1ABIA_1ABIO_1ARDB_3AHEGB_3AZHA",
)


__all__ = ["tl"]