__maintainer__ = "Michal Szajkowski"
__team__ = "RFSW WRO TA CORE"
__email__ = "I_AM_RFSW_WRO_TA_CORE@internal.nsn.com"
__owner_email__ = "michal.szajkowski@nokia.com"

__all__ = ["tl"]

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import SshServiceDetails

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.37", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.45.183.118", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

_rmod_1 = RU(
    ru_hw_group="5g-mk4-la",
    radio_type=RadioTypes.AZQG,
    serial_number="L1192409147",
    pdu_port=_pdu_1.pdu_ports[1],
)

_vm = RealEnb(rms=[_rmod_1])

tl = TestLine(
    test_pc=_test_pc_1,
    tl_cloud_topology="CLOUD_AZQG",
    pdus=[_pdu_1],
    enbs=[_vm],
)
