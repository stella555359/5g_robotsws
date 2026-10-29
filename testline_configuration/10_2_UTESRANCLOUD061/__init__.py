__maintainer__ = "Shree Harsha"
__owner_email__ = "shree.harsha_r@nokia.com"
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
from taf.config.testline.attenuator import AttenuationPort, TopYoung


_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.54.162", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

# AZNA
_attenuator1 = TopYoung(
    ip_addr="10.58.178.72",
    port=3001,
    attenuation_port_numbers=[6, 9],
    model="TAS16T16-51-120-1N-DEJS",
)

# AZNA
_attenuator2 = TopYoung(
    ip_addr="10.58.178.72",
    port=3001,
    attenuation_port_numbers=[6, 9],
    model="TAS16T16-51-120-1N-DEJS",
)


_IP_PDU_1 = RRB("10.41.155.204", [7])
_IP_PDU_2 = RRB("10.41.155.203", [5, 6])
_IP_PDU_3 = RRB("10.41.155.207", [8])
_IP_PDU_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_IP_PDU_3.pdu_ports[8].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[5].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA204857164",
    pdu_port=_IP_PDU_2.pdu_ports[6],
    product_code="473914A.203",
    radio_type="AZNA",
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA221256796",
    pdu_port=_IP_PDU_3.pdu_ports[8],
    product_code="474914A.101",
    radio_type="AHEGC",
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9173634028",
    pdu_port=_IP_PDU_2.pdu_ports[5],
    product_code="472574A.102",
    radio_type="FXJB",
)




_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    serial_number="EA184482025",
	product_code="473096A.103",
    rus=[_rmod_1,],
    pdu_port=_IP_PDU_1.pdu_ports[7],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    serial_number="EA184482014",
	product_code="473096A.103",
    rus=[_rmod_2,_rmod_3,],
    pdu_port=_IP_PDU_1.pdu_ports[7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_IP_PDU_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="6Q182812883",
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3], oam_ip=[NetworkAddress(v4="10.41.211.207")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    attenuator=[_attenuator1,_attenuator2],
    tl_cloud_topology="CLOUD_SRAN_LG_1ASIA_2ABIA_1AZNA_1AHEGC_1FXJB",
)

__all__ = ["tl"]
