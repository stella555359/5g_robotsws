__maintainer__ = "kezhou"
__team__ = "I_MN_RAN_L3_SW_3_CN_04_SG_GMS"
__email__ = "I_MN_RAN_L3_SW_3_CN_04_SG@internal.nsn.com"
__owner_email__ = "kexin.zhou@nokia-sbell.com"
 
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
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.cloud_hosting import CloudDeployment, ContainerRegistry
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId

from taf.config.testline.pdu import FPFH

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
 
container_registry = ContainerRegistry(url="harbor-vrf34.ocp.hz.nsn-rdnet.net:443/vrf34", username ="admin", password="Harbor12345")
 
_pdu = FPFH(addr="10.64.49.80", port_numbers=[1, 2, 3, 4, 5, 6],login="admin", password="admin")
 
_pdus = [_pdu]
 
_vdu1_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.64.51.170", username="core", password="system123"
)

_vdu2_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.64.51.171", username="core", password="system123"
)
 
_vdu1_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.64.51.170", username="core", password="system123", port=22
)

_vdu2_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.64.51.171", username="core", password="system123", port=22
)
 
_vdu1_master_node = MasterNode(
    k8s_connection_details=_vdu1_k8s_connection_details,
    ssh_connection_details=_vdu1_k8s_ssh_connection_details,
)
 
_vdu2_master_node = MasterNode(
    k8s_connection_details=_vdu2_k8s_connection_details,
    ssh_connection_details=_vdu2_k8s_ssh_connection_details,
)

_vdu1_k8s = K8S(namespace="t020", master_node=_vdu1_master_node)

_vdu2_k8s = K8S(namespace="t020", master_node=_vdu2_master_node)

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
    container_registry=container_registry
)
 
_k8s_cloud_deployment_2 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu2_k8s,
    prerequisite=_prerequisite_du_2,
    cnf=_cnf_du_2,
    container_registry=container_registry
)

_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
)
 
_vdu2_oam_http_connection_details = HttpConnectionDetails(
    addr="192.168.255.130", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu_0_rannic1 = RANNIC(serial_number="L1240605284", product_code="AF1791.101")

_vdu_1_rannic1 = RANNIC(serial_number="L1240605289", product_code="AF1791.101")

_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_1,
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[2912],
    rannics=[_vdu_0_rannic1]
)
 
_vdu_1 = VDU(
    cloud_deployment=_k8s_cloud_deployment_2,
    oam_http_connection_details=_vdu2_oam_http_connection_details,
    instance_id=2,
    fhuc_vlans=[2913],
    rannics=[_vdu_1_rannic1]
)
 
_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.130", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.100.130", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)
 
_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.57.173.2", username="core", password="system123"
)
 
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.57.173.2", username="core", password="system123", port=22
)
 
_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)
 
_vcu_k8s = K8S(namespace="t021", master_node=_vcu_master_node)

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
    container_registry=container_registry
)
 
_cbts = CloudBts(
    dus=[_vdu_0, _vdu_1],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment_1,
)
 
_vlan1 = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=2914)
 
_vlan2 = PreferredVlan(slot_id=SlotId.B1, port_id=7, preferred_vlan_id=2915)
 
_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                [CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
                hardware_type="ASIL",
                pdu_port=_pdus[0].pdu_ports[2],
            )
        ]
    ),
    preferred_vlans=[_vlan1, _vlan2],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.171.52",
        username="ute",
        password="ute",
    ),
    connections=[_cbts, _ue],
)
 
tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu1_k8s, _vdu2_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC",
    ues=[_ue],
    pdus=_pdus,
)
 
__all__ = ["tl"]
