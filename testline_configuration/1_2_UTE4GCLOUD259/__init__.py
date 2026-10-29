__maintainer__ = "Hari krishna"
__owner_email__ = "hari.mada@nokia.com"
__team__ = "RANPzBLRSG03Galaxy"
__email__ = "hari.mada@nokia.com"
 
from typing import Optional, List, Union
from enum import Enum
 
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, RRB
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
 
 
_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.54.117", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)
 
 
_IP_PDU_1 = RRB("10.41.155.253", [6])
_IP_PDU_2 = RRB("10.41.155.235", [6])
_IP_PDU_3 = RRB("10.41.155.254", [4])
 
_IP_PDU_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[6].contactor = "NORMALLY_OPENED"	
_IP_PDU_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
 
_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1T2R",
    serial_number="BL2108V05DK",
    pdu_port=_IP_PDU_2.pdu_ports[6],
    product_code="474216A.101",
    radio_type="AHFIB",
)	
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="6Q202002518",
    pdu_port=_IP_PDU_3.pdu_ports[4],
    product_code="474052A.101",
    radio_type="AZNC",
)
 
 
_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[],
    pdu_port=_IP_PDU_1.pdu_ports[6],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213154033",
    rus=[_rmod_1, _rmod_2],
	test_pc=_test_pc_master,
)
 
_smod_1 = Airscale([_fct_1])
 

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1], oam_ip=[NetworkAddress(v4="10.41.211.213")])
 
_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
)
 
 
tl = TestLine(
    test_pc=_test_pc_master,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASOE_1AHFIG_1AZNC_BTS259",
)	
__all__ = ["tl"]
