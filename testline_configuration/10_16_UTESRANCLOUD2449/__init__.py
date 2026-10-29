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
    addr="10.44.206.85",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.140.15",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.69.131", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.140.15", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.29.143",
        vlan_id=549,
        routing_v4=RoutingInformation(gateway="10.255.29.129/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.29.15",
        vlan_id=548,
        routing_v4=RoutingInformation(gateway="10.255.29.1/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.25.15",
        vlan_id=568,
        routing_v4=RoutingInformation(gateway="10.255.25.1/25"),
    ),
    f1u=NetworkAddress(
        v4="10.255.24.143",
        vlan_id=567,
        routing_v4=RoutingInformation(gateway="10.255.24.129/25"),
    ),
    ngc=NetworkAddress(
        v4="10.44.81.15",
        vlan_id=561,
        routing_v4=RoutingInformation(gateway="10.44.81.1/25"),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.15",
        vlan_id=560,
        routing_v4=RoutingInformation(gateway="10.42.220.1/25"),
    ),
    tracing=None,
    global_bts_id=852801,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.69.131", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.69.131", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8528", master_node=_vcu_master_node)

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
    radio_type = "AZQS",
    ru_hw_group="cMAAr6.1_8T8R",
    pdu_port=_pdu1.pdu_ports[11],
    serial_number="1M213113938",
    )

_rannic_0 = RANNIC(
    serial_number = "L1242202598",
    product_code = "AF1791.102",
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
    addr="10.42.139.8", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.8", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.135", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_0],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.7",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.135",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/25"),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8528",
    instance_id=8528, # parameter to do depricated!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.16",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

# vCU is on cluster - below are details of all 3 master nodes
# HPE.7.3.vcu
vcu_server_mgmt_0 = SshServiceDetails(
        addr="10.42.138.4",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# HPE.7.2.vcu
vcu_server_mgmt_1 = SshServiceDetails(
        addr="10.42.138.3",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# HPE.7.1.vcu
vcu_server_mgmt_2 = SshServiceDetails(
        addr="10.42.138.2",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.42.138.33",
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
