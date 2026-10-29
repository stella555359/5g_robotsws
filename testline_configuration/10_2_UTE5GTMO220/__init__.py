__owner__ = "Bhabani"
__maintainer__ = "Bhabani"
__team__ = "VRF_BLR1_T09"
__email__ = "Bhabani.sankar_rout@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
	HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import FPFH, Gude, FACOM, PduPort, Pdu, HBTE, RRB	
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb import DU


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.43.13.80", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.129")],
)



_pdu_1 = RRB(
    addr="10.41.155.47", 
    port_numbers=[1,6,7]

)
    
_pdu_2 = RRB(
    addr="10.41.155.20", 
    port_numbers=[8]    
    
)

_pdu_3 = RRB(
    addr="10.41.155.15", 
    port_numbers=[5]    
    
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"  
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[8].contactor = "NORMALLY_OPENED"

_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="",
    serial_number="AH232600041",
    pdu_port=_pdu_1.pdu_ports[7],
    product_code="475432A.101",
    radio_type="AZHL",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="AH250100564",
    pdu_port=_pdu_1.pdu_ports[6],
    product_code="475432A.101",
    radio_type="AZHL",
)

_rmod_3 = RU(
    ru_hw_group="",
    serial_number="K9175234864",
    pdu_port=_pdu_3.pdu_ports[5],
    product_code="474216A.101",
    radio_type="AHFIB",
)

_rmod_4 = RU(
    ru_hw_group="",
    serial_number="K9185201468",
    pdu_port=_pdu_2.pdu_ports[8],
    product_code="474216A.101",
    radio_type="AHFIB",
)

_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211604192",
    rus=[_rmod_3, _rmod_4],
)

_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIA",
    hardware_version="475266A.103",
    serial_number="DH221944885",
    rus=[_rmod_1, _rmod_2],
    
)

    
_asil_master = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio,_abio],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1250806336",
    test_pc=_test_pc_1,
)


_smod_1 = Airscale([_asil_master])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.41.209.122", port="443", username="dcapuser", password="dcapadmin!"
    )
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1,_rmod_2,_rmod_3,_rmod_4],
    oam_ip=NetworkAddress("10.43.14.17"),
    instance_id=30311,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_5G_1ASIL_2ABIO_2AZHL_2AHFIB",
)

__all__ = ["tl"]