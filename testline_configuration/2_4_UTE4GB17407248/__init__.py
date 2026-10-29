__maintainer__ = "UTE team"
__team__ = "UTE team"
__email__ = "UTE@nokia.com"
import os
from taf.config.testline.adapters.ute_testline_adapter import prepare_ute_testline_configuration_data
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.ue import IPHY

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu_1 = FPFH(addr="10.16.94.48", port_numbers=[5, 6])
vlans = None
airscale_1_capacity_unit_fbip1 = CapacityUnit(addr="127.0.0.2", hardware_type="ABIA")
airscale_1_common_unit = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[airscale_1_capacity_unit_fbip1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A102",
)
enb_airscale_1 = Airscale([airscale_1_common_unit])
enb_1 = RealEnb(
    system_module=enb_airscale_1,
    trs_ip=NetworkAddress(v4="10.0.1.2"),
    top_ip=NetworkAddress(v4="10.42.161.252"),
    oam_ip="10.0.1.1",
)
iphy_ue_1 = IPHY(
    SshServiceDetails(addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    pdu_port=_pdu_1.pdu_ports[6],
    trs_ip="10.0.2.2",
    hardware_type="FSMF",
)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.16.94.217", username="ute", password="ute"),
    connections=[airscale_1_common_unit, iphy_ue_1],
)
tl = prepare_ute_testline_configuration_data(
    TestLine(test_pc=_test_pc_1, enbs=[enb_1], tl_cloud_topology="unknown", ues=[iphy_ue_1], vlan_ids=vlans)
)
__all__ = ["tl"]
