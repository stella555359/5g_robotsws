# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Simona Marcu"
__email__ = "simona.marcu@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.lmi import SerialOverTcp, Remote


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.141", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.142", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = APC("10.255.1.120", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
_pdu_2 = Gude("10.255.1.121", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
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
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA192071678",
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304440",
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233005556",
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304436",
)

_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304422",
)

_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233203414",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIM",
    serial_number="L1240701355",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    serial_number="L1224503552",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

MUMIN_AVHA_L1252001882 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5001)])
MUMIN_AHLOB_AH243522004 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5002)])
MUMIN_AVHA_L1251805075 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5003)])
MUMIN_AHLOB_AH243706173 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5004)])
MUMIN_AVHA_L1252001886 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5005)])
MUMIN_AHLOB_AH243521961 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5006)])
MUMIN_AEQQ_1M222414832 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5007)])
MUMIN_AHFII_BL2332N47A9 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5008)])
MUMIN_AZNA_6Q190823908 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5009)])
MUMIN_AZQS_1M223421644 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5010)])
MUMIN_AENB_1M222721530 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5011)])
MUMIN_AHFII_K9244701949 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5012)])
MUMIN_AHFII_BL2331N4770 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.5"), port=5013)])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M223421644",
    pdu_port=_pdu_2.pdu_ports[4],
    #lmi=MUMIN_AZQS_1M223421644,
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2332N47A9",
    pdu_port=_pdu_2.pdu_ports[3],
    #lmi=MUMIN_AHFII_BL2332N47A9,
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2331N4770",
    pdu_port=_pdu_2.pdu_ports[2],
    #lmi=MUMIN_AHFII_BL2331N4770,
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701949",
    pdu_port=_pdu_2.pdu_ports[1],
    #lmi=MUMIN_AHFII_K9244701949,
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1251805075",
    pdu_port=_pdu_2.pdu_ports[6],
    #lmi=MUMIN_AVHA_L1251805075,
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1252001886",
    pdu_port=_pdu_2.pdu_ports[5],
    #lmi=MUMIN_AVHA_L1252001886,
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1252001882",
    pdu_port=_pdu_2.pdu_ports[10],
    #lmi=MUMIN_AVHA_L1252001882,
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243521961",
    pdu_port=_pdu_2.pdu_ports[7],
    #lmi=MUMIN_AHLOB_AH243521961,
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243522004",
    pdu_port=_pdu_2.pdu_ports[8],
    #lmi=MUMIN_AHLOB_AH243522004,
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243706173",
    pdu_port=_pdu_2.pdu_ports[9],
    #lmi=MUMIN_AHLOB_AH243706173,
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQQ.value,
    serial_number="1M222414832",
    pdu_port=_pdu_2.pdu_ports[11],
    #lmi=MUMIN_AEQQ_1M222414832,
)

_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M222721530",
    pdu_port=_pdu_2.pdu_ports[12],
    #lmi=MUMIN_AENB_1M222721530,
)

_rmod_13 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M161932284",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_14 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M161933127",
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_15 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190823908",
    pdu_port=_pdu_1.pdu_ports[3],
    #lmi=MUMIN_AZNA_6Q190823908,
)

_fsp_1.rus = [_rmod_2, _rmod_3, _rmod_4]
_fsp_2.rus = [_rmod_8, _rmod_9, _rmod_10]
_fsp_3.rus = [_rmod_1, _rmod_15]
_fsp_4.rus = [_rmod_12, _rmod_11, _rmod_13, _rmod_14]
_fsp_5.rus = [_rmod_2, _rmod_3, _rmod_4]
_fsp_6.rus = [_rmod_5, _rmod_6, _rmod_7]

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2,_rmod_3,_rmod_4,_rmod_8,_rmod_9,_rmod_10,_rmod_11,_rmod_12,_rmod_13,_rmod_14],
    oam_ip=NetworkAddress("10.15.236.108"),
    instance_id=10708,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6,_rmod_7,_rmod_15],
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
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=SshServiceDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1708_2ASIM_1ABIA_2ABIO_2ABIP_1ABIN_2AHCA_2AHMPDA_2FXDB_1AZNA_1AENB_1AZQS",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]