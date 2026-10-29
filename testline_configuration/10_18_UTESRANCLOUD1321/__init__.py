__maintainer__ = "Mohamad Al Hamwi"
__email__ = "mohamad.al_hamwi@nokia.com"
__owner_email__ = "mihai.rusu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.19", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.1.13", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.255.1.12", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805521",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW190300319",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1164604287",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXCB,
    serial_number="1M154507574",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="K9172536575",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXCB,
    serial_number="1M161069769",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.247.21"),
    instance_id=10321,
)


_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.120", username="", password=""
    ),
)

_bsc = BSC(
    name="BSC_AVENSIS_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_2ABIA_2FXCB_1FRGU",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
