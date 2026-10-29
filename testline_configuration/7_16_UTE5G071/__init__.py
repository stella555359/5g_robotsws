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
from taf.config.testline.gnb.du import Cablink, Endpoint, VDU
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# _lmp_vm_gnb_2 = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.42.53.11", username="ute", password="ute"
#     )
# )
cfg_dir = os.path.dirname(os.path.abspath(__file__))

_controlNode = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.181.191", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.181.191", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.210.208", username="admin", password="admin"
    ),
)
_ncir = NCIR(compute_nodes=[], control_nodes=[_controlNode], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="7_16_UTE5G071_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="tl071",
)

_cbts_net = DeploymentNetworkStack(
    name="7_16_UTE5G071_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_16_UTE5G071_BTS",
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
        v4="10.44.81.6",
        # v6="2A00:8A00:6000:607c::3414",
        vlan_id=411,
        routing_v4=RoutingInformation(gateway="10.44.81.1/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3401", ip_prefix_length=120
        # ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.81.6", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.81.6", port=443, username="Nemuadmin", password="nemuuser"
    ),
    f1m=NetworkAddress(
        v4="10.44.81.21",
        # v6="2A00:8A00:6000:607c::3514",
        vlan_id=412,
        routing_v4=RoutingInformation(gateway="10.44.81.17/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
        # ),
    ),
    f1c=NetworkAddress(
        v4="10.44.81.37",
        # v6="2A00:8A00:6000:607c::3614",
        vlan_id=413,
        routing_v4=RoutingInformation(gateway="10.44.81.33/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
        # ),
    ),
    f1u=NetworkAddress(
        v4="10.44.81.69",
        # v6="2A00:8A00:6000:607c::3814",
        vlan_id=415,
        routing_v4=RoutingInformation(gateway="10.44.81.65/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
        # ),
    ),
    x2c=NetworkAddress(
        v4="10.44.81.54",
        # v6="2A00:8A00:6000:607c::3714",
        vlan_id=414,
        routing_v4=RoutingInformation(gateway="10.44.81.49/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3701", ip_prefix_length=120
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.44.81.85",
        # v6="2A00:8A00:6000:607c::3914",
        vlan_id=416,
        routing_v4=RoutingInformation(gateway="10.44.81.81/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3901", ip_prefix_length=120
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.44.81.101",
        # v6="2A00:8A00:6000:607c::3A14",
        vlan_id=417,
        routing_v4=RoutingInformation(gateway="10.44.81.97/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3A01", ip_prefix_length=120
        # ),
    ),
    global_bts_id=50271,
    instance_id=50271,
)

_pdu_gnb = ATEN(addr="10.42.61.189", port_numbers=[2])

_pdu_gnb_ru = ATEN(addr="10.44.206.114", port_numbers=[7])

_gnb_ru = RU(
    ru_hw_group="AEUB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASIK",
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

# NetworkAddress(
#         v4="10.44.81.6",
#         v6="2A00:8A00:6000:607c::3414",
#         vlan_id=411,
#         routing_v4=RoutingInformation(gateway="10.44.81.1", ip_prefix_length=26),
#         routing_v6=RoutingInformation(
#             gateway="2A00:8A00:6000:607c::3401", ip_prefix_length=120
#         ),

_du_1 = DU(
    airscale=_airscale_gnb_1,
    f1_c_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3C14",
        v4="10.44.81.133",
        vlan_id=419,
    ),
    oam_ip=NetworkAddress(
        v4="10.44.81.117",
        vlan_id=418,
        routing_v4=RoutingInformation(gateway="10.44.81.113/26"),
        # username="Nemuadmin",
        # password="nemuuser",
    ),
    f1_m_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3B14",
        v4="10.44.81.117",
        vlan_id=418,
    ),
    f1_u_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3D14",
        v4="10.44.81.149",
        vlan_id=420,
    ),
    f1_c_cu=NetworkAddress(
        v4="10.44.81.128",
        # v6="2A00:8A00:6000:607c::3C00",
        vlan_id=419,
        routing_v4=RoutingInformation(gateway="10.44.81.33/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
        # ),
    ),
    f1_m_cu=NetworkAddress(
        v4="10.44.81.112",
        # v6="2A00:8A00:6000:607c::3B00",
        vlan_id=418,
        routing_v4=RoutingInformation(gateway="10.44.81.17/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
        # ),
    ),
    f1_u_cu=NetworkAddress(
        v4="10.44.81.144",
        # v6="2A00:8A00:6000:607c::3D00",
        vlan_id=420,
        routing_v4=RoutingInformation(gateway="10.44.81.65/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
        # ),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=50271,
    instance_id=50272,
)

_du_2 = DU(
    airscale=_airscale_gnb_1,
    f1_c_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3C04",
        v4="10.44.81.132",
        vlan_id=419,
    ),
    oam_ip=NetworkAddress(
        v4="10.44.81.117",
        vlan_id=418,
        routing_v4=RoutingInformation(gateway="10.44.81.113/26"),
        # username="Nemuadmin",
        # password="nemuuser",
    ),
    f1_m_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3B04",
        v4="10.44.81.116",
        vlan_id=418,
    ),
    f1_u_ip_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3D04",
        v4="10.44.81.148",
        vlan_id=420,
    ),
    f1_c_cu=NetworkAddress(
        v4="10.44.81.128",
        # v6="2A00:8A00:6000:607c::3C00",
        vlan_id=419,
        routing_v4=RoutingInformation(gateway="10.44.81.33/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3601", ip_prefix_length=120
        # ),
    ),
    f1_m_cu=NetworkAddress(
        v4="10.44.81.112",
        # v6="2A00:8A00:6000:607c::3B00",
        vlan_id=418,
        routing_v4=RoutingInformation(gateway="10.44.81.17/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3501", ip_prefix_length=120
        # ),
    ),
    f1_u_cu=NetworkAddress(
        v4="10.44.81.144",
        # v6="2A00:8A00:6000:607c::3D00",
        vlan_id=420,
        routing_v4=RoutingInformation(gateway="10.44.81.65/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3801", ip_prefix_length=120
        # ),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=50271,
    instance_id=50273,
)

_pdu_enb = ATEN(addr="None", port_numbers=[7])

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[7],
    hardware_type="ASIK",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40210,
    instance_id=40210,
    x2_link_addr=NetworkAddress(
        # v6="2A00:8A00:6000:607c::3715",
        v4="10.44.81.55",
        vlan_id=414,
        routing_v4=RoutingInformation(gateway="10.44.81.49/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3701", ip_prefix_length=120
        # ),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        # v6="2A00:8A00:6000:607c::3415",
        v4="10.44.81.7",
        vlan_id=411,
        routing_v4=RoutingInformation(gateway="10.44.81.1/26"),
        # routing_v6=RoutingInformation(
        #    gateway="2A00:8A00:6000:607c::3401", ip_prefix_length=120
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
        # _du_2,
    ],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl071",
    dcap=_dcap,
)

_tl_cloud_topology = "CLOUD_5G_ASIK_ABIL_AEUB_ENB"


# _amf_ssh = SshServiceDetails(
#    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
# )

# _amf_n2_addr = NetworkAddress(
#    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
# )

# _amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)


# _core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=540, mnc=1)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.12", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp"),
    ],
)
_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="ute", password="ute"
    )
)

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
    enbs=[_enb_1],
)

__all__ = ["tl"]
