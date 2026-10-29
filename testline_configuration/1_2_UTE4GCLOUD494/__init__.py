__maintainer__ = "arunkumar.a@nokia.com"
__team__ = "MN_RAN_Pz_BLR_2_SG"
__email__ = "arunkumar.a@nokia.com"
__Owner_email__ = "arunkumar.a@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, RRB
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.54.229", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_IP_PDU_1 = RRB("10.41.155.176", [2,3,6])
_IP_PDU_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[6].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="AS175102203",
    pdu_port=_IP_PDU_1.pdu_ports[3]
    )

_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="AS175102222",
    pdu_port=_IP_PDU_1.pdu_ports[6]
    )
_bbmod_1 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIA",
    serial_number="EA184980187",
    rus=[_rmod_1, _rmod_2] 
    )

_bbmod_2 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIA",
    serial_number="K9172928176",
    )

_ASIA_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2],
    pdu_port=_IP_PDU_1.pdu_ports[2],
    hardware_type="ASIA",
    serial_number="AH184600923",
    test_pc=_test_pc_master,
    ) 
_smod_1 = Airscale([_ASIA_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2]
    )
_test_pc_master.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_2ABIA_2FRMF",
    )
 
__all__ = ["tl"]

