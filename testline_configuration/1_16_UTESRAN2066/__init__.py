__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "maciej.pietraszewski@nokia.com"
__customer__ = "Generic"
__bucket__ = "3.3"
__rack__ = "GTA-923"

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
from taf.config.testline.lmi import SerialOverTcp, Remote

# rm port 2, 5, 8
_pdu_1 = Gude(
    addr="10.42.80.94",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)  # smod port 11
_pdu_2 = Gude(
    addr="10.42.80.123",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)  # rm port 5
_pdu_3 = Gude(
    addr="10.42.80.61",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGA",
    serial_number="K9175039261",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.92", port=5001),
        ]
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7161110094",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="AH200800179",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_8T8R",
    radio_type="AKNB",
    serial_number="K9240206080",
    pdu_port=_pdu_3.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.111", port=5001),
        ]
    ),
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:101",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1224301033",
    rus=[_rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:201",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1240700395",
    rus=[_rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:143d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602834",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1204605823",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
                      instance_id=8649, global_bts_id=8649)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.128", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIB_1ABIA_1ABIO_1ABIQ_1FXDB_1AHEGA_1AHFB_1AKNB_UUF_2_UTECA",
)

__all__ = ["tl"]
