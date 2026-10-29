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
from taf.config.testline.fhs import FHS, FhsType

# _pdu = Gude(addr="10.106.245.81",port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],model="FACOM")

_pdu_1 = FACOM(addr="10.70.19.53", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu_2 = FACOM(addr="10.70.14.132", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7170242097",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHB.value,
    serial_number="K9214812550",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],  # not PB, need update， this RF maybe will be deleted
)

_rmod_3 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZHA.value,
    serial_number="6Q191407807",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS174711382",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type=RadioTypes.AHGB.value,
    serial_number="EB204260830",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9190930104",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_7 = RU(
    ru_hw_group="FRMr2.3_2T2R_Reno",
    radio_type=RadioTypes.FHDB.value,
    serial_number="1M173663254",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.125", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],  # not PB need update
)

_test_pc_fhs = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.253.64",
        username="ute",
        password="uteUTE!",  # need update to a correct pc
    ),
    connections=[NetworkAddress(v4="192.168.255.124")],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_2.pdu_ports[2],  # not PB need update
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    test_pc=_test_pc_fhs,
    optical_switch_channels=None,
    serial_number="6Q194602188",
    product_code="473922A.102",
    rus=[_rmod_7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907348",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204206380",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206663",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103999",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1182914415",
    fhs=[_fhs_1],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="	L1181410701",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="L1230610684",
    capacity_units=[_fsp_1, _fsp_3, _fsp_6],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH232141864",
    capacity_units=[_fsp_2, _fsp_4, _fsp_5],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_3],
    oam_ip=NetworkAddress("10.106.245.81"),
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1
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
        addr="10.106.245.44", username="ute"
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
        addr="10.106.245.45", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1917_2ASIM_1ABIO_1ABIA_2ABIP_4AHFII_2AHEGG_1FRGU_1AKNB_1FRGU",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
