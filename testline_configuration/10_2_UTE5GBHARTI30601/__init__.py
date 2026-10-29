__maintainer__ = "Kshitij Tyagi"
__owner_email__ = "kshitij.tyagi@nokia.com"
__team__ = "VRF_BLR1_T09"
__email__ = "kshitij.tyagi@nokia.com"

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
        addr="10.43.13.74", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = RRB(
    addr="10.41.155.16", 
    port_numbers=[2]

)
    
_pdu_2 = RRB(
    addr="10.41.155.20", 
    port_numbers=[1,5]

)

_pdu_3 = RRB(
    addr="10.41.155.40", 
    port_numbers=[2]    
    
)

_pdu_4 = RRB(
    addr="10.41.155.15", 
    port_numbers=[6]
    
) 
   
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"   
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="L1184812088",
    pdu_port=_pdu_2.pdu_ports[1],
    product_code="474198A.101",
    radio_type="AREA",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="K9242201926",
    pdu_port=_pdu_3.pdu_ports[2],
    product_code="474841A.102",
    radio_type="ARCA",
)

_rmod_3 = RU(
    ru_hw_group="",
    serial_number="1M250705608",
    pdu_port=_pdu_2.pdu_ports[5],
    product_code="476504A.101",
    radio_type="AVQF",
)

_rmod_4 = RU(
    ru_hw_group="",
    serial_number="1M230221814",
    pdu_port=_pdu_4.pdu_ports[6],
    product_code="475922A.101",
    radio_type="AQQF",
)

_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIO",
    hardware_version="A.105",
    serial_number="DH225049176",
    rus=[_rmod_1, _rmod_3, _rmod_4],
)

_abia = CapacityUnit(
    addr="", 
    hardware_type="ABIA",
    hardware_version="A.104",
    serial_number="EA194454837",
    rus=[_rmod_1, _rmod_2]
    
)
    
_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio,_abia],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH221548288",
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
_du_asib = DU(airscale=a, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])
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
    tl_cloud_topology="CLOUD_5G_1ASIB_1ABIA_1ABIO_1AREA_1ARCA_1AVQF_1AQQF",
)


__all__ = ["tl"]