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


# _pdu = Gude(addr="10.106.253.39", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="FACOM")

_pdu_1 = FACOM(addr="10.106.253.39", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu_2 = FACOM(addr="10.106.253.41", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu_3 = FPFH(
    addr="10.106.253.28",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2050W2LGF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="EA191772879",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH211900888",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZHM.value,
    serial_number="1M222529160",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_6 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type=RadioTypes.FRHG.value,
    serial_number="K9171805280",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213706168",
    rus=[_rmod_5],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204707994",
    rus=[_rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162908762",
    rus=[_rmod_2],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172315590",
    rus=[_rmod_1],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213615815",
    rus=[_rmod_1],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206729",
    rus=[_rmod_3],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1210706904",
    capacity_units=[_fsp_1, _fsp_3, _fsp_6],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1210706903",
    capacity_units=[_fsp_2, _fsp_4, _fsp_5],
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_3, _rmod_5],
    oam_ip=NetworkAddress("10.106.253.10"),
    instance_id=1910,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_6], master=_enb_sbts_1)
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
        addr="10.107.151.140", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.253.61", username="ute"
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
        addr="10.106.253.62", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1910_2ASIL_3ABIN_2ABIA_1ABIO_1AHFIG_1AHDB_1AZHL_1AZHM_1FRHG",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
