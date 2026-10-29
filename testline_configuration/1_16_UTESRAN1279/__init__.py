__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "8.4"
__rack__ = "GTA-782"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

# smod port 1
_pdu_1 = Gude(
    addr="10.42.199.241",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# rm port 2, 3, 4, 10, 11, 12
_pdu_2 = Gude(
    addr="10.42.199.243",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL2106H26TQ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2111I27BZ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2109I278Y",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL1921HI09K",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL1944H1005",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.136", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2109I2796",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.137", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)


_abia_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170115127",
    rus=[_rmod_1, _rmod_2],
)
_abia_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172230575",
    rus=[_rmod_3, _rmod_4],
)
_abia_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171402112",
    rus=[_rmod_5, _rmod_6],
)

_asib_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2, _abia_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1230408195",
)


_smod_1 = Airscale([_asib_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    global_bts_id=100899, instance_id=100899
)

_pdus = [_pdu_1, _pdu_2]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.107", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_L_1ASIB_3ABIA_3AAIB_3AAFB_UUF_1_UTECA",
)

__all__ = ["tl"]
