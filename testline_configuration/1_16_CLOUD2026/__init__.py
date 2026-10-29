__maintainer__ = "Lukasz Lechowicz"
__email__ = "lukasz.lechowicz@nokia.com"

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
from taf.config.testline.testpc import Connection, TestPc

_pdu = Gude(
    addr="10.42.60.95",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_rmod_1 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH193502319", pdu_port=_pdu.pdu_ports[6])

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIN",
    hardware_version="A.103",
    serial_number="L1213014351",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171221075",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1223306776",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod_1  = Flexi([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.247", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_ASIML_ABIN_ABIA_AZQC_UTECA_CBRS_15",
)

__all__ = ["tl"]
