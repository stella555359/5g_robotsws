# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Simona Marcu"
__email__ = "simona.marcu@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc, Connection

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.41", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.42", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.1.63", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.1.102", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.255.1.146", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"

_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173715477",
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW191000278",
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213014346",
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010380",
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225206951",
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241408109",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    serial_number="L1220208170",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    serial_number="DH202963436",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240512087",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240512312",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240614449",
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXEB.value,
    serial_number="1M164901028",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXEB.value,
    serial_number="NK164203533",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M204626554",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M211100003",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M211100004",
    pdu_port=_pdu_3.pdu_ports[12],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M214106788",
    pdu_port=_pdu_2.pdu_ports[9],
)

_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_2.rus = [_rmod_4, _rmod_5]
_fsp_3.rus = [_rmod_9]
_fsp_4.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_5.rus = [_rmod_6, _rmod_7, _rmod_8]
_fsp_6.rus = [_rmod_9]


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.15.247.189"),
    instance_id=10489,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_9],
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
        addr="10.91.190.121", username="Nemuadmin", password="Nokia@123"
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1489_2ASIB_2ABIA_2ABIO_1ABIN_1ABIQ_3AHPMDD_2FXEB_3AEQE_1AENB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
