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


_pdu_1 = Gude(addr="10.44.200.147", port_numbers=[5], model="EPC", version="8220-1")
_pdu_2 = Gude(addr="10.44.200.146", port_numbers=[5], model="EPC", version="8220-1")
_pdu_3 = Gude(addr="10.44.200.227", port_numbers=[2,3], model="EPC", version="8220-1")
_pdus = [_pdu_1, _pdu_2, _pdu_3]

# ************************************************ RMs *************************************************
_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="K9154203626",
    pdu_port=_pdu_3.pdu_ports[2],
    default_telnet_connection_details=TelnetConnectionDetails(
    addr="172.16.10.128", port=2323
    )

)

_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="K9154203626",
    pdu_port=_pdu_3.pdu_ports[3],
    default_telnet_connection_details=TelnetConnectionDetails(
    addr="172.16.10.128", port=2323
    )

)

# ************************************************ UNITs ************************************************

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232102385",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234205702",
    rus=[_rmod_1, _rmod_2],
)


_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234205697",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1202800709",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1224704442",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.42.84.47"),
    instance_id=54013,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.84.48"),
    instance_id=8958,
)
# ************************************************ VMs ************************************************

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.124", username="ute"),
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
    SshServiceDetails(addr="10.44.156.45", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_2ASIL_ABIP_ABIQ_2AVQL",
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
)

__all__ = ["tl"]
