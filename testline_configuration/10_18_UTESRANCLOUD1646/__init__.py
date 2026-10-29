__maintainer__ = "Sorescu Valentin"
__email__ = "valetin.sorescu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

import os
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid


HW_LOCATION_CODE = "Timisoara"

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.47.56", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(
    addr="10.255.3.114",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)

_pdu_2 = FPFH(
    addr="10.255.3.111",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)


_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ232692520",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ232391285",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ232391142",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPB.value,
    serial_number="DH244316256",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPB.value,
    serial_number="DH244316253",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA213353868",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.236.46"),
    instance_id=10646,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_N_10646_1ASOE_3AQQJ_2AHPB",
)


__all__ = ["tl"]
