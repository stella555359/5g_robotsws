__maintainer__ = "raluca-elena.butcovan@nokia.com"
__email__ = "raluca-elena.butcovan@nokia.com"

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
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude
_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.37", username="ute", password="UTE.debian12"
    ),
    connections=[],
)

_pdu_1 = Gude(
    addr="10.255.2.20",
    port_numbers=[7, 8, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_pdus = [_pdu_1]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.5.12.41",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.5.12.17", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.5.12.41", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.5.12.86",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    xnc=NetworkAddress(
        v4="10.5.12.87",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    f1c=NetworkAddress(
        v4="10.5.12.86",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    f1u=NetworkAddress(
        v4="10.5.12.87",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    ngc=NetworkAddress(
        v4="10.5.12.86",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    ngu=NetworkAddress(
        v4="10.5.12.87",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    tracing=None,
    global_bts_id=62314801,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.12.17", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.12.17", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-cluster-preparation.yaml'),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="vcu-148",
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
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="BL2341C656K",
    pdu_port=_pdu_1.pdu_ports[12],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9182830755",
    pdu_port=_pdu_1.pdu_ports[7],
	
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9183140933",
    pdu_port=_pdu_1.pdu_ports[8],
)


_rannic_0 = RANNIC(
    serial_number = "L1240804824",
    product_code = "AF1791.101",
    rus = [_ru_1, _ru_2, _ru_3],
)

_vdu_vnf_0 = DeploymentVnfStack(
    name="vdu-148",
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
    addr="10.5.12.17", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.12.17", username="core", password="system123", port=22
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
    name="vdu-148",
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
    addr="10.5.12.40", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_0],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[],
    f1_c_ip_addr=NetworkAddress(
        v4="10.5.12.96",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.64/26"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.5.12.97",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.64/26"),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vDU-623148",
    instance_id=623148, # parameter to do depricated!
)

_test_pc.connections.append(_cbts)

vcu_server_mgmt = SshServiceDetails(
        addr="10.5.46.43",
        username="bmc_user",
        password="Aikon_1234",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.5.46.43",
        username="bmc_user",
        password="Aikon_1234",
    )
    
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    pdus=_pdus,
)    

__all__ = ["tl"]
