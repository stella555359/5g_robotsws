__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"

from taf.config.testline.airscale import Airscale, CoreUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude("10.42.80.143", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdus = [_pdu_1]

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="AH205300312",
    radio_type="AZQC",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASOF",
    hardware_version="476147A.101",
    serial_number="EA232850514",
    rus=[_rmod_1],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.183.37"),
    instance_id=8048,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.116", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_L_ASOF_AZQC",
)

__all__ = ["tl"]
