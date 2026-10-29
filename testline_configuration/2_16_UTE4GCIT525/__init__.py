__maintainer__ = "Przemyslaw Krolikowski"
__owner_email__ = "I_MN_RAN_TRUNK_SG_WRO2@internal.nsn.com"
__email__ = "przemyslaw.krolikowski@nokia.com"

from taf.config.testline import Connection
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CoreUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine

__all__ = ["tl"]

_pdu_enb = ATEN(addr="10.42.168.236", port_numbers=[7])
_pdu_rus = ATEN(addr="10.42.169.48", port_numbers=[6, 7])

_ru1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="6Q190118722",
    pdu_port=_pdu_rus.pdu_ports[6],
)
_ru2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9190906224",
    pdu_port=_pdu_rus.pdu_ports[7],
)
_asoh = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_enb.pdu_ports[7],
    hardware_type="ASOH",
    hardware_version="A.101",
    serial_number="L1241601555",
    rus=[_ru1, _ru2],
)
_airscale = Airscale(core_units=[_asoh])
_enb = RealEnb(
    system_module=_airscale,
    rms=[_ru1, _ru2],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.163.155", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb.system_module.core_units[0],
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_R4H_REALRF_TL01",
)
