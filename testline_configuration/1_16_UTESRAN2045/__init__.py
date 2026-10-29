__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "Verizon"
__bucket__ = "x"

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

# smod port 5, 7
# rm port 6, 8, 9, 10, 11, 12
_pdu_1 = Gude(
    addr="10.42.80.68",
    port_numbers=[5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2035Y20MX",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_shared_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2035Y20N2",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)

_shared_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2035Y20N4",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.133", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)

_shared_ru_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2035Y20N7",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)

_shared_ru_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2035Y20N3",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)

_shared_ru_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2035Y20Q6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_abia_1 = CapacityUnit(
    addr="",
    serial_number="L1180417966",
    hardware_type="ABIA",
    hardware_version="473096A",
    rus=[_shared_ru_2, _shared_ru_3, _shared_ru_4, _shared_ru_5, _shared_ru_6],
)

_abia_2 = CapacityUnit(
    addr="",
    serial_number="L1173915554",
    hardware_type="ABIA",
    hardware_version="473096A",
    rus=[_shared_ru_1],
)

_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473098A",
    serial_number="L1201104783",
)

# ================================================  GNB  ==================

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.140",
        vlan_id="286",
        routing=RoutingInformation(gateway="10.42.19.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.19.140", v6="", vlan_id=286),
    x2u=NetworkAddress(v4="10.42.18.140", v6="", vlan_id=285),
    s1u=NetworkAddress(v4="10.42.21.140", v6="", vlan_id=288),
)

_abil_gnb_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B",
    serial_number="L1201205268",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_abil_gnb_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B",
    serial_number="L1194704709",
    rus=[_shared_ru_4, _shared_ru_5, _shared_ru_6],
)

_abil_gnb_3 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B",
    serial_number="L1194704709",
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_gnb_1, _abil_gnb_2, _abil_gnb_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="474021A",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _shared_ru_1,
        _shared_ru_2,
        _shared_ru_3,
        _shared_ru_4,
        _shared_ru_5,
        _shared_ru_6,
    ],
)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asib]),
    rms=[
        _shared_ru_1,
        _shared_ru_2,
        _shared_ru_3,
        _shared_ru_4,
        _shared_ru_5,
        _shared_ru_6,
    ],
)
_pdus = [_pdu_1]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=54003, instance_id=54003
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.230", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_lte.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.92", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_airscale_gnb_1.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_RFS_AIBR_B4_B5_AIBL_B1_B2_B3_6AHBCC_UUF_1_UTECA",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
