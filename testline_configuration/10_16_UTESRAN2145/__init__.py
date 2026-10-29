__maintainer__ = "Szymon Romanowski"
__email__ = 'szymon.romanowski@nokia.com'

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.radio import RU
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_pdu1 = Gude(addr="10.44.200.226", port_numbers=[9], model="EPC", version="8220-1")
_pdu2 = Gude(addr="10.44.200.147", port_numbers=[9], model="EPC", version="8220-1")
_pdu3 = Gude(addr="10.44.200.228", port_numbers=[5], model="EPC", version="8220-1")

_rmod_1 = RU(
	radio_type="RadioTypes.AHFIB.value", 
	ru_hw_group="RF.FRM5.trunk24.20250912.027", 
	product_code="474216A.101", 
	serial_number="BL1911V00BK",
	pdu_port=_pdu1.pdu_ports[9],
)

_rmod_2 = RU(
	radio_type="RadioTypes.AHIB.value", 
	ru_hw_group="RF.FRM5.trunk24.20250912.027",
	product_code="474050A.102", 
	serial_number="EA174211166",
	pdu_port=_pdu3.pdu_ports[5],
)

_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu2.pdu_ports[9],
    hardware_type="ASOG",
    hardware_version="476254A.101",
    serial_number="L1240913067",
    rus=[_rmod_1, _rmod_2]
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.87.28"),
    instance_id=100722,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.132", username="ute"),
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
    pdus=[_pdu1,_pdu2,_pdu3],
    tl_cloud_topology="CLOUD_SRAN_NL_ASOG_AHFIB_LM",
)

__all__ = ["tl"]
