__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "piotr.linek@nokia.com"
__customer__ = "Generic"
__bucket__ = "7.3"
__rack__ = "GTA-885"

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

# smod port 12 pdu_1, port 11 pdu_1,
# rm port 3,6 pdu_1, port 8 pdu_2, port 4,8,10,11 pdu_3
_pdu_1 = Gude(
    addr="10.42.60.40",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.42.60.51",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3 = Gude(
    addr="10.42.60.52",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_4 = Gude(
    addr="10.42.80.26",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_5 = Gude(
    addr="10.42.80.61",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="SRM7",
    radio_type="AVQC",
    serial_number="1M243613554",
    pdu_port=_pdu_4.pdu_ports[12],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #     ]
    # ),
)
_rmod_2 = RU(
    ru_hw_group="FRM5",
    radio_type="AHPMDA",
    serial_number="K9201003083",
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.74", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRM3",
    radio_type="FRIJ",
    serial_number="EA204855835",
    pdu_port=_pdu_3.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="FRM3",
    radio_type="FRIJ",
    serial_number="EA173184162",
    pdu_port=_pdu_3.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="ERM6",
    radio_type="AZQP",
    serial_number="1M203844907",
    pdu_port=_pdu_5.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.131", port=5001),
        ]
    ),
)
_rmod_6 = RU(
    ru_hw_group="FRU6",
    radio_type="AWHHJ",
    serial_number="1M243806991",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.127", port=5001),
        ]
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_7 = RU(
    ru_hw_group="MRM6",
    radio_type="AWHHF",
    serial_number="AH243003030",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204301236",
    rus=[_rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="L1244007793",
    serial_number="475792A.102",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173009890",
    rus=[_rmod_2],
)
_fsp_4 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:223d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172558065",
    rus=[_rmod_3, _rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:1201",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224505309",
    rus=[_rmod_5, _rmod_6],
)
_fsp_6 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:1301",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1213300332",
    rus=[_rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403366",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1230408211",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=8652, global_bts_id=8652
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.130", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.131", username="ute"),  # sprawdzic czy ok adresy
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIM_1ABIO_1ABIP_1ABIA_1ASIB_1ABIA_1ABIO_1ABIL_1AVQC_1AHPMDA_2FRIJ_1AZQP_1AWHHJ_1AWHHF_1_UUFWRO",
)
__all__ = ["tl"]
