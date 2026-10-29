__maintainer__ = "Yuyan Xu"
__email__ = "yuyan.xu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, RRB, APC, Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress

# 2024-2-7:PDU info is incorrect.
_pdu_1 = FACOM(addr="10.69.14.82", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_rmod_1 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="L6144129250",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHDA.value,
    serial_number="F7185106503",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AS0",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZHA.value,
    serial_number="6Q191407812",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type=RadioTypes.AKNB.value,
    serial_number="1M223512389",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9171627332",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="L1182715982",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204707995",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172423701",
    rus=[_rmod_2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233104001",
    rus=[_rmod_3],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650606",
    rus=[_rmod_4],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH220845349",
    rus=[_rmod_6],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIP",
    hardware_version="475792A.Y16",
    serial_number="L1230208381",
    rus=[_rmod_5, _rmod_7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH232142093",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH232141655",
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.68.159.207"),
    instance_id=1811,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_rnc = RNC(
    rnc_id=511,
    oms_ip=NetworkAddress("10.68.171.228"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.69.28.173", username="root", password="root"
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.107.151.137", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.161.93", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.161.94", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
