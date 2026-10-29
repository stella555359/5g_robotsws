###############################
#      TL194 Cloud AP NPS     #
###############################
__maintainer__ = "Sudi Lou"
__team__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2_GMS"
__email__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2_GMS@internal.nsn.com"
__owner_email__ = "sudi.lou@nokia-sbell.com"

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
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.pdu import ATEN

# PDU  port2= Airphone
_pdu = ATEN(addr="10.97.65.130", port_numbers=[2])

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdus = [_pdu]

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.69.104.82", username="cranuser1", password="systeM!23"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.69.104.82", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vdu-prerequisite.yaml"),
)

_cnf_du = HelmChart(name="aic-vdu", yaml_file=os.path.join(_cfg_dir, "vdu-cnf.yaml"))

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.69.104.114", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu_0_rannic1 = RANNIC(serial_number="L1234509044", product_code="AF1791.101")

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=10872,
    rannics=[_vdu_0_rannic1],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.110.29.139", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.110.29.139", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.110.10.66", username="cranuser11", password="systeM!23"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.110.10.66", username="core", password="system123!", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran11", master_node=_vcu_master_node)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(name="aic-vcu", yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"))

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_cbts = CloudBts(dus=[_vdu], cu=_cu, cloud_deployment=_vcu_k8s_cloud_deployment)

_preferred_vlan = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=205)

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
    preferred_vlans=[_preferred_vlan],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.97.65.249", username="ute", password="uteUTE!"
    ),
    connections=[_cbts, _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_AIC_TDD_SA_1xMate1_1xvDU_OE20_1xFHGW_1xAEQY",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
