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
    SshServiceDetails(addr="10.43.54.198", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude("10.41.155.145", [2], "MYCOMP", "8221-1") 
_pdu_2 = Gude("10.41.155.144", [4, 3], "MYCOMP", "8221-1")   
_pdu_3 = Gude("10.41.155.146", [8, 5], "MYCOMP", "8221-1")	 

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170407044",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184481524",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473095A.202",
    serial_number="K9171153216",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FXEF,
    serial_number="L1153803749",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRMF,
    serial_number="AS175102206",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXFC,
    serial_number="F7183103180",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXEB,
    serial_number="F7143519960",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2,_rmod_3,_rmod_4],
    oam_ip=NetworkAddress("10.43.197.139"),
    instance_id=427,
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_2ABIA_1FXEF_1FRMF_1FXFC_1FXEB",
)

__all__ = ["tl"]
