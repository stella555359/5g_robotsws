__maintainer__ = "raluca-elena.butcovan@nokia.com"
__owner__ = "raluca-elena.butcovan@nokia.com"
__email__ = "raluca-elena.butcovan@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit, CoreUnit
# Use CoreUnit for ASOx boards which doesn't have dedicated BBMODs
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.fhs import FHS, FhsType
from taf.config.testline import NetAct



# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.247", username="ute", password="ute"
        #addr VM 5G first
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.248", username="ute", password="ute"
        #addr VM LTE
        
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.7.3", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.7.2", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"  #used for new ok module
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"   #used for old broken module
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"  



_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR242900458",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    
            )

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240512220",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240614441",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    lmi=SerialOverHost(
                    host=TestPc(
                        default_ssh_connection_details=SshServiceDetails(
                            addr="10.5.55.127",
                            username="rfsharing",
                            password="Nokia2022!@1"
                        )
                    ),
                    uart_mapping=[  # windows
                        Local(
                            port="COM4"
                        )
                    ]
                ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2331H60BI",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2330H60AO",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9241813524",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW240800031",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverHost(
                    host=TestPc(
                        default_ssh_connection_details=SshServiceDetails(
                            addr="10.5.55.127",
                            username="rfsharing",
                            password="Nokia2022!@1"
                        )
                    ),
                    uart_mapping=[  # windows
                        Local(
                            port="COM5"
                        )
                    ]
                )
            )



_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW240800027",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW240800034",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M234401656",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverHost(
                    host=TestPc(
                        default_ssh_connection_details=SshServiceDetails(
                            addr="10.5.55.126",
                            username="rfsharing",
                            password="Nokia2022!@1"
                        )
                    ),
                    uart_mapping=[  # windows
                        Local(
                            port="COM4"
                        )
                    ]
                )
            )



_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M234401658",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M234401657",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233003869",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="DH251512053",
    rus=[_rmod_10, _rmod_11, _rmod_12],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.104",
    serial_number="EA193774835",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233003858",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233003875",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="DH251432943",
    test_pc=_test_pc_1,
#    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_10, _rmod_11, _rmod_12],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212874104",
    test_pc=_test_pc_2,
#    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_smod_1 = Airscale([_fct_1, _fct_2])

_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
    instance_id=623126,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[1],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL126",
)


CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL126/cell_target_bw.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": False,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": True,
    "USER_STOP_AND_FIX_BLOCK_TEST": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL126/MTNRL126_custom_rmod_setup.yaml",
    "RMOD_UDP_LOG_CONFIG_PATH": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL70/MTNRL126_rmod_udp_log.yaml",
    "NETACT_CHECK": False,
}


##### ADDITIONAL VARIABLES  #####
# Path to ues.yaml configuration file. Useful for ute_ue automated voice call/data transfer tests
#UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL45/ues.yaml"

__all__ = ["tl"]
