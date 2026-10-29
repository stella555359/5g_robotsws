__maintainer__ = "dorin.stoenica@nokia.com"
__owner__ = "dorin.stoenica@nokia.com"
__email__ = "dorin.stoenica@nokia.com"

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






# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.236", username="ute", password="UTE.debian12"
        #addr VM 5G first
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


# DCAP class defines details about DCAP server used by test to collect logs; one ore more DCAP objects can be declared
# Data you need to provide: DCAP IP, username, pass, port(default=9443) for usage of local VM installed DCAP or 443 for external DCAP
# Automation and DCAP is supported by using local test-line VM installed DCAP usage, please set DCAP addr to test-line VM-1 IP address


# Gude class for PDU defining.
# Data you need to provide: PDU IP, port (12 by default), type (EPC, APC, etc)
# Then, for each port, specify it's contactor position: NORMALLY_OPEN or NORMALLY_CLOSED
# You can create as many Gude objects as you need (in case your SMODs/RMODs are connected to multiple PDUs)
_pdu_1 = Gude("10.255.7.11", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.7.12", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"

# RU class for RMOD defining.
# Data you need to provide: RMOD type (FHEB, FXDB, etc), serial number, IP address, PDU port where it is connected
# You can create as many RU objects as you need (in case of multiple RMODs)
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="K9191401882",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="K9181518282",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="K9191402032",
    pdu_port=_pdu_1.pdu_ports[12],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSA.value,
    serial_number="RW235000378",
    pdu_port=_pdu_1.pdu_ports[2],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.232",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM10"
            )
        ]
    )
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSA.value,
    serial_number="RW235000390",
    pdu_port=_pdu_1.pdu_ports[1],
        lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.232",
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
    radio_type=RadioTypes.AHSA.value,
    serial_number="RW235000414",
    pdu_port=_pdu_1.pdu_ports[3],
        lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.232",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM13"
            )
        ]
    )
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233201710",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

# CommonUnit class for SMOD defining.
# Data you need to provide: hardware IP address, username, pass, capacity unit object(if defined), PDU port where it is connected
# serial number and TestPc object which contains data about assigned VM
# You can create as many CommonUnit objects as you need (in case of multiple SMODs)
# Capacity units is mandatory attribute. If not equipped, it should be set with empty list, i.e capacity_units=[]

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="L1230604559",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])


_enb_SBTS = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=622118,
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_SBTS.system_module.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_enb_SBTS,
    test_pcs=[_test_pc_1],
    enbs=[_enb_SBTS],
    tl_cloud_topology="CLOUD_HRAN_RFS_MTNRL118",
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": True,
}



__all__ = ["tl"]


