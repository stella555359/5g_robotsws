__maintainer__ = "EIT Timisoara"
__team__ = "I_BOAM_CU_PES_TIM"
__email__ = "I_BOAM_CU_PES_TIM@internal.nsn.com"


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
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import NetworkAddress

# from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline import DU


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.25.222", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.5.62.18",
        username="admin",
        tenant="cloudadmin",
        password="system123",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.62.18", username="cloudadmin", password="system123"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_18")

flavor_env_files = [os.path.join(_CFG_DIR, "5gbts_flavor.env")]

net_env_files = [os.path.join(_CFG_DIR, "config_ext_net_dummy.env")]

vnf_env_files = [
    os.path.join(_CFG_DIR, "5gbts_heat.env"),
    os.path.join(_CFG_DIR, "5gbts_heat_coam211.env"),
]

_cbts_flavor = DeploymentFlavorStack(
    name="coam211_flavor",
    env_files=flavor_env_files,
    yaml_file=os.path.join(_CFG_DIR, "5gbts_flavor.yaml"),
    default_vnf_prefix="coam211",
)

_cbts_net = DeploymentNetworkStack(
    name="coam211_ext_net",
    env_files=net_env_files,
    yaml_file=os.path.join(_CFG_DIR, "5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="coam211",
    env_files=vnf_env_files,
    yaml_file=os.path.join(_CFG_DIR, "5gbts_heat.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.5.63.211", vlan_id=2005),
    f1m=NetworkAddress(v4="10.5.63.161/26", vlan_id=2004),
    f1c=NetworkAddress(v4="10.5.63.161/26", vlan_id=2004),
    x2c=NetworkAddress(v4="10.5.63.48/27", vlan_id=2002),
    s1c=NetworkAddress(v4="", vlan_id=2001),
    f1u=NetworkAddress(v4="10.5.63.171", vlan_id=2004),
    x2u=NetworkAddress(v4="10.5.63.56/26", vlan_id=2002),
    s1u=NetworkAddress(v4="10.5.63.56/26", vlan_id=2001),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.5.63.211", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.5.63.211", username="Nemuadmin", password="nemuuser"
    ),
)

_abil_du1 = CapacityUnit(addr="")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="", username="toor4nsn"),
    capacity_units=[_abil_du1],
)

_du1 = DU(Airscale(common_units=[_asik_du1]))

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="coam211", dus=[_du1]
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ASIKR_ABILB4_AEUD",
)
# tl = TestlineWrapper(tl)

__all__ = ["tl"]
