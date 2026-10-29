__maintainer__ = "Piotr Lukaszewicz"
__email__ = "piotr.lukaszewicz@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
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
from taf.config.testline.ran import BSC, RNC

_pdu_1 = Gude(
    addr="10.42.60.95",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_rmod_1 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH193502332", pdu_port=_pdu_1.pdu_ports[11])
_rmod_2 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH210200019", pdu_port=_pdu_1.pdu_ports[12])
_rmod_3 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH210100546", pdu_port=_pdu_1.pdu_ports[1])
_rmod_4 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH205300356", pdu_port=_pdu_1.pdu_ports[2])

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171216181",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9172606380",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA183642785",
    rus=[_rmod_4],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1181310726",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.241", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_ASIAAL_ABIAB1_ABIAB2_ABIAB3_4xAZQC_CBRS_13",
)

__all__ = ["tl"]
