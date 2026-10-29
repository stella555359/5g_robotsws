__maintainer__ = "Sandeep Sahu"
__team__ = "MN_RAN_Pz_BLR_5_SG"
__email__ = "I_MN_RAN_PZ_BLR_SG5_VAJRA_SQD@internal.nsn.com"
__owner_email__ = "sandeep.1.sahu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress

from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_test_pc = TestPc(
    SshServiceDetails(addr="10.43.54.200", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude("10.41.155.145", [5], "MYCOMP", "8221-1")
_pdu_2 = Gude("10.41.155.146", [2, 7], "MYCOMP", "8221-1")

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101445"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191003571",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHEC,
    serial_number="6Q191427771",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEB,
    serial_number="EA192276326",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.43.197.141"),
    instance_id=434,
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIB_1ABIO_1AHEC_1AHEB",
)

__all__ = ["tl"]
