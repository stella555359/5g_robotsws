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
        addr="10.43.54.89", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)


_IP_PDU_1 = RRB("10.41.155.237", [4])
_IP_PDU_2 = RRB("10.41.155.236", [3])
_IP_PDU_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_IP_PDU_2.pdu_ports[3].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    serial_number="K9191719226",
    pdu_port=_IP_PDU_2.pdu_ports[3],
    product_code="473995A.101",
    radio_type="AHEGA",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1214206694",
    product_code="475266A.104",
    pdu_port=_IP_PDU_1.pdu_ports[4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_IP_PDU_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH203362914",
    rus=[_rmod_1,],
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])




_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1], oam_ip=[NetworkAddress(v4="10.41.211.213")])

_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )


tl = TestLine(
    test_pc=_test_pc_master,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RRM_L_1ASIB_1ABIO_1AHEGA_CPKPI_BTS136",
)

__all__ = ["tl"]
