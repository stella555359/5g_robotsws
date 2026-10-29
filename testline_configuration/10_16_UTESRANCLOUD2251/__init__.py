__maintainer__ = "Roscislaw Szuminski"
__team__ = "MN_RAN_Pz_3_WRO_03&01"
__email__ = "roscislaw.szuminski@nokia.com"

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
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.206.90",
    port_numbers=[3],
    model="EPC",
    version="8221-1",
)
_pdu2 = Gude(
    addr="10.44.206.89",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1,_pdu2]

_control = ControlNode(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.138.19", username="core", password="system123"
    ),
    open_stack_connection_details=OpenStackConnectionDetails(
        username="core",
        password="system123",
        ip_addr="10.42.139.17",
        tenant="cran870001",
    ),
    # Configuration for BMC access if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_17")

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
        v4="10.42.140.31",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.69.184", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.140.31", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.29.187",
        vlan_id=549,
        routing_v4=RoutingInformation(gateway="10.255.29.129", ip_prefix_length=24),
    ),
    xnc=NetworkAddress(
        v4="10.255.29.30",
        vlan_id=548,
        routing_v4=RoutingInformation(gateway="10.255.29.1", ip_prefix_length=24),
    ),
    f1c=NetworkAddress(
        v4="10.255.25.30",
        vlan_id=568,
        routing=RoutingInformation(gateway="10.255.25.1", ip_prefix_length=26),
    ),
    f1u=NetworkAddress(
        v4="10.255.24.187",
        vlan_id=567,
        routing=RoutingInformation(gateway="10.255.24.129", ip_prefix_length=26),
    ),
    ngc=NetworkAddress(
        v4="10.44.81.30",
        vlan_id=561,
        routing=RoutingInformation(gateway="10.44.81.1", ip_prefix_length=24),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.59",
        vlan_id=560,
        routing=RoutingInformation(gateway="10.42.220.1", ip_prefix_length=24),
    ),
    tracing=None,
    global_bts_id=87001,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.69.184", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.69.184", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran870001", master_node=_vcu_master_node)

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
    ru_hw_group="FRMr5.1a_4T4R",
    pdu_port=_pdu1.pdu_ports[3],
    serial_number="BL1933G10R6",
)

_ru_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    pdu_port=_pdu2.pdu_ports[11],
    serial_number="L1181711680",
)


_fhgw_0 = FHGW(
    user_config_path=os.path.join(
       _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1,_ru_2],
    default_ssh_connection_details=SshServiceDetails(
    addr="10.42.138.57", username="toor4nsn", port=22, password="Fhgw@nokia1243"),
    # pxe_server=_pxe_server,
    fhgw_id=8700,
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
    addr="10.42.139.17", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.17", username="core", password="system123", port=22
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
    addr="10.42.139.143", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.15",
        vlan_id=566,
        routing=RoutingInformation(gateway="10.255.24.1", ip_prefix_length=24),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.143",
        vlan_id=565,
        routing=RoutingInformation(gateway="10.255.23.129", ip_prefix_length=24),
    ),
    instance_id=1,
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="475266A.104",
    serial_number="L1213010371",
    rus=[_ru_1],
)
 
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="10.44.207.150", username="Nemuadmin", password="nemuuser"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH211166997",
)
 
_smod_1 = Airscale([_fct_1])
 
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1],
    oam_ip=NetworkAddress("10.44.207.150"),
    instance_id=40411,
)
_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="8700",
    instance_id="8700",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.250.156",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_ncir],
    gnbs=[_cbts, _enb_sbts_1],
    tl_cloud_topology="CLOUD_AIC_10_16_UTESRANCLOUD2071",
#    core=_realcore,
    pdus=_pdus,
)

__all__ = ["tl"]
