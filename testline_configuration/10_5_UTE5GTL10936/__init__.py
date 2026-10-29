# description INFO
__maintainer__ = "Cao Zhao"
__team__ = "MN 5G RAN L2 CN1 SG6"
__email__ = "I_EXT_MN_RAN_L2_SW_1_CN_06_SG@internal.nsn.com"
__owner_email__ = "zhao.cao@nokia-sbell.com"

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
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.pdu import HBTE

_cfg_dir = os.path.dirname(os.path.abspath(__file__))


_pdu = HBTE(addr="10.107.15.36", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.56.104.206", username="cranuser1", password="systeM!23"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.56.104.206", username="cranuser1", password="systeM!23", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

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
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.56.104.226", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[2310,2310],
)
_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.110.29.140", username="Nemuadmin", password="Nokia@123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.110.29.140", username="Nemuadmin", password="Nokia@123", port=443
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.110.10.66", username="cranuser12", password="systeM!23"
)
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.110.10.66", username="cranuser12", password="systeM!23", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran12", master_node=_vcu_master_node)

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

_preferred_vlan = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=2313)

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
                pdu_port=_pdu.pdu_ports[4],
            )
        ]
    ),
    preferred_vlan_id="2313",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.107.125.45",
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
    pdus=_pdu,
)

__all__ = ["tl"]
