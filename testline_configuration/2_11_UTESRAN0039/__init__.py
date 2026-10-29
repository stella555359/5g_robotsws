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
from taf.config.testline.pdu import ENICS, PduPort
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint

###############################################
# UTE Oulu 5G Classical BTS SA configuration  #
###############################################

# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))


# Power breakers
_pdu_du = ENICS(addr="100.68.226.169", port_numbers=[2])
_pdu_ru_gnb = ENICS(addr="100.68.226.21", port_numbers=[6, 7, 8])


# 5G Radio units
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    pdu_port=_pdu_ru_gnb.pdu_ports[8],
    serial_number="EA211752850",
    product_code="474253A.101",
)
_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    pdu_port=_pdu_ru_gnb.pdu_ports[7],
    serial_number="EA211752849",
    product_code="474253A.101",
)
_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AHEH",
    pdu_port=_pdu_ru_gnb.pdu_ports[6],
    serial_number="EA211752848",
    product_code="474253A.101",
)
_radio_units_gnb = [_ru_1, _ru_2, _ru_3]

# 5G Cloud unit
_cloud_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="100.68.98.175/26",
        v6="2a00:8a00:4000:4a43::150f/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.98.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    ngu=NetworkAddress(
        v4="100.68.98.175/26",
        v6="2a00:8a00:4000:4a43::150f/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.98.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
    ),
    ngc=NetworkAddress(
        v4="100.68.98.207/26",
        v6="2a00:8a00:4000:4a43::160f/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.98.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1601"),
    ),
    xnc=NetworkAddress(
        v4="100.68.98.207/26",
        v6="2a00:8a00:4000:4a43::160f/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.98.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1601"),
    ),
    xnu=NetworkAddress(
        v4="100.68.98.175/26",
        v6="2a00:8a00:4000:4a43::150f/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.98.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
    ),
)

# 5G Distributed unit
_PowerSwitch_du0_pdu_port = PduPort(pdu=_pdu_du, port_no="2")
_du0_master_capacity_unit_L_0 = CapacityUnit(
    addr="fsp-1a",
    hardware_type="ABIO",
    product_code="475266A.105",
    serial_number="DH232541389",
    rus=[_ru_3],
    slot_id=SlotId.B4,
)
_du0_master_capacity_unit_L_1 = CapacityUnit(
    addr="fsp-2a",
    hardware_type="ABIO",
    product_code="475266A.103",
    serial_number="DH220451139",
    rus=[_ru_2],
    slot_id=SlotId.B5,
)
_du0_master_capacity_unit_L_2 = CapacityUnit(
    addr="fsp-3a",
    hardware_type="ABIO",
    product_code="475266A.103",
    serial_number="DH220349756",
    rus=[_ru_1],
    slot_id=SlotId.B6,
)
_common_unit_0_L = CommonUnit(
    hardware_type="ASIB",
    serial_number="L1212703260",
    slot_id=SlotId.C2,
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _du0_master_capacity_unit_L_0,
        _du0_master_capacity_unit_L_1,
        _du0_master_capacity_unit_L_2,
    ],
    pdu_port=_PowerSwitch_du0_pdu_port,
)
_airscale = Airscale(common_units=[_common_unit_0_L], product_code="473764A.102")
_ru0_cablink = [
    Cablink(
        source=Endpoint(unit=_du0_master_capacity_unit_L_0, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_3, label="SFP", port_id="1"),
    ),
    Cablink(
        source=Endpoint(unit=_du0_master_capacity_unit_L_1, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_2, label="SFP", port_id="1"),
    ),
    Cablink(
        source=Endpoint(unit=_du0_master_capacity_unit_L_2, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_1, label="SFP", port_id="1"),
    ),
]

_distributed_unit_gnb = DU(
    airscale=_airscale, rus=_radio_units_gnb, cablinks=_ru0_cablink
)

# 5G Classical BTS
_classical_bts_gnb = ClassicalBts(
    cu=_cloud_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=101613,
    global_bts_id=101613,
)

# gnb virtual machine
_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.160", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_common_unit_0_L, interface_type="lmp")
    ],
)

# Core network
_amf_oam_ssh_connection_details = SshServiceDetails(
    addr=None, username=None, password=None
)
_n2_address = NetworkAddress(v4="10.35.18.70", v6="2a00:8a00:4000:4a22::2:1146")
_amf = AMF(oam_ssh_connection_details=_amf_oam_ssh_connection_details, n2=_n2_address)
_real_5g_core_details = RealCore5GDetails(amf=_amf, tac=7926)
_core = RealCore(mcc=244, mnc=9, five_g=_real_5g_core_details)

# Testline
tl = TestLine(
    test_pc=_lmp_vm,
    test_pcs=[_lmp_vm],
    gnbs=[_classical_bts_gnb],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIB_3xABIO_3xAHEH",
)

__all__ = ["tl"]

radios_info = [
    {
        "antenna_lines": 4,
        "integrated_antenna": False,
        "protocol_type": "CPRI",
        "duplex_method": "FDD",
    },
    {
        "antenna_lines": 4,
        "integrated_antenna": False,
        "protocol_type": "CPRI",
        "duplex_method": "FDD",
    },
    {
        "antenna_lines": 4,
        "integrated_antenna": False,
        "protocol_type": "CPRI",
        "duplex_method": "FDD",
    },
]
