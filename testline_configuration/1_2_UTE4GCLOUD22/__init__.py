__maintainer__ = "Selvamariappan"
__team__ = "MN_RAN_RD_VRF_BLR1_5"
__email__ = "I_MN_RAN_PZ_BLR_SG5_ATHULYA_SQD_GMS@internal.nsn.com"
__owner_email__ = "selvamariappan.subramanian@nokia.com"

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
        addr="10.43.54.159", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)


_IP_PDU_1 = RRB("10.41.155.204", [6])
_IP_PDU_2 = RRB("10.58.178.84", [1, 2])
_IP_PDU_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[2].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="VEG22.40.R01",
    serial_number="1M173466350",
    pdu_port=_IP_PDU_2.pdu_ports[1],
    product_code="472501A.105",
    radio_type="FXEB",
)
_rmod_2 = RU(
    ru_hw_group="VEG22.40.R01",
    serial_number="1M173835629",
    pdu_port=_IP_PDU_2.pdu_ports[2],
    product_code="472501A.105",
    radio_type="FXEB",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    serial_number="L1231609499",
	product_code="475792A.101",
    pdu_port=_IP_PDU_1.pdu_ports[6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_IP_PDU_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH224040991",
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])



_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2], oam_ip=[NetworkAddress(v4="10.41.211.141")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIL_1ABIP_2FXEB",
)

__all__ = ["tl"]
