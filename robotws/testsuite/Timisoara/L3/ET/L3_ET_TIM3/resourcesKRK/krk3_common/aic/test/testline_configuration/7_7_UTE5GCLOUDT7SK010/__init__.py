__maintainer__ = "Hubert Chrzan"
__team__ = "OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197"
__email__ = "OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com"
__owner_email__ = "hubert.chrzan@nokia.com"

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
from taf.config.testline.gnb.du import VDU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId

from taf.config.testline.pdu import FPFH

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu = FPFH(
    addr="10.255.16.12",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
)

_pdus = [_pdu]

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.84.144.203", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="api.krk-ska-l3-et-oe20-sno-tl10.ska-lab.nsn-rdnet.net:6443",
    username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="ute5gcloudt7sk010", master_node=_vdu_master_node)

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
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu = VDU(
    cloud_deployment=_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[3510, 3510],
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
    addr="10.84.134.3", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="api.krk-ska-l3-et-rm17-mno-1.ska-lab.nsn-rdnet.net:6443",
    username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="ute5gcloudt7sk010", master_node=_vcu_master_node)

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
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_preferred_vlan = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=210)

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
                pdu_port=_pdus[0].pdu_ports[1],
            )
        ]
    ),
    preferred_vlans=[_preferred_vlan],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-7-UTE5GCLOUDT7SK010.p07.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[_cbts, _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dRNIC_1vDU_O_AP_LO",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
