__maintainer__ = "Damian Siwa"
__team__ = "TRSSEC"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)

from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import RRB, ATEN, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.41.5.6", username="ute", password="ute"
    )
)

# _lmp_vm_gnb_2 = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.44.149.30", username="ute", password="ute"
#     )
# )
cfg_dir = os.path.dirname(os.path.abspath(__file__))

_controlNode = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.41.5.34", username="admin", tenant="admin", password="system123"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.41.5.34", username="cloudadmin", password="system123"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.58.104.45", username="cdslabuser", password="IjwSPfCLU2019"
    ),
)
_ncir = NCIR(compute_nodes=[], control_nodes=[_controlNode], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="2_7_UTETRS5G104_FLAVOUR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="tl104",
)

_cbts_net = DeploymentNetworkStack(
    name="2_7_UTETRS5G104_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="2_7_UTETRS5G104_BTS",
    env_files=[os.path.join(_CFG_DIR, "5gbts_heat.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.41.5.68",
        # v6="2A00:8A00:6000:607c::3444",
        vlan_id=32,
        routing_v4=RoutingInformation(gateway="10.41.5.65", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3401", ip_prefix_length=120
        # ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.41.5.68", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.41.5.68", username="Nemuadmin", password="nemuuser"
    ),
    f1m=NetworkAddress(
        v4="10.41.5.68",
        # v6="2A00:8A00:6000:607c::3544",
        vlan_id=32,
        routing_v4=RoutingInformation(gateway="10.41.5.65", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
        # ),
    ),
    f1c=NetworkAddress(
        v4="10.41.5.98",
        # v6="2A00:8A00:6000:607c::3644",
        vlan_id=33,
        routing_v4=RoutingInformation(gateway="10.41.5.97", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
        # ),
    ),
    f1u=NetworkAddress(
        v4="10.41.5.99",
        # v6="2A00:8A00:6000:607c::3844",
        vlan_id=33,
        routing_v4=RoutingInformation(gateway="10.41.5.97", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
        # ),
    ),
    x2c=NetworkAddress(
        v4="10.41.5.130",
        # v6="2A00:8A00:6000:607c::3714",
        vlan_id=34,
        routing_v4=RoutingInformation(gateway="10.41.5.129", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3701", ip_prefix_length=120
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.41.5.131",
        # v6="2A00:8A00:6000:607c::3944",
        vlan_id=34,
        routing_v4=RoutingInformation(gateway="10.41.5.129", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3901", ip_prefix_length=120
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.41.5.132",
        # v6="2A00:8A00:6000:607c::3A44",
        vlan_id=34,
        routing_v4=RoutingInformation(gateway="10.41.5.129", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3A01", ip_prefix_length=120
        # ),
    ),
    global_bts_id=76007,
    instance_id=76007,
)

_pdu = ATEN(addr="10.58.104.35", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdus = [_pdu]


_gnb_ru = RU(
    ru_hw_group="AEUD",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    pdu_port=_pdus[0].pdu_ports[4],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdus[0].pdu_ports[5],
)

# _asik_gnb_2 = CommonUnit(
#     lmp_connection=SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
#     pdu_port=_pdu_gnb.pdu_ports[2],  # <-----need to fill
# )

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])
# _airscale_gnb_2 = Airscale(common_units=[_asik_gnb_2])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=1),
    )
]


_du_1 = DU(
    airscale=_airscale_gnb_1,
    f1_c_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3C44",
        v4="10.41.5.120",
        vlan_id=33,
    ),
    oam_ip=NetworkAddress(
        v4="10.41.5.120",
        vlan_id=33,
        routing_v4=RoutingInformation(gateway="10.41.5.97", ip_prefix_length=27),
        # username="Nemuadmin",
        # password="nemuuser",
    ),
    f1_m_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3B44",
        v4="10.41.5.120",
        vlan_id=33,
    ),
    f1_u_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3D44",
        v4="10.63.104.194",
        vlan_id=41,
    ),
    f1_c_cu=NetworkAddress(
        v4="10.63.104.162",
        # v6="2A00:8A00:6000:607c::3C00",
        vlan_id=40,
        routing_v4=RoutingInformation(gateway="10.41.5.97", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
        # ),
    ),
    f1_m_cu=NetworkAddress(
        v4="10.41.5.68",
        # v6="2A00:8A00:6000:607c::3B00",
        vlan_id=32,
        routing_v4=RoutingInformation(gateway="10.41.5.65", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
        # ),
    ),
    f1_u_cu=NetworkAddress(
        v4="10.41.5.98",
        # v6="2A00:8A00:6000:607c::3D00",
        vlan_id=33,
        routing_v4=RoutingInformation(gateway="10.41.5.97", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
        # ),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=76007,
    instance_id=76007,
)

# _du_2 = DU(
#     airscale=_airscale_gnb_1,
#     f1_c_ip_addr=NetworkAddress(
#         # v6="2A00:8A00:6000:607c::3C6F",
#         v4="10.44.81.138",
#         vlan_id=419,
#     ),
#     oam_ip=NetworkAddress(
#         v4="10.44.81.122",
#         vlan_id=418,
#         routing_v4=RoutingInformation(gateway="10.44.81.113", ip_prefix_length=26),
#         # username="Nemuadmin",
#         # password="nemuuser",
#     ),
#     f1_m_ip_addr=NetworkAddress(
#         # v6="2A00:8A00:6000:607c::3B6F",
#         v4="10.44.81.122",
#         vlan_id=418,
#     ),
#     f1_u_ip_addr=NetworkAddress(
#         v6="2A00:8A00:6000:607c::3D6F",
#         v4="10.44.81.154",
#         vlan_id=420,
#     ),
#     f1_c_cu=NetworkAddress(
#         v4="10.44.81.128",
#         v6="2A00:8A00:6000:607c::3C00",
#         vlan_id=419,
#         routing_v4=RoutingInformation(gateway="10.44.81.129", ip_prefix_length=26),
#         routing_v6=RoutingInformation(
#             gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
#         ),
#     ),
#     f1_m_cu=NetworkAddress(
#         v4="10.44.81.112",
#         v6="2A00:8A00:6000:607c::3B00",
#         vlan_id=418,
#         routing_v4=RoutingInformation(gateway="10.44.81.113", ip_prefix_length=26),
#         routing_v6=RoutingInformation(
#             gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
#         ),
#     ),
#     f1_u_cu=NetworkAddress(
#         v4="10.44.81.144",
#         v6="2A00:8A00:6000:607c::3D00",
#         vlan_id=420,
#         routing_v4=RoutingInformation(gateway="10.44.81.145", ip_prefix_length=26),
#         routing_v6=RoutingInformation(
#             gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
#         ),
#     ),
#     rus=[_gnb_ru],
#     cablinks=_ru_cablinks,
#     global_bts_id=40242,
#     instance_id=50246,
# )

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.158.217", username="ute", password="ute"
    )
)

_pdu_enb = RRB(addr="None", port_numbers=[9])

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[9],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=3747,
    instance_id=3747,
    x2_link_addr=NetworkAddress(
        v4="10.45.140.90",
        # v6="2A00:8A00:6000:607c::3715",
        vlan_id=414,
        routing_v4=RoutingInformation(gateway="10.45.140.66", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3701", ip_prefix_length=120
        # ),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        v4="10.45.157.154",
        # v6="2A00:8A00:6000:607c::3415",
        vlan_id=411,
        routing_v4=RoutingInformation(gateway="10.45.157.129", ip_prefix_length=27),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3401", ip_prefix_length=120
        # ),
    ),
)

_cbts = CloudBts(
    cu=_cu_gnb_1,
    dus=[
        _du_1,
        # _du_2,
    ],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl104",
)

_tl_cloud_topology = "CLOUD_5G_ASIK_ABIL_AEUB_ENB"


# _amf_ssh = SshServiceDetails(
#     addr="to_be_updated", username="to_be_updated", password="to_be_updated"
# )

# _amf_n2_addr = NetworkAddress(
#     v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
# )

# _amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)


# _core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=540, mnc=1)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[
        _lmp_vm_gnb_1,
        _lmp_vm_enb_1,
        # _lmp_vm_gnb_2,
    ],
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    # core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    # enbs=[_enb_1],
)

__all__ = ["tl"]
