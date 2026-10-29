__maintainer__ = "Marek Starzyk"
__team__ = "MN_RAN_Pz_3_WRO_03&01"
__email__ = "marek.starzyk@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    HelmChart,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.cloud_hosting import CloudDeployment, ContainerRegistry

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.206.91",
    port_numbers=[5],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.206.91",
    port_numbers=[5],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.206.90",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

# *******************************************************vDU1-8512*******************************************************

_vdu8512_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.38", username="core", password="system123"
)

_vdu8512_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.38", username="core", password="system123", port=22
)

_vdu8512_master_node = MasterNode(
    k8s_connection_details=_vdu8512_k8s_connection_details,
    ssh_connection_details=_vdu8512_k8s_ssh_connection_details,
)

_vdu8512_k8s = K8S(namespace="cran1", master_node=_vdu8512_master_node)

_cluster_preparation_du8512 = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(
        _cfg_dir,
        "common_helm_values/8512values-override.aic-vdu-cluster-preparation.yaml",
    ),
)

_prerequisite_du8512 = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/8512values-override.aic-vdu-prerequisite.yaml"
    ),
)

_cnf_du8512 = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/8512values-override.aic-vdu.yaml"
    ),
)

_vdu8512_container_registry = ContainerRegistry(
    url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu",
    username="robot$vrf",
    password="m7SRFboceS9eRedcLu1yGvAoMq2YKX5o",
)

_vdu8512_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu8512_k8s,
    cluster_preparation=_cluster_preparation_du8512,
    prerequisite=_prerequisite_du8512,
    cnf=_cnf_du8512,
    container_registry=_vdu8512_container_registry,
)

_vdu8512_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.155", port=443, username="Nemuadmin", password="Nokia@123"
)

# RU configuration

_ru_AHFIB = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[5],
    serial_number="BL1911V00CF",
    radio_type="AHFIB",
)

_rannic8512_0 = RANNIC(
    serial_number="L1240603829",
    product_code="AF1791.102",
    rus=[_ru_AHFIB],
)

_vdu8512 = VDU(
    cloud_deployment=_vdu8512_k8s_cloud_deployment,
    oam_http_connection_details=_vdu8512_oam_http_connection_details,
    rannics=[_rannic8512_0],
    instance_id=8512,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.27",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.155",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/25"),
    ),
)

# *******************************************************vDU2-8781*******************************************************

_vdu8781_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.34", username="core", password="system123"
)

_vdu8781_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.34", username="core", password="system123", port=22
)

_vdu8781_master_node = MasterNode(
    k8s_connection_details=_vdu8781_k8s_connection_details,
    ssh_connection_details=_vdu8781_k8s_ssh_connection_details,
)

_vdu8781_k8s = K8S(namespace="cran1", master_node=_vdu8781_master_node)

_cluster_preparation_du8781 = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(
        _cfg_dir,
        "common_helm_values/8781values-override.aic-vdu-cluster-preparation.yaml",
    ),
)

_prerequisite_du8781 = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/8781values-override.aic-vdu-prerequisite.yaml"
    ),
)

_cnf_du8781 = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/8781values-override.aic-vdu.yaml"
    ),
)

_vdu8781_container_registry = ContainerRegistry(
    url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu",
    username="robot$vrf",
    password="m7SRFboceS9eRedcLu1yGvAoMq2YKX5o",
)

_vdu8781_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu8781_k8s,
    cluster_preparation=_cluster_preparation_du8781,
    prerequisite=_prerequisite_du8781,
    cnf=_cnf_du8781,
    container_registry=_vdu8781_container_registry,
)

_vdu8781_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.152", port=443, username="Nemuadmin", password="Nokia@123"
)

# RU configuration

_ru_AZQL = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    pdu_port=_pdu2.pdu_ports[5],
    serial_number="L1193104179",
    radio_type="AZQL",
)
_ru_AZQP = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu3.pdu_ports[7],
    serial_number="1M203844895",
    radio_type="AZQP",
)

_rannic8781_0 = RANNIC(
    serial_number="L1243401253",
    product_code="AF1791.102",
    rus=[_ru_AZQL, _ru_AZQP],
)

_vdu8781 = VDU(
    cloud_deployment=_vdu8781_k8s_cloud_deployment,
    oam_http_connection_details=_vdu8781_oam_http_connection_details,
    rannics=[_rannic8781_0],
    instance_id=8781,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.24",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.0/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.152",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.128/25"),
    ),
)

