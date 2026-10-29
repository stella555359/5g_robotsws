__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Reliance India"
__bucket__ = "6.2"
__rack__ = "GTA-890"

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

# smod port 1
_pdu_1 = Gude(
    addr="10.42.60.49",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 1, 2, 3
_pdu_2 = Gude(
    addr="10.42.80.26",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 5, 6, 7
_pdu_3 = Gude(
    addr="10.42.60.38",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="EA223056147",
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.237", port=5001),
        ],
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="EA223056150",
    pdu_port=_pdu_2.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.239", port=5001),
        ],
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="EA223056148",
    pdu_port=_pdu_2.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.233", port=5001),
        ],
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="K9234908769",
    pdu_port=_pdu_3.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.195", port=5001),
        ],
    ),
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="NQ232791570",
    pdu_port=_pdu_3.pdu_ports[6],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.156", port=5001),
        ],
    ),
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="NQ232791564",
    pdu_port=_pdu_3.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.197", port=5001),
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
            rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
        )
    ],
    hardware_version="475587A.102",
    serial_number="EA213154001",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    global_bts_id=55035, instance_id=55035
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.176", username="ute"),
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
    tl_cloud_topology="CLOUD_RF_AO_3AHPB_3AQQJ_UTECA",
)

__all__ = ["tl"]
