__maintainer__ = "zhlu"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "zhonggenn.lu@nokia-sbell.com"
__owner_email__ = "zhonggenn.lu@nokia-sbell.com"


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

_pdu_1 = TopYoung(
    addr="10.108.161.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_2 = FPFH(
    addr="10.106.205.35",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)
_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXDD,
    serial_number="F7175003717",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA222651576",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,        
    ],
    oam_ip=NetworkAddress("10.106.245.139"),
    instance_id=1415,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.152.148", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_ASOE_2FXDD_HZ_OAM",
)

__all__ = ["tl"]
