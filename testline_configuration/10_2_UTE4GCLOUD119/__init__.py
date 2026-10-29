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
        addr="10.41.209.62", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_IP_PDU_1 = RRB("10.41.155.233", [3])
_IP_PDU_2 = RRB("10.41.155.234", [4])
_IP_PDU_3 = RRB("10.41.155.247", [1])
_IP_PDU_4 = RRB("10.58.178.86", [1])
_IP_PDU_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_IP_PDU_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_IP_PDU_4.pdu_ports[1].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA204859644",
    pdu_port=_IP_PDU_2.pdu_ports[4],
    product_code="473941A.101",
    radio_type="AZHA",
)
_rmod_2 = RU(
    ru_hw_group="cMAArChile_64T64R",
    serial_number="L1204110678",
    pdu_port=_IP_PDU_3.pdu_ports[1],
    product_code="475124B.M01",
    radio_type="AEHC",
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="AH221500748",
    pdu_port=_IP_PDU_4.pdu_ports[1],
    product_code="475432A.101",
    radio_type="AZHL",
)

_fsp_1 = CapacityUnit(
    addr="192.168.255.1",
    hardware_type="ABIO",
    serial_number="L1211709870",
    product_code="475266A.102",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.255.1",
    hardware_type="ABIN",
    serial_number="L1204802726",
    product_code="474824A.102",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_IP_PDU_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191004195",
	test_pc=_test_pc_master,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])





_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    enbs=[_enb_sbts_1],
	tl_cloud_topology="CLOUD_SRAN_L_1ASIB_1ABIO_1AZHA_1AEHC_1AZHL",
)

__all__ = ["tl"]
