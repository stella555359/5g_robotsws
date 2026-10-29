__maintainer__ = "lin.licai@Nokia-sbell.com"
__team__ = "I_NSB_MN_RAN_BOAM_RD_OM_OSSEMS_UTE_CLOUD"
__email__ = "I_NSB_MN_RAN_BOAM_RD_OM_OSSEMS_UTE_CLOUD@internal.nsn.com"
__owner_email__ = "lin.licai@Nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, ATEN, APC, Gude, Pdu

# test pc ok
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.212.205", username="ute", password="ute"
    )
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.9.98", username="ute", password="ute"
    )
)
# ===================================== ENB ===========================================
_gnb_pdu_asik = FACOM(addr="10.69.66.39", port_numbers=[1])
_gnb_pdu_rf = FACOM(addr="10.69.66.25", port_numbers=[4])
_lte_pdu_asia = FACOM(addr="10.69.66.55", port_numbers=[2])

_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AZQC",
    serial_number="1M181624861",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_gnb_pdu_rf.pdu_ports[4],
)

_abia_1 = CapacityUnit(
    addr="192.168.253.20",
    serial_number="K9174000025",
    hardware_type="ABIA",
    hardware_version="473096A",
)

_abia_2 = CapacityUnit(
    addr="192.168.253.24",
    serial_number="K9174002046",
    hardware_type="ABIA",
    hardware_version="473096A",
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2],
    pdu_port=_lte_pdu_asia.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473095A",
    serial_number="L1173810150",
)

# ================================================  GNB  ==================

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.233.130",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.233.142", ip_prefix_length=28),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.106.233.130", vlan_id=None),
    x2u=NetworkAddress(v4="10.106.233.130", vlan_id=None),
    s1u=NetworkAddress(v4="10.106.233.130", vlan_id=None),
)

_abil_gnb_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA213056146",
)

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_gnb_1],
    pdu_port=_gnb_pdu_asik.pdu_ports[1],
    hardware_type="ASIK",
    hardware_version="474021A",
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _shared_ru_1,
    ],
)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    rms=[
        _shared_ru_1,
    ],
)
_pdus = [_gnb_pdu_asik, _gnb_pdu_rf, _lte_pdu_asia]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=10909, instance_id=10909
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK_ABIL_ASIA_2xABIA_AZQC_RFS",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
