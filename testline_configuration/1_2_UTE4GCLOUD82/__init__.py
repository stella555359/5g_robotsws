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
        addr="10.41.209.49", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_IP_PDU_1 = RRB("10.58.178.86", [3])
_IP_PDU_2 = RRB("10.41.155.234", [2])
_IP_PDU_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[2].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="1M192906932",
    pdu_port=_IP_PDU_2.pdu_ports[2],
    product_code="474715A.101",
    radio_type="AAHF",
)



_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIC",
    serial_number="6Q191131762",
    product_code="474723A.101",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_IP_PDU_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="474408A.102",
    serial_number="L1194603935",
	test_pc=_test_pc_master,
    rus=[_rmod_1,],
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])



_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
	tl_cloud_topology="CLOUD_SRAN_L_1ASIBA_1ABIC_1AAHF",
)

__all__ = ["tl"]
