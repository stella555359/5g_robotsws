__maintainer__ = "anca.tatar@nokia.com"
__owner__ = "anca.tatar@nokia.com"
__email__ = "anca.tatar@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
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
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.108", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.6",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.5.5",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS220890780",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="LR242602075",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEB.value,
    serial_number="L1175003910",
    pdu_port=_pdu_2.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204101565",
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171914505",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171218043",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201106377",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.26.87", port="443", username="dcapuser", password="dcapadmin!"
    )
)

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621044,
    dcap=_dcap_1,
    bcf_id="3044",
)

_rnc = RNC(
    rnc_id=8,
    oms_ip="10.44.44.219",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="root", password="root"
    ),
)

_bsc = BSC(
     name="BSC_PAAVAI",
     logging_ssh_connection_details=SshServiceDetails(
         addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
     ),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
    rncs=[_rnc],
    bscs=[_bsc],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-3_MTNRL44_2xAHPMDB_1xAHEB",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_STOP_AND_FIX": False,
}

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL44/ues.yaml"

__all__ = ["tl"]
