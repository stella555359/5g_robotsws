__maintainer__ = "Nicolae Marcel Caragel"
__email__ = "nicolae-marcel.caragel@nokia.com"
			  
				

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress

from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

#_pdu_1 = Gude(addr="10.255.3.19", port_numbers=[10], model="EPC", version="8220-1")

#_pdu_2 = Gude(addr="10.255.3.20", port_numbers=[8, 10, 12], model="EPC", version="8220-1")

_pdu_1 = APC(
    addr="10.255.1.37",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_pdu_2 = Gude(
    addr="10.255.1.36",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
																				 

_rmod_1 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk24.20250826.030",
    serial_number="EA224752558",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk24.20250826.030",
    serial_number="EA221150677",
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_3 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk24.20250826.030",
    serial_number="DH213843615",			  
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    radio_type="AHPE",
    ru_hw_group="RF.FRM5.trunk24.20250826.030",
    serial_number="1M222040019",			  
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_5 = RU(
    radio_type="AHPE",
    ru_hw_group="RF.FRM5.trunk24.20250826.030",
    serial_number="1M212503002",			  
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_6 = RU(
    radio_type="AHPE",
    ru_hw_group="RF.FRM5.trunk24.20250826.030",
    serial_number="1M201816786",			  
    pdu_port=_pdu_2.pdu_ports[2],
)



_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASOE",
    hardware_version="475587A.101",
    serial_number="EA212356635",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.247.2"),
    instance_id=10302,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.170", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
			   
    tl_cloud_topology="CLOUD_SRAN_NL_10302_1ASOE_3AHEH_3AHPE",
)

__all__ = ["tl"]

