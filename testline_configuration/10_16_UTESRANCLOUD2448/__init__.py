__maintainer__ = "Roscislaw Szuminski"
__team__ = "MN_RAN_Pz_3_WRO_03&01"
__email__ = "roscislaw.szuminski@nokia.com"

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
from taf.config.testline.core import RealCore
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import VDU, FHGW
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.pdu import Gude

# from taf.config.testline.nms import NMS
# from taf.config.testline.nom import NOM

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu = Gude(
    addr="10.44.206.90",
    port_numbers=[2, 4, 7],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu]

_control = ControlNode(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.138.182", username="core", password="system123"
    ),
    open_stack_connection_details=OpenStackConnectionDetails(
        username="core",
        password="system123",
        ip_addr="10.42.139.52",
        tenant="cran8888",
    ),
    # Configuration for BMC access if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_17")

_vcu_intnet_1 = DeploymentNetworkStack(
    name="aic-vcu-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vcu_vnf_1 = DeploymentVnfStack(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_vdu_values_override_0.yaml"
    ),
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.91.162",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.162", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.93.187", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.10.61",
        vlan_id=762,
        routing_v4=RoutingInformation(gateway="10.255.10.1", ip_prefix_length=24),
    ),
    xnc=NetworkAddress(
        v4="10.45.187.187",
        vlan_id=767,
        routing_v4=RoutingInformation(gateway="10.45.187.128", ip_prefix_length=25),
    ),
    f1c=NetworkAddress(
        v4="10.255.11.59",
        vlan_id=763,
        routing=RoutingInformation(gateway="10.255.11.1", ip_prefix_length=24),
    ),
    f1u=NetworkAddress(
        v4="10.255.10.61",
        vlan_id=762,
        routing=RoutingInformation(gateway="10.255.10.1", ip_prefix_length=24),
    ),
    ngc=NetworkAddress(
        v4="10.45.187.187",
        vlan_id=767,
        routing=RoutingInformation(gateway="10.45.187.129", ip_prefix_length=25),
    ),
    ngu=NetworkAddress(  # ??
        v4="",
        vlan_id=560,
        routing=RoutingInformation(gateway="10.42.220.1", ip_prefix_length=24),
    ),
    tracing=None,
    global_bts_id=888801,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.91.162", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.91.162", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran888801", master_node=_vcu_master_node)

# _cluster_preparation_cu = HelmChart(
#     name="aic-vcu-cluster-preparation",
#     yaml_file=os.path.join(
#         _cfg_dir, "common_helm_values/values-override.aic-vcu-cluster-preparation.yaml"
#     ),
# )
#
# _prerequisite_cu = HelmChart(
#     name="aic-vcu-prerequisite",
#     yaml_file=os.path.join(
#         _cfg_dir, "common_helm_values/values-override.aic-vcu-prerequisite.yaml"
#     ),
# )
#
# _cnf_cu = HelmChart(
#     name="aic-vcu",
#     yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vcu.yaml"),
# )

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    # cluster_preparation=_cluster_preparation_cu,
    # prerequisite=_prerequisite_cu,
    # cnf=_cnf_cu,
)

_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu.pdu_ports[2],
    serial_number="BL1934G10W1",
)

_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu.pdu_ports[4],
    serial_number="BL1934G10WK",
)

_ru_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    pdu_port=_pdu.pdu_ports[7],
    serial_number="L1174816563",
)

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2, _ru_3],
    # pxe_server=_pxe_server,
    fhgw_id=8888,
)

_fhgw_0.ssh_username = "toor4nsn"
_fhgw_0.ssh_password = "Fhgw@nokia1243"

_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.52", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.52", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran10", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/values-override.aic-vdu-cluster-preparation.yaml"
    ),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/values-override.aic-vdu-prerequisite.yaml"
    ),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, "common_helm_values/values-override.aic-vdu.yaml"),
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.161", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.33",
        vlan_id=566,
        routing=RoutingInformation(gateway="10.255.24.1", ip_prefix_length=25),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.167",
        vlan_id=565,
        routing=RoutingInformation(gateway="10.255.23.129", ip_prefix_length=25),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="8888",
    instance_id="8888",
)

# _pxe_server_ssh_info = SshServiceDetails(
#     addr="", username="", password=""
# )
# _pxe_server = PxeServer(
#     nfs_ip="", ssh_connection_details=_pxe_server_ssh_info
# )

# _realcore = RealCore(five_g=None, mcc="", mnc="", pdns=None)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.250.243",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_ncir],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_2xAHLOA_AHCA",
    #    core=_realcore,
    pdus=_pdus,
)

__all__ = ["tl"]
