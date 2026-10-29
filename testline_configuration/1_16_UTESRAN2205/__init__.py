__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Generic"
__bucket__ = "1.1"
__rack__ = "GTA-1068"

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

# smod port 9, 10
# rm port 8, 11, 12
_pdu_1 = Gude(
    addr="10.42.80.111",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 9, 12
_pdu_2 = Gude(
    addr="10.42.80.218",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 6, 12
_pdu_3 = Gude(
    addr="10.42.80.223",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 12
_pdu_4 = Gude(
    addr="10.42.80.226",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type="FXCA",
    serial_number="K9174115695",
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type="FXCA",
    serial_number="K9173810761",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGHA",
    serial_number="K9251021332",
    pdu_port=_pdu_3.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.171", port=5002),
        ],
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1224807075",
    pdu_port=_pdu_2.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.130", port=5001),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FXEF",
    serial_number="K9173214966",
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEH",
    serial_number="EA213657630",
    pdu_port=_pdu_2.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.171", port=5004),
        ],
    ),
)
_rmod_7 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R",
    radio_type="AZQG",
    serial_number="EA202050565",
    pdu_port=_pdu_3.pdu_ports[6],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.215", port=5001),
        ]
    ),
)
_rmod_8 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type="AEQQ",
    serial_number="1M241603458",
    pdu_port=_pdu_4.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.213", port=5001),
        ]
    ),
)

_abio_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224206411",
    rus=[_rmod_7],
)
_abin_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824B.101",
    serial_number="L1224006546",
    rus=[_rmod_5],
)
_abia_1 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162708819",
    rus=[_rmod_1, _rmod_2],
)
_abio_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224206404",
    rus=[_rmod_3],
)

_abil_1 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1192405416",
    rus=[_rmod_6],
)

_abip_1 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244806847",
    rus=[_rmod_4, _rmod_8],
)

_asil_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abio_1, _abin_1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224704449",
)
_asil_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_2, _abil_1, _abip_1],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224704461",
)

_smod_1 = Airscale([_asil_1])
_smod_2 = Airscale([_asil_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_5, _rmod_7],
                      instance_id=8621, global_bts_id=8621)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_6, _rmod_8], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.137", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.138", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIL_1ABIA_1ABIL_1ABIN_2ABIO_1ABIP_2FXCA_1FXEF_1AEQQ_1AHEH_1AHEGHA_1AQQK_1AZQG_3_UUFWRO",
)

__all__ = ["tl"]
