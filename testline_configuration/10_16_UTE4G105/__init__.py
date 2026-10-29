__maintainer__ = "Slawomir Jastrzebski"
__email__ = "slawomir.jastrzebski@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.simulator import IPHY

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.90", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = Gude(
    addr="10.42.169.130",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="ATEN",
    version="PE8108G",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    serial_number="NK154330298",
    pdu_port=_pdu.pdu_ports[2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBBC",
    serial_number="AS173620617",
    pdu_port=_pdu.pdu_ports[3],
)

_fct_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.102",
    serial_number="L1133810613",
)

_smod = Flexi([_fct_enb_1])

_enb_sbts = RealEnb(system_module=_smod)

_fct_iphy_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="L1141929038",
    mac_addr="00:af:fe:d0:0f:01",
)

_fct_iphy_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA143961240",
    mac_addr="60:a8:fe:0b:2f:db",
)

_fct_iphy_3 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="F7141811944",
    mac_addr="60:a8:fe:3a:74:7b",
)

_rmod_sim_1 = IPHY(
    ip_set=1,
    trs_ip_addr=NetworkAddress(v4="10.0.2.2"),
    common_unit=_fct_iphy_1,
    test_pc=_test_pc,
)
_rmod_sim_2 = IPHY(
    ip_set=2,
    trs_ip_addr=NetworkAddress(v4="10.0.2.4"),
    common_unit=_fct_iphy_2,
    test_pc=_test_pc,
)

_rmod_sim_3 = IPHY(
    ip_set=3,
    trs_ip_addr=NetworkAddress(v4="10.0.2.6"),
    common_unit=_fct_iphy_3,
    test_pc=_test_pc,
)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    iphys=[_rmod_sim_1, _rmod_sim_2, _rmod_sim_3],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_FCC_CC_3IPHY",
)

__all__ = ["tl"]
