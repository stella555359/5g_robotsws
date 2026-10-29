__maintainer__ = "jakub.ozierski@nokia.com"
__email__ = "jakub.ozierski@nokia.com"

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
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import VDU, FHGW, RANNIC
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.pdu import Gude

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.200.7",
    port_numbers=[3, 10],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.93.186",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.147", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.93.186", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.15.57",
        vlan_id=774,
        routing_v4=RoutingInformation(gateway="10.255.15.1/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.14.184",
        vlan_id=773,
        routing_v4=RoutingInformation(gateway="10.255.14.129/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.11.61",
        vlan_id=763,
        routing_v4=RoutingInformation(gateway="10.255.11.1/24"),
    ),
    f1u=NetworkAddress(
        v4="10.255.10.64",
        vlan_id=762,
        routing_v4=RoutingInformation(gateway="10.255.10.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.42.39.236",
        vlan_id=767,
        routing_v4=RoutingInformation(gateway="10.42.39.193/26"),
    ),
    ngu=NetworkAddress(
        v4="10.42.39.171",
        vlan_id=766,
        routing_v4=RoutingInformation(gateway="10.42.39.129/26"),
    ),
    tracing=None,
    global_bts_id=850901,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.91.147", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.91.147", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran85091lcm", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-cluster-preparation.yaml'),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu.yaml'),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_ru_1 = RU(
    radio_type = "AHFIB",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[10],
    serial_number="K9181806843",
    )
    
_ru_2 = RU(
    radio_type = "AHHB",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[3],
    serial_number="EA223855244",
    )

_rannic_0 = RANNIC(
    serial_number = "L1240603825",
    product_code = "AF1791.101",
    rus = [_ru_1],
)

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
    addr="10.42.38.35", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.35", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1lcm", master_node=_vdu_master_node)

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
    addr="10.42.38.227", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_0],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.8.22",
        vlan_id=759,
        routing_v4=RoutingInformation(gateway="10.255.8.1/24"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.9.22",
        vlan_id=760,
        routing_v4=RoutingInformation(gateway="10.255.9.1/24"),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8509",
    instance_id=8509, # parameter to do depricated!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.149.74",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

# vCU is on cluster - below are details of all 3 master nodes
# HPE.vcu5.1
vcu_server_mgmt_0 = SshServiceDetails(
        addr="10.42.142.224",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# HPE.vcu5.1
vcu_server_mgmt_1 = SshServiceDetails(
        addr="10.42.142.225",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# HPE.vcu5.1
vcu_server_mgmt_2 = SshServiceDetails(
        addr="10.42.142.226",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.42.142.195",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    # tl_cloud_topology="CLOUD_5G_FHGW_1vDU_AZQS",
    pdus=_pdus,
)

__all__ = ["tl"]
