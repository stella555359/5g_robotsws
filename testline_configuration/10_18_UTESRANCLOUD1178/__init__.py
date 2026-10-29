__maintainer__ = "Oana Badea"
__email__ = "oana.badea@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.95", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.1.67",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.68",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.255.1.66",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"



_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221151",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA192071874",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171213611",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1181305751",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXCA.value,
    serial_number="K9170506883",
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRHG.value,
    serial_number="K9181532786",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXEB.value,
    serial_number="1M183123270",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRGT.value,
    serial_number="	F7170740007",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_7 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXCA.value,
    serial_number="	K9171502935",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXEB.value,
    serial_number="	1M164841335",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRHG.value,
    serial_number="	K9162158636",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_10 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRHG.value,
    serial_number="K9170333547",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_11 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXCA.value,
    serial_number="K9170640127",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_12 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXCA.value,
    serial_number="K9170640129",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_13 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7170739995",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_14 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRHG.value,
    serial_number="	K9173352489",
    pdu_port=_pdu_2.pdu_ports[10],
)


_rmod_15 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7164756676",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_16 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FRGT.value,
    serial_number="	F7164756678",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_17 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXEB.value,
    serial_number="NK163703309",
    pdu_port=_pdu_3.pdu_ports[10],
)

_rmod_18 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXEB.value,
    serial_number="	NK163703313",
    pdu_port=_pdu_2.pdu_ports[6],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
        _rmod_13,
        _rmod_14,
        _rmod_15,
        _rmod_16,
		_rmod_17,
		_rmod_18,
    ],
    oam_ip=NetworkAddress("10.5.38.178"),
    instance_id=10178,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_LW_1ASIA_3ABIA_7FRGH_7FXCA",
    rncs=[_rnc],
)
__all__ = ["tl"]
