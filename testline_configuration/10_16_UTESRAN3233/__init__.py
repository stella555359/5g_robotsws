__maintainer__ = "Alicja Tomczak"
__email__ = "alicja.tomczak@nokia.com"

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


_pdu_1 = Gude("10.44.200.146", [8], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.228", [2], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="RF.MRM6.trunk19.20250908.001",
    serial_number="AH212300361",
    radio_type="AWHHF",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOF",
    hardware_version="476147A.101",
    serial_number="EA232850506",
    rus=[_rmod_1],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.84.51"),
    instance_id=100792,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.131", username="ute"),
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
    pdus=[_pdu_1, _pdu_2],
    tl_cloud_topology="CLOUD_SRAN_L_ASOF_AZQC_CBRS_18",
)

__all__ = ["tl"]
