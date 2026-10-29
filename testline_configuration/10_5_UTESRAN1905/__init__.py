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


_pdu_1 = FACOM(addr="10.106.253.4", port_numbers=[2, 5, 6, 7])
_pdu_2 = FACOM(addr="10.106.253.6", port_numbers=[1, 4])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHED.value,
    serial_number="6Q191512810",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M211008288",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.17.0.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1210701397",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.17.0.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M172571130",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS210101325",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="A.Y16",
    serial_number="L1224707923",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="B.101",
    serial_number="L1224112811",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA183241562",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202800728",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod_1 = Flexi([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.106.253.8"),
)

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
        addr="10.106.253.60", username="ute"
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

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1905_1ASIL_1ABIP_1ABIO_1ABIA_1AHED_1AEQP_1AEHB_1FXDB_1AHCA",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
