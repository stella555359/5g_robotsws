# Osilek

__maintainer__ = "Bartosz Jachym"
__email__ = "bartosz.jachym@nokia.com"

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
    SshServiceDetails(addr="10.42.53.89", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.53.90", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.44.177.114", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.177.125", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3 = Gude("10.44.177.126", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172710629",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172911398",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172604842",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172602578",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172906934",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172705294",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="K9181925216",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type=RadioTypes.FRHC,
    serial_number="F7164104127",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="K9191209789",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="K9183840432",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.44.74.131"),
    instance_id=1350,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.210"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC32",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.215.4", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_2ASIA_4ABIA_3AHEGB_1FRHC",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
