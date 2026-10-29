__maintainer__ = "Krzysztof Michalek"
__team__ = "MN 5G RAN I&V 3 Pz Autom 1 SG"
__email__ = "I_UTE_CORE_5G@internal.nsn.com"
__owner_email__ = "krzysztof.michalek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline import NetworkAddress
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
    ComputeNode,
)
from taf.config.testline.gnb import CloudBts, CU
from taf.compatibility.configuration import TestlineWrapper


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.68.14", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.181.195", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.181.195", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.2", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_18")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD1500T03_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="cloud028t03",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD1500T03_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD1500T03_BTS",
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
    backhaul_site_oam_ip="10.44.77.70",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.77.70", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.77.70", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.44.77.112", v6=None, vlan_id=828),
)

_cbts = CloudBts(cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="cloud028t03")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_BB3",
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
