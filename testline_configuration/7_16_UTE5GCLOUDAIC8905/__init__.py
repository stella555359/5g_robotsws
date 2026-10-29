__maintainer__ = "Sebastian Mikos"
__team__ = "MN RAN RD VRF WRO2 5"
__email__ = "sebastian.mikos@nokia.com"
__owner_email__ = "sebastian.mikos@nokia.com"

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
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.dcap import DcapBasic

_cfg_dir = os.path.dirname(os.path.abspath(__file__))


_attenuator1 = TopYoung(
    ip_addr="10.42.221.81",
    port="3001",
    attenuation_port_numbers=range(1, 16),
    pdu_port=None,
)

_attenuator2 = TopYoung(
    ip_addr="10.42.221.98",
    port="3001",
    attenuation_port_numbers=range(1, 16),
    pdu_port=None,
)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        addr="10.44.180.37", port=443, username="utfuser", password="utfadmin!"
    )
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.33", username="core", password="system123"
)


_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.33", username="core", password="system123", port=22
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

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, "vdu-cnf.yaml"),
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.185", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=8905,
    global_bts_id=8905,
    fhuc_vlans=[301, 301],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.57", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.57", username="Nemuadmin", password="nemuuser", port=443
    ),
    backhaul_site_oam_ip="None",
    instance_id=8905,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.33", username="core", password="system123"
)
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.33", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8905", master_node=_vcu_master_node)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_cbts = CloudBts(
    dus=[_vdu], cu=_cu, cloud_deployment=_vcu_k8s_cloud_deployment, dcap=_dcap
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.197",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_proxy.yaml"
)


tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_AIC_1xvDU_1xvCU_AVHA_AVQQA_AHLOB_AHFII",
    ues=[_ues],
    pdus=[],
    attenuators=[_attenuator1, _attenuator2],
)

__all__ = ["tl"]
