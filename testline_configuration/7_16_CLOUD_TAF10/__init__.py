__maintainer__ = "TAF"
__team__ = "MN 5G RAN I&V 3 Pz Autom 1 SG"
__email__ = "I_CV_WRO_AUTOTEAM@internal.nsn.com"
__owner_email__ = "I_CV_WRO_AUTOTEAM@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    BmcConnectionDetails,
    OpenStackConnectionDetails,
)
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.cloud_hosting import (
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    NCIR,
    ControlNode,
)


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.189", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.73.78", vlan_id=798),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.73.78", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.73.78", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_cbts_flavor = DeploymentFlavorStack(
    name="TAF_10_S6_flavor",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="TAF_10_S6_prefix",
)

_cbts_net = DeploymentNetworkStack(
    name="TAF_10_S6_net",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TAF_10_S6_deploy",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_bts.yaml"),
)

_control = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.149.37", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.37", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.149.37", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_18")

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cbts = CloudBts(cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="c02610")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_BB3",
    cloud_hostings=[_ncir],
)

__all__ = ["tl"]
