__maintainer__ = "Oana Badea"
__email__ = "oana.badea@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.167", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.168", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.3.30",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.3.28",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.255.3.29",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_pdu_4 = Gude(
    addr="10.255.3.27",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

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
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010422",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010406",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204604566",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101549",
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224207710",
)

_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104696",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2,_fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH214240064",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4,_fsp_5,_fsp_6],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH214240517",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M222033043",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS193810090",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1181700178",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M222033047",
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS195003412",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1181700163",
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1919V00LC",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2012V090X",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1920V006P",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_16 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2014V001V",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_17 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2013V003P",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_18 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2014V000K",
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_19 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS195003420",
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_20 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1181711692",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_21 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS193810089",
    pdu_port=_pdu_3.pdu_ports[11],
)

_rmod_25 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M192428615",
    pdu_port=_pdu_3.pdu_ports[12],
)

_rmod_26 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2012V08ZY",
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_27 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2014V001W",
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_28 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA213152307",
    pdu_port=_pdu_1.pdu_ports[11],
)

_rmod_29 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA213152433",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_30 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752544",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_34 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201650196",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_35 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752559",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_36 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA213152427",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_37 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA213152196",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_38 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA213657475",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_39 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752565",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_43 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752573",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_44 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752569",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_45 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752577",
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_46 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752575",
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_47 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA225054755",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_48 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752574",
    pdu_port=_pdu_3.pdu_ports[10],
)

_rmod_52 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474347",
    pdu_port=_pdu_4.pdu_ports[8],
)

_rmod_53 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474336",
    pdu_port=_pdu_4.pdu_ports[9],
)

_rmod_54 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474348",
    pdu_port=_pdu_4.pdu_ports[10],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
		_rmod_7,
		_rmod_8,
		_rmod_9,
		_rmod_10,
		_rmod_11,
		_rmod_12,
		_rmod_16,
		_rmod_17,
		_rmod_18,
		_rmod_19,
		_rmod_20,
		_rmod_21,
		_rmod_25,
		_rmod_26,
		_rmod_27,
    ],
    oam_ip=NetworkAddress("10.15.236.178"),
    instance_id=10778,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_28,
        _rmod_29,
        _rmod_30,
		_rmod_34,
		_rmod_35,
		_rmod_36,
		_rmod_37,
		_rmod_38,
		_rmod_39,
		_rmod_43,
		_rmod_44,
		_rmod_45,
		_rmod_46,
		_rmod_47,
		_rmod_48,
		_rmod_52,
		_rmod_53,
		_rmod_54,
    ],
    master=_enb_sbts_1
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1,_test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_N_1778_2ASIB_6ABIO_18AHEH_10AHCA_8AHFIB",
)

__all__ = ["tl"]
