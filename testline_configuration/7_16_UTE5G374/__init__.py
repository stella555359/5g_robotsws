__maintainer__ = "Damian Siwa"
__team__ = "TRSSEC"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.249.246",
        v6="2a00:8a00:6000:607c::4a16",
        vlan_id=923,
        routing_v4=RoutingInformation(gateway="10.42.249.225/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.255.21.22",
        v6="2a00:8a00:6000:607c::4b16",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.21.1/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4b01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.255.21.54",
        v6="2a00:8a00:6000:607c::4c16",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.21.33/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4c01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.255.21.86",
        v6="2a00:8a00:6000:607c::4d16",
        vlan_id=926,
        routing_v4=RoutingInformation(gateway="10.255.21.65/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4d01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.140.150",
        v6="2a00:8a00:6000:607c::4e16",
        vlan_id=927,
        routing_v4=RoutingInformation(gateway="10.42.140.129/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.140.182",
        v6="2a00:8a00:6000:607c::4f16",
        vlan_id=928,
        routing_v4=RoutingInformation(gateway="10.42.140.161/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4f01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.255.21.22",
        v6="2a00:8a00:6000:607c::4b16",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.21.1/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4b01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.255.21.54",
        v6="2a00:8a00:6000:607c::4c16",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.21.33/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4c01/120"),
    ),
)

_pdu_gnb = ATEN(addr="10.42.61.202", port_numbers=[3])

_pdu_gnb_ru = ATEN(addr="10.42.61.202", port_numbers=[8])

_gnb_ru = RU(
    ru_hw_group="AZQO",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"  # need to fill
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_abio1_gnb_1_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIO", rus=[_gnb_ru]
)

_abio1_gnb_1_slave = CapacityUnit(
    addr="192.168.253.21", hardware_type="ABIO", rus=[_gnb_ru]
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_gnb_1_master, _abio1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIB",
    rus=[_gnb_ru],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abio1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=1),
    )
]

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50284, instance_id=50284, dcap=_dcap
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIB_ABIO_AZQO_SEC_SCAN"


# _amf_ssh = SshServiceDetails(
#     addr="to_be_updated", username="to_be_updated", password="to_be_updated"
# )

# _amf_n2_addr = NetworkAddress(
#     v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
# )

# _amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

# _core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7151), mcc=540, mnc=1)

_cu_gnb_1.m = NetworkAddress(
    v4="10.42.249.246",
    v6="2a00:8a00:6000:607c::4a16",
    vlan_id=923,
    routing_v4=RoutingInformation(gateway="10.42.249.225/27"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.71", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asib_gnb_1, interface_type="lmp")
    ],
)

# with open(
#    os.path.join(os.path.dirname(os.path.abspath(__file__)), "nokia_ue.yaml")
# ) as ue_config:
#    import yaml
#
#    _nokia_ue = yaml.load(ue_config, yaml.SafeLoader)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    # core=_core,
    # ues=[_nokia_ue],
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
)
