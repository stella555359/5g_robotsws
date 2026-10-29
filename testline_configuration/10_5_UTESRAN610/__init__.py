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


_pdu_1 = Gude(
    addr="10.106.205.24",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)


_fsp_1 = CapacityUnit(addr='None', hardware_type='FBIH', hardware_version='472568A.101',  serial_number='EA174512002')


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="FSIH",
    hardware_version="A.102",
    serial_number="EA174511676",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FZHA,
    serial_number="RY133515810 ",
    pdu_port=_pdu_1.pdu_ports[1],
)


_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.237", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_FH_COMMON_FZHA",
)

__all__ = ["tl"]
