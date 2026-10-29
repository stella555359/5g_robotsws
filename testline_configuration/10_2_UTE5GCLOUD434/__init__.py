__maintainer__ = "Sandeep Sahu"
__team__ = "MN_RAN_Pz_BLR_5_SG"
__email__ = "I_MN_RAN_PZ_BLR_SG5_VAJRA_SQD@internal.nsn.com"
__owner_email__ = "sandeep.1.sahu@nokia.com"

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
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.attenuator import AttenuationPort, TopYoung


_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.54.200", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_IP_PDU_1 = RRB("10.41.155.145", [5])
_IP_PDU_2 = RRB("10.41.155.146", [2, 7])
_IP_PDU_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[7].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    serial_number="6Q191427771",
    pdu_port=_IP_PDU_2.pdu_ports[2],
    product_code="473806A.101",
    radio_type="AHEC",
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="EA192276326",
    pdu_port=_IP_PDU_2.pdu_ports[7],
    product_code="473484A.101",
    radio_type="AHEB",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1204101445",
	product_code="475266A.101",
    pdu_port=_IP_PDU_1.pdu_ports[5],  
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_IP_PDU_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191003571",
    rus=[_rmod_1,_rmod_2,],
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1,_rmod_2], oam_ip=[NetworkAddress(v4="10.43.197.141")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )
                                                                
tl = TestLine(
    test_pc=_test_pc_master,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIB_1ABIO_1AHEC_1AHEB",
)

__all__ = ["tl"]
