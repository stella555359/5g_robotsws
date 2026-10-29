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
    addr="10.44.206.77",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.206.78",
    port_numbers=[1, 3],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.140.6",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.139.11", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.140.6", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.29.134",
        vlan_id=549,
        routing_v4=RoutingInformation(gateway="10.255.29.129/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.29.6",
        vlan_id=548,
        routing_v4=RoutingInformation(gateway="10.255.29.1/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.25.6",
        vlan_id=568,
        routing_v4=RoutingInformation(gateway="10.255.25.1/25"),
    ),
    f1u=NetworkAddress(
        v4="10.255.24.134",
        vlan_id=567,
        routing_v4=RoutingInformation(gateway="10.255.24.129/25"),
    ),
    ngc=NetworkAddress(
        v4="10.44.81.6",
        vlan_id=561,
        routing_v4=RoutingInformation(gateway="10.44.81.1/25"),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.6",
        vlan_id=560,
        routing_v4=RoutingInformation(gateway="10.42.220.1/25"),
    ),
    tracing=None,
    global_bts_id=869901,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.11", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.11", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8699", master_node=_vcu_master_node)

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
    radio_type = "AZQG",
    ru_hw_group="cMAA_Gen4.0_8T8R",
    pdu_port=_pdu2.pdu_ports[3],
    serial_number="L1193014019",
    )

_ru_2 = RU(
    radio_type = "AZQI",
    ru_hw_group="cMAAr6.1_8T8R",
    pdu_port=_pdu2.pdu_ports[1],
    serial_number="1M210806863",
    )

_ru_3 = RU(
    radio_type = "AZQO",
    ru_hw_group="cMAAr6.1_8T8R",
    pdu_port=_pdu1.pdu_ports[1],
    serial_number="1M204844249",
    )

_rannic_0 = RANNIC(
    serial_number = "L1240809144",
    product_code = "AF1791.101",
    rus = [_ru_1, _ru_2, _ru_3],
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
    addr="10.42.139.11", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.11", username="core", password="system123", port=22
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
    addr="10.42.139.138", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_0],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.10",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.138",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/25"),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8699",
    instance_id=8699, # parameter to do depricated!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.16",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

vcu_server_mgmt = SshServiceDetails(
        addr="10.42.138.36",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.42.138.36",
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
