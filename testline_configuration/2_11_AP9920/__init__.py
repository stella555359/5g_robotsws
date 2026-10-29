__maintainer__ = "Dineshwaran Subramani"
__team__ = "I_CNP_AP_ABIL_ABIO@internal.nsn.com"
__email__ = "I_CNP_AP_ABIL_ABIO@internal.nsn.com"
__owner_email__ = "dineshwaran.subramani@nokia.com"

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

from taf.config.testline.pdu import ENICS

_cfg_dir = os.path.dirname(os.path.abspath(__file__))



_pdu = ENICS(addr="10.34.90.203", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 14])

_pdus = [_pdu]

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.34.175.98", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.34.175.98", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)


_prerequisite_du = HelmChart(
    name="oulu-cran1-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="oulu-cran1-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
)

_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,

    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="2a00:8a00:4000:4504::1622", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu = VDU(
    cloud_deployment=_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[301, 301],
) 

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="2a00:8a00:4000:4504::166a", username="Nemuadmin", password="Nokia@123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2a00:8a00:4000:4504::166a", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.34.175.98", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.34.175.98", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)



_prerequisite_cu = HelmChart(
    name="oulu-cran2-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="oulu-cran2-vcu",
    yaml_file=os.path.join(_cfg_dir, 'vcu-cnf.yaml'),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,

    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

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
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.34.90.210",
        username="ute",
        password="Ut3pa5s#4da1",
    ),
    connections=[_cbts, _ue],
)
tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dRNIC_1vDU_P_AP_LOOO_SWFH",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
