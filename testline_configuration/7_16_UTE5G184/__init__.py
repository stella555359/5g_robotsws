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
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# _lmp_vm_gnb_2 = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.44.149.30", username="ute", password="ute"
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
    name="7_16_UTE5G184_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="tl184",
)

_cbts_net = DeploymentNetworkStack(
    name="7_16_UTE5G184_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_16_UTE5G184_BTS",
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
        v4="10.44.83.74",
        # v6="2A00:8A00:6000:607c::3444",
        vlan_id=469,
        routing_v4=RoutingInformation(gateway="10.44.83.65/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3401", ip_prefix_length=120
        # ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.83.74", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.83.74", port=443, username="Nemuadmin", password="nemuuser"
    ),
    f1m=NetworkAddress(
        v4="10.44.83.87",
        # v6="2A00:8A00:6000:607c::3544",
        vlan_id=470,
        routing_v4=RoutingInformation(gateway="10.44.83.81/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
        # ),
    ),
    f1c=NetworkAddress(
        v4="10.44.83.103",
        # v6="2A00:8A00:6000:607c::3644",
        vlan_id=471,
        routing_v4=RoutingInformation(gateway="10.44.83.97/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
        # ),
    ),
    f1u=NetworkAddress(
        v4="10.44.83.135",
        # v6="2A00:8A00:6000:607c::3844",
        vlan_id=473,
        routing_v4=RoutingInformation(gateway="10.44.83.129/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
        # ),
    ),
    x2c=NetworkAddress(
        v4="10.44.83.122",
        # v6="2A00:8A00:6000:607c::3714",
        vlan_id=472,
        routing_v4=RoutingInformation(gateway="10.44.83.113/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3701", ip_prefix_length=120
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.44.83.151",
        # v6="2A00:8A00:6000:607c::3944",
        vlan_id=474,
        routing_v4=RoutingInformation(gateway="10.44.83.145/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3901", ip_prefix_length=120
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.44.83.167",
        # v6="2A00:8A00:6000:607c::3A44",
        vlan_id=475,
        routing_v4=RoutingInformation(gateway="10.44.83.161/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3A01", ip_prefix_length=120
        # ),
    ),
    global_bts_id=50250,
    instance_id=50250,
)

_pdu_gnb = Gude(
    addr="10.44.205.237",
    port_numbers=[9],
    model="EPC",
    version="8220-1",
)

_pdu_gnb_ru = Gude(
    addr="0.0.0.0",  # need to fill!
    port_numbers=[11],
    model="EPC",
    version="8220-1",
)

_gnb_ru = RU(
    ru_hw_group="AEUB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[11],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

# _abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

# _abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master],
    pdu_port=_pdu_gnb.pdu_ports[9],
    hardware_type="ASIK",
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])


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
        v4="10.44.83.199",
        vlan_id=477,
    ),
    oam_ip=NetworkAddress(
        v4="10.44.83.183",
        vlan_id=476,
        routing_v4=RoutingInformation(gateway="10.44.83.177/26"),
        # username="Nemuadmin",
        # password="nemuuser",
    ),
    f1_m_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3B44",
        v4="10.44.83.183",
        vlan_id=476,
    ),
    f1_u_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3D44",
        v4="10.44.83.215",
        vlan_id=478,
    ),
    f1_c_cu=NetworkAddress(
        v4="10.44.83.103",
        # v6="2A00:8A00:6000:607c::3C00",
        vlan_id=471,
        routing_v4=RoutingInformation(gateway="10.44.83.97/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
        # ),
    ),
    f1_m_cu=NetworkAddress(
        v4="10.44.83.87",
        # v6="2A00:8A00:6000:607c::3B00",
        vlan_id=470,
        routing_v4=RoutingInformation(gateway="10.44.83.81/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
        # ),
    ),
    f1_u_cu=NetworkAddress(
        v4="10.44.83.135",
        # v6="2A00:8A00:6000:607c::3D00",
        vlan_id=473,
        routing_v4=RoutingInformation(gateway="10.44.83.129/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
        # ),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=50250,
    instance_id=50251,
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
    global_bts_id=40292,
    instance_id=40292,
    x2_link_addr=NetworkAddress(
        v4="10.44.83.123",
        # v6="2A00:8A00:6000:607c::3715",
        vlan_id=472,
        routing_v4=RoutingInformation(gateway="10.44.83.113/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3701", ip_prefix_length=120
        # ),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        v4="10.44.83.75",
        # v6="2A00:8A00:6000:607c::3415",
        vlan_id=469,
        routing_v4=RoutingInformation(gateway="10.44.83.65/26"),
        # routing_v6=RoutingInformation(
        #     gateway="2A00:8A00:6000:607c::3401", ip_prefix_length=120
        # ),
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
    vnf_name="tl184",
    dcap=_dcap,
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

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.121", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp"),
    ],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.28", username="ute", password="ute"
    )
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
