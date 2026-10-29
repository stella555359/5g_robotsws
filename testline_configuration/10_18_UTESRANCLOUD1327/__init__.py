# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Simona Marcu"
__email__ = "simona.marcu@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc, Connection


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.96", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.145", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = APC("10.255.1.42", [1, 2, 3, 4, 5, 6, 7, 8])
_pdu_2 = Gude("10.255.1.41", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.255.1.112", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101514",
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221109",
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234800799",
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608262",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    serial_number="L1234204946",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    serial_number="L1211012391",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQU.value,
    serial_number="1M222314684",
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7170322710",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1211409570",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2307V0GY6",
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9192320959",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ232692517",
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQE.value,
    serial_number="L1242504668",
    pdu_port=_pdu_3.pdu_ports[9],
)

_fsp_1.rus = [_rmod_1,_rmod_4,_rmod_5]
_fsp_2.rus = [_rmod_2,_rmod_4,_rmod_5]
_fsp_3.rus = [_rmod_7,_rmod_6]
_fsp_4.rus = [_rmod_3]

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_3, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.15.247.27"),
    instance_id=10327,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_4, _rmod_5],
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
    name="BSC_KAISA_SBTS",
    logging_telnet_connection_details=SshServiceDetails(
        addr="10.92.249.108", username="TIMISO", password="TI2019"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1327_1ASIL_1ABIO_1ABIA_1ASIM_1ABIP_1ABIO_1AZQU_1FXDB_1AEHC_1AHFIB_1AHEGA_1AQQJ_1AVQE",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
