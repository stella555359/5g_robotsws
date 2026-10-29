__maintainer__ = "damian.kotula@nokia.com"
__email__ = "damian.kotula@nokia.com"

import os

from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)

from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)

from taf.config.testline.testpc import TestPc
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import VDU, FHGW, RANNIC
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.pdu import Gude

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.206.83",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.206.84",
    port_numbers=[1, 2, 4],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.206.98",
    port_numbers=[9],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.249.15",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.162", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.249.15", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.15.56",
        vlan_id=774,
        routing_v4=RoutingInformation(gateway="10.255.12.1/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.14.151",
        vlan_id=773,
        routing_v4=RoutingInformation(gateway="10.255.14.129/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.11.18",
        vlan_id=763,
        routing_v4=RoutingInformation(gateway="10.255.11.1/25"),
    ),
    f1u=NetworkAddress(
        v4="10.255.10.62",
        vlan_id=762,
        routing_v4=RoutingInformation(gateway="10.255.10.1/25"),
    ),
    ngc=NetworkAddress(
        v4="10.45.187.146",
        vlan_id=767,
        routing_v4=RoutingInformation(gateway="10.45.187.128/25"),
    ),
    ngu=NetworkAddress(
        v4="10.45.187.18",
        vlan_id=766,
        routing_v4=RoutingInformation(gateway="10.45.187.1/25"),
    ),
    tracing=None,
    global_bts_id=877701,
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

_vcu_k8s = K8S(namespace="cran8777", master_node=_vcu_master_node)

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
    radio_type = "AHFIB",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu2.pdu_ports[1],
    serial_number="BL2241V0CQI",
    )

_ru_2 = RU(
    radio_type = "AZQI",
    ru_hw_group="cMAAr6.1_8T8R",
    pdu_port=_pdu2.pdu_ports[2],
    serial_number="1M203838333",
    )

_ru_3 = RU(
    radio_type = "AHLOA",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[1],
    serial_number="BL1930G11NC",
    )

_ru_4 = RU(
    radio_type = "AEHC",
    ru_hw_group="cMAArChile_64T64R",
    pdu_port=_pdu2.pdu_ports[4],
    serial_number="L1210604536",
    )

_ru_5 = RU(
    radio_type = "AHFIB",
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu3.pdu_ports[9],
    serial_number="BL2241V0CQC",
    )

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
       _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_3, _ru_5],
    fhgw_id=8777,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.103.180", port=22, username="toor4nsn", password="Fhgw@nokia12435"
    ),
)

_rannic_0 = RANNIC(
    serial_number = "L1243401202",
    product_code = "AF1791.101",
    rus = [_ru_2, _ru_4],
)

_rannic_1 = RANNIC(
    serial_number = "L1240813768",
    product_code = "AF1791.101",
    rus = [_ru_1, _ru_3],
)

_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.12", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.12", username="core", password="system123", port=22
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

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.139.139", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_0, _rannic_1],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.11",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.174",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/25"),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8777",
    instance_id=8777, # parameter to do depricated!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.16",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

vcu_server_mgmt = SshServiceDetails(
        addr="10.42.142.168",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.42.138.48",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    # tl_cloud_topology="CLOUD_5G_FHGW_1vDU_AZQS",
    pdus=_pdus,
)

__all__ = ["tl"]
