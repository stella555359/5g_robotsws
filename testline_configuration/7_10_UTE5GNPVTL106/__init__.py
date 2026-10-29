__maintainer__ = "Piotr Brzezicki"
__team__ = "5G_PZ_MMW_KRK_6_SG"
__email__ = "piotr.brzezicki@nokia.com"

import os
import yaml

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
    ComputeNode,
)
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline import (
    DU,
    RU,
    RoutingInformation,
    RealCore5G,
    RealEnb,
    NetworkAddress,
    SyncInputSource,
)
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_5g_bts_id = 106
_4g_bts_id = 106

_ncir_vnf = "5gbts" + str(_5g_bts_id)

# HD15
_ncir_ip = "10.52.201.223"
_ncir_user = "swenguser1"
_ncir_pass = "Scp@dm1!"
_ncir_tenant = "5gtenant1"

_cu_m_ip = NetworkAddress(
    v6="2a00:8a00:2000:4901::184",
    routing_v6=RoutingInformation(
        gateway="2a00:8a00:2000:4901::015f", ip_prefix_length=64
    ),
)


_du_m_ip = NetworkAddress(
    v6="2a00:8a00:2000:4901::19e",
    routing_v6=RoutingInformation(
        gateway="2a00:8a00:2000:4901::19f", ip_prefix_length=124
    ),
)

_du_m_route_cu = NetworkAddress(
    routing_v4=RoutingInformation(
        gateway="2a00:8a00:2000:4901::19f", ip_prefix_length=0
    )
)

_4g_ip = NetworkAddress(v6="2a00:8a00:2000:4901::1be")

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.52.200.153",
        username="ute",
        password="ute",
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr=_ncir_ip,
        username=_ncir_user,
        tenant=_ncir_tenant,
        password=_ncir_pass,
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr=_ncir_ip, username=_ncir_user, password=_ncir_pass
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password="")
)

_ncir = NCIR(compute_nodes=[_compute], control_nodes=[_control_0], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_10_UTE5GNPVTL106_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    default_vnf_prefix=_ncir_vnf,
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_10_UTE5GNPVTL106_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_10_UTE5GNPVTL106_BTS",
    env_files=[os.path.join(_CFG_DIR, "5gbts_heat.env")],
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip=_cu_m_ip,
    oam_ssh_connection_details=SshServiceDetails(
        addr=_cu_m_ip.v6, username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr=_cu_m_ip.v6, username="Nemuadmin", password="nemuuser"
    ),
    instance_id=_5g_bts_id,
    global_bts_id=_5g_bts_id,
)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    sync_input=SyncInputSource(),
)

_ru_du1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(addr="", username=""),
    lmp_connection=SshServiceDetails(addr="", username=""),
    radio_type="AEWB",
)


_du1 = DU(
    Airscale(common_units=[_asik_du1]),
    instance_id=_5g_bts_id,
    global_bts_id=_5g_bts_id,
    rus=[_ru_du1],
    oam_ip=_du_m_ip,
    f1_c_ip_addr=_du_m_ip,
    f1_u_ip_addr=_du_m_ip,
    f1_m_cu=_du_m_route_cu,
)

_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_cloud_deployment,
    vnf_name=_ncir_vnf,
    dus=[_du1],
    instance_id=_5g_bts_id,
    global_bts_id=_5g_bts_id,
)

_enb = RealEnb(
    oam_ip=_4g_ip,
    instance_id=_4g_bts_id,
    global_bts_id=_4g_bts_id,
    x2_link_addr=_4g_ip,
)

_core = RealCore5G(mcc=1, mnc=1)


def _set_abstract_lib_config_env(ue_config_file):
    tl_config_dir = os.path.dirname(os.path.abspath(__file__))
    ue_config_abs_path = os.path.join(tl_config_dir, ue_config_file)

    with open(ue_config_abs_path) as ta_ue_config:
        ue_config = yaml.safe_load(ta_ue_config)

    os.environ["ABSTRACT_LIB_CONFIG"] = ue_config_abs_path

    return ue_config


_ue_config = _set_abstract_lib_config_env("ue_config.yaml")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ANDROID_ASOD_AEWB",
    enbs=[_enb],
)

__all__ = ["tl"]
