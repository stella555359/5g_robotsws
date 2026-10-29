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
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = HBTE(
    addr="10.106.243.45",
    port_numbers=[1, 2, 3, 4, 5, 6],
)
_pdu_2 = HBTE(
    addr="10.106.243.43",
    port_numbers=[1, 2, 3, 4, 5, 6],
)


_rmod_1 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1203007271",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASOE",
    hardware_version="475587A.103",
    serial_number="EA221952807",
)


_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.68.195.134"),
    instance_id=2519,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.152.45", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_N_1ASOE_1AEHC_HZ_OAM",
)

__all__ = ["tl"]
