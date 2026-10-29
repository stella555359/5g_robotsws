__maintainer__ = "Suhas Ramesh Kumar"
__team__ = "MN_RAN_PZ_BLR_SG7"
__email__ = "I_MN_RAN_PZ_BLR_SG7_JAGUARS_SQD_GMS <I_MN_RAN_PZ_BLR_SG7_JAGUARS_SQD@internal.nsn.com>"
__owner_email__ = "suhas.ramesh_kumar@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.radio import RU


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.43.54.84", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.41.155.55",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="mycomp",
    version="8221-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="ABIA",
	hardware_version="473096A.103",
    serial_number="L1173610941",
)

_fct_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1,],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1200500384",
)

_smod_1 = Airscale([_fct_enb_1])

_rmod_1 = RU(
      ru_hw_group="FRMr3.1_6T6R",
      radio_type="FRHC",
      serial_number="F7172259590",
      default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.8.128", port=2323),
      pdu_port=_pdu_1.pdu_ports[2],
  )
_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="1_2_UTE4GCLOUD188",
)

__all__ = ["tl"]