# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "xiaochen"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "xiaofei.chen@nokia-sbell.com"
__owner_email__ = "xiaofei.chen@nokia-sbell.com"

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
    addr="10.106.243.44",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_2 = FACOM(
    addr="10.106.243.49",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_3 = FACOM(
    addr="10.106.243.47",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)


_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type=RadioTypes.AEQE,
    serial_number="1M211902616",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type=RadioTypes.AHEGA,
    serial_number="K9182036668",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1243303670",
    capacity_units=[],
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.106.243.15"),
    instance_id=5522,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.151.249", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_N_ASOG_AHEGA_AEQE_5522",
)

__all__ = ["tl"]
