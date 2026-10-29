# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Corneliu Marcu"
__email__ = "corneliu.marcu@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.121", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.122", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# SMODS ASIA ASIB
_pdu_1 = Gude(    
addr="10.255.1.48",    
port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],    
model="EPC",    
version="8221-1",)
 
 # RMODS AHPMDD ANEGA FRGY
_pdu_2 = Gude(    
addr="10.255.1.49",    
port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],    
model="EPC",    
version="8220-1",)

_pdu_4 = FPFH(addr="10.255.1.129", port_numbers=[1, 2, 3, 4, 5, 6])   # RMODS AHEGHA AVQL

_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"  # SMOD ASIB
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"  # SMOD
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"  # RMODS AHPMDD 50
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"  # RMODS AHPMDD 07
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"  # RMODS AHPMDD 70
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"  # RMOD ANEGA
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"  # RMOD FRGY
_pdu_4.pdu_ports[1].contactor = "NORMALLY_OPENED"  # RMODS AHEGHA
_pdu_4.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"  # RMODS AVQL
_pdu_4.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225206923",
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706785",
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101519",
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1191402719",
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824659",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIB",
    serial_number="DH220446043",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    serial_number="L1162615260",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="6Q204403807",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240613270",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240614450",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9252531884",
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9252531818",
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9252531940",
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1242504688",
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1242504691",
    pdu_port=_pdu_4.pdu_ports[5],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1242504689",
    pdu_port=_pdu_4.pdu_ports[6],
)
_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ANEGA.value,
    serial_number="L1190105466",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9165119522",
    pdu_port=_pdu_2.pdu_ports[10],
)

_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_2.rus = [_rmod_4, _rmod_5, _rmod_6]
_fsp_3.rus = [_rmod_7, _rmod_8, _rmod_9]
_fsp_4.rus = [_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6]
_fsp_6.rus = [_rmod_10, _rmod_11]

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.15.247.48"),
    instance_id=10348,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_10, _rmod_11, _rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
    ),
)

_bsc = BSC(
    name="BSC_DHARANI",
    logging_telnet_connection_details=SshServiceDetails(addr="10.27.126.20", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_10348_ASIB_3ABIO_ASIA_2ABIA_3AHPMDD_3AHEGHA_3AVQL_ANEGA_FRGY",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
