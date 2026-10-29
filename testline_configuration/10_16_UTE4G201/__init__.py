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
    SshServiceDetails(addr="10.42.62.145", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = Gude(
    addr="10.42.60.199",
    port_numbers=[1, 2, 3, 4, 5, 6, 7],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170313714",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170320007",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170320005",
)

_fct_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173719035",
)

_smod = Flexi([_fct_enb_1])

_enb_sbts = RealEnb(system_module=_smod)

_fct_iphy_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="empty",
    serial_number="empty",
    mac_addr="empty",
)

_fct_iphy_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="empty",
    serial_number="empty",
    mac_addr="empty",
)

_fct_iphy_3 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="empty",
    serial_number="empty",
    mac_addr="empty",
)

_fct_iphy_4 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.4", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7164308716",
    mac_addr="d8:ef:cd:73:ee:eb",
)

_fct_iphy_5 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.5", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7154945197",
    mac_addr="48:ec:5b:42:e8:32",
)

_fct_iphy_6 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.6", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7164308695",
    mac_addr="d8:ef:cd:73:ef:9b",
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
_rmod_sim_4 = IPHY(
    ip_set=4,
    trs_ip_addr=NetworkAddress(v4="10.0.2.8"),
    common_unit=_fct_iphy_4,
    test_pc=_test_pc,
)
_rmod_sim_5 = IPHY(
    ip_set=5,
    trs_ip_addr=NetworkAddress(v4="10.0.2.10"),
    common_unit=_fct_iphy_5,
    test_pc=_test_pc,
)
_rmod_sim_6 = IPHY(
    ip_set=6,
    trs_ip_addr=NetworkAddress(v4="10.0.2.12"),
    common_unit=_fct_iphy_6,
    test_pc=_test_pc,
)
tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    iphys=[
        _rmod_sim_1,
        _rmod_sim_2,
        _rmod_sim_3,
        _rmod_sim_4,
        _rmod_sim_5,
        _rmod_sim_6,
    ],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_AIR_B1-3_6IPHY",
)

__all__ = ["tl"]
