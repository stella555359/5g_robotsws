__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "kamil.nowacki@nokia.com"
__customer__ = "CB014309"
__bucket__ = "CB014309"
__rack__ = "GTA-822"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

########### PDUS ###########

# smod port 12
_pdu_1 = Gude(
    addr="10.42.80.142",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 6
_pdu_2 = Gude(
    addr="10.42.80.195",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

########### RMODS ###########

_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1250205215",
    pdu_port=_pdu_2.pdu_ports[6],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="", port=5001),
    #         Remote(addr="", port=5002),
    #     ]
    # ),
)

########### BBMODS ###########

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244806872",
    rus=[_rmod_1]
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309890",
    rus=[_rmod_1],
)

########### SMODS ###########

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403357",
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(system_module=_smod_1,
                      rms=[_rmod_1],
                      global_bts_id=55466, instance_id=55466)


_pdus = [_pdu_1, _pdu_2]

########### VMS ###########

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.26", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIM_1ABIP_1ABIO_1AVHA_UUFWRO",
)

__all__ = ["tl"]
