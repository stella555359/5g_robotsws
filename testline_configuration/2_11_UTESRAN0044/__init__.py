__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import TafUeAppServer

###############################################
# UTE Oulu 5G Classical BTS SA configuration  #
###############################################

# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))


# Power breakers
_pdu_du = ENICS(addr="100.68.226.172", port_numbers=[2])
_pdu_ru_gnb = ENICS(addr="100.68.226.89", port_numbers=[1, 2])


# 5G Radio units
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AEQE",
    pdu_port=_pdu_ru_gnb.pdu_ports[1],
    serial_number="1M214329307",
)
_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AEQE",
    pdu_port=_pdu_ru_gnb.pdu_ports[2],
    serial_number="1M214329361",
)
_radio_units_gnb = [_ru_1, _ru_2]

# 5G Cloud unit
_cloud_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="100.68.99.163/27",
        v6="2a00:8a00:4000:4a43::1d03/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    ngu=NetworkAddress(
        v4="100.68.99.163/27",
        v6="2a00:8a00:4000:4a43::1d03/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
    ngc=NetworkAddress(
        v4="100.68.99.195/27",
        v6="2a00:8a00:4000:4a43::1e03/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1e01"),
    ),
    xnc=NetworkAddress(
        v4="100.68.99.195/27",
        v6="2a00:8a00:4000:4a43::1e03/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1e01"),
    ),
    xnu=NetworkAddress(
        v4="100.68.99.163/27",
        v6="2a00:8a00:4000:4a43::1d03/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
)

# 5G Distributed unit
_abio_master = CapacityUnit(
    addr="192.168.253.36",
    rus=_radio_units_gnb,
    hardware_type="ABIN",
    product_code="474824A.103",
    serial_number="L1213615754",
    slot_id=SlotId.B4
)

_capacity_units_gnb = [_abio_master]

_common_unit_gnb = CommonUnit(
    hardware_type="ASIL",
    serial_number="DH222350235",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=_capacity_units_gnb,
    pdu_port=_pdu_du.pdu_ports[2],
    slot_id = SlotId.C2
)

_airscale_gnb = Airscale(common_units=[_common_unit_gnb], product_code="474767A.101")

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abio_master, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abio_master, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_2, label="SFP", port_id=1),
    ),
]

_distributed_unit_gnb = DU(
    airscale=_airscale_gnb, rus=_radio_units_gnb, cablinks=_ru_cablinks
)

# 5G Classical BTS
_classical_bts_gnb = ClassicalBts(
    cu=_cloud_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=101501,
    global_bts_id=101501,
)

# gnb virtual machine
_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.9", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_common_unit_gnb, interface_type="lmp")
    ],
)

# Core network
_amf_oam_ssh_connection_details = SshServiceDetails(
    addr=None, username=None, password=None
)
_n2_address = NetworkAddress(v4="10.35.108.72", v6="2a00:8a00:4000:4a22::8086")
_amf = AMF(oam_ssh_connection_details=_amf_oam_ssh_connection_details, n2=_n2_address)
_real_5g_core_details = RealCore5GDetails(amf=_amf, tac=8000)
_core = RealCore(mcc=244, mnc=9, five_g=_real_5g_core_details)

# Testline
tl = TestLine(
    test_pc=_lmp_vm,
    test_pcs=[_lmp_vm],
    gnbs=[_classical_bts_gnb],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIL_ABIN_2xAEQE_eCPRI",
    ues=None,
)

__all__ = ["tl"]
