__maintainer__ = ""
__team__ = ""
__email__ = "@internal.nsn.com"

import os
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
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
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore4G, LTEEmuCore
from taf.compatibility.configuration import TestlineWrapper

__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.21", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_controlNode = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.149.37", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.37", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.233", username="admin", password="admin"
    ),
)

# _computeNode = ComputeNode(
#     bmc_connection_details=BmcConnectionDetails(addr='10.44.196.230',
#                                                 username='admin',
#                                                 password='admin'))

_ncir = NCIR(compute_nodes=[], control_nodes=[_controlNode], version="ncir_18")

_cbts_flavor = DeploymentFlavorStack(
    name="7_16_CLOUD1900T01_FLAVOR",
    env_files=[os.path.join(cfg_dir, "config_flavor.env")],
    yaml_file=os.path.join(cfg_dir, ""),
    default_vnf_prefix="c026t01",
)

_cbts_net = DeploymentNetworkStack(
    name="7_16_CLOUD1900T01_EXT_NET",
    env_files=[os.path.join(cfg_dir, "config_ext_net.env")],
    yaml_file=os.path.join(cfg_dir, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_16_CLOUD1900T01_BTS",
    env_files=[os.path.join(cfg_dir, "config_bts.env")],
    yaml_file=os.path.join(cfg_dir, ""),
)

os.path.join(cfg_dir, "config_bts.env"), os.path.join(cfg_dir, "config_bts.env")

_cloud_deployment = CloudDeployment(
    default_cfg_dir=cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)


_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4A04",
        vlan_id=776,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4A01", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::1:4A04", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::1:4A04"
    ),
    f1m=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4B04",
        vlan_id=777,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4B01", ip_prefix_length=120
        ),
    ),
    f1c=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4C04",
        vlan_id=778,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4C01", ip_prefix_length=120
        ),
    ),
    x2c=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4D04",
        vlan_id=779,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4C01", ip_prefix_length=120
        ),
    ),
    s1c=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4D05",
        vlan_id=779,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4D01", ip_prefix_length=120
        ),
    ),
)

_cbts = CloudBts(
    cu=_cu_gnb_1,
    cloud_deployment=_cloud_deployment,
    vnf_name="C026T01",
    global_bts_id=1900,
    instance_id=1900,
)

_tl_cloud_topology = "CLOUD_5G_BB3"

_tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology=_tl_cloud_topology,
)

tl = TestlineWrapper(_tl)
