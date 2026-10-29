__maintainer__ = "Manasa Chandrashekar"
__owner_email__ = "manasa.chandrashekar@nokia.com"
__team__ = "MN_RAN_Pz_BLR_5_SG"
__email__ = "I_MN_RAN_PZ_BLR_SG5_ATHULYA_SQD@internal.nsn.com"

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
        addr="10.43.54.222", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_IP_PDU_1 = RRB("10.41.155.145", [4])
_IP_PDU_2 = RRB("10.41.155.146", [4, 6])
_IP_PDU_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[6].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    serial_number="RW192203807",
    pdu_port=_IP_PDU_2.pdu_ports[4],
    product_code="473914A.203",
    radio_type="AZNA",
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA222758052",
    pdu_port=_IP_PDU_2.pdu_ports[6],
    product_code="474914A.101",
    radio_type="AHEGC",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="EA184979754",
	product_code="473096A.103",
    pdu_port=_IP_PDU_1.pdu_ports[4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    serial_number="L1204008449",
	product_code="475266A.101",
    pdu_port=_IP_PDU_1.pdu_ports[4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_IP_PDU_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH213853711",
    test_pc=_test_pc_master,
    rus=[_rmod_1, _rmod_2,],
)

_smod_1 = Airscale([_fct_1])



_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1,_rmod_2,], oam_ip=[NetworkAddress(v4="10.53.203.108")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIB_1ABIA_1ABIO_1AHEGC_1AZNA",
)

__all__ = ["tl"]

