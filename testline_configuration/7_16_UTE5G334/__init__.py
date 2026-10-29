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
from taf.config.testline.testpc import TestPc, Connection
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
from taf.config.testline.dcap import DcapBasic

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# _lmp_vm_gnb_2 = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="0.0.0.0", username="ute", password="ute"  # need to fill

#     )
# )
cfg_dir = os.path.dirname(os.path.abspath(__file__))

_controlNode = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.203.87", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.203.87", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.210.128", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_controlNode], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="7_16_UTE5G334_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="tl334",
)

_cbts_net = DeploymentNetworkStack(
    name="7_16_UTE5G334_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_16_UTE5G334_BTS",
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
        v6="2A00:8A00:6000:607c::1:6AA6",
        vlan_id=469,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::1:6A01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::1:6AA6",
        username="robot",
        password="rastre1",
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::1:6AA6",
        port=443,
        username="Nemuadmin",
        password="nemuuser",
    ),
    f1m=NetworkAddress(
        v6="2A00:8A00:6000:607c::64A6",
        vlan_id=470,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6401/120"),
    ),
    f1c=NetworkAddress(
        v6="2A00:8A00:6000:607c::65A6",
        vlan_id=471,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6501/120"),
    ),
    f1u=NetworkAddress(
        v6="2A00:8A00:6000:607c::67A6",
        vlan_id=473,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6701/120"),
    ),
    x2c=NetworkAddress(
        v6="2A00:8A00:6000:607c::66A6",
        vlan_id=472,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6601/120"),
    ),
    x2u=NetworkAddress(
        v6="2A00:8A00:6000:607c::68A6",
        vlan_id=474,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6801/120"),
    ),
    s1u=NetworkAddress(
        v6="2A00:8A00:6000:607c::69A6",
        vlan_id=475,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6901/120"),
    ),
    global_bts_id=51062,
    instance_id=51062,
)

_pdu_gnb = ATEN(
    addr="10.44.205.49",
    port_numbers=[3],
)

_pdu_gnb_ru = APC(
    addr="10.44.205.47",
    port_numbers=[6],
    model="aos",
    version="v3.7.4",
)

_gnb_ru = RU(
    ru_hw_group="AEUB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_asik_gnb_1 = CommonUnit(
    hardware_type="ASOD",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master],
    pdu_port=_pdu_gnb.pdu_ports[3],
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
        v6="2A00:8A00:6000:607c::6BA6",
        vlan_id=477,
    ),
    oam_ip=NetworkAddress(
        v6="2A00:8A00:6000:607c::6AA6",
        vlan_id=476,
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6A01/120"),
        # routing_v4=RoutingInformation(gateway="10.44.83.177", ip_prefix_length=26),
        # username="Nemuadmin",
        # password="nemuuser",
    ),
    f1_m_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::6AA6",
        vlan_id=476,
    ),
    f1_u_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::6CA6",
        vlan_id=478,
    ),
    f1_c_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::6B00",
        vlan_id=471,
        # routing_v4=RoutingInformation(gateway="10.44.83.97", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6501/120"),
    ),
    f1_m_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::6A00",
        vlan_id=470,
        # routing_v4=RoutingInformation(gateway="10.44.83.81", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6401/120"),
    ),
    f1_u_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::6C00",
        vlan_id=473,
        # routing_v4=RoutingInformation(gateway="10.44.83.129", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6701/120"),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=51062,
    instance_id=51063,
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="ute", password="ute"  # need to fill
    )
)

_pdu_enb = ATEN(addr="0.0.0.0", port_numbers=[7])

_asia_enb_1 = CommonUnit(
    hardware_type="ASOD",
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
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::6601/120"),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        v6="2A00:8A00:6000:607c::1:6AA5",
        vlan_id=469,
        # routing_v4=RoutingInformation(gateway="10.44.83.65", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::1:6A01/120"),
    ),
)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = CloudBts(
    cu=_cu_gnb_1,
    dus=[
        _du_1,
    ],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl334",
    dcap=_dcap,
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

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.247", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp"),
    ],
)

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
    enbs=[_enb_1],
)

__all__ = ["tl"]
