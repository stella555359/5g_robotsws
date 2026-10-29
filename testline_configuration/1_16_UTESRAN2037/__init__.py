__maintainer__ = "Sebastian Jakobczyk"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "sebastian.jakobczyk@nokia.com"

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
        addr="10.42.82.243", username="ute", password="ute!!"
    )
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.82.96", username="ute", password="ute!!"
    )
)
# ===================================== ENB ===========================================

_pdu_lte_sm = Gude(
    addr="10.42.80.123", port_numbers=[12], model="EPC", version="8220-1"
)
# gude dziala
_pdu_shared_ru_1 = Gude(addr="10.42.80.94", port_numbers=[1], model="EPC")
_pdu_shared_ru_2 = Gude(addr="10.42.80.94", port_numbers=[2], model="EPC")
_pdu_shared_ru_3 = Gude(addr="10.42.80.94", port_numbers=[4], model="EPC")
_pdu_shared_ru_4 = Gude(addr="10.42.80.134", port_numbers=[1], model="EPC")
_pdu_shared_ru_5 = Gude(addr="10.42.80.134", port_numbers=[2], model="EPC")
_pdu_shared_ru_6 = Gude(addr="10.42.80.47", port_numbers=[7], model="EPC")

_shared_ru_1 = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    serial_number="BL2031G1G8L",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.128", port=2323
    ),
    pdu_port=_pdu_shared_ru_1.pdu_ports[1],
)
_shared_ru_2 = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    serial_number="BL2031G1GIT",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.131", port=2323
    ),
    pdu_port=_pdu_shared_ru_2.pdu_ports[2],
)
_shared_ru_3 = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    serial_number="BL2031G1G8K",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.130", port=2323
    ),
    pdu_port=_pdu_shared_ru_3.pdu_ports[4],
)
_shared_ru_4 = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    serial_number="BL2032G1GNG",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.129", port=2323
    ),
    pdu_port=_pdu_shared_ru_4.pdu_ports[1],
)
_shared_ru_5 = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    serial_number="BL2032G1GNF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.132", port=2323
    ),
    pdu_port=_pdu_shared_ru_5.pdu_ports[2],
)
_shared_ru_6 = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    serial_number="BL2032G1GQZ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.133", port=2323
    ),
    pdu_port=_pdu_shared_ru_6.pdu_ports[7],
)

_abia_1 = CapacityUnit(addr="192.168.253.36", serial_number="L1194900538")
_abia_2 = CapacityUnit(addr="192.168.253.40", serial_number="L1171312767")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2],
    pdu_port=_pdu_lte_sm.pdu_ports[12],
    serial_number="L1171504322",
)

# ================================================  GNB  ==================
_pdu_gnb = Gude(addr="10.42.80.123", port_numbers=[11], model="EPC", version="8220-1")

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.152",
        vlan_id="286",
        routing=RoutingInformation(gateway="10.42.19.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.19.152", v6="", vlan_id=286),
    x2u=NetworkAddress(v4="10.42.18.152", v6="", vlan_id=285),
    s1u=NetworkAddress(v4="10.42.21.152", v6="", vlan_id=288),
)

_abil_gnb_1 = CapacityUnit(addr="192.168.253.20")
_abil_gnb_2 = CapacityUnit(addr="192.168.253.24")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_gnb_1, _abil_gnb_2],
    pdu_port=_pdu_gnb.pdu_ports[11],
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
_pdus = [
    _pdu_lte_sm,
    _pdu_gnb,
    _pdu_shared_ru_1,
    _pdu_shared_ru_2,
    _pdu_shared_ru_3,
    _pdu_shared_ru_4,
    _pdu_shared_ru_5,
    _pdu_shared_ru_6,
]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=54005, instance_id=54005
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_RFS_AIR_B4_B5_ASIKL_B1_B2_6AHLOA_UUF_1",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
