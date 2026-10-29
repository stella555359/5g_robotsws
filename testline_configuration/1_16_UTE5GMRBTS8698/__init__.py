__maintainer__ = "karol.sadowski@nokia.com"
__email__ = "karol.sadowski@nokia.com"

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

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

################################# PDU #################################
_pdu1 = Gude(
    addr="10.44.206.79",
    port_numbers=[1, 2, 3, 4],
    model="EPC",
    version="8221-1",
)
_pdu2 = Gude(
    addr="10.44.206.70",
    port_numbers=[12],
    model="EPC",
    version="8220-1",
)
_pdus = [_pdu1, _pdu2]
################################# PDU #################################

################################# ACM #################################
vcu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu", username ="robot$vrf", password="WlVa2nE3ko36Dus2izeMlDSuK3YeIq3X")
vdu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu", username ="robot$vrf", password="8dCEjs0NHOmsMXIWR7H0Ve4Ys3gdAdGA")
################################# ACM #################################

################################# VCU #################################
_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.139.10", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.140.5", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.140.5",
    ),
    xnu=NetworkAddress(
        v4="10.255.29.133",
        vlan_id=549,
        routing_v4=RoutingInformation(gateway="10.255.29.129/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.29.5",
        vlan_id=548,
        routing_v4=RoutingInformation(gateway="10.255.29.1/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.25.5",
        vlan_id=568,
        routing_v4=RoutingInformation(gateway="10.255.25.1/25"),
    ),
    f1u=NetworkAddress(
        v4="10.255.24.133",
        vlan_id=567,
        routing_v4=RoutingInformation(gateway="10.255.24.129/25"),
    ),
    ngc=NetworkAddress(
        v4="10.44.81.5",
        vlan_id=561,
        routing_v4=RoutingInformation(gateway="10.44.81.1/25"),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.5",
        vlan_id=560,
        routing_v4=RoutingInformation(gateway="10.42.220.1/25"),
    ),
    tracing=None,
    global_bts_id=869801,
)
_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.10", username="core", password="system123"
)
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.10", username="core", password="system123", port=22
)
_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)
_vcu_k8s = K8S(namespace="cran869801", master_node=_vcu_master_node, cluster_name="wro-wl-pz-st-dpe-sno-tl8698")
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
_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
    container_registry=vcu_container_registry
)
################################# VCU #################################

################################# RMOD #################################
_ru_1 = RU(
    radio_type = "AHLOA",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[2],
    serial_number="BL2048G1RE2",
    )
_ru_2 = RU(
    radio_type = "AHCA",
    ru_hw_group="FRMr5.1_1_4T4R",
    pdu_port=_pdu1.pdu_ports[4],
    serial_number="L1181700166",
    )
_ru_3 = RU(
    radio_type = "AHFIC",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[1],
    serial_number="BL2037K2098",
    )
_ru_4 = RU(
    radio_type = "AHFIC",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[3],
    serial_number="K9200523333",
    )
_ru_5 = RU(
    radio_type = "AHFB",
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    pdu_port=_pdu2.pdu_ports[12],
    serial_number="EA191210184",
    )
_fhgw_1 = FHGW(
    user_config_path=os.path.join(
       _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5],
    fhgw_id=8698,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.103.186", port=22, username="toor4nsn", password="Fhgw@nokia12435"
    ),
)
_rannic_1 = RANNIC(
    serial_number = "L1240809147",
    product_code = "AF1791.101",
    rus = [],
)
################################# RMOD #################################

################################# VDU #################################
_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.10", username="core", password="system123", port=22
)
_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.10", username="core", password="system123"
)
_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)
_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node, cluster_name="wro-wl-pz-st-dpe-sno-tl8698")
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
_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=vdu_container_registry
)
_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.137", port=443, username="Nemuadmin", password="nemuuser"
)
_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=8698,
    fhgws=[_fhgw_1],
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.9",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.137",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/25"),
    ),
)
################################# VDU #################################

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    instance_id=8698, # parameter to do depricated use it under VDU object instead!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.138",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_1_16_UTE5GMRBTS8698",
    pdus=_pdus,
)

__all__ = ["tl"]
