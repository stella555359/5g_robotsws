__maintainer__ = "georgiana.stefan@nokia.com"
__owner__ = "georgiana.stefan@nokia.com"
__email__ = "georgiana.stefan@nokia.com"
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ran import BSC
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.lmi import SerialOverHost, SerialOverTcp, Local, Remote

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.187", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.2.114", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[9].contactor = "NORMALLY_OPENED"


_pdu_2 = Gude("10.255.2.115", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREC.value,
    serial_number="L1251203815",
    pdu_port=_pdu_2.pdu_ports[6],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.86", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM5")],  # windows
    ),
)
_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1233201711",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233402618",
    test_pc=_test_pc_master,
)

_smod_1 = Airscale([_fct_1])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=621123,
    oam_ip=NetworkAddress(v4="10.0.66.133"),
)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master],
    enbs=[_enb_lte_1],
    bscs=[_bsc],
    tl_cloud_topology="None",
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    "USER_STOP_AND_FIX": True,
    "USER_STOP_AND_FIX_BLOCK_TEST": False,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": True,
}
__all__ = ["tl"]
