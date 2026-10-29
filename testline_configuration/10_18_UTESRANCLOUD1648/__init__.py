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
        addr="10.5.47.43", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(
    addr="10.255.3.145",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)

_pdu_2 = FPFH(
    addr="10.255.3.134",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)

_pdu_3 = FPFH(
    addr="10.255.3.140",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)

_pdu_4 = FPFH(
    addr="10.255.3.141",
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

_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_4.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"


_fsp_1 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="AH180505888"
)

_fsp_2 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="AH180506385"
)

_fsp_3 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.102", serial_number="L1163319117"
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH202260440",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2028G1BUO",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2028G1BUX",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2022G15JN",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9202300338",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2051W2NWJ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2051W2NWP",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.51"),
    instance_id=10651,
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
    tl_cloud_topology="CLOUD_SRAN_L_10648_1ASIB_3ABIA_3AHLOA_3AHFIG_1ExtASIL",
)


__all__ = ["tl"]