# ******************************************************vCU1-851201******************************************************
_cu851201 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.102.14",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.102.152", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.102.14", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.47.58",
        vlan_id=604,
        routing_v4=RoutingInformation(gateway="10.255.47.1/24"),
    ),
    xnc=NetworkAddress(
        v4="10.255.46.78",
        vlan_id=603,
        routing_v4=RoutingInformation(gateway="10.255.46.65/26"),
    ),
    f1c=NetworkAddress(
        v4="10.255.46.14",
        vlan_id=602,
        routing_v4=RoutingInformation(gateway="10.255.46.1/26"),
    ),
    f1u=NetworkAddress(
        v4="10.255.45.58",
        vlan_id=601,
        routing_v4=RoutingInformation(gateway="10.255.45.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.42.102.78",
        vlan_id=598,
        routing_v4=RoutingInformation(gateway="10.42.102.65/26"),
    ),
    ngu=NetworkAddress(
        v4="10.42.100.58",
        vlan_id=600,
        routing_v4=RoutingInformation(gateway="10.42.100.1/24"),
    ),
    tracing=None,
    global_bts_id=851201,
)

_vcu851201_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.102.152", username="core", password="system123"
)

_vcu851201_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.102.152", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu851201_k8s_connection_details,
    ssh_connection_details=_vcu851201_k8s_ssh_connection_details,
)

_vcu851201_k8s = K8S(namespace="cran851201", master_node=_vcu_master_node)

_cluster_preparation_cu851201 = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(
        _cfg_dir,
        "common_helm_values/851201values-override.aic-vcu-cluster-preparation.yaml",
    ),
)

_prerequisite_cu851201 = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/851201values-override.aic-vcu-prerequisite.yaml"
    ),
)

_cnf_cu851201 = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/851201values-override.aic-vcu.yaml"
    ),
)

_vcu01_container_registry = ContainerRegistry(
    url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu",
    username="robot$vrf",
    password="biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR",
)

_vcu851201_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu851201_k8s,
    cluster_preparation=_cluster_preparation_cu851201,
    prerequisite=_prerequisite_cu851201,
    cnf=_cnf_cu851201,
    container_registry=_vcu01_container_registry,
)

# ******************************************************vCU2-851202******************************************************
_cu851202 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.102.20",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.102.157",
        username="core",
        password="system123",  # 10.42.102.157 <- cluster13
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.102.20", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.47.76",
        vlan_id=604,
        routing_v4=RoutingInformation(gateway="10.255.47.1/24"),
    ),
    xnc=NetworkAddress(
        v4="10.255.46.84",
        vlan_id=603,
        routing_v4=RoutingInformation(gateway="10.255.46.65/26"),
    ),
    f1c=NetworkAddress(
        v4="10.255.46.20",
        vlan_id=602,
        routing_v4=RoutingInformation(gateway="10.255.46.1/26"),
    ),
    f1u=NetworkAddress(
        v4="10.255.45.76",
        vlan_id=601,
        routing_v4=RoutingInformation(gateway="10.255.45.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.42.102.84",
        vlan_id=598,
        routing_v4=RoutingInformation(gateway="10.42.102.65/26"),
    ),
    ngu=NetworkAddress(
        v4="10.42.100.76",
        vlan_id=600,
        routing_v4=RoutingInformation(gateway="10.42.100.1/24"),
    ),
    tracing=None,
    global_bts_id=851202,
)

_vcu851202_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.102.157",
    username="core",
    password="system123",  # 10.42.102.157 <- cluster13
)

_vcu851202_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.102.157", username="core", password="system123", port=22
)

_vcu851202_master_node = MasterNode(
    k8s_connection_details=_vcu851202_k8s_connection_details,
    ssh_connection_details=_vcu851202_k8s_ssh_connection_details,
)

_vcu851202_k8s = K8S(namespace="cran851202", master_node=_vcu851202_master_node)

_cluster_preparation_cu851202 = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(
        _cfg_dir,
        "common_helm_values/851202values-override.aic-vcu-cluster-preparation.yaml",
    ),
)

_prerequisite_cu851202 = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/851202values-override.aic-vcu-prerequisite.yaml"
    ),
)

_cnf_cu851202 = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/851202values-override.aic-vcu.yaml"
    ),
)

_vcu02_container_registry = ContainerRegistry(
    url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu",
    username="robot$vrf",
    password="biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR",
)

_vcu851202_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu851202_k8s,
    cluster_preparation=_cluster_preparation_cu851202,
    prerequisite=_prerequisite_cu851202,
    cnf=_cnf_cu851202,
    container_registry=_vcu02_container_registry,
)

# ******************************************************vCU3-878101******************************************************
_cu878101 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.102.12",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.102.152", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.102.12", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.47.52",
        vlan_id=604,
        routing_v4=RoutingInformation(gateway="10.255.47.1/24"),
    ),
    xnc=NetworkAddress(
        v4="10.255.46.76",
        vlan_id=603,
        routing_v4=RoutingInformation(gateway="10.255.46.65/26"),
    ),
    f1c=NetworkAddress(
        v4="10.255.46.12",
        vlan_id=602,
        routing_v4=RoutingInformation(gateway="10.255.46.1/26"),
    ),
    f1u=NetworkAddress(
        v4="10.255.45.52",
        vlan_id=601,
        routing_v4=RoutingInformation(gateway="10.255.45.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.42.102.76",
        vlan_id=598,
        routing_v4=RoutingInformation(gateway="10.42.102.65/26"),
    ),
    ngu=NetworkAddress(
        v4="10.42.100.52",
        vlan_id=600,
        routing_v4=RoutingInformation(gateway="10.42.100.1/24"),
    ),
    tracing=None,
    global_bts_id=878101,
)

