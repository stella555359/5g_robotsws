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


_pdu_1 = FACOM(
    addr="10.68.170.187",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_2 = FACOM(
    addr="10.68.170.190",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_3 = FACOM(
    addr="10.68.170.188",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103958",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204105018",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101503",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503545",
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_4T4R",
    radio_type=RadioTypes.AZNA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    serial_number="6Q174625312",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_4T4R",
    radio_type=RadioTypes.AZNA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    serial_number="6Q185142197",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_4T4R",
    radio_type=RadioTypes.AZNA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    serial_number="6Q172117317",
    pdu_port=_pdu_2.pdu_ports[5],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.68.179.223"),
    instance_id=883,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.56.127.15", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_ASIM_ABIQ_2ABIO_3AZNA_883",
)

__all__ = ["tl"]
