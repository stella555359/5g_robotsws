__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "piotr.frydryszak@nokia.com"
__customer__ = "Generic"
__bucket__ = "STRESSED_TEST_LINES"
__rack__ = "GTA-881"

from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU, DU
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


# rm port 1, 2, 3, 4
_pdu_1 = Gude(
    addr="10.42.80.63",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# smod port 4, 5
_pdu_2 = Gude(
    addr="10.42.80.184",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQF",
    serial_number="1M251706789",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQF",
    serial_number="1M251706790",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245006258",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.45.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.27", port="5001"),
        ],
    ),
)

_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:1201",
    hardware_type="ABIN",
    hardware_version="474020B.102",
    serial_number="DH212563474",
    rus=[_rmod_3],
)


_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH221041185",
)

# ================================================  GNB  ==================

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.149.212", v6="", vlan_id=149),
    x2u=NetworkAddress(v4="10.42.148.113", v6="", vlan_id=148),
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1243601479",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="473764A.102",
    serial_number="DH214044573",
)

_airscale_gnb_1 = Airscale(common_units=[_fct_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_rmod_1, _rmod_2, _rmod_3])

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_fct_2]), rms=[_rmod_3], global_bts_id=1894, instance_id=1894
)

_pdus = [_pdu_1, _pdu_2]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=55304, instance_id=55304
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.80", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_airscale_gnb_1.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.97", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_lte.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIM_1ABIP_1ASIL_1ABIN_2AVQF_1AHFII_UTECA",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
