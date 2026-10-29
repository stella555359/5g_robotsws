__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "maciej.brzezniak@nokia.com"
__customer__ = "Generic"
__bucket__ = "5.2"
__rack__ = "GTA-366"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.lmi import SerialOverTcp, SerialOverHost, LMI, Remote, Local
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

# smod port 1
_pdu_1 = Gude(
    addr="10.42.80.164",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 4, 8, 11
_pdu_2 = Gude(
    addr="10.42.60.203",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="ScRMr6.1_4T4R",
    radio_type="AHCI",
    serial_number="1M240507652",
    pdu_port=_pdu_2.pdu_ports[8],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.87", port=5001),
        ],
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPE",
    serial_number="1M204604164",
    pdu_port=_pdu_2.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.86", port=5001),
        ],
    ),
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQA",
    serial_number="1M232007169",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.37", port=5001),
        ],
    ),
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOE",
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.20",
            hardware_type="ABOE",
            rus=[_rmod_1, _rmod_2, _rmod_3],
        )
    ],
    hardware_version="475587A.103",
    serial_number="DH224715644",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3],
                      instance_id=55280, global_bts_id=55280)

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.16", username="ute"),
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
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NL_1ASOE_1AHCI_1AHPE_1AQQA_UUF_3_UTECA",
)

__all__ = ["tl"]
