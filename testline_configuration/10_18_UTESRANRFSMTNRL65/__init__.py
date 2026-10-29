__maintainer__ = "snejana.gabor@nokia.com"
__owner__ = "snejana.gabor@nokia.com"
__email__ = "snejana.gabor@nokia.com"
import os
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.ran import BSC
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.55", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.56", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.111", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.112", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude("10.255.5.110", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AKNB.value,
    serial_number="1M224537855",
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.26",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM"
            )
        ]
    )
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AKNB.value,
    serial_number="1M223512407",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AKNB.value,
    serial_number="1M224537865",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA222551350",
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA222551295",
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA222551296",
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.65",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM17"
            )
        ]
    )
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1145104913",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA215050784",
    pdu_port=_pdu_3.pdu_ports[11],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA215050702",
    pdu_port=_pdu_3.pdu_ports[12],
)


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240104904",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_8, _rmod_9],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1220509008",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1243802127",
    test_pc=_test_pc_master,
    rus=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503505",
    test_pc=_test_pc_slave,
)

_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale(common_units=[_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    instance_id=623065,
    oam_ip=NetworkAddress(v4="10.0.65.65"),
    bcf_id="3065",
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_8, _rmod_9],
    instance_id=624065,
    oam_ip=NetworkAddress(v4="10.0.67.65"),
)

_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.core_units[0],
        interface_type="lmp",
    )
)

_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.134",
)
_app_server_2 = TafUeAppServer(app_server_name="APP_2",
                               address="10.9.146.30",
                               user="iperf_user",
                               password="Treperf",
                               bind_interface_ip="10.9.146.30"
                               )
_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_data_transfer_iperf_3 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_2, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="fad7baf5",
    ue_pc_address="10.5.55.26",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.26", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="82",
    capabilities=["NR1"],
)

_android2 = TafUeAndroid(
    serial_number="H0D9FI1LV0250900227",
    ue_pc_address="10.5.55.26",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.26", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="82",
    capabilities=["LTE1"],
)
_android3 = TafUeAndroid(
    serial_number="HZQN1876AAL32100338",
    ue_pc_address="10.5.55.26",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.26", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="82",
    capabilities=["NR2"],
)
_android4 = TafUeAndroid(
    serial_number="H0D9FI1LV0181000247",
    ue_pc_address="10.5.55.26",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.26", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="82",
    capabilities=["LTE2"],
)
_android5 = TafUeAndroid(
    serial_number="HZQN1876BAKB2500252",
    ue_pc_address="10.5.55.26",
    data_transfer=[_data_transfer_iperf_3],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.55.26", username="rfsharing", password="Nokia2022!@1"
    ),
    ue_pc_port="82",
    capabilities=["GSM"],
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    enbs=[_enb_lte_1, _enb_lte_2],
    bscs=[_bsc],
    tl_cloud_topology="CLOUD_HRAN_RFS_ASOG_AIL_B1-2_MTNRL65_3AKNB_5AHEGC_1FHFB",
    ues=[_android1, _android2, _android3, _android4, _android5],
)

ATTENUATOR_CONFIG_PATH = (  
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL65/pa.yaml"
)
CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL65/cell_target_bw.yaml"
)
RFS_TL_FLAGS = {
    "SYSLOG_CHECK": False,
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL65/MTNRL65_custom_rmod_setup.yaml"
}
__all__ = ["tl"]
