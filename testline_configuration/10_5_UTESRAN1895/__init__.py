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

# _pdu = Gude(addr="10.97.78.71", port_numbers=[1, 2, 3, 4, 5, 6], model="FACOM")

_pdu = FPFH(
    addr="10.68.93.7",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS174711935",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.224", port=2323
    ),
    pdu_port=_pdu.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED.value,
    serial_number="1M180417812",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.226", port=2323
    ),
    pdu_port=_pdu.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXJB.value,
    serial_number="1M174803411",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.230", port=2323
    ),
    pdu_port=_pdu.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXJB.value,
    serial_number="1M174803370",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.228", port=2323
    ),
    pdu_port=_pdu.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA180324416",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.35",
    hardware_type="FBBA",
    hardware_version="472182A.103",
    serial_number="F7140701888",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="FBBA",
    hardware_version="472182A.102",
    serial_number="L6132239931",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA142866808",
    capacity_units=[_fsp_1],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="L6143331534",
    capacity_units=[_fsp_2, _fsp_3],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[],
    oam_ip=NetworkAddress("10.68.159.208"),
    instance_id=1895,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4], master=_enb_sbts_1
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
        addr="10.68.93.53", username="ute"
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
        addr="10.68.93.54", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1895_2FSMF_1FBBC_2FBBA_1FRGU_1FXED_2FXJB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
