__maintainer__ = "toader.zapartan@nokia.com"
__owner__ = "beatrice.cuca@nokia.com"
__email__ = "beatrice.cuca@nokia.com"
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
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.46", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.60.62", username="rfsharing", password="Nokia2022!@1"
    ),
    connections=[NetworkAddress(v4="192.168.255.131")],
)

_pdu_1 = Gude("10.255.2.87", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.2.86", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.102", serial_number="L1171013373"
)
_fsp_2 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.102", serial_number="L1164304034"
)
_fsp_3 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="EA184778036"
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="AH173511278",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="AH173511288",
    test_pc=_test_pc_1,
)
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="104",
    serial_number="EA153864083",
    test_pc=_test_pc_2,
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])
_smod_3 = Flexi([_fct_3])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC,
    serial_number="F7171205134",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC,
    serial_number="L9132600741",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC,
    serial_number="1M171546654",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.5.21.46"),
    instance_id=10433,
)

_bts2g_gsm_2 = Bts2G(
    bcf_id="1433",
    system_module=_smod_3,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    master=_enb_lte_1,
)

_bsc = BSC(
    name="BSC_AVENSIS",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

_test_pc_2.connections.append(Connection(interface="NOKLAB", device=_bts2g_gsm_2.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    bts2g_objects=[_bts2g_gsm_2],
    tl_cloud_topology="None",
    bscs=[_bsc],
    rncs=[None],
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSLGMTAS14/ues.yaml"

TARGET_LOGICAL_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSLGMTAS14/logical_config.yaml"
)

RFS_TL_FLAGS = {"fail_if_unexpected_alarms": True, "fail_if_wrn_threshold": True}

__all__ = ["tl"]
