__maintainer__ = "Magdalena Bielska"
__team__ = "siso_T07"
__email__ = "magdalena.bielska@nokia.com"
__owner_email__ = "magdalena.bielska@nokia.com"

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


_pdu_1 = Gude("10.44.167.90", [12], "EPC", "8220-1") #SMOD ASOH
_pdu_2 = Gude("10.44.167.59", [10], "EPC", "8220-1") #AXEGHA_180


_rmod_1 = RU(
    ru_hw_group="RU_FDr8_4T4R",
    serial_number="L1254600180",
    pdu_port=_pdu_2.pdu_ports[10],
    product_code="476626A.X23",
    radio_type="AXEGHA",
) #AXEGHA_180

# Fake BBMOD
_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ASOH",
    hardware_version="476255A.101",
    serial_number="EA240250051",
    pdu_port=_pdu_1.pdu_ports[12],
    rus=[_rmod_1]
)



_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASOH",
    hardware_version="A.101",
    serial_number="EA240250051",
)


_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.24.201"),
    instance_id=1039,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.136", username="ute"),
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
