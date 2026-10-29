__maintainer__ = "anna.niedzwiecka@nokia.com"
__email__ = "anna.niedzwiecka@nokia.com"

import os

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
    addr="10.44.206.85",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.249.68",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.144", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.68", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.15.20",
        vlan_id=774,
        routing_v4=RoutingInformation(gateway="10.255.15.1/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.14.143",
        vlan_id=773,
        routing_v4=RoutingInformation(gateway="10.255.14.129/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.11.81",
        vlan_id=763,
        routing_v4=RoutingInformation(gateway="10.255.11.1/24"),
    ),
    f1u=NetworkAddress(
        v4="10.255.10.81",
        vlan_id=762,
        routing_v4=RoutingInformation(gateway="10.255.10.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.45.187.151",
        vlan_id=767,
        routing_v4=RoutingInformation(gateway="10.45.187.129/25"),
    ),
    ngu=NetworkAddress(
        v4="10.45.187.23",
        vlan_id=766,
        routing_v4=RoutingInformation(gateway="10.45.187.1/25"),
    ),
    tracing=None,
    global_bts_id=889001,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.249.144", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.249.144", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8890", master_node=_vcu_master_node)

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
)

_ru_1 = RU(
    radio_type = "AZQU",
    ru_hw_group="cMAAr6.1_8T8R",
    pdu_port=_pdu1.pdu_ports[11],
    serial_number="1M234107192",
    )
    
_ru_2 = RU(
    radio_type = "AZQU",
    ru_hw_group="cMAAr6.1_8T8R",
    pdu_port=_pdu1.pdu_ports[11],
    serial_number="1M234107075",
    )

_rannic_1 = RANNIC(
    serial_number = "L1243401169",
    product_code = "AF1791.102",
    rus = [_ru_1],
)

_rannic_2 = RANNIC(
    serial_number = "L1243401214",
    product_code = "AF1791.102",
    rus = [_ru_1, _ru_2],
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.63", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.63", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

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
    url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu",
    username="robot$vrf",
    password="m7SRFboceS9eRedcLu1yGvAoMq2YKX5o",
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
    addr="10.42.139.169", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_1, _rannic_2],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.41",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.183",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/25"),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8890",
    instance_id=8890, # parameter to do depricated!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.172",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

# vCU is on cluster - below are details of all 3 master nodes
# HPE.7.3.vcu
vcu_server_mgmt_0 = SshServiceDetails(
        addr="10.42.138.4",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# HPE.7.2.vcu
vcu_server_mgmt_1 = SshServiceDetails(
        addr="10.42.138.3",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# HPE.7.1.vcu
vcu_server_mgmt_2 = SshServiceDetails(
        addr="10.42.138.2",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.42.138.33",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    # tl_cloud_topology="CLOUD_5G_FHGW_1vDU_AZQU",
    pdus=_pdus,
)

__all__ = ["tl"]
