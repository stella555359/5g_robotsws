__maintainer__ = "Piotr Linek"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "piotr.linek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import EPCSim
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, APC, Gude, Pdu

# test pc ok
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.169", username="ute", password="ute!!"
    )
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.87", username="ute", password="ute!!"
    )
)
# ===================================== ENB ===========================================

_pdu_sm_rus = Gude(
    addr="10.42.80.115",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_shared_ru_1 = Gude(
    addr="10.42.80.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_shared_ru_2 = Gude(
    addr="10.42.80.94",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_shared_ru_1 = RU(
    ru_hw_group="FRMr2.3_4T4R_Quattro",
    radio_type="FRIG",
    serial_number="RY154504193",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.130", port=2323
    ),
    pdu_port=_pdu_shared_ru_1.pdu_ports[10],
)

_shared_ru_2 = RU(
    ru_hw_group="FRMr2.3_4T4R_Quattro",
    radio_type="FRIG",
    serial_number="RY154504192",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.128", port=2323
    ),
    pdu_port=_pdu_shared_ru_1.pdu_ports[12],
)

_shared_ru_3 = RU(
    ru_hw_group="FRMr2.3_4T4R_Quattro",
    radio_type="FRIG",
    serial_number="RY154504202",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.129", port=2323
    ),
    pdu_port=_pdu_shared_ru_1.pdu_ports[11],
)

_shared_ru_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2004G104D",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.133", port=2323
    ),
    pdu_port=_pdu_sm_rus.pdu_ports[5],
)

_shared_ru_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2003G10YB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.128", port=2323
    ),
    pdu_port=_pdu_sm_rus.pdu_ports[1],
)

_shared_ru_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G10NM",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.129", port=2323
    ),
    pdu_port=_pdu_sm_rus.pdu_ports[6],
)

_shared_ru_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIG",
    serial_number="K9203119588",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.132", port=2323
    ),
    pdu_port=_pdu_shared_ru_2.pdu_ports[10],
)

_shared_ru_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIG",
    serial_number="K9203119597",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.130", port=2323
    ),
    pdu_port=_pdu_shared_ru_2.pdu_ports[11],
)

_shared_ru_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIG",
    serial_number="K9203119593",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.131", port=2323
    ),
    pdu_port=_pdu_shared_ru_2.pdu_ports[12],
)

_abia_1 = CapacityUnit(
    addr="192.168.253.36",
    serial_number="DH195291159",
    hardware_type="ABIA",
    hardware_version="473096A.104",
)

_abia_2 = CapacityUnit(
    addr="192.168.253.40",
    serial_number="DH195290546",
    hardware_type="ABIA",
    hardware_version="473096A.104",
)

_abia_3 = CapacityUnit(
    addr="192.168.253.44",
    serial_number="L1173915548",
    hardware_type="ABIA",
    hardware_version="473096A.103",
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2, _abia_3],
    pdu_port=_pdu_sm_rus.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="473095A.204",
    serial_number="EA195156769",
)

# ================================================  GNB  ==================

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.53",
        vlan_id="286",
        routing=RoutingInformation(gateway="10.42.19.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.19.53", v6="", vlan_id=286),
    x2u=NetworkAddress(v4="10.42.18.74", v6="", vlan_id=285),
    s1u=NetworkAddress(v4="10.42.21.53", v6="", vlan_id=288),
)

_abil_gnb_1 = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIL", hardware_version="474020B.102"
)

_abil_gnb_2 = CapacityUnit(
    addr="192.168.253.24", hardware_type="ABIL", hardware_version="474020B.102"
)

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_gnb_1, _abil_gnb_2],
    pdu_port=_pdu_sm_rus.pdu_ports[11],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="L1201004526",
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _shared_ru_4,
        _shared_ru_5,
        _shared_ru_6,
        _shared_ru_7,
        _shared_ru_8,
        _shared_ru_9,
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
        _shared_ru_7,
        _shared_ru_8,
        _shared_ru_9,
    ],
)
_pdus = [_pdu_sm_rus, _pdu_shared_ru_1, _pdu_shared_ru_2]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=3611, instance_id=3611
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_RFS_AIR_B4_B6_ASIKL_B1_3AHFIG_3AHLOA_3FRIG_UUF_1",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
