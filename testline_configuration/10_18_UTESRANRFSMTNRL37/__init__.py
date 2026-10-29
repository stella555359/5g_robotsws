__maintainer__ = "marc.jurca@nokia.com"
__owner__ = "marc.jurca@nokia.com"
__email__ = "marc.jurca@nokia.com"
import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CoreUnit, CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverHost, SerialOverTcp, Local, Remote

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.232", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.27", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# PDU RFs
_pdu_1 = Gude(
    addr="10.255.7.19",
    port_numbers=[3, 4, 5, 6],
    model="EPC",
    version="8221-1",
)


_pdu_2 = Gude(
    addr="10.255.7.18",
    port_numbers=[10, 11],
    model="EPC",
    version="8221-1",
)


_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"


_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

# RFs
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA212650486",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[]
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA200150649",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[]
)


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1173917427",
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204101564",
    rus=[_rmod_1, _rmod_2],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="DH251512120",
    rus=[_rmod_1, _rmod_2],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212873479",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1250804333",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2],
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.22", port="9443", username=None, password=None)
)

_calient = Calient(
    addr="10.255.2.169",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=621037,
    oam_ip=NetworkAddress(v4="10.0.69.37"),
    dcap=_dcap_1,
)
_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2],
    instance_id=623037,
    oam_ip=NetworkAddress(v4="10.0.67.37"),
    dcap=_dcap_1,
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1, _enb_lte_2],
    test_pcs=[_test_pc_1, _test_pc_2],
    optical_switches=[_calient],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL37",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
}

OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL37/optical_switch_ports.yaml"
)

# DCAP_PROFILES_CONFIG_PATH = (
#    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL37/dcap_profiles.yaml"
# )

__all__ = ["tl"]
