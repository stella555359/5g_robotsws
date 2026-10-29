__maintainer__ = "Alexandru Tancau"
__email__ = "alexandru.tancau@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

# BTS1 Primary Core
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.47.58", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
# BTS1 Secondary Core
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.47.59", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# BTS2
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.118", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(
    addr="10.255.3.115",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    protocol="http",
)

_pdu_2 = FPFH(
    addr="10.255.3.117",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    protocol="http",
)

_pdu_3 = FPFH(
    addr="10.255.3.118",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    protocol="http",
)

_pdu_4 = FPFH(
    addr="10.255.3.114",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    protocol="http",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_4.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRIG",
    serial_number="RY142524772",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRIG",
    serial_number="RY142524664",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRIG",
    serial_number="RY142524744",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="FHFB:CPRI_RRH_4T4R",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1151106116",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="FHFB:CPRI_RRH_4T4R",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1145010982",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="FHFB:CPRI_RRH_4T4R",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1145013411",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_7 = RU(
    ru_hw_group="RF.FRM5.trunk24.20241028.005",
    radio_type="AHLOA",
    serial_number="BL1919G10HQ",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_8 = RU(
    ru_hw_group="RF.FRM5.trunk24.20241028.005",
    radio_type="AHLOA",
    serial_number="BL1919G10HK",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="RF.FRM5.trunk24.20241028.005",
    radio_type="AHLOA",
    serial_number="BL1919G10HR",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_10 = RU(
    ru_hw_group="FRMr5.1a",
    radio_type="AHFIB",
    serial_number="BL2307V0GVM",
    pdu_port=_pdu_4.pdu_ports[5],
)

_rmod_11 = RU(
    ru_hw_group="FRMr5.1a",
    radio_type="AHFIB",
    serial_number="BL2040V0MVM",
    pdu_port=_pdu_4.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164119726",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162903374",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164112443",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164114902",
    rus=[_rmod_10],
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171213602",
    rus=[_rmod_11],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225206953",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162214156",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162214155",
    test_pc=_test_pc_3,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_6],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220747608",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1, _fct_2])
_smod_2 = Airscale([_fct_3])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11],
    instance_id=10644,
    oam_ip=NetworkAddress("10.15.236.44"),
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[1],
        interface_type="lmp",
    )
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    instance_id=10643,
    oam_ip=NetworkAddress("10.15.236.43"),
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_3, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_L_10644_2ASIA_4ABIA_3FRIG_3FHFB_3AHLOA_RFS_N_10643_1ASIL_1ABIO_3AHLOA",
)

__all__ = ["tl"]
