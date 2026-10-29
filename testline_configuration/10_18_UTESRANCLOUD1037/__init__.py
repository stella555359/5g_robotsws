__maintainer__ = "Adrian Rosa"
__team__ = "MN RAN RD VRF TSR1 1 (L05)"
__email__ = "adrian.rosa@nokia.com"
__owner_email__ = "adrian.rosa@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    CloudDeployment,
    HelmChart,
    ContainerRegistry,
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

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.15.2", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.15.2", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "vdu-cluster-preparation.yaml"),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vdu-prerequisite.yaml"),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, "vdu-cnf.yaml"),
)

_registry_vdu = ContainerRegistry(url="harbor.timisoara-rhacm.dyn.nesc.nokia.net:443/vdu", username="robot$tester1",
                                  password="7kV8f2ffPt5subzuWN8QCKL9IxV2g7Cj")

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=_registry_vdu,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.14.242",
    port=443,
    username="Nemuadmin",
    password="nemuuser",  # password="nemuuser"
)

_pdu_1 = Gude("10.255.1.72", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2215Y28QZ",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2215Y28UD",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2215Y28R1",
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9241812690",
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9241813532",
    pdu_port=_pdu_1.pdu_ports[11],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9241813580",
    pdu_port=_pdu_1.pdu_ports[12],
)
_rannic_0 = RANNIC(
    serial_number="L1241604968",
    product_code="AF1791.101",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_rannic_1 = RANNIC(
    serial_number="L1240203176",
    product_code="AF1791.101",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=137,
    fhuc_vlans=[301],
    rannics=[_rannic_0, _rannic_1]
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.5.15.50", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.5.15.50",
        port=443,
        username="Nemuadmin",
        password="nemuuser",  # password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.15.2", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.15.2", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "vcu-cluster-preparation.yaml"),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
)

_registry_vcu = ContainerRegistry(url="harbor.timisoara-rhacm.dyn.nesc.nokia.net:443/vcu", username="robot$tester1",
                                  password="7kV8f2ffPt5subzuWN8QCKL9IxV2g7Cj")

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    container_registry=_registry_vcu,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.102",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_4G_dRNIC_vDU137",
)

__all__ = ["tl"]
