__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Reliance India"
__bucket__ = "6.3"
__rack__ = "GTA-1066"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc


# ************************************************ PDUs ************************************************
# rm port 1, 2, 3, 4, 5
_pdu_1 = Gude(
    addr="10.42.80.222",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# smod port 4
_pdu_2 = Gude(
    addr="10.42.80.176",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu_1, _pdu_2]

# ************************************************ RMs *************************************************
_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="DH242335035",
    pdu_port=_pdu_1.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.242", port=5001),
        ],
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="EA222355914",
    pdu_port=_pdu_1.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.241", port=5001),
        ],
    ),
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="1M230522182",
    pdu_port=_pdu_1.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.194", port=5001),
        ],
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="1M230524281",
    pdu_port=_pdu_1.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.189", port=5001),
        ],
    ),
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="1M230524288",
    pdu_port=_pdu_1.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.196", port=5001),
        ],
    ),
)

# ************************************************ ENB1 ************************************************

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASOE",
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.20",
            hardware_type="ABOE",
            rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
        )
    ],
    hardware_version="475587A.103",
    serial_number="EA223155453",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    global_bts_id=55070, instance_id=55070
)

# ************************************************ VMs ************************************************

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.111", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

# ************************************************ SUM ************************************************

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_N_1ASOE_3AQQJ_2AHPB_UTECA",
)

__all__ = ["tl"]
