__maintainer__ = "Tomasz Korzekwa"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_UTE_CORE_5G@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.gnb import CloudBts, CU
from taf.compatibility.configuration import TestlineWrapper


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.19", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="2A00:8A00:6000:607c::e07",
        username="wrsroot",
        tenant="admin",
        password="uteadmin",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::e07", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cbts_flavor = DeploymentFlavorStack(
    name="c2000_T01_flavor",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="c2000_T01",
)

_cbts_net = DeploymentNetworkStack(
    name="c2000_T01_ext_net",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="c2000_T01_deploy",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_bts.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="2A00:8A00:6000:607c::d07",
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::d07", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::d07", username="Nemuadmin", password="nemuuser"
    ),
)

_cbts = CloudBts(cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="c2000t01")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_BB3_AIO",
    cloud_hostings=[_ncir],
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
