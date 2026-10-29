__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Generic"
__bucket__ = "1.1"
__rack__ = "GTA-1067"

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
# rm port  6, 11, 12
_pdu_1 = Gude(
    addr="10.42.80.47",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 4,7,8
_pdu_2 = Gude(
    addr="10.42.80.223",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 3
_pdu_3 = Gude(
    addr="10.42.80.224",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 10
_pdu_4 = Gude(
    addr="10.42.80.218",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type="FXCA",
    serial_number="L6120517041",
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type="FXCA",
    serial_number="K9124504259",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGHA",
    serial_number="K9251025340",
    pdu_port=_pdu_2.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.153", port=5001),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1225206314",
    pdu_port=_pdu_3.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.151", port=5001),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FXEF",
    serial_number="K9173120735",
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEH",
    serial_number="EA213657631",
    pdu_port=_pdu_4.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.60.171", port=5006),
        ],
    ),
)
_rmod_7 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R",
    radio_type="AZQG",
    serial_number="L1194014639",
    pdu_port=_pdu_2.pdu_ports[8],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.217", port=5001),
        ],
    ),
)
_rmod_8 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type="AEQQ",
    serial_number="DH242131635",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.218", port=5001),
        ],
    ),
)

_fsp1_ = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224206412",
    rus=[_rmod_7],
)
_fsp2_ = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824B.101",
    serial_number="L1224006552",
    rus=[_rmod_5],
)
_fsp3_ = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216142",
    rus=[_rmod_1, _rmod_2],
)
_fsp4_ = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224206406",
    rus=[_rmod_3],
)
_fsp5_ = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184319528",
    rus=[_rmod_6],
)
_fsp6_ = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244806862",
    rus=[_rmod_4, _rmod_8],
)

_asil_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp1_, _fsp2_, _fsp3_],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224704445",
)
_asil_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp4_, _fsp5_, _fsp6_],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1240504373",
)

_smod_1 = Airscale([_asil_1])
_smod_2 = Airscale([_asil_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_5, _rmod_7],
                      instance_id=8616, global_bts_id=8616)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_6, _rmod_8], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.133", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.134", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIL_1ABIA_1ABIL_1ABIN_2ABIO_1ABIP_2FXCA_1FXEF_1AEQQ_1AHEH_1AHEGHA_1AQQK_1AZQG_1_UUFWRO",
)

__all__ = ["tl"]
