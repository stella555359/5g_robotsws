__maintainer__ = "Alicja Tomczak"
__email__ = "alicja.tomczak@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdu import Gude

_pdu_1 = Gude("10.44.200.146", [4], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.229", [10], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.226", [1,3], "EPC", "8220-1")
_pdu_4 = Gude("10.44.200.228", [3], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="RF.FRM5.25R300PD.20250903.002",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AS7",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),

    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_2 = RU(
    ru_hw_group="RF.FRM5.25R300PD.20250903.002",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA174110415",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),    
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="RF.FRM5.25R300PD.20250903.002",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA174510939",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),    
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="RF.ERM6.25R3.20250809.001",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH223139071",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.2", port=2323
    ),    
    pdu_port=_pdu_4.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204008342",
    rus=[_rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204101488",
    rus=[_rmod_1],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204101570",
    rus=[_rmod_4],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
	capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1240404815",
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4], oam_ip=NetworkAddress("10.42.87.26") , instance_id=100855)

_test_pc = TestPc(
    SshServiceDetails(addr="10.44.156.125", username="ute"),
    connections=[
		NetworkAddress(v4="192.168.255.126"),
		Connection(
  interface="eth1",
  device=_enb_sbts.system_module.common_units[0],
  interface_type="lmp",
  ),
	],
)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_NL_ASIL_3ABIO_AHIB_AHFB_AHLOA_AZHL",
)

__all__ = ["tl"]
