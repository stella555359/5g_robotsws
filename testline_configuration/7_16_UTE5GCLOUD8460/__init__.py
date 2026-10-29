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
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.cloud_hosting import CloudDeployment, ContainerRegistry
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId



_cfg_dir = os.path.dirname(os.path.abspath(__file__))
 
vcu_container_registry = ContainerRegistry(url="ccr-wg-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu", username ="robot$vrf", password="swqgJTZSPBt4XHcfgeyz8DErRyXjgj5R")
vdu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu", username ="robot$vrf", password="ObCV0W80KGzzazO1aCRKDU25DozYU338")
 
_pdu1 = Gude(
    addr="10.44.200.206", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8041-1")
_pdu2 = Gude(
    addr="10.44.200.216", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8041-1")    

_pdus=[_pdu1,_pdu2]
  
_vdu1_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.71", username="core", password="system123"
)

_vdu2_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.72", username="core", password="system123"
)
 
_vdu1_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.71", username="core", password="system123", port=22
)

_vdu2_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.72", username="core", password="system123", port=22
)
 
_vdu1_master_node = MasterNode(
    k8s_connection_details=_vdu1_k8s_connection_details,
    ssh_connection_details=_vdu1_k8s_ssh_connection_details,
)
 
_vdu2_master_node = MasterNode(
    k8s_connection_details=_vdu2_k8s_connection_details,
    ssh_connection_details=_vdu2_k8s_ssh_connection_details,
)

_vdu1_k8s = K8S(namespace="cran1", master_node=_vdu1_master_node)

_vdu2_k8s = K8S(namespace="cran1", master_node=_vdu2_master_node)

_prerequisite_du_1 = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite-1.yaml'),
)

_prerequisite_du_2 = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite-2.yaml'),
)

_cnf_du_1 = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf-1.yaml'),
)

_cnf_du_2 = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf-2.yaml'),
)

_k8s_cloud_deployment_1 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu1_k8s,
    prerequisite=_prerequisite_du_1,
    cnf=_cnf_du_1,
    container_registry=vdu_container_registry
)
 
_k8s_cloud_deployment_2 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu2_k8s,
    prerequisite=_prerequisite_du_2,
    cnf=_cnf_du_2,
    container_registry=vdu_container_registry
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.202", port=443, username="Nemuadmin", password="nemuuser"
)
 
_vdu2_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.203", port=443, username="Nemuadmin", password="nemuuser"
)
#radios from vdu 8460
_ru_1 = RU(ru_hw_group="", pdu_port=_pdu1.pdu_ports[12], radio_type="AHPMDG", serial_number="LR251414514")
_ru_2 = RU(ru_hw_group="", pdu_port=_pdu1.pdu_ports[11], radio_type="AVQQ", serial_number="1M244107298")
#radios from vdu 8461
_ru_3 = RU(ru_hw_group="", pdu_port=_pdu2.pdu_ports[6], radio_type="AHPMDG", serial_number="LR251414475")
_ru_4 = RU(ru_hw_group="", pdu_port=_pdu1.pdu_ports[9], radio_type="AHPMDG", serial_number="BL2322C61MR")
_ru_5 = RU(ru_hw_group="", pdu_port=_pdu1.pdu_ports[10], radio_type="AVQQ", serial_number="1M250610474")

_vdu_0_rannic1 = RANNIC(serial_number="L1240809131", product_code="AF1791.101")

_vdu_1_rannic1 = RANNIC(serial_number="L1240809121", product_code="AF1791.101")


_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_1,
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    instance_id=8460,
    rannics=[_vdu_0_rannic1],
    

)
 
_vdu_1 = VDU(
    cloud_deployment=_k8s_cloud_deployment_2,
    oam_http_connection_details=_vdu2_oam_http_connection_details,
    instance_id=8461,
    rannics=[_vdu_1_rannic1],
    

)
 
_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.77", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.77", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)
 
_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.71", username="core", password="system123"
)
 
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.71", username="core", password="system123", port=22
)
 
_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)
 
_vcu_k8s = K8S(namespace="cran8460", master_node=_vcu_master_node)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'vcu-cnf.yaml'),
)
_vcu_k8s_cloud_deployment_1 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    container_registry=vcu_container_registry
)
 
_cbts = CloudBts(
    dus=[_vdu_0, _vdu_1],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment_1,
)
 
 #Vm for TL8460
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.196", 
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu1_k8s, _vdu2_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_AIC_7_16_UTE5GCLOUD8460",
    pdus=_pdus
)

__all__ = ["tl"]
