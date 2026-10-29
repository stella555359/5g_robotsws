__maintainer__ = "Boguslaw Trojnar"
__team__ = "VRF_WRO3_T07"
__email__ = "boguslaw.trojnar@nokia.com"
__owner_email__ = "boguslaw.trojnar@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import OpticalSwitch, Leoni
from taf.config.testline.testpc import TestPc, Connection


_pdu_1 = Gude("10.44.167.19", [10], "EPC", "8220-1") #SMOD ASIM
_pdu_2 = Gude("10.44.167.3", [8], "EPC", "8221-1") #AHPB_931
_pdu_3 = Gude("10.44.167.5", [9], "EPC", "8221-1") #AHPB_684
_pdu_4 = Gude("10.44.167.4", [11, 12], "EPC", "8221-1") #AVQA_406, AVQA_407

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="K9190237931",
    pdu_port=_pdu_2.pdu_ports[8],
    product_code="474119A.101",
    radio_type="AHPB",
) #AHPB_931

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="K9200708684",
    pdu_port=_pdu_3.pdu_ports[9],
    product_code="474119A.101",
    radio_type="AHPB",
) #AHPB_684


_rmod_3 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    serial_number="L1251403406",
    pdu_port=_pdu_4.pdu_ports[11],
    product_code="476457A.101",
    radio_type="AVQA",
) #AVQA_406

_rmod_4 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    serial_number="L1251403407",
    pdu_port=_pdu_4.pdu_ports[12],
    product_code="476457A.101",
    radio_type="AVQA",
) #AVQA_407



_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231800028",
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_3, _rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232807067",
    pdu_port=_pdu_1.pdu_ports[10],
    rus=[_rmod_1, _rmod_2],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230613870",
)


_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.42.24.180"),
    instance_id=1017,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.137", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    #    optical_switches=[_opt_sw_1],
)

__all__ = ["tl"]
