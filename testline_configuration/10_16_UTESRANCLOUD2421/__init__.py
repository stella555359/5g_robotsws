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
    port_numbers=[2,4,7],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu]

# ******************************************************vCU1-888701******************************************************

_vcu888701_intnet_1 = DeploymentNetworkStack(
    name="aic-vcu-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vcu888701_vnf_1 = DeploymentVnfStack(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_vdu_values_override_0.yaml"
    ),
)

_cu888701 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.102.26",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.102.167", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.102.26", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.47.88",
        vlan_id=604,
        routing_v4=RoutingInformation(gateway="10.255.47.0/24"),
    ),
    xnc=NetworkAddress(
        v4="10.255.46.88",
        vlan_id=603,
        routing_v4=RoutingInformation(gateway="10.255.46.64/26"),
    ),
    f1c=NetworkAddress(
        v4="10.255.46.24",
        vlan_id=602,
        routing=RoutingInformation(gateway="10.255.46.0/26"),
    ),
    f1u=NetworkAddress(
        v4="10.255.45.88",
        vlan_id=601,
        routing=RoutingInformation(gateway="10.255.45.0/24"),
    ),
    ngc=NetworkAddress(
        v4="10.42.102.88",
        vlan_id=598,
        routing=RoutingInformation(gateway="10.42.102.64/26"),
    ),
    ngu=NetworkAddress(
        v4="10.42.100.88",
        vlan_id=600,
        routing=RoutingInformation(gateway="10.45.100.0/24"),
    ),
    tracing=None,
    global_bts_id=888701,
)

_vcu888701_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.102.167", username="core", password="system123"
)

_vcu888701_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.102.167", username="core", password="system123", port=22
)

_vcu888701_master_node = MasterNode(
    k8s_connection_details=_vcu888701_k8s_connection_details,
    ssh_connection_details=_vcu888701_k8s_ssh_connection_details,
)

_vcu888701_k8s = K8S(namespace="cran888701", master_node=_vcu888701_master_node)

_cluster_preparation_cu888701 = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-cluster-preparation.yaml'),
)

_prerequisite_cu888701 = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-prerequisite.yaml'),
)

_cnf_cu888701 = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu.yaml'),
)

_vcu888701_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu888701_k8s,
    cluster_preparation=_cluster_preparation_cu888701,
    prerequisite=_prerequisite_cu888701,
    cnf=_cnf_cu888701,
)

# ******************************************************vCU2-888702******************************************************

_vcu888702_intnet_1 = DeploymentNetworkStack(
    name="aic-vcu-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vcu888702_vnf_1 = DeploymentVnfStack(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_vdu_values_override_0.yaml"
    ),
)

_cu888702 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.102.22",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.102.162", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.102.22", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.47.86",
        vlan_id=604,
        routing_v4=RoutingInformation(gateway="10.255.47.0/24"),
    ),
    xnc=NetworkAddress(
        v4="10.255.46.86",
        vlan_id=603,
        routing_v4=RoutingInformation(gateway="10.255.46.64/26"),
    ),
    f1c=NetworkAddress(
        v4="10.255.46.22",
        vlan_id=602,
        routing=RoutingInformation(gateway="10.255.46.0/26"),
    ),
    f1u=NetworkAddress(
        v4="10.255.45.86",
        vlan_id=601,
        routing=RoutingInformation(gateway="10.255.45.0/24"),
    ),
    ngc=NetworkAddress(
        v4="10.42.102.86",
        vlan_id=598,
        routing=RoutingInformation(gateway="10.42.102.64/26"),
    ),
    ngu=NetworkAddress(
        v4="10.42.100.86",
        vlan_id=600,
        routing=RoutingInformation(gateway="10.45.100.0/24"),
    ),
    tracing=None,
    global_bts_id=888702,
)

_vcu888702_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.102.162", username="core", password="system123"
)

_vcu888702_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.102.162", username="core", password="system123", port=22
)

_vcu888702_master_node = MasterNode(
    k8s_connection_details=_vcu888702_k8s_connection_details,
    ssh_connection_details=_vcu888702_k8s_ssh_connection_details,
)

_vcu888702_k8s = K8S(namespace="cran888702", master_node=_vcu888702_master_node)

_cluster_preparation_cu888702 = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-cluster-preparation.yaml'),
)

_prerequisite_cu888702 = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-prerequisite.yaml'),
)

_cnf_cu888702 = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu.yaml'),
)

_vcu888702_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu888701_k8s,
    cluster_preparation=_cluster_preparation_cu888702,
    prerequisite=_prerequisite_cu888702,
    cnf=_cnf_cu888702,
)

# **********************************************************RU***********************************************************

_ru_1 = RU(
    ru_hw_group="cMAAr6.2_8T8R",
    pdu_port=_pdu.pdu_ports[2],
    serial_number="BL1934G10W1",
)

# *******************************************************vDU-8887********************************************************

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
    addr="10.42.139.33", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.33", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu-cluster-preparation.yaml'),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu.yaml'),
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.162", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.34",
        vlan_id=566,
        routing=RoutingInformation(gateway="10.255.24.0/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.176",
        vlan_id=565,
        routing=RoutingInformation(gateway="10.255.23.128/25"),
    ),
    instance_id=1,
)

_cbts888701 = CloudBts(
    dus=[_vdu],
    cu=_cu888701,
    cloud_deployment=_vcu888701_k8s_cloud_deployment,
    vnf_name="8887",
    instance_id="8887",
)

_cbts888702 = CloudBts(
    dus=[_vdu],
    cu=_cu888702,
    cloud_deployment=_vcu888702_k8s_cloud_deployment,
    vnf_name="8887",
    instance_id="8887",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.33",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts888701, _cbts888702],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu888701_k8s, _vcu888702_k8s],
    gnbs=[_cbts888701, _cbts888702],
    tl_cloud_topology="CLOUD_5G_2xAHLOA_AHCA",
#    core=_realcore,
    pdus=_pdus,
)

__all__ = ["tl"]

