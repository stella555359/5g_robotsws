__maintainer__ = "jack.1.wu@Nokia-sbell.com"
__team__ = "I_NSB_MN_RAN_BOAM_RD_OM_OSSEMS_UTE_CLOUD"
__email__ = "I_NSB_MN_RAN_BOAM_RD_OM_OSSEMS_UTE_CLOUD@internal.nsn.com"
__owner_email__ = "jack.1.wu@Nokia-sbell.com"

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
        addr="10.69.9.73", username="ute", password="ute"
    )
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.9.62", username="ute", password="OSSEMS_cbrs_ET2"
    )
)
# ===================================== ENB ===========================================
_gnb_pdu_asib = FACOM(addr="10.106.210.30", port_numbers=[6])
_gnb_pdu_rf = FACOM(addr="10.69.66.46", port_numbers=[3])
_lte_pdu_asib = FACOM(addr="10.106.210.30", port_numbers=[4])

_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AEQM",
    serial_number="1M210131536",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_gnb_pdu_rf.pdu_ports[3],
)

_lte_abio_1 = CapacityUnit(
    addr="192.168.253.20",
    serial_number="DH214542930",
    hardware_type="ABIO",
    hardware_version="475266A",
)


_lte_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_lte_abio_1],
    pdu_port=_lte_pdu_asib.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A",
    serial_number="DH213146879",
)

# ================================================  GNB  ==================

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.233.134",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.233.142", ip_prefix_length=28),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.106.233.134", vlan_id=None),
    x2u=NetworkAddress(v4="10.106.233.134", vlan_id=None),
    s1u=NetworkAddress(v4="10.106.233.134", vlan_id=None),
)

_abio_gnb_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="DH214542928",
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1],
    pdu_port=_gnb_pdu_asib.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="089596A",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _shared_ru_1,
    ],
)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_lte_asib]),
    rms=[
        _shared_ru_1,
    ],
)
_pdus = [_gnb_pdu_asib, _gnb_pdu_rf, _lte_pdu_asib]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=10672, instance_id=10672
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xASIB_2xABIO_AEQM_RFS",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
