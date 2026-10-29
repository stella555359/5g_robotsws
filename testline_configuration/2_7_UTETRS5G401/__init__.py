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
from taf.config.testline.pdu import ATEN, EPC, Gude, APC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.41.5.9", username="ute", password="ute"
    )
)
# _lmp_vm_gnb_2 = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="0.0.0.0", username="ute", password="ute"  # need to fill

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
    name="2_7_UTETRS5G401_FLAVOUR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="tl401",
)

_cbts_net = DeploymentNetworkStack(
    name="2_7_UTETRS5G401_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_16_UTE5G401_BTS",
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
        v6="2a00:8a00:a000:11b8::a3f:6842",
        vlan_id=37,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6841", ip_prefix_length=123
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="2a00:8a00:a000:11b8::a3f:6842",
        username="robot",
        password="rastre1",
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2a00:8a00:a000:11b8::a3f:6842",
        username="Nemuadmin",
        password="nemuuser",
    ),
    f1m=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6862",
        vlan_id=38,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6861", ip_prefix_length=123
        ),
    ),
    f1c=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6862",
        vlan_id=38,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6861", ip_prefix_length=123
        ),
    ),
    f1u=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6862",
        vlan_id=38,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6861", ip_prefix_length=123
        ),
    ),
    x2c=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6882",
        vlan_id=39,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6881", ip_prefix_length=123
        ),
    ),
    x2u=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6882",
        vlan_id=39,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6881", ip_prefix_length=123
        ),
    ),
    s1u=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6882",
        vlan_id=39,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6881", ip_prefix_length=123
        ),
    ),
    global_bts_id=76008,
    instance_id=76008,
)

_pdu_gnb = ATEN(addr="10.58.104.35", port_numbers=[1])

_pdu_gnb_ru = ATEN(addr="10.58.104.35", port_numbers=[2])

_gnb_ru = RU(
    ru_hw_group="AEUB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master],
    pdu_port=_pdu_gnb.pdu_ports[1],
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
        v6="2a00:8a00:a000:11b8::a3f:6902",
        vlan_id=43,
    ),
    oam_ip=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:68e2",
        vlan_id=42,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:68e1", ip_prefix_length=123
        ),
        # routing_v4=RoutingInformation(gateway="10.44.83.177", ip_prefix_length=26),
        # username="Nemuadmin",
        # password="nemuuser",
    ),
    f1_m_ip_addr=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6902",
        vlan_id=43,
    ),
    f1_u_ip_addr=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6922",
        vlan_id=44,
    ),
    f1_c_cu=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6902",
        vlan_id=43,
        # routing_v4=RoutingInformation(gateway="10.44.83.97", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6901", ip_prefix_length=123
        ),
    ),
    f1_m_cu=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6902",
        vlan_id=43,
        # routing_v4=RoutingInformation(gateway="10.44.83.81", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6901", ip_prefix_length=123
        ),
    ),
    f1_u_cu=NetworkAddress(
        v6="2a00:8a00:a000:11b8::a3f:6922",
        vlan_id=44,
        # routing_v4=RoutingInformation(gateway="10.44.83.129", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:a000:11b8::a3f:6921", ip_prefix_length=123
        ),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=76008,
    instance_id=76008,
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.158.217", username="ute", password="ute"  # need to fill
    )
)

_pdu_enb = ATEN(addr="0.0.0.0", port_numbers=[7])

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master],
    pdu_port=_pdu_enb.pdu_ports[7],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40292,  # need to fill
    instance_id=40292,  # need to fill
    x2_link_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::66A5",
        vlan_id=472,
        # routing_v4=RoutingInformation(gateway="10.44.83.113", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2A00:8A00:6000:607c::6601", ip_prefix_length=120
        ),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        v6="2A00:8A00:6000:607c::1:6AA5",
        vlan_id=469,
        # routing_v4=RoutingInformation(gateway="10.44.83.65", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:6A01", ip_prefix_length=120
        ),
    ),
)

_cbts = CloudBts(
    cu=_cu_gnb_1,
    dus=[
        _du_1,
    ],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl105",
)

_tl_cloud_topology = "CLOUD_5G_ASOD_AEUB_ENB_IPV6"


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
    ],
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    # core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    # enbs=[_enb_1],
)

__all__ = ["tl"]
