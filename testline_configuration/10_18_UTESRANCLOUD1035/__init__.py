__maintainer__ = "xxx"
__team__ = "xxxx"
__email__ = "xxxx"
__owner_email__ = "xxxx"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    CloudDeployment,
    HelmChart,
    ContainerRegistry
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude

_pdu_1 = Gude("10.255.1.74", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.15.255.230", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.15.255.230", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cluster-preparation.yaml'),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
)

_registry_vdu = ContainerRegistry(url="harbor.timisoara-rhacm.dyn.nesc.nokia.net:443/vdu", username="robot$tester1",
    password="7kV8f2ffPt5subzuWN8QCKL9IxV2g7Cj")

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=_registry_vdu
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.15.254.234", port=443, username="Nemuadmin", password="nemuuser"      #password="Nokia@123"
)

#RMODs need PDU port as a mandatory object, this should be edited when PDU is installed
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M215101101",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2310N43VV",
    pdu_port=_pdu_1.pdu_ports[10],
)

_rannic_0 = RANNIC(
    serial_number="L1240203223",
    product_code="AF1791.101",
    rus=[_rmod_1, _rmod_2],
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    f1_c_ip_addr='10.15.254.226',
    f1_u_ip_addr='10.15.254.226',
    instance_id=35,
    fhuc_vlans=[301],
    rannics=[_rannic_0]
)


_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.5.62.226", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.253.199", port=443, username="Nemuadmin", password="nemuuser"            #password="Nokia@123"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.62.226", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.62.226", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran6", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'vcu-cluster-preparation.yaml'),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'vcu-cnf.yaml'),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.146",
        username="ute",
        password="ute",
    ),
    connections=[_cbts]
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_vDU35_AEQP_AHFII",
)

__all__ = ["tl"]
