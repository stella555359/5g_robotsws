__maintainer__ = "Karol Sadowski"
__email__ = "karol.sadowski@nokia.com"

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
    addr="10.42.199.247",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="EPC",
)

_rmod_1 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH205200288", pdu_port=_pdu_1.pdu_ports[1])
_rmod_2 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="AH193502311", pdu_port=_pdu_1.pdu_ports[2])
_rmod_3 = RU(ru_hw_group="FRMr5.1a_4T4R", radio_type="AZQC", serial_number="1M184800053", pdu_port=_pdu_1.pdu_ports[3])

_fsp_1 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171221096",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212874030",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3])

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.97", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_L_ASIB_ABIA_3AZQC_CBRS_2",
)

__all__ = ["tl"]
