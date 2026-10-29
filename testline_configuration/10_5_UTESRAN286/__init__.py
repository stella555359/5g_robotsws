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
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = FACOM(
    addr="10.108.153.122",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_2 = APC(
   addr="10.68.93.69",
   port_numbers=[8],
)


_rmod_1 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    radio_type=RadioTypes.AWHHH.value,
    serial_number="EB2213R0649",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASOF",
    hardware_version="476147A.101",
    serial_number="EA232850569",
)


_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.106.245.144"),
    instance_id=2516,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.152.167", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_N_1ASOF_3AWHHH_HZ_OAM",
)

__all__ = ["tl"]
