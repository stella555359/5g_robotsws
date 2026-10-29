__maintainer__ = "Piotr Lukaszewicz"
__email__ = "piotr.lukaszewicz@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ran import BSC, RNC


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.244", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.80.125",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1173009888",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171212680",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.104",
    serial_number="L1182816609",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Flexi([_fct_1])

_rmod_1 = RU(ru_hw_group="", serial_number="1M184800058", pdu_port=_pdu_1.pdu_ports[7])

_rmod_2 = RU(ru_hw_group="", serial_number="1M185214596", pdu_port=_pdu_1.pdu_ports[8])

_rmod_3 = RU(ru_hw_group="", serial_number="DC19460017J", pdu_port=_pdu_1.pdu_ports[2])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3])

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_AIR_B4_B5_AZQC_AZRB_AHFIC_CBRS_8",
)

__all__ = ["tl"]
