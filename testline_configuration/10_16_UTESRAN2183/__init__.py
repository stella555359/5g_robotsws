__maintainer__ = "Szymon Romanowski"
__email__ = "szymon.romanowski@nokia.com"
# BTS ID: 100729
 
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
 
 
_pdu_1 = Gude("10.44.200.147", [2], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.146", [2], "EPC", "8220-1")
_pdu_3 = Gude("10.44.177.145", [3, 4], "EPC", "8041-1")
_pdus = [_pdu_1, _pdu_2, _pdu_3]


_rmod_1 = RU(
	radio_type="RadioTypes.AHFIB.value", 
	ru_hw_group="RF.FRM5.24T26R1.20251201.001", 
	product_code="474216A.101", 
	serial_number="BL2215V011G",
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),	
	pdu_port=_pdu_3.pdu_ports[4]
)

_rmod_2 = RU(
	radio_type="RadioTypes.AZQP.value", 
	ru_hw_group="RF.ERM6.26R1.20251202.002", 
	product_code="475198A.102", 
	serial_number="1M203440041",
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.26", port=2323
    ),	
	pdu_port=_pdu_3.pdu_ports[3]
)
 
_fsp_1 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602177",
	rus=[],
)
 
_fsp_2 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204206288",
	rus=[],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204214669",
	rus=[],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1250605472",
	rus=[_rmod_1, _rmod_2],
)
 
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
	capacity_units=[_fsp_1, _fsp_2, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1192405938",
)
 
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
	capacity_units=[_fsp_3],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH214044618",
)
 
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
 
_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2], oam_ip=NetworkAddress("10.42.87.24"), instance_id=100729,)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1,)
_enb_sbts_1.slave = _enb_sbts_2
 
_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.53.56", username="ute"),
    connections=[
		NetworkAddress(v4="192.168.255.126"),
		Connection(
  interface="eth1",
  device=_enb_sbts_1.system_module.common_units[0],
  interface_type="lmp",
  ),
	],
)
 
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.53.57", username="ute"),
    connections=[
		NetworkAddress(v4="192.168.255.126"),
		Connection(
  interface="eth1",
  device=_enb_sbts_2.system_module.common_units[0],
  interface_type="lmp",
  ),
	],
)
 
tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_WG_ASIB_ABIA_ABIO_ASIB_ABIN_AHFIB_LM",
)
 
__all__ = ["tl"]
