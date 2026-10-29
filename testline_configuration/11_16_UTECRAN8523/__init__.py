__maintainer__ = "Jagoda Kubacka"
__team__ = "MN_RAN_Pz_3_WRO_04"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

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

vcu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu", username ="robot$vrf", password="biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR")
vdu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu", username ="robot$vrf", password="m7SRFboceS9eRedcLu1yGvAoMq2YKX5o")
#pdu is not checked - before adding this TL to UTE Manager check pdu
_pdu1 = Gude(
    addr="10.44.200.16",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1]


_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.4", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.4", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file='',
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file='',
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file='',
)

vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=vdu_container_registry,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.136", port=443, username="Nemuadmin", password="Nokia@123"
)

# RU configuration
_ru_1 = RU(radio_type = "AHCA",
    ru_hw_group="cMAA_Gen4.0_8T8R_eCPRI",
    pdu_port=_pdu1.pdu_ports[7],
    serial_number="AS195112263",
    )

_rannic_0 = RANNIC(
    serial_number = "L1242200271",
    product_code = "AF1791.101",
    rus = [_ru_1],
)

_vdu = VDU(
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    rannics=[_rannic_0],
    instance_id=1,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.8.8",
        vlan_id=759,
        routing_v4=RoutingInformation(gateway="10.255.8.1/24"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.9.8",
        vlan_id=760,
        routing_v4=RoutingInformation(gateway="10.255.9.1/24"),
    ),
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.18", username="Nemuadmin", password="Nokia@123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.18", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.249.18"
    ),
    f1c=NetworkAddress(
        v4="10.255.11.54",
        vlan_id=763,
        routing=RoutingInformation(gateway="10.255.11.1", ip_prefix_length=24),
    ),
    f1u=NetworkAddress(
        v4="10.255.10.57",
        vlan_id=762,
        routing=RoutingInformation(gateway="10.255.10.1", ip_prefix_length=24),
    ),
    xnc=NetworkAddress(
        v4="10.255.14.149",
        vlan_id=762,
        routing=RoutingInformation(gateway="10.255.10.1", ip_prefix_length=24),
    ),
    ngc=NetworkAddress(
        v4="10.45.187.168",
        vlan_id=762,
        routing=RoutingInformation(gateway="10.255.10.1", ip_prefix_length=24),
    ),
    global_bts_id=8523,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.91.162", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.91.162", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8523", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file='',
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file='',
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file='',
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    container_registry=vcu_container_registry,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8523",
    instance_id="8523",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.56",
        username="ute",
        password="Piotrek!1234",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_CRAN_TL8523",
    pdus=_pdus,
)

__all__ = ["tl"]
