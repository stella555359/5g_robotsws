__maintainer__ = "Hubert Chrzan"
__team__ = "I_MN_RAN_RD_VRF_KRK_12"
__email__ = "I_MN_RAN_RD_VRF_KRK_12@internal.nsn.com"
__owner_email__ = "madhukara.m_v@nokia.com"

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
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.cloud_hosting import CloudDeployment, ContainerRegistry
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.pdu import RRB, Gude, FPFH

vcu_container_registry = ContainerRegistry(url="harbor.blr-cosi-cnf.ocpblr.nsn-rdnet.net:443/vcu", username ="robot$blr-vrf-st", password="FYjyure68ah6Yky9XKHjmwDjfvbIVfRV")
vdu_container_registry = ContainerRegistry(url="harbor.blr-cosi-cnf.ocpblr.nsn-rdnet.net:443/vdu", username ="robot$blr-vrf-st", password="FYjyure68ah6Yky9XKHjmwDjfvbIVfRV")

#_pdu = FPFH(addr="http://10.41.155.22/RRB/userControl.php", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], username ="admin", password ="admin")
#_pdu = RRB(addr="10.43.239.99", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu = FPFH(
    addr="10.43.239.115",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdus = [_pdu]

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.43.196.8", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.43.196.8", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="1-2-ute5grancloudtl3-du", master_node=_vdu_master_node)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
)

_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=vdu_container_registry,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu_rannic1 = RANNIC(serial_number="L1242600922", product_code="AF1791.102")
_vdu_rannic2 = RANNIC(serial_number="L1242012481", product_code="AF1791.101")

_vdu = VDU(
    cloud_deployment=_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[276, 276],
    rannics=[_vdu_rannic1]
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.129", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.100.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.43.196.9", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.43.196.9", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="1-2-ute5grancloudtl3-cu", master_node=_vcu_master_node)

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

_preferred_vlan = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=295)

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
                pdu_port=_pdu.pdu_ports[2],
            )
        ]
    ),
    preferred_vlans=[_preferred_vlan],
)
2
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr='10.43.13.48',
        username="ute",
#        password="ute@12345",
        password="BT5l@bus3rl0g1n",
    ),
    connections=[_cbts, _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
