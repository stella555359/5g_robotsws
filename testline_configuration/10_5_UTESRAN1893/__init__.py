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

# SBTS1893 do not have PB
_pdu_1 = FACOM(addr="10.69.14.22", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu_2 = FACOM(addr="10.69.14.23", port_numbers=[1, 2, 3, 4])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2050W2LGM",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2208W2HCL",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2050W2LGK",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G1040",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AR8",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AS0",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_13 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9204004449",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.154", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_14 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1210701397",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_15 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1202604238",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214610621",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206671",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171909236",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220402331",
    rus=[_rmod_13, _rmod_14, _rmod_15],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223901138",
    rus=[_rmod_13, _rmod_14, _rmod_15],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH232141856",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.103",
    serial_number="DH232141658",
    capacity_units=[_fsp_4, _fsp_5],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.106.254.222"),
    instance_id=1893,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_13, _rmod_14, _rmod_15], master=_enb_sbts_1
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
        addr="10.106.245.42", username="ute"
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
        addr="10.106.245.43", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
