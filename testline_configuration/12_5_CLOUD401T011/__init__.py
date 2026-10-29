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
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import DU, VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit


__maintainer__ = "Xie Yunyi"
__team__ = "MN BOAM RD O&M OSS&EMS EIT HZH SG"
__email__ = "I_NSB_MN_BTSOAM_RD_OM_OSSEMS_EIT@nokia.com"
__owner_email__ = "yunyi.xie@nokia-sbell.com"

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# ##########Control PC#########################################################
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.0.92.7", username="ute", password="ute"
    )
)

# #########NCIR################################################################
# CU related NCIR controlNode
_control = ControlNode(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.101.90", username="user666", password="Cu_test456!"
    ),
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.56.101.90",
        username="user666",
        password="Cu_test456!",
        port=5000,
        tenant="USER666",
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

# CU related NCIR/OSP
_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_19")

# flavor of CU
_cbts_flavor = DeploymentFlavorStack(
    name="ossems-tl011-flavor",
    env_files=[os.path.join(_cfg_dir, "5gbts_flavor.env")],
    yaml_file=os.path.join(_cfg_dir, "5gbts_flavor.yaml"),
    default_vnf_prefix="ossems-tl011-flavor",
)

# ext_net of CU
_cbts_net = DeploymentNetworkStack(
    name="ossems-tl011-int",
    env_files=[os.path.join(_cfg_dir, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_cfg_dir, "5gbts_ext_net.yaml"),
)

# heat parameters
_cbts_vnf = DeploymentVnfStack(
    name="ossems-tl011",
    env_files=[os.path.join(_cfg_dir, "5gbts_heat.env")],
    yaml_file=os.path.join(_cfg_dir, "5gbts_heat.yaml"),
)

# cloud deployment configuration for CU
_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

# ##########CU################################################################
_cu_oam_ip = "10.108.201.207"
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4=_cu_oam_ip),
    oam_ssh_connection_details=SshServiceDetails(
        addr=_cu_oam_ip, username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr=_cu_oam_ip, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.97.122.0",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.110.101.1", ip_prefix_length=24),
    ),
    f1c=NetworkAddress(
        v4="10.71.171.8",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.110.100.1", ip_prefix_length=29),
    ),
    f1u=NetworkAddress(
        v4="10.71.171.8",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.110.100.1", ip_prefix_length=29),
    ),
    tracing=None,
)

# #########ENB for NSA#########################################################
_real_enb = RealEnb(
    oam_ip="10.97.122.232",
    x2_link_addr=NetworkAddress(
        v4="", vlan_id=None, routing=RoutingInformation(gateway="", ip_prefix_length=29)
    ),
    instance_id="",
)

# ##########classical DU#######################################################
_lmp_connection_0 = SshServiceDetails(
    addr="10.108.231.48", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.18")

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection_0, capacity_units=[_capacity_unit_0], pdu_port=None
)

_airscale_0 = Airscale(common_units=[_common_unit_0])

_du_0 = DU(airscale=_airscale_0, f1_m_ip_addr="", f1_c_ip_addr="", f1_u_ip_addr="")

# ##########vDU#############################################################
# vDU configuration for deployment
_vdu_vnf_1 = DeploymentVnfStack(
    name="aic-vdu-mvp", yaml_file=os.path.join(_cfg_dir, "aic-vdu-values-override.yaml")
)

# vDU internal network configuration for deployment
_vdu_intnet_1 = DeploymentNetworkStack(
    name="aic-intnet-mvp",
    yaml_file=os.path.join(_cfg_dir, "aic-intnet-values-override.yaml"),
)

# ssh connection information of OE, for tenant user
_ssh_connection_details = SshServiceDetails(
    addr="10.69.246.82", username="cranuser1", password="systeM!23"
)

# ssh connection information of OE, for cloudadmin user
_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.69.246.82", username="cloudadmin", password="system123", port="22"
)

# master node information of OE
_master_node = MasterNode(
    k8s_connection_details=_k8s_connection_details,
    ssh_connection_details=_ssh_connection_details,
)

_k8s = K8S(namespace="cran1", master_node=_master_node)

# vDU deployment configuration
_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_1],
    vnfs=[_vdu_vnf_1],
    cloud_hosting=_k8s,
)

# vDU oam http connection
_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.69.246.98", port="443", username="nemuadmin", password="nemuadmin"
)

# RU configuration
_ru_1 = RU(ru_hw_group="RU_INT_CPRI", serial_number="L1181016004")

# PXE server info for FHGW deployment
_pxe_server_ssh_info = SshServiceDetails(
    addr="10.68.179.27", username="root", password="centos"
)
_pxe_server = PxeServer(
    nfs_ip="10.68.179.27", ssh_connection_details=_pxe_server_ssh_info
)

# FHGW information
_fhgw_1 = FHGW(
    user_config_path=os.path.join(_cfg_dir, "user_config_0.yaml"),
    rus=[_ru_1],
    pxe_server=_pxe_server,
)

# vDU global configuration
_vdu_1 = VDU(
    cloud_deployment=_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_1],
    f1_m_ip_addr=NetworkAddress(
        v4="10.69.246.90",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.246.89", ip_prefix_length=29),
    ),
    f1_c_ip_addr=NetworkAddress(
        v4="10.69.246.90",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.246.89", ip_prefix_length=29),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.69.246.92",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.246.89", ip_prefix_length=29),
    ),
)

# ##########Cloud BTS##########################################################
_cbts = CloudBts(
    dus=[_du_0, _vdu_1],  # vdu related parameter
    cu=_cu,
    cloud_deployment=_cloud_deployment,
    instance_id="8298",
    global_bts_id="1",
)

# #########Testline############################################################
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_real_enb],
    tl_cloud_topology="CLOUD_5G_AIC_NCIR_NoneUE_NSA_1xVDU__OE19_FHGW_1xAHCA",
    cloud_hostings=[_ncir],
)

# only tl variable can be accessed by user
__all__ = ["tl"]
