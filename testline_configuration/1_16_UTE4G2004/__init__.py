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
    addr="10.42.80.144",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_pdu_2 = Gude(
    addr="10.42.80.145",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_rmod_1 = RU(ru_hw_group="RF.SRM6", radio_type="AEQM", serial_number="1M211713652", pdu_port=_pdu_2.pdu_ports[10])

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",	
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214608288",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201902190",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.252", username="ute"),
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
    tl_cloud_topology="CLOUD_RF_AIL_B2_B3_AEQM_CBRS_11",
)

__all__ = ["tl"]
