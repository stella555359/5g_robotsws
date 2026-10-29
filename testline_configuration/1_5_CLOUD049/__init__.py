__owner__ = "Wu Xiaotong"
__maintainer__ = "Wu Xiaotong"
__email__ = "xiaotong.wu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.195", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.128",
    port_numbers=[1, 7],
    model="facom",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="A.103",
    serial_number="L1204206389",
    pdu_port=_pdu_1.pdu_ports[7],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.203",
    serial_number="L1182413287",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AWHHF:CPRI_A_RRH_4T4R",
    serial_number="EB194060094",
    pdu_port=_pdu_1.pdu_ports[1],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_FHB_CRT1_1049",
)

__all__ = ["tl"]
