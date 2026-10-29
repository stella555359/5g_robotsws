__maintainer__ = "Karol Sadowski"
__email__ = "karol.sadowski@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.23", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.60.95",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.42.80.20",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.42.80.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9172606372",
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204212543",
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1204706738",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.203",
    serial_number="L1192208481",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="", serial_number="BL1911V00BX", pdu_port=_pdu_2.pdu_ports[5]
)  # AHFIB
_rmod_2 = RU(
    ru_hw_group="", serial_number="AH204301193", pdu_port=_pdu_3.pdu_ports[5]
)  # AZQC
_rmod_3 = RU(
    ru_hw_group="", serial_number="BL2040G1M5C", pdu_port=_pdu_1.pdu_ports[8]
)  # AHLOA

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])


tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_AIL_B1-B3_AZQC_AHFIB_AHLOA_CBRS_17",
)

__all__ = ["tl"]
