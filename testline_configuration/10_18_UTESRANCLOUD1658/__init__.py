__maintainer__ = "Antoci Cristina"
__email__ = "cristina.antoci@nokia.com"

from taf.config.testline.airscale import Airscale
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.lmi import SerialOverTcp, Remote

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.12", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.13", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = FPFH(
    addr="10.255.3.123",
    port_numbers=[1, 2, 3, 4, 5, 6],
)

_pdu_2 = FPFH(
    addr="10.255.3.124",
    port_numbers=[1, 2, 3, 4, 5, 6],
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




_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183408244"
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184609662"
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1194010575"
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225207068"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,  _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224815320",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
	pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224815459",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

MUMIN_AHLOA_BL1934G10V0 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5001)])
MUMIN_AHLOA_BL1934G10TU = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5002)])
MUMIN_AHLOA_BL1934G10VG = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5003)])
MUMIN_AHFIG_K9192808687 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5004)])
MUMIN_AHFIG_K9192713050 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5005)])
MUMIN_AHFIG_K9192808686 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5006)])
MUMIN_AEHC_L1204110703 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5007)])
MUMIN_AEHC_L1204708731 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5008)])
MUMIN_AEHC_L1204708730 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.4"), port=5009)])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1934G10V0",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
    lmi=MUMIN_AHLOA_BL1934G10V0,
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1934G10TU",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    lmi=MUMIN_AHLOA_BL1934G10TU,
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1934G10VG",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=MUMIN_AHLOA_BL1934G10VG,
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9192808686",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    lmi=MUMIN_AHFIG_K9192808686,
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9192808687",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    lmi=MUMIN_AHFIG_K9192808687,
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9192713050",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    lmi=MUMIN_AHFIG_K9192713050,
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204110703",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    #lmi=MUMIN_AEHC_L1204110703,
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204708730",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    #lmi=MUMIN_AEHC_L1204708730,
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204708731",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.158", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    #lmi=MUMIN_AEHC_L1204708731,
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.58"),
    instance_id=10615,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1,_test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_N_10658_1ASIL_3ABIL_1ASIL_1ABIO_3AEHC_3AHFIG_3AHLOA",

)


__all__ = ["tl"]
