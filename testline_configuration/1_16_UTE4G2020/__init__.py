__maintainer__ = "Szymon Romanowski"
__email__ = "szymon.romanowski.com"
 
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
 
 
_pdu_1 = Gude("10.44.200.146", [7], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.147", [7], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.226", [2, 4, 10, 11], "EPC", "8220-1")
_pdu_4 = Gude("10.44.200.228", [4], "EPC", "8220-1")
_pdu_5 = Gude("10.44.200.229", [2,11], "EPC", "8220-1")
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]
 
_rmod_1 = RU(
	radio_type="RadioTypes.AHFIB.value", 
	ru_hw_group="RF.FRM5.trunk.20240219.004", 
	product_code="474216A.101", 
	serial_number="BL1946V00PW",
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),	
	#pdu_port=_pdu_3.pdu_ports[10]
	#PR868129 IR-4
	pdu_port=_pdu_5.pdu_ports[2]
)
 
_rmod_2 = RU(
	radio_type="RadioTypes.AHFIB.value", 
	ru_hw_group="RF.FRM5.trunk.20240219.004", 
	product_code="474216A.101", 
	serial_number="K9181806844", 
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),		
	pdu_port=_pdu_3.pdu_ports[4]
)
 
_rmod_3 = RU(
	radio_type="RadioTypes.AHLOA.value", 
	ru_hw_group="RF.FRM5.trunk.20240219.004", 
	product_code="474331A.101", 
	serial_number="BL2027G1AVK",
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),	
	pdu_port=_pdu_5.pdu_ports[11]
)
 
_rmod_4 = RU(
	radio_type="RadioTypes.AHIB.value", 
	ru_hw_group="RF.FRM5.trunk.20240219.004", 
	product_code="474050A.102", 
	serial_number="EA174211120", 
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),	
	pdu_port=_pdu_3.pdu_ports[2]
)
 
_rmod_5 = RU(
	radio_type="RadioTypes.AEHC.value", 
	ru_hw_group="RF.CHB0.24R1.20240301.004", 
	product_code="475124B.102", 
	serial_number="AH234900454", 
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.10", port=2323
    ),	
	pdu_port=_pdu_3.pdu_ports[11]
)

_rmod_6 = RU(
	radio_type="RadioTypes.AZQP.value", 
	ru_hw_group="RF.ERM6.trunk.20240801.001", 
	product_code="475198A.102", 
	serial_number="1M203844898",
	default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),	
	pdu_port=_pdu_4.pdu_ports[4]
)

 
_fsp_1 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1173514755",
	rus=[_rmod_1, _rmod_2],
)
 
_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204214690",
	rus=[_rmod_3],
)
 
_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1223009503",
	rus=[_rmod_5],
)
 
_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="A.101",
    serial_number="L1231807397",
	rus=[_rmod_6],
)
 
_fsp_5 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233105845",
	rus=[_rmod_4],
)
 
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
	capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1215010380",
)
 
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
	capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1220403357",
)
 
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
 
_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_5], oam_ip=NetworkAddress("10.42.87.25"), instance_id=100755,)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_4, _rmod_6])
_enb_sbts_2.slave = _enb_sbts_1
 
_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.53.78", username="ute"),
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
    SshServiceDetails(addr="10.42.53.79", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_ASIL_ABIA_ABIN_ABIO_ASIL_ABIP_ABIQ_2AHFIB_AHLOA_AHIB_AEHC_AZQP",
)
 
__all__ = ["tl"]
