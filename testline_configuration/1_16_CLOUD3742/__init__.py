__maintainer__ = "Kamil Szczesniak"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "kamil.szczesniak@nokia.com"

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
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.83.121", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.42.80.107",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBIH",
    hardware_version="472568A.101",
    serial_number="L1144220830",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBIH",
    hardware_version="472568A.101",
    serial_number="EA180211198",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="FSIH",
    hardware_version="472567A",
    serial_number="EA174301297",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FZND",
    radio_type="FZND",
    serial_number="10TYR10E2000104",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_FHBB_FZND",
)

__all__ = ["tl"]
