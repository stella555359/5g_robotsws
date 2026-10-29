__maintainer__ = "haifhuan"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "haifeng.huang@nokia-sbell.com"
__owner_email__ = "haifeng.huang@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc


_pdu_1 = FPFH(
    addr="10.56.206.162",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_2 = FPFH(
    addr="10.56.206.163",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_3 = FPFH(
    addr="10.56.206.164",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2027G1AU1",
    radio_type=RadioTypes.AHLOA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL1933G10OQ",
    radio_type=RadioTypes.AHLOA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2145G1Q9Q",
    radio_type=RadioTypes.AHLOA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2112W240E",
    radio_type=RadioTypes.AHFIG,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2112W24AW",
    radio_type=RadioTypes.AHFIG,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9200425205",
    radio_type=RadioTypes.AHFIG,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    serial_number="AH211900895",
    radio_type=RadioTypes.AZHL,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_8 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    serial_number="AH213190183",
    radio_type=RadioTypes.AZHL,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220807262",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608250",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q181636092",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="473096A.103",
    serial_number="L1204706781",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1204601125",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIN",
    hardware_version="475266A.104",
    serial_number="L1204212519",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH233641163",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_3.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224815355",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    oam_ip=NetworkAddress("10.97.125.67"),
    instance_id=2572,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_7,
        _rmod_8,
    ], 
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.229.10", username="ute"),
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
    SshServiceDetails(addr="10.108.229.11", username="ute"),
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
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLW_1ASIM_1ASIL_1ABIO_1ABIP_2ABIN_2ABIA_1AHCA_1AZNB_1AHFIB_1AKNB",
)

__all__ = ["tl"]
