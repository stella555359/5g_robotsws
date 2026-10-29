__maintainer__ = "LM"
__team__ = "I_MN_RAN_RD_VRF_WRO3_5"
__email__ = "I_MN_RAN_RD_VRF_WRO3_5@internal.nsn.com"


from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU, DU
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
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude("10.44.200.147", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.146", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.228", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")



# smod port 3
_pdu_1 = Gude(
    addr="10.44.200.147",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# smod port 3
_pdu_2 = Gude(
    addr="10.44.200.146",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 1
_pdu_3 = Gude(
    addr="10.44.200.228",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

# ************************************************ RMs *************************************************
_rmod_1 = RU(
    ru_hw_group="FRM33.32.R67D",
    radio_type="FRAA",
    serial_number="K9154203626",
    pdu_port=_pdu_3.pdu_ports[1],
    default_telnet_connection_details=TelnetConnectionDetails(
    addr="172.16.10.128", port=2323
    )
)
# ************************************************ UNITs ************************************************

_fsp_1 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602134",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173643738",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1202606207",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1213502822",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.87.21"),
    instance_id=100702,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.87.22"),
    instance_id=100790,
)
# ************************************************ VMs ************************************************

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.40", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.156.41", username="ute"),
    connections=[
		NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

# ************************************************ SUM ************************************************

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    tl_cloud_topology="CLOUD_SRAN_2ASIL_2ABIA_1FRAA",
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
)

__all__ = ["tl"]
