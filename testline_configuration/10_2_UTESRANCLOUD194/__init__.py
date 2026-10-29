__maintainer__ = "Durga Kant Yadav"
__owner_email__ = "durga.yadav@nokia.com"
__team__ = "RANPzBLRSG03CPKPI"
__email__ = "durga.yadav@nokia.com"

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
        addr="10.41.209.2", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)


_IP_PDU_1 = RRB("10.41.155.42", [3, 7])
_IP_PDU_2 = RRB("10.41.155.41", [1, 2])
_IP_PDU_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[2].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA211254473",
    pdu_port=_IP_PDU_1.pdu_ports[7],
    product_code="474914A.101",
    radio_type="AHEGC",
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    serial_number="YK210500050",
    pdu_port=_IP_PDU_2.pdu_ports[2],
    product_code="475432A.101",
    radio_type="AZHL",
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="1M212137746",
    pdu_port=_IP_PDU_2.pdu_ports[1],
    product_code="475243A.101",
    radio_type="AZQI",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1232907381",
    product_code="475792A.102",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    serial_number="L1204505954",
	product_code="475266A.102",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    serial_number="L1220402322",
	product_code="475266A.104",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)



_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2,_fsp_3],
    pdu_port=_IP_PDU_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="473095A.102",
    serial_number="DH224041014",
    rus=[_rmod_1,_rmod_2,_rmod_3],
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])





_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1,_rmod_2,_rmod_3], oam_ip=[NetworkAddress(v4="10.43.14.109")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIL_1ABIP_2ABIO_1AZHL_1AHEGC_1AZQI",
)

__all__ = ["tl"]
