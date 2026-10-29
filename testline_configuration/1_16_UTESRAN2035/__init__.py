__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "maciej.brzezniak@nokia.com"
__customer__ = "UUF"
__bucket__ = "Special"
__rack__ = "GTA-1048"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

# ************************************************ PDUs ************************************************
# smod port 7, 8; rm port 9, 10
_pdu_1 = Gude(
    addr="10.42.60.140",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 1, 2
_pdu_2 = Gude(
    addr="10.42.60.196",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu_1, _pdu_2]

# ************************************************ RUs *************************************************
_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQF",
    serial_number="1M251706791",
    pdu_port=_pdu_2.pdu_ports[1],
    #lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="", port=5001),
    #    ]
    #),
)

_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQF",
    serial_number="1M251706792",
    pdu_port=_pdu_2.pdu_ports[2],
    #lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="", port=5001),
    #    ]
    #),
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARPB",
    serial_number="K9251943717",
    pdu_port=_pdu_1.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.176", port=5001),
        ]
    ),
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARPB",
    serial_number="K9252600380",
    pdu_port=_pdu_1.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.163", port=5001),
        ]
    ),
)

_asog1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOG",
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.17",
            hardware_type="ABOG",
            rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
        )
    ],
    hardware_version="476254A.102",
    serial_number="L1250801865",
)

_asog2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOG",
    capacity_units=[
        CapacityUnit(
            addr="192.168.253.17",
            hardware_type="ABOG",
            rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
        )
    ],
    hardware_version="476254A.102",
    serial_number="L1250801868",
)

_smod_1 = Airscale([_asog1])
_smod_2 = Airscale([_asog2])

_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=55449,
    global_bts_id=55449,
)

_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    master=_sbts_1
)


# ************************************************ VMs ************************************************
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.27", username="ute", password="qwe123QWE!@#"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.28", username="ute", password="qwe123QWE!@#"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_sbts_1, _sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NL_2ASOG_2AVQF_2ARPB_1_UUFWRO",
    pdus=_pdus,
)

__all__ = ["tl"]