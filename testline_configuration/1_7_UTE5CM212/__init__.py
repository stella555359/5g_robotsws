__maintainer__ = "Przemyslaw Slaba"
__team__ = "I_MN_RAN_RD_VRF_KRK_9"
__email__ = "I_MN_RAN_RD_VRF_KRK_9@internal.nsn.com"
__owner_email__ = "przemyslaw.slaba@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.cloud_hosting import MasterNode, K8S, ContainerRegistry
from taf.config.testline.pdu import FPFH

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

vcu_container_registry = ContainerRegistry(url="ccr-krk-py-vrf-01.ocp.ska-lab.nsn-rdnet.net:443/vcu", username ="robot$vcu", password="2g3q7ARZYcXwIh8vxfWWbGihOP15x80Y")
vdu_container_registry = ContainerRegistry(url="ccr-krk-py-vrf-01.ocp.ska-lab.nsn-rdnet.net:443/vdu", username ="robot$vdu", password="x7Zn5766WrX8xIS3Wy8IZ9urHFGEZ3PJ")

_pdu = FPFH(
    addr="10.255.16.30",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="master0.krk-vrf-siso-hpe-sno-1-tl12.ocp.ska-lab.nsn-rdnet.net", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="master0.krk-vrf-siso-hpe-sno-1-tl12.ocp.ska-lab.nsn-rdnet.net", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="1-7-tl12-krk-vrf-siso-du", master_node=_vdu_master_node, cluster_name="krk-vrf-siso-hpe-sno-1-tl12")

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

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=vdu_container_registry,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.83.243.153", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu_0_rannic1 = RANNIC(serial_number="L1240603830", product_code="AF1791.101")
_vdu_0_rannic2 = RANNIC(serial_number="L1240604129", product_code="AF1791.101")

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[301, 301],
    rannics=[_vdu_0_rannic1, _vdu_0_rannic2]
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.83.243.154", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.83.243.154", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="master0.krk-vrf-siso-hpe-sno-1-tl12.ocp.ska-lab.nsn-rdnet.net", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="master0.krk-vrf-siso-hpe-sno-1-tl12.ocp.ska-lab.nsn-rdnet.net", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="1-7-tl12-krk-vrf-siso-cu", master_node=_vcu_master_node, cluster_name="krk-vrf-siso-hpe-sno-1-tl12")

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
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    container_registry=vcu_container_registry,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="1-7-UTE5CM212.macro.krk-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dRNIC_1vDU_P_TL212",
    pdus=_pdu,
)

__all__ = ["tl"]
