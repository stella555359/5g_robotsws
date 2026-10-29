__owner__ = "Sowrabha"
__maintainer__ = "Sowrabha"
__team__ = "VRF_BLR1_T09"
__email__ = "sowrabha.s_m@nokia.com"


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
    SshServiceDetails(addr="10.43.13.86", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.129")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.43.13.87", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.129")],
)


_pdu_1 = RRB(
    addr="10.41.155.24", 
    port_numbers=[1,2,3,4,7,8]

)
    
_pdu_2 = RRB(
    addr="10.41.155.21", 
    port_numbers=[1,2]

)

_pdu_3 = RRB(
    addr="10.41.155.62", 
    port_numbers=[6]    
    
)

_pdu_4 = FPFH(
    addr="10.41.155.61", 
    port_numbers=[1,2]    
    
)
   
_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"

_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_4.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    serial_number="BL2247D514L",
    pdu_port=_pdu_1.pdu_ports[4],
    product_code="475910A.101",
    radio_type="AHLOB",
)

_rmod_2 = RU(
    ru_hw_group="",
    serial_number="BL2247D5146",
    pdu_port=_pdu_1.pdu_ports[1],
    product_code="475910A.101",
    radio_type="AHLOB",
)

_rmod_3 = RU(
    ru_hw_group="",
    serial_number="BL2247D516A",
    pdu_port=_pdu_1.pdu_ports[2],
    product_code="475910A.101",
    radio_type="AHLOB",
)

_rmod_4 = RU(
    ru_hw_group="",
    serial_number="BL2221N406B",
    pdu_port=_pdu_1.pdu_ports[8],
    product_code="475656A.101",
    radio_type="AHFII",
)

_rmod_5 = RU(
    ru_hw_group="",
    serial_number="K9244348203",
    pdu_port=_pdu_1.pdu_ports[7],
    product_code="475656A.101",
    radio_type="AHFII",
)

_rmod_6 = RU(
    ru_hw_group="",
    serial_number="K9185201469",
    pdu_port=_pdu_1.pdu_ports[3],
    product_code="474216A.101",
    radio_type="AHFIB",
)

_rmod_7 = RU(
    ru_hw_group="",
    serial_number="L1251510229",
    pdu_port=_pdu_4.pdu_ports[1],
    product_code="476541A.101",
    radio_type="AVHA",
)

_rmod_8 = RU(
    ru_hw_group="",
    serial_number="L1251510232",
    pdu_port=_pdu_4.pdu_ports[2],
    product_code="476541A.101",
    radio_type="AVHA",
)

_rmod_9 = RU(
    ru_hw_group="",
    serial_number="L1251205186",
    pdu_port=_pdu_3.pdu_ports[6],
    product_code="476541A.101",
    radio_type="AVHA",
)

_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="DH222245192",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abia = CapacityUnit(
    addr="", 
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162908751",
    rus=[_rmod_4, _rmod_5, _rmod_6],
    
)

_abip = CapacityUnit(
    addr="", 
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231800088",
    rus=[_rmod_7, _rmod_8, _rmod_9],
    
)

_abip = CapacityUnit(
    addr="", 
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234501019",
    rus=[_rmod_4, _rmod_5, _rmod_6],
    
)
    
_asim_master = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio,_abia],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233404797",
    test_pc=_test_pc_1,
)

_asim_slave = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip,_abip],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.103",
    serial_number="L1231204152",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_asim_master])
_smod_2 = Airscale([_asim_slave])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.41.209.122", port="443", username="dcapuser", password="dcapadmin!"
    )
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6],
    oam_ip=NetworkAddress("10.41.227.14"),
    instance_id=30330,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4,_rmod_5,_rmod_6,_rmod_7,_rmod_8,_rmod_9],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)


_bsc = BSC(
    name="BSC_VENILLA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.111.107.158", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_5G_2ASIM_1ABIA_1ABIO_2ABIP_3AHLOB_1AHFIB_2AHFII_3AVHA",
    bscs=[_bsc],
)

__all__ = ["tl"]
