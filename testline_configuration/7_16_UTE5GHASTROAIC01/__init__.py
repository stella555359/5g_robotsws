__maintainer__ = "Tomasz Godlewski"
__team__ = "MN RAN RD VRF WRO2 4"
__email__ = "tomasz.1.godlewski@nokia.com"
__owner_email__ = "tomasz.1.godlewski@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
    ContainerRegistry,
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
from taf.config.testline.pdu import HBTE
from taf.config.testline.attenuator import HBTE
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.pdu import ATEN

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_pdu_hbte = ATEN(addr="10.44.206.118", port_numbers=[1])
_attenuator = HBTE(
    ip_addr="10.42.75.252",
    port="5000",
    attenuation_port_numbers=range(1, 21),
    model="PA-32-32-6-127-0.5",
    pdu_port=_pdu_hbte.pdu_ports[1],
)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        addr="10.42.158.243", port=443, username="utfuser", password="utfadmin!"
    )
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.25", username="core", password="system123"
)


_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.25", username="core", password="system123", port=22
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

_vdu_container_registry = ContainerRegistry(
    url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu",
    username="robot$vrf",
    password="m7SRFboceS9eRedcLu1yGvAoMq2YKX5o",
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=_vdu_container_registry,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.38.218", port=443, username="Nemuadmin", password="Nokia@123"
)


_vdu_0_rannic1 = RANNIC(serial_number="L1240813786", product_code="AF1791.101")


_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=8675,
    global_bts_id=8675,
    fhuc_vlans=[301, 301],
    # rannics=[_vdu_0_rannic1],
)
_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.6", username="Nemuadmin", password="Nokia@123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.6", username="Nemuadmin", password="Nokia@123", port=443
    ),
    backhaul_site_oam_ip="None",
    instance_id=8675,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.25", username="core", password="system123"
)
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.25", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8675", master_node=_vcu_master_node)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
)

_vcu_container_registry = ContainerRegistry(
    url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu",
    username="robot$vrf",
    password="biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR",
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    container_registry=_vcu_container_registry,
)

_cbts = CloudBts(
    dus=[_vdu], cu=_cu, cloud_deployment=_vcu_k8s_cloud_deployment, dcap=_dcap
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.86",
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
    tl_cloud_topology="CLOUD_5G_HASTROAIC01_1xvDU_1xvCU_AQQQA_AHFII_AHLOB_AEHC",
    pdus=[],
    attenuator=_attenuator,
)

__all__ = ["tl"]
