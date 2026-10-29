__maintainer__ = "dorin.caluser@nokia.com"
__owner__ = "dorin.caluser@nokia.com"
__email__ = "dorin.caluser@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH, PSU
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.159", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.161", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.160", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.255.2.47",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"


_pdu_2 = Gude(
    "10.255.2.48",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRMA.value,
    serial_number="K9143900558",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRMA.value,
    serial_number="K9144515330",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA203756188",
    pdu_port=_pdu_1.pdu_ports[6],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.33",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM8"
            )
        ]
    )
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA203756202",
    pdu_port=_pdu_1.pdu_ports[5],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.33",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM5"
            )
        ]
    )

)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7204203029",
    pdu_port=_pdu_1.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.33",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM9"
            )
        ]
    )
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="AS212707135",
    pdu_port=_pdu_1.pdu_ports[7],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.33",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM4"
            )
        ]
    )

)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="L6133112298",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7131316715",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171013417",
    rus=[],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164304348",
    rus=[_rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164304344",
    rus=[_rmod_1, _rmod_2],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1142902997",
    rus=[_rmod_7, _rmod_8],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1141634073",
    rus=[_rmod_7, _rmod_8],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223402773",
    rus=[_rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="L1201900009",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="NK171070786",
    test_pc=_test_pc_2,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_6],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212873472",
    test_pc=_test_pc_3,
)

_smod_1 = Airscale([_fct_1, _fct_2])
_smod_2 = Airscale([_fct_3])

_enb_SBTS = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
    instance_id=621069,
    oam_ip=NetworkAddress("10.0.70.69"),
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_SBTS.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_SBTS.system_module.common_units[1],
        interface_type="lmp",
    )
)
_enb_NR = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8],
    instance_id=623069,
    oam_ip=NetworkAddress("10.0.66.69"),
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_NR.system_module.common_units[0],
        interface_type="lmp",
    )
)



tl = TestLine(
    test_pc=_enb_SBTS,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_SBTS, _enb_NR],
    tl_cloud_topology="CLOUD_HRAN_RFS_MTNRL69",
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_STOP_AND_FIX_BLOCK_TEST": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "NETACT_CHECK": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL69/MTNRL69_custom_rmod_setup.yaml",
}

__all__ = ["tl"]
