__maintainer__ = "Roscislaw Szuminski"
__team__ = "MN_RAN_Pz_3_WRO_03&01"
__email__ = "roscislaw.szuminski@nokia.com"

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
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone, RoutingInformation
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.optical_switch import Leoni
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.cloud_hosting import CloudDeployment, ContainerRegistry

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.206.91",
    port_numbers=[5, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1]

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.5", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.5", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node, cluster_name="wro-wl-pz-st-dpe-sno-tl8688")

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu-cluster-preparation.yaml'),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu.yaml'),
)

_vdu_container_registry = ContainerRegistry(
    url="ccr-wg-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu",
    username="robot$vrf",
    password="zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9",
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=_vdu_container_registry,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.132", port=443, username="Nemuadmin", password="nemuuser"
)

# RU configuration

_ru_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    pdu_port=_pdu1.pdu_ports[12],
    serial_number="1M204213739",
    radio_type = "AZQO",
)

_ru_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    pdu_port=_pdu1.pdu_ports[5],
    serial_number="L1241800746",
    radio_type = "AVQL",
)

_rannic_0 = RANNIC(
    serial_number = "L1242202618",
    product_code = "AF1791.102",
    rus = [_ru_1, _ru_2],
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    rannics=[_rannic_0],
    instance_id=1,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.14",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/24"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.142",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/24"),
    ),
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.140.4",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.139.5", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.140.4", port=443, username="Nemuadmin", password="nemuuser"
    ),
    xnu=NetworkAddress(
        v4="10.255.29.132",
        vlan_id=549,
        routing_v4=RoutingInformation(gateway="10.255.29.129", ip_prefix_length=24),
    ),
    xnc=NetworkAddress(
        v4="10.255.29.4",
        vlan_id=548,
        routing_v4=RoutingInformation(gateway="10.255.29.1", ip_prefix_length=24),
    ),
    f1c=NetworkAddress(
        v4="10.255.25.4",
        vlan_id=568,
        routing=RoutingInformation(gateway="10.255.25.1", ip_prefix_length=26),
    ),
    f1u=NetworkAddress(
        v4="10.255.24.132",
        vlan_id=567,
        routing=RoutingInformation(gateway="10.255.24.129", ip_prefix_length=26),
    ),
    ngc=NetworkAddress(
        v4="10.44.81.4",
        vlan_id=561,
        routing=RoutingInformation(gateway="10.44.81.1", ip_prefix_length=24),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.4",
        vlan_id=560,
        routing=RoutingInformation(gateway="10.42.220.1", ip_prefix_length=24),
    ),
    tracing=None,
    global_bts_id=868801,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.5", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.5", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran86881", master_node=_vcu_master_node, cluster_name="wro-wl-pz-st-dpe-sno-tl8688")

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-cluster-preparation.yaml'),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu.yaml'),
)

_vcu_container_registry = ContainerRegistry(
    url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu",
    username="robot$vrf",
    password="biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR",
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    container_registry=_vcu_container_registry,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="8688",
    instance_id="8688",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.171",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_CRAN_TL8688",
    pdus=_pdus,
)

__all__ = ["tl"]
