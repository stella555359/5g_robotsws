__maintainer__ = "Roscislaw Szuminski"
__team__ = "MN_RAN_Pz_3_WRO_03&01"
__email__ = "roscislaw.szuminski@nokia.com"

import os

from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
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

_pdu_1 = Gude(
    addr="10.44.206.81",
    port_numbers=[1],
    model="",
    version="",
)
_pdu_2 = Gude(
    addr="10.44.206.82",
    port_numbers=[1],
    model="",
    version="",
)
_pdu_3 = Gude(
    addr="10.44.206.83",
    port_numbers=[1],
    model="",
    version="",
)
_pdu_4 = Gude(
    addr="10.44.206.98",
    port_numbers=[1],
    model="",
    version="",
)
_pdu_5 = Gude(
    addr="10.44.206.92",
    port_numbers=[1],
    model="",
    version="",
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]

_control = ControlNode(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="core", password="system123"
    ),
    open_stack_connection_details=OpenStackConnectionDetails(
        username="core",
        password="system123",
        ip_addr="10.42.139.19",
        tenant="cran8877",
    ),
    # Configuration for BMC access if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(
    compute_nodes=[], control_nodes=[_control], version="ncir_17"
)  # dopytać rostka o version

_vcu_intnet_1 = DeploymentNetworkStack(
    name="aic-vcu-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vcu_vnf_1 = DeploymentVnfStack(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_vdu_values_override_0.yaml"
    ),
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.140.61",  # oam vcu
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.139.19", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.140.61", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.29.242",
        vlan_id=549,
        routing_v4=RoutingInformation(gateway="10.255.29.129", ip_prefix_length=24),
    ),
    xnc=NetworkAddress(
        v4="10.255.29.54",  # xnc
        vlan_id=548,
        routing_v4=RoutingInformation(gateway="10.255.29.1", ip_prefix_length=24),
    ),
    f1c=NetworkAddress(
        v4="10.255.25.56",
        vlan_id=568,
        routing=RoutingInformation(gateway="10.255.25.1", ip_prefix_length=26),
    ),
    f1u=NetworkAddress(
        v4="10.255.24.189",
        vlan_id=567,
        routing=RoutingInformation(gateway="10.255.24.129", ip_prefix_length=26),
    ),
    ngc=NetworkAddress(
        v4="10.44.81.65",
        vlan_id=561,
        routing=RoutingInformation(gateway="10.44.81.1", ip_prefix_length=24),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.113",
        vlan_id=560,
        routing=RoutingInformation(gateway="10.42.220.1", ip_prefix_length=24),
    ),
    tracing=None,
    global_bts_id=887701,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.139.19", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.19", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8877", master_node=_vcu_master_node)

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

_ru_1_AEQQ = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    pdu_port=_pdu_1.pdu_ports[1],  # dodać port i pdu
    serial_number="1M211010137",
)
_ru_2_AEQQ = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    pdu_port=_pdu_2.pdu_ports[1],  # dodać port i pdu
    serial_number="DH242131625",
)
_ru_3_AEQQ = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    pdu_port=_pdu_3.pdu_ports[1],  # dodać port i pdu
    serial_number="1M224104496",
)
_ru_4_AHPMDG = RU(
    ru_hw_group="FRMr6.2_4T4R",
    pdu_port=_pdu_4.pdu_ports[1],  # dodać port i pdu
    serial_number="K9250424124",
)
_ru_5_AHPMDG = RU(
    ru_hw_group="FRMr6.2_4T4R",
    pdu_port=_pdu_5.pdu_ports[1],  # dodać port i pdu
    serial_number="K9250424117",
)
_ru_6_AHPMDG = RU(
    ru_hw_group="FRMr6.2_4T4R",
    pdu_port=_pdu_5.pdu_ports[1],  # dodać port i pdu
    serial_number="K9250424115",
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
    addr="10.42.139.19", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.19", username="core", password="system123", port=22
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
    addr="10.42.139.144", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    rus=[_ru_1_AEQQ, _ru_2_AEQQ, _ru_3_AEQQ, _ru_4_AHPMDG, _ru_5_AHPMDG, _ru_6_AHPMDG],
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.16",
        vlan_id=566,
        routing=RoutingInformation(gateway="10.255.24.1", ip_prefix_length=24),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.144",
        vlan_id=565,
        routing=RoutingInformation(gateway="10.255.23.129", ip_prefix_length=24),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="8877",
    instance_id="8877",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.250.209",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_ncir],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_AEQQ_AHPMDG_RFS_DC",
    #    core=_realcore,
    pdus=_pdus,
)

__all__ = ["tl"]
