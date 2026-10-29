__maintainer__ = "Jakub Bodzek"
__email__ = "jakub.bodzek@nokia.com"

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
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.gnb.du import VDU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.optical_switch import Leoni
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import RANNIC
from taf.config.testline.cloud_hosting import MasterNode, K8S, ContainerRegistry

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

vcu_container_registry = ContainerRegistry(url="ccr-wg-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu", username ="robot$vrf", password="swqgJTZSPBt4XHcfgeyz8DErRyXjgj5R")
vdu_container_registry = ContainerRegistry(url="ccr-wg-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu", username ="robot$vrf", password="zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9")

_pdu1 = Gude(
    addr="10.44.200.216", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8041-1")

_pdu2 = Gude(
    addr="10.44.200.211", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8041-1")
 
_pdus = [_pdu1, _pdu2]

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.73", username="core", password="system123"
)
_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.73", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node, cluster_name="wro-wl-pz-st-dpe-sno-tl8443")

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
    container_registry=vdu_container_registry
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.204", port=443, username="Nemuadmin", password="nemuuser"
)
# RU configuration
_ru_1 = RU(ru_hw_group="", pdu_port=_pdu1.pdu_ports[5], radio_type="AVQC", serial_number="1M243200001")
_ru_2 = RU(ru_hw_group="", pdu_port=_pdu2.pdu_ports[2], radio_type="ARPA", serial_number="F7203610648")
_ru_3 = RU(ru_hw_group="", pdu_port=_pdu1.pdu_ports[3], radio_type="AVQC", serial_number="1M243200009")
_ru_4 = RU(ru_hw_group="", pdu_port=_pdu2.pdu_ports[1], radio_type="ARGA", serial_number="K9221667757")


_vdu_0_rannic1 = RANNIC(serial_number="L1250904713", product_code="AF1791.102")

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=8443,
    fhuc_vlans=[301, 301],
    rannics=[_vdu_0_rannic1]
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.78", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.78", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.73", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.73", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8443", master_node=_vcu_master_node, cluster_name="wro-wl-pz-st-dpe-sno-tl8443")

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
        addr="10.42.195.103",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_AIC_7_16_UTE5GCLOUD8443",
    pdus=_pdus,
)

__all__ = ["tl"]
