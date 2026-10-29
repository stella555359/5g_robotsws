__maintainer__ = "Baburaj"
__team__ = "TRSVRF"
__email__ = "abhishek.baburaj@nokia.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import RRB, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF

__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.82.67", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.63.86.218",
        v6="2a00:8a00:a000:11b0::3bda",
        vlan_id=237,
        routing_v4=RoutingInformation(gateway="10.63.86.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b0::3bc1", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.63.87.186",
        v6="2a00:8a00:a000:11b0::3cba",
        vlan_id=244,
        routing_v4=RoutingInformation(gateway="10.63.87.161", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b0::3ca1", ip_prefix_length=120
        ),
    ),
    x2u=NetworkAddress(
        v4="10.43.87.154",
        v6="2a00:8a00:a000:11b0::3c9a",
        vlan_id=243,
        routing_v4=RoutingInformation(gateway="10.63.87.129", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b0::3c81", ip_prefix_length=120
        ),
    ),
    s1u=NetworkAddress(
        v4="10.63.87.122",
        v6="2a00:8a00:a000:11b0::3c7a",
        vlan_id=242,
        routing_v4=RoutingInformation(gateway="10.63.87.97", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b0::3c61", ip_prefix_length=120
        ),
    ),
    # ngu=NetworkAddress(
    #     v4="10.63.87.218",
    #     v6="2a00:8a00:a000:11b0::3cda",
    #     vlan_id=245,
    #     routing_v4=RoutingInformation(gateway="10.63.87.193", ip_prefix_length=26),
    #     routing_v6=RoutingInformation(
    #         gateway="2a00:8a00:a000:11b0::3cc1", ip_prefix_length=120
    #     ),
    # ),
    # ngc=NetworkAddress(
    #     v4="10.63.87.250",
    #     v6="2a00:8a00:a000:11b0::3cfa",
    #     vlan_id=246,
    #     routing_v4=RoutingInformation(gateway="10.63.87.225", ip_prefix_length=26),
    #     routing_v6=RoutingInformation(
    #         gateway="2a00:8a00:a000:11b0::3ce1", ip_prefix_length=120
    #     ),
    # ),
    xnc=NetworkAddress(
        v4="10.43.82.250",
        v6="2a00:8a00:a000:11b0::3dfa",
        vlan_id=248,
        routing_v4=RoutingInformation(gateway="10.43.82.225", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b0::3de1", ip_prefix_length=120
        ),
    ),
    xnu=NetworkAddress(
        v4="10.43.82.218",
        v6="2a00:8a00:a000:11b0::3dda",
        vlan_id=247,
        routing_v4=RoutingInformation(gateway="10.43.82.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b0::3dc1", ip_prefix_length=120
        ),
    ),
)

_pdu_gnb = RRB(addr="10.43.82.107", port_numbers=[1])

_pdu_gnb_ru = Gude(
    addr="10.43.82.107",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)

# _gnb_ru = RU(ru_hw_group='AEQP',
_gnb_ru = RU(
    ru_hw_group="AEQP",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=2),
    )
]

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)

_pdu_enb = RRB(addr="0.0.0.0", port_numbers=[8])  # need to fill

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[8],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=3924,
    instance_id=3924,
    x2_link_addr=NetworkAddress(
        v4="10.44.85.134",
        v6="2a00:8a00:6000:607c::1:6173",
        vlan_id=237,
        routing_v4=RoutingInformation(gateway="10.63.86.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b0::3bc1", ip_prefix_length=120
        ),
    ),
)

_enb_1.m_plane = NetworkAddress(
    v4="10.44.85.70",
    v6="2a00:8a00:6000:607c::1:6073",
    vlan_id=820,
    routing_v4=RoutingInformation(gateway="10.44.85.65", ip_prefix_length=26),
    routing_v6=RoutingInformation(
        gateway="2a00:8a00:6000:607c::1:6001", ip_prefix_length=120
    ),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50285, instance_id=50285
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIL_ABIO_AEQN_eCPRI"


# _amf_ssh = SshServiceDetails(
#     addr="to_be_updated", username="to_be_updated", password="to_be_updated"
# )

# _amf_n2_addr = NetworkAddress(
#     v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
# )

# _amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

# _core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7151), mcc=540, mnc=1)
_cu_gnb_1.m = NetworkAddress(
    v4="10.44.85.69",
    v6="2a00:8a00:6000:607c::1:6072",
    vlan_id=820,
    routing_v4=RoutingInformation(gateway="10.44.85.85", ip_prefix_length=26),
    routing_v6=RoutingInformation(
        gateway="2a00:8a00:6000:607c::1:6001", ip_prefix_length=120
    ),
)
# temp _enb_1.m
_enb_1.m = NetworkAddress(
    v4="10.44.85.70",
    v6="2a00:8a00:6000:607c::1:6073",
    vlan_id=820,
    routing_v4=RoutingInformation(gateway="10.44.85.65", ip_prefix_length=26),
    routing_v6=RoutingInformation(
        gateway="2a00:8a00:6000:607c::1:6001", ip_prefix_length=120
    ),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.85", username="ute", password="ute"  # need to fill
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    # core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
)
