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
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = FACOM(
    addr="10.108.166.195",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='FACOM',
)
_pdu_2 = FACOM(
    addr="10.108.151.208",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='FACOM',
)
_pdu_3 = FPFH(
    addr="10.106.205.35",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model='FPFH',
)
_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS203806230",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZQI.value,
    serial_number="1M223213326",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508132",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9173315830",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9174042714",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233304608",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
    ],
    oam_ip=NetworkAddress("10.106.205.204"),
    instance_id=10875,
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.197", username="ute"
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
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIM_1ABIO_2ABIA_1AHCA_1AZQI",
)

__all__ = ["tl"]
