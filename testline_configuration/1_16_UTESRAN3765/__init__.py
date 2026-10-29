__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "AT&T"
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

# smod port 10, 12
_pdu_sm = Gude(
    addr="10.42.199.233",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 1, 3, 5, 7, 9, 11
_pdu_1 = Gude(
    addr="10.42.80.236",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="AS193810094",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.31.33", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)

_shared_ru_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="AS193810093",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.31.34", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)

_shared_ru_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="AS200205557",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.31.35", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_shared_ru_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="DC20140079Q",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_shared_ru_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="K9200523325",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_shared_ru_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="K9200523329",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_abia_1 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:223d",
    serial_number="L1171216182",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    rus=[_shared_ru_4, _shared_ru_5, _shared_ru_6],
)
_abia_2 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:233d",
    serial_number="EA193577785",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2],
    pdu_port=_pdu_sm.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="473095A.204",
    serial_number="EA195156820",
)

# ================================================  GNB  ==================

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.28",
        vlan_id="286",
        routing=RoutingInformation(gateway="10.42.19.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.19.28", v6="2a00:8a00:6000:603a:4aec:5bff:fedd:5cf6", vlan_id=286
    ),
    x2u=NetworkAddress(
        v4="10.42.18.28", v6="2a00:8a00:6000:603c:4aec:5bff:fedd:5cf6", vlan_id=285
    ),
    s1u=NetworkAddress(
        v4="10.42.21.28", v6="2a00:8a00:6000:603c:4aec:5bff:fedd:5cf6", vlan_id=288
    ),
)

_abil_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    serial_number="L1182908942",
    hardware_type="ABIL",
    hardware_version="A.101",
    rus=[_shared_ru_5],
)

_abil_gnb_2 = CapacityUnit(
    addr="192.168.253.24",
    serial_number="L1194210376",
    hardware_type="ABIL",
    hardware_version="B.101",
    rus=[_shared_ru_4, _shared_ru_6],
)

_abil_gnb_3 = CapacityUnit(
    addr="192.168.253.28",
    serial_number="L1203805674",
    hardware_type="ABIL",
    hardware_version="B.102",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_gnb_1, _abil_gnb_2, _abil_gnb_3],
    pdu_port=_pdu_sm.pdu_ports[12],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="L1200602296",
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

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
    system_module=Airscale(common_units=[_asia]),
    rms=[
        _shared_ru_1,
        _shared_ru_2,
        _shared_ru_3,
        _shared_ru_4,
        _shared_ru_5,
        _shared_ru_6,
    ],
)
_pdus = [_pdu_sm, _pdu_1]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=3601, instance_id=3601
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.201", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_lte.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.200", username="ute"),
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
    tl_cloud_topology="CLOUD_RFS_AIR_B4_B5_ASIKL_B1_B2_B3_3AHCA_3AHFIC_UTECA",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
