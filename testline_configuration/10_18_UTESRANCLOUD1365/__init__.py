__maintainer__ = "Corneliu Marcu"
__email__ = "corneliu.marcu@nokia.com"
__owner_email__ = "corneliu.marcu@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc, Connection


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.31", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = APC("10.255.1.45", [1, 2, 3, 4, 5, 6, 7, 8])
_pdu_2 = Gude("10.255.1.112", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = FPFH(addr="10.255.1.44", port_numbers=[1, 2, 3, 4, 5, 6])

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233704771",
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1241104186",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233304591",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9234908771",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9234908767",
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9234908772",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPB.value,
    serial_number="K9224630360",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232931983",
    pdu_port=_pdu_2.pdu_ports[7],
)
_fsp_1.rus = ([_rmod_1, _rmod_2])
_fsp_2.rus = ([_rmod_3, _rmod_4, _rmod_5])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.247.65"),
    instance_id=10365,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
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
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_N_1365_ASIM_2ABIP_3AQQJ_AHPJ_AHPB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
