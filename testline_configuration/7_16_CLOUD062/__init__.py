__maintainer__ = "Siwa Damian"
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
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.compatibility.configuration import TestlineWrapper

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
control = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.244", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.244", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.134", username="admin", password="admin"
    ),
)

ncir = NCIR(compute_nodes=[], control_nodes=[control], version="ncir_17a")

host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.83", username="ute", password="ute"
    )
)

lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.83", username="ute", password="ute"
    ),
    dir_path="/opt/lteemu",
    cfg_filename="basic_cfg_LteEmu.cfg",
    mme_ip="192.168.4.134",
    mcc=-1,
    mnc=-1,
    tac=-1,
    edaemon_port=22222,
    egate_port=10000,
)

cbts_flavor = DeploymentFlavorStack(
    name="tl62_flavor",
    env_files=[os.path.join(cfg_dir, "config_flavor.env")],
    yaml_file=os.path.join(cfg_dir, "config_flavor.yaml"),
    default_vnf_prefix="tl62_prefix",
)

cbts_net = DeploymentNetworkStack(
    name="tl62_net",
    env_files=[os.path.join(cfg_dir, "config_ext_net.env")],
    yaml_file=os.path.join(cfg_dir, "config_ext_net.yaml"),
)

cbts_vnf = DeploymentVnfStack(
    name="tl62_deploy",
    env_files=[os.path.join(cfg_dir, "config_bts.env")],
    yaml_file=os.path.join(cfg_dir, "config_bts.yaml"),
)

cu = CU(
    backhaul_site_oam_ip="2A00:8A00:6000:607c::3414",
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::3414", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="2A00:8A00:6000:607c::3414"),
)

cloud_deployment = CloudDeployment(
    default_cfg_dir=cfg_dir,
    flavors=[cbts_flavor],
    networks=[cbts_net],
    vnfs=[cbts_vnf],
    cloud_hosting=ncir,
)

cbts = CloudBts(cu=cu, cloud_deployment=cloud_deployment, vnf_name="tl62")

tl_cloud_topology = "CLOUD_5G_LB_ASIKA101_ABILA102"

tl = TestLine(
    test_pc=host,
    gnbs=[cbts],
    cloud_hostings=[ncir],
    core=lteemu,
    tl_cloud_topology=tl_cloud_topology,
)

tl = TestlineWrapper(tl)
