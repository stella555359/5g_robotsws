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
from taf.config.testline.pdu import ENICS, DELTA
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint

###############################################
# UTE Oulu 5G Classical BTS SA configuration  #
###############################################

# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))


# Power breakers
_pdu_du = ENICS(addr="100.68.226.168", port_numbers=[4])
_pdu_ru_gnb = ENICS(addr="100.68.226.10", port_numbers=[11])


# 5G Radio units
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AZQG",
    pdu_port=_pdu_ru_gnb.pdu_ports[11],
    serial_number="EA210351641",
    product_code="474994A.103",
)
_radio_units_gnb = [_ru_1]

# 5G Cloud unit
_cloud_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="100.68.98.165/26",
        v6="2a00:8a00:4000:4a43::1505/120",
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
        v4="100.68.98.165/26",
        v6="2a00:8a00:4000:4a43::1505/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.98.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
    ),
    ngc=NetworkAddress(
        v4="100.68.98.197/26",
        v6="2a00:8a00:4000:4a43::1605/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.98.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1601"),
    ),
    xnc=NetworkAddress(
        v4="100.68.98.197/26",
        v6="2a00:8a00:4000:4a43::1605/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.98.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1601"),
    ),
    xnu=NetworkAddress(
        v4="100.68.98.165/26",
        v6="2a00:8a00:4000:4a43::1505/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.98.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
    ),
)

# 5G Distributed unit
_abil_master = CapacityUnit(
    addr="192.168.253.36",
    rus=_radio_units_gnb,
    slot_id=SlotId.B4,
    hardware_type="ABIL",
    product_code="474020B.102",
    serial_number="L1201402388",
)

_capacity_units_gnb = [_abil_master]

_common_unit_gnb = CommonUnit(
    hardware_type="ASIB",
    serial_number="L1183314238",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=_capacity_units_gnb,
    pdu_port=_pdu_du.pdu_ports[4],
    slot_id=SlotId.C2,
)

_airscale_gnb = Airscale(common_units=[_common_unit_gnb], product_code="473764A.101")

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil_master, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    )
]

_distributed_unit_gnb = DU(
    airscale=_airscale_gnb, rus=_radio_units_gnb, cablinks=_ru_cablinks
)

# 5G Classical BTS
_classical_bts_gnb = ClassicalBts(
    cu=_cloud_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=101603,
    global_bts_id=101603,
)

# gnb virtual machine
_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.119", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_common_unit_gnb, interface_type="lmp")
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIB_ABIL_AZQG",
)

__all__ = ["tl"]

radios_info = [
    {
        "antenna_lines": 8,
        "integrated_antenna": False,
        "protocol_type": "CPRI",
        "duplex_method": "TDD",
    },
]
