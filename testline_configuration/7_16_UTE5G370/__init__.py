__maintainer__ = "Damian Siwa"
__team__ = "TRSSEC"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.147",
        v6="2a00:8a00:6000:607c::1:ae08",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ae01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.68.211",
        v6="2a00:8a00:6000:607c::1:af08",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.19",
        v6="2a00:8a00:6000:607c::1:b008",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.83",
        v6="2a00:8a00:6000:607c::1:b108",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b101/120"),
    ),
    # 5giav_classical_sync	10.44.70.147	10.44.70.129	907	2a00:8a00:6000:607c::1:b208	2a00:8a00:6000:607c::1:b201
    # 5giav_classical_/ngc	10.44.70.211	10.44.70.193	908	2a00:8a00:6000:607c::1:b308	2a00:8a00:6000:607c::1:b301
    # ngu=NetworkAddress(
    # ),
    # ngc=NetworkAddress(
    # ),
    xnc=NetworkAddress(
        v4="10.44.68.211",
        v6="2a00:8a00:6000:607c::1:af08",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.70.19",
        v6="2a00:8a00:6000:607c::1:b008",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
)

_pdu_gnb = Gude(
    addr="10.44.205.209",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru = Gude(
    addr="10.44.205.175",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
)

# _gnb_ru = RU(ru_hw_group='AHCA',
_gnb_ru = RU(
    ru_hw_group="AZQO",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)
_abil1_gnb_1_master = CapacityUnit(
     addr="192.168.253.20", 
     hardware_type="ABIO", 
     hardware_version="101",
     rus=[_gnb_ru],
)     
_abil1_gnb_1_slave = CapacityUnit(
     addr="192.168.253.21", 
     hardware_type="ABIO", 
     hardware_version="101",
     rus=[_gnb_ru],
)     
_abil1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO", 
    hardware_version="101",
    rus=[_gnb_ru],
) 
_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[11],
    hardware_type="ASIB",
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=2),
    )
]

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)

#_pdu_enb = ATEN(addr="0.0.0.0", port_numbers=[8])  # need to fill
#
#_asik_enb_1 = CommonUnit(
#    lmp_connection=SshServiceDetails(
#        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#    ),
#    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
#    pdu_port=_pdu_enb.pdu_ports[8],
#    hardware_type="ASIB",
#)
#
#_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])
#
#_enb_1 = RealEnb(
#    airscale=_airscale_enb_1,
#    global_bts_id=40214,
#    instance_id=40214,
#    x2_link_addr=NetworkAddress(
#        v4="10.44.79.19",
#        v6="2a00:8a00:6000:607c::1:b508",
#        vlan_id=910,
#        routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b501/120"),
#    ),
#)
#_enb_1.m_plane = NetworkAddress(
#    v4="10.44.78.211",
#    v6="2a00:8a00:6000:607c::1:b408",
#    vlan_id=909,
#    routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
#    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b401/120"),
#)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50280, instance_id=50280, dcap=_dcap
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIB_ABIO_AZQO_ENB"


# _amf_ssh = SshServiceDetails(
#     addr="to_be_updated", username="to_be_updated", password="to_be_updated"
# )

# _amf_n2_addr = NetworkAddress(
#     v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
# )

# _amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

# _core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7151), mcc=540, mnc=1)
_cu_gnb_1.m = NetworkAddress(
    v4="10.44.68.147",
    v6="2a00:8a00:6000:607c::1:ae08",
    vlan_id=903,
    routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ae01/120"),
)
# temp _enb_1.m
#_enb_1.m = NetworkAddress(
#    v4="10.44.78.211",
#    v6="2a00:8a00:6000:607c::1:b408",
#    vlan_id=909,
#    routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
#    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b401/120"),
#)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.67", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp"),
    ],
)

#_lmp_vm_enb_1 = TestPc(
#    default_ssh_connection_details=SshServiceDetails(
#        addr="0.0.0.0", username="ute", password="ute"  # need to fill
#    ),
#    connections=[_enb_1],
#)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    # core=_core,
    tl_cloud_topology=_tl_cloud_topology,
  #  enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1],  # test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
)
