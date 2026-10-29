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


# _pdu_1 = Gude(addr="10.69.14.82", port_numbers=[4, 5, 6, 7, 8], model="FACOM")
# _pdu_2 = Gude(addr="10.69.14.2", port_numbers=[4], model="FACOM")

_pdu_1 = FACOM(addr="10.56.201.147", port_numbers=[1, 2, 3, 4, 5, 6])
_pdu_2 = FACOM(addr="10.56.201.148", port_numbers=[1, 2, 3, 4, 5, 6])

_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZHM.value,
    serial_number="1M222529161",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.58.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCF.value,
    serial_number="RW223200423",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907334",
    rus=[_rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309966",
    rus=[_rmod_3],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233304525",
    capacity_units=[_fsp_1, _fsp_2],
)


_smod_1 = Flexi([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.56.201.203"),
    instance_id=37376,
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
        addr="10.68.161.95", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
