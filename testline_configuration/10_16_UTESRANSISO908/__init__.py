__maintainer__ = "Izabela Wencel"
__email__ = "izabela.wencel@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.optical_switch import OpticalSwitch, Leoni
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.fhs import FHS, FhsType

_pdu_1 = ATEN("10.42.169.160", [1, 2, 4, 6], "", "")
_pdu_2 = Gude("10.42.168.248", [8, 9, 10, 11, 12], "EPC", "8220-1")
# _pdu_3 = Gude("10.42.169.159", [1, 3], "EPC", "8220-1")

# rmods, fsp, fct, test_pc, tl

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGA",
    serial_number="K9175107174",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.1", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_2T4R",
    radio_type="UHEC",
    serial_number="YP16020784B",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_3 = RU(
    ru_hw_group="FRMr4.0a_2T2R_Corona",
    radio_type="FRGB",
    serial_number="K9153640179",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_4T4R_Quattro",
    radio_type="FRHD",
    serial_number="RY133607248",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.127", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
# _rmod_5 = RU(
#    ru_hw_group="FRMr4.3a_2T2R_Halo",
#    radio_type="FHPD",
#    serial_number="EA174551742",
#    default_telnet_connection_details=TelnetConnectionDetails(
#        addr="172.16.73.ip", port=2323
#    ),
#    pdu_port=_pdu_1.pdu_ports[12],
# )

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[4],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    # test_pc=_test_pc_fhs,
    optical_switch_channels=None,
    serial_number="6Q191131212",
    product_code="473922A.101",
    rus=[_rmod_3],
)


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1215008488",
    pdu_port=_pdu_1.pdu_ports[2],
    fhs=[_fhs_1],
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="47309gA.102",
    serial_number="L1163606709",
    pdu_port=_pdu_1.pdu_ports[2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204705905",
    pdu_port=_pdu_1.pdu_ports[2],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512022",
    pdu_port=_pdu_1.pdu_ports[6],
    rus=[_rmod_1, _rmod_2],
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172435118",
    pdu_port=_pdu_1.pdu_ports[6],
    rus=[_rmod_4],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512029",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1202810828",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1163406189",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        # _rmod_1,
        # _rmod_2,
        _rmod_3,
        # _rmod_4,
    ],
    oam_ip=NetworkAddress("10.42.175.56"),
    instance_id=1444,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        # _rmod_3,
        _rmod_4,
    ],
    master=_enb_sbts_1,
    # oam_ip=NetworkAddress("10.42.175.56"),
    instance_id=1444,
)

_enb_sbts_1.slave = _enb_sbts_2

# _opt_sw_1 = Leoni(addr="10.42.170.186", model="mol 6x4", port=10001)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.30", username="ute"),
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
    SshServiceDetails(addr="10.42.184.104", username="ute"),
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
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO908",
    #    optical_switches=[_opt_sw_1],
)

__all__ = ["tl"]
