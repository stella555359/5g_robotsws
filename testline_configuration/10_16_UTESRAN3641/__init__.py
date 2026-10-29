__maintainer__ = "Grzegorz Niedzwiedz"
__email__ = "grzegorz.niedzwiedz@nokia.com"

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
        addr="10.42.184.74", username="ute", password="uteUTE!"
    )
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.184.75", username="ute", password="uteUTE!"
    )
)
# ===================================== ENB ===========================================

_pdu_1 = Gude("10.42.212.9", [11, 12], "EPC", "")
_pdu_2 = Gude("10.42.212.13", [9, 12], "EPC", "")
_pdu_3 = Gude("10.42.212.17", [9, 10, 11, 12], "EPC", "")
_pdu_4 = Gude("10.42.212.18", [1, 2, 3], "EPC", "")

_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2215Y28U7",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.135", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
)

_shared_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2215Y28U5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)

_shared_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC",
    serial_number="BL2215Y29G3",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)

_shared_ru_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="DC19460017J",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.134", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)

_shared_ru_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="DC19330015J",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)

_shared_ru_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIC",
    serial_number="DC1935000PN",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[11],
)

_shared_ru_7 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705843",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.73.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_shared_ru_8 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705845",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.73.6", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[3],
)

_shared_ru_9 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQK",
    serial_number="L1221705849",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.73.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)


_abia_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="DH195291308",
)

_abia_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="DH195290515",
)

_asiaa = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIAA",
    hardware_version="A.101",
    serial_number="L1173418437",
)

# ================================================  GNB  ==================

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::7c06",
        vlan_id="170",
        routing=RoutingInformation(
            gateway="2a00:8a00:6000:607c::7c01", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="", v6="2a00:8a00:6000:607c::7c06", vlan_id=170),
    x2u=NetworkAddress(v4="", v6="2a00:8a00:6000:607c::7b06", vlan_id=169),
    s1u=NetworkAddress(v4="", v6="2a00:8a00:6000:607c::7b06", vlan_id=169),
)

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223009522",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223103468",
)


_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="DH222244652",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
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

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asiaa]),
    rms=[
        _shared_ru_1,
        _shared_ru_2,
        _shared_ru_3,
        _shared_ru_4,
        _shared_ru_5,
        _shared_ru_6,
    ],
)
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4 ]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=8547, instance_id=8547
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIAA_2ABIA_1ASIL_2ABIO_3AHBCC_3AHFIC_3AQQK",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]

