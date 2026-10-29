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
        addr="10.43.54.165", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)


_IP_PDU_1 = RRB("10.41.155.213", [2, 7, 8])
_IP_PDU_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[8].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="1M184217576",
    pdu_port=_IP_PDU_1.pdu_ports[8],
    product_code="472924A.203",
    radio_type="FXED",
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="L1150506179",
    pdu_port=_IP_PDU_1.pdu_ports[7],
    product_code="472924A.101",
    radio_type="FXED",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="EA191377986",
	product_code="473096A.103",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1190710349",
	product_code="473096A.103",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_IP_PDU_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="AH184600909",
    rus=[_rmod_1,_rmod_2,],
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])





_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2], oam_ip=[NetworkAddress(v4="10.41.211.214")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RRM_L_1ASIA_2ABIA_2FXED_CP_KPI",
)

__all__ = ["tl"]
