__maintainer__ = "Jakub Pachana"
__email__ = "jakub.pachana@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.simulator import IPHY

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.164.155", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.164.87", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.169.59",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.42.169.60",
    port_numbers=[1, 2],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512074",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512032",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512075",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.39",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512034",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512040",
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512071",
)

_fct_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="A.202",
    serial_number="L1164704607",
)

_fct_enb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.202",
    serial_number="L1164802986",
)

_smod_1 = Flexi([_fct_enb_1])
_smod_2 = Flexi([_fct_enb_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1)
_enb_sbts_2 = RealEnb(system_module=_smod_2, master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_fct_iphy_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7164443576",
    mac_addr="d8:ef:cd:74:c2:a0",
)

_fct_iphy_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="L1142036527",
    mac_addr="00:0f:bb:f7:eb:d6",
)

_fct_iphy_3 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162902216",
    mac_addr="d8:ef:cd:4f:b7:a4",
)

_fct_iphy_4 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.4", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162902191",
    mac_addr="d8:ef:cd:4f:97:03",
)

_fct_iphy_5 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.5", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162854934",
    mac_addr="d8:ef:cd:4f:b5:b4",
)

_fct_iphy_6 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.6", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162854948",
    mac_addr="d8:ef:cd:4f:77:32",
)

_fct_iphy_7 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162854923",
    mac_addr="d8:ef:cd:4f:96:b3",
)

_fct_iphy_8 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.8", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162854932",
    mac_addr="d8:ef:cd:4f:94:f3",
)

_fct_iphy_9 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.9", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162902214",
    mac_addr="d8:ef:cd:4f:b8:14",
)

_fct_iphy_10 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.10", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162854925",
    mac_addr="d8:ef:cd:4f:97:43",
)

_fct_iphy_11 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162854920",
    mac_addr="d8:ef:cd:4f:7e:02",
)

_fct_iphy_12 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.12", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7162854935",
    mac_addr="d8:ef:cd:4f:7b:82",
)

_rmod_sim_1 = IPHY(
    ip_set=1,
    trs_ip_addr=NetworkAddress(v4="10.0.2.2"),
    common_unit=_fct_iphy_1,
    test_pc=_test_pc_1,
)
_rmod_sim_2 = IPHY(
    ip_set=2,
    trs_ip_addr=NetworkAddress(v4="10.0.2.4"),
    common_unit=_fct_iphy_2,
    test_pc=_test_pc_1,
)
_rmod_sim_3 = IPHY(
    ip_set=3,
    trs_ip_addr=NetworkAddress(v4="10.0.2.6"),
    common_unit=_fct_iphy_3,
    test_pc=_test_pc_1,
)
_rmod_sim_4 = IPHY(
    ip_set=4,
    trs_ip_addr=NetworkAddress(v4="10.0.2.8"),
    common_unit=_fct_iphy_4,
    test_pc=_test_pc_1,
)
_rmod_sim_5 = IPHY(
    ip_set=5,
    trs_ip_addr=NetworkAddress(v4="10.0.2.10"),
    common_unit=_fct_iphy_5,
    test_pc=_test_pc_1,
)
_rmod_sim_6 = IPHY(
    ip_set=6,
    trs_ip_addr=NetworkAddress(v4="10.0.2.12"),
    common_unit=_fct_iphy_6,
    test_pc=_test_pc_1,
)
_rmod_sim_7 = IPHY(
    ip_set=7,
    trs_ip_addr=NetworkAddress(v4="10.0.2.14"),
    common_unit=_fct_iphy_7,
    test_pc=_test_pc_2,
)
_rmod_sim_8 = IPHY(
    ip_set=8,
    trs_ip_addr=NetworkAddress(v4="10.0.2.16"),
    common_unit=_fct_iphy_8,
    test_pc=_test_pc_2,
)
_rmod_sim_9 = IPHY(
    ip_set=9,
    trs_ip_addr=NetworkAddress(v4="10.0.2.18"),
    common_unit=_fct_iphy_9,
    test_pc=_test_pc_2,
)
_rmod_sim_10 = IPHY(
    ip_set=10,
    trs_ip_addr=NetworkAddress(v4="10.0.2.20"),
    common_unit=_fct_iphy_10,
    test_pc=_test_pc_2,
)
_rmod_sim_11 = IPHY(
    ip_set=11,
    trs_ip_addr=NetworkAddress(v4="10.0.2.22"),
    common_unit=_fct_iphy_11,
    test_pc=_test_pc_2,
)
_rmod_sim_12 = IPHY(
    ip_set=12,
    trs_ip_addr=NetworkAddress(v4="10.0.2.24"),
    common_unit=_fct_iphy_12,
    test_pc=_test_pc_2,
)
tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    iphys=[
        _rmod_sim_1,
        _rmod_sim_2,
        _rmod_sim_3,
        _rmod_sim_4,
        _rmod_sim_5,
        _rmod_sim_6,
        _rmod_sim_7,
        _rmod_sim_8,
        _rmod_sim_9,
        _rmod_sim_10,
        _rmod_sim_11,
        _rmod_sim_12,
    ],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_AILR_B1-6_12IPHY",
)

__all__ = ["tl"]
