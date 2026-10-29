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
        addr="10.43.54.96", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)



_IP_PDU_1 = RRB("10.41.155.224", [1, 4])
_IP_PDU_2 = RRB("10.41.155.225", [2, 5])

_IP_PDU_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[2].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="RY132112284",
    pdu_port=_IP_PDU_1.pdu_ports[1],
    product_code="472704A.103",
    radio_type="FRIG",
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="RY160301408",
    pdu_port=_IP_PDU_2.pdu_ports[5],
    product_code="472704A.103",
    radio_type="FRIG",
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_3T6R",
    serial_number="K9123708953",
    pdu_port=_IP_PDU_2.pdu_ports[2],
    product_code="472142A.202",
    radio_type="FXCA",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1173705242",
    product_code="473096A.103",
    pdu_port=_IP_PDU_1.pdu_ports[4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_IP_PDU_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162615080",
    rus=[_rmod_1,_rmod_2,_rmod_3,],
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])




_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3], oam_ip=[NetworkAddress(v4="10.41.211.190")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RRM_L_1ASIA_1ABIA_2FRIG_1FXCA_CPKPI_BTS79",
)

__all__ = ["tl"]