_vcu878101_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.102.152", username="core", password="system123"
)

_vcu878101_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.102.152", username="core", password="system123", port=22
)

_vcu878101_master_node = MasterNode(
    k8s_connection_details=_vcu878101_k8s_connection_details,
    ssh_connection_details=_vcu878101_k8s_ssh_connection_details,
)

_vcu878101_k8s = K8S(namespace="cran878101", master_node=_vcu878101_master_node)

_cluster_preparation_cu878101 = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(
        _cfg_dir,
        "common_helm_values/878101values-override.aic-vcu-cluster-preparation.yaml",
    ),
)

_prerequisite_cu878101 = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/878101values-override.aic-vcu-prerequisite.yaml"
    ),
)

_cnf_cu878101 = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/878101values-override.aic-vcu.yaml"
    ),
)

_vcu878101_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu878101_k8s,
    cluster_preparation=_cluster_preparation_cu878101,
    prerequisite=_prerequisite_cu878101,
    cnf=_cnf_cu878101,
    container_registry=_vcu01_container_registry,
)

# ******************************************************vCU4-878102******************************************************
_cu878102 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.102.16",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.102.157",
        username="core",
        password="system123",  # 10.42.102.157 <- cluster13
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.102.16", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.47.64",
        vlan_id=604,
        routing_v4=RoutingInformation(gateway="10.255.47.1/24"),
    ),
    xnc=NetworkAddress(
        v4="10.255.46.80",
        vlan_id=603,
        routing_v4=RoutingInformation(gateway="10.255.46.65/26"),
    ),
    f1c=NetworkAddress(
        v4="10.255.46.16",
        vlan_id=602,
        routing_v4=RoutingInformation(gateway="10.255.46.1/26"),
    ),
    f1u=NetworkAddress(
        v4="10.255.45.64",
        vlan_id=601,
        routing_v4=RoutingInformation(gateway="10.255.45.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.42.102.80",
        vlan_id=598,
        routing_v4=RoutingInformation(gateway="10.42.102.65/26"),
    ),
    ngu=NetworkAddress(
        v4="10.42.100.64",
        vlan_id=600,
        routing_v4=RoutingInformation(gateway="10.42.100.1/24"),
    ),
    tracing=None,
    global_bts_id=878101,
)

_vcu878102_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.102.152",
    username="core",
    password="system123",  # 10.42.102.157 <- cluster13
)

_vcu878102_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.102.152", username="core", password="system123", port=22
)

_vcu878102_master_node = MasterNode(
    k8s_connection_details=_vcu878102_k8s_connection_details,
    ssh_connection_details=_vcu878102_k8s_ssh_connection_details,
)

_vcu878102_k8s = K8S(namespace="cran878102", master_node=_vcu878102_master_node)

_cluster_preparation_cu878102 = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(
        _cfg_dir,
        "common_helm_values/878102values-override.aic-vcu-cluster-preparation.yaml",
    ),
)

_prerequisite_cu878102 = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/878102values-override.aic-vcu-prerequisite.yaml"
    ),
)

_cnf_cu878102 = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "common_helm_values/878102values-override.aic-vcu.yaml"
    ),
)

_vcu878102_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu878102_k8s,
    cluster_preparation=_cluster_preparation_cu878102,
    prerequisite=_prerequisite_cu878102,
    cnf=_cnf_cu878102,
    container_registry=_vcu02_container_registry,
)

_cbts851201 = CloudBts(
    dus=[_vdu8512],
    cu=_cu851201,
    cloud_deployment=_vcu851201_k8s_cloud_deployment,
    vnf_name="8512",
    instance_id=8512,
)

_cbts851202 = CloudBts(
    dus=[_vdu8512],
    cu=_cu851202,
    cloud_deployment=_vcu851202_k8s_cloud_deployment,
    vnf_name="8512",
    instance_id=8512,
)

_cbts878101 = CloudBts(
    dus=[_vdu8781],
    cu=_cu878101,
    cloud_deployment=_vcu878101_k8s_cloud_deployment,
    vnf_name="8781",
    instance_id=8781,
)

_cbts878102 = CloudBts(
    dus=[_vdu8781],
    cu=_cu878102,
    cloud_deployment=_vcu878102_k8s_cloud_deployment,
    vnf_name="8781",
    instance_id=8781,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.250.208",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts851201, _cbts851202, _cbts878101, _cbts878102],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts851201, _cbts851202, _cbts878101, _cbts878102],
    cloud_hostings=[
        _vcu851201_k8s,
        _vcu851202_k8s,
        _vcu878101_k8s,
        _vcu878102_k8s,
        _vdu8781_k8s,
        _vdu8512_k8s,
    ],
    tl_cloud_topology="CLOUD_CRAN_TL8512",
    pdus=_pdus,
)

__all__ = ["tl"]
