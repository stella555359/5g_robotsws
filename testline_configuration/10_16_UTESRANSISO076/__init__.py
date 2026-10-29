__maintainer__ = "Kamil Adamowski"
__email__ = "kamil.adamowski@nokia.com"
__owner_email__ = "kamil.adamowski@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.optical_switch import OpticalSwitch, Leoni
from taf.config.testline.fhs import FHS, FhsType

_pdu_1 = Gude("10.44.200.19", [1, 2, 5, 6, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.15", [1, 3], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.22", [1, 2, 4, 5, 6, 7, 8, 9, 10], "EPC", "8220-1")
_pdu_4 = Gude("10.44.200.21", [6, 7], "EPC", "8220-1")

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA191771394",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGS",
    serial_number="L9134400966",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="L1140309611",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXDD",
    serial_number="F7201302243",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr4.0a_2T2R",
    radio_type="FRGY",
    serial_number="K9173442946",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr4.3b_4T4R",
    radio_type="FRIJ",
    serial_number="EA163885106",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHIB",
    serial_number="EA173715126",
    pdu_port=_pdu_3.pdu_ports[10],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="EA201652685",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHIB",
    serial_number="AH192301520",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_12 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="FRIJ",
    serial_number="EA173584364",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_14 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="6Q184426178",
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_11 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHIB",
    serial_number="EA173715136",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_10 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="FRIJ",
    serial_number="EA173380101",
    pdu_port=_pdu_3.pdu_ports[6],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[12],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.126", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.126", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # test_pc=_test_pc_fhs,
    optical_switch_channels=None,
    serial_number="6Q192920547",
    product_code="473922A.101",
    rus=[_rmod_1, _rmod_8],
)

_fhs_2 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[11],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.127", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.127", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # test_pc=_test_pc_fhs,
    optical_switch_channels=None,
    serial_number="6Q191322004",
    product_code="473922A.101",
    rus=[_rmod_2, _rmod_6, _rmod_9],
)

_fhs_3 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[10],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # test_pc=_test_pc_fhs,
    optical_switch_channels=None,
    serial_number="6Q191131211",
    product_code="473922A.101",
    rus=[_rmod_3, _rmod_5, _rmod_7],
)

_fhs_4 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_3.pdu_ports[7],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # test_pc=_test_pc_fhs,
    optical_switch_channels=None,
    serial_number="6Q211901454",
    product_code="473922A.101",
    rus=[_rmod_10, _rmod_11],
)

_fhs_5 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_3.pdu_ports[2],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # test_pc=_test_pc_fhs,
    optical_switch_channels=None,
    serial_number="6Q192920568",
    product_code="473922A.101",
    rus=[_rmod_12, _rmod_14],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="4752266B.101",
    serial_number="L1223309842",
    pdu_port=_pdu_4.pdu_ports[7],
    fhs=[_fhs_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808032",
    pdu_port=_pdu_4.pdu_ports[7],
    rus=[_rmod_4, _rmod_8],
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163913878",
    pdu_port=_pdu_4.pdu_ports[7],
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1223309808",
    pdu_port=_pdu_4.pdu_ports[6],
    fhs=[_fhs_2, _fhs_4, _fhs_5],
    rus=[_rmod_1],
)

_fsp_5 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508114",
    pdu_port=_pdu_4.pdu_ports[6],
    fhs=[_fhs_2, _fhs_3, _fhs_5],
    rus=[_rmod_1],
)

_fsp_6 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213114807",
    pdu_port=_pdu_4.pdu_ports[6],
    fhs=[_fhs_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_4.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1232304193",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_4.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224102503",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_14,
    ],
    oam_ip=NetworkAddress("10.44.137.152"),
    instance_id=1486,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_4,
        _rmod_2,
        _rmod_3,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_12,
        _rmod_11,
    ],
    master=_enb_sbts_1,
    oam_ip=NetworkAddress("10.44.137.152"),
    instance_id=1487,
)

_enb_sbts_1.slave = _enb_sbts_2

_opt_sw_1 = Leoni(addr="10.42.54.49", model="mol 6x(2x6)", port=10001)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.178.108", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.178.109", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    optical_switches=[_opt_sw_1],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO076",
)

__all__ = ["tl"]
