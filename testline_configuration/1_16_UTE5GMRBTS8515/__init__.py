__maintainer__ = "karol.sadowski@nokia.com"
__email__ = "karol.sadowski@nokia.com"

import os

from taf.config.testline.cloud_hosting import (
    ControlNode,
    #ControlNode,
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
    ContainerRegistry,
)

from taf.config.testline.connection_details import (
    #OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)

from taf.config.testline.testpc import TestPc
#from taf.config.testline import NetworkAddress, RoutingInformation
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
    addr="10.44.200.7",
    port_numbers=[5],
    model="EPC",
    version="8220-1",
)
_pdu2 = Gude(
    addr="10.44.200.3",
    port_numbers=[2],
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
        addr="10.42.38.31", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.93.152", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.93.152",
    ),
    xnu=NetworkAddress(
        v4="10.255.15.14",
        vlan_id=774,
        routing_v4=RoutingInformation(gateway="10.255.15.1/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.14.141",
        vlan_id=773,
        routing_v4=RoutingInformation(gateway="10.255.14.129/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.11.119",
        vlan_id=763,
        routing_v4=RoutingInformation(gateway="10.255.11.1/25"),
    ),
    f1u=NetworkAddress(
        v4="10.255.10.119",
        vlan_id=762,
        routing_v4=RoutingInformation(gateway="10.255.10.1/25"),
    ),
    ngc=NetworkAddress(
        v4="10.42.39.216",
        vlan_id=767,
        routing_v4=RoutingInformation(gateway="10.42.39.193/25"),
    ),
    ngu=NetworkAddress(
        v4="10.42.39.152",
        vlan_id=766,
        routing_v4=RoutingInformation(gateway="10.42.39.129/25"),
    ),
    tracing=None,
    global_bts_id=851501,
)
_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.31", username="core", password="system123"
)
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.31", username="core", password="system123", port=22
)
_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran851501", master_node=_vcu_master_node, cluster_name="wro-wl-pz-st-hpe-sno-tl8515")

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
    radio_type = "AEHC",
    ru_hw_group="cMAArChile_64T64R",
    pdu_port=_pdu1.pdu_ports[5],
    serial_number="L1210604535",
    )
_ru_2 = RU(
    radio_type = "AZQI",
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    pdu_port=_pdu2.pdu_ports[2],
    serial_number="YK202400042",
    )

_fhgw_1 = FHGW(
    user_config_path=os.path.join(
       _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2],
    fhgw_id=8515,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.44.116", port=22, username="toor4nsn", password="Fhgw@nokia12435"
    ),
)

_rannic_1 = RANNIC(
    serial_number = "L1234404333",
    product_code = "AF1791.M01",
    rus = [],
)
################################# RMOD #################################

################################# VDU  #################################
_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.31", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.31", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)
_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node, cluster_name="wro-wl-pz-st-hpe-sno-tl8515")

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
    addr="10.42.38.223", port=443, username="Nemuadmin", password="nemuuser"
)


_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    rannics=[_rannic_1],
    instance_id=8515,
    fhgws=[_fhgw_1],
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.8.119",
        vlan_id=759,
        routing_v4=RoutingInformation(gateway="10.255.8.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.9.119",
        vlan_id=760,
        routing_v4=RoutingInformation(gateway="10.255.9.1/25"),
    ),
)
################################# VDU #################################


_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    instance_id=8515,# parameter to do depricated use it under VDU object instead!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.109",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_1_16_UTE5GMRBTS8515",
    pdus=_pdus,
)

__all__ = ["tl"]
